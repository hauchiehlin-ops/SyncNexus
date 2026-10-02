using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;

namespace SyncNexus.Core.Engine;

public enum EndpointStatus
{
    Online,
    Offline
}

public record IdentityCheckResult(EndpointStatus Status, string? Reason = null)
{
    public static IdentityCheckResult Online() => new(EndpointStatus.Online);
    public static IdentityCheckResult Offline(string reason) => new(EndpointStatus.Offline, reason);
}

public class SyncEngine
{
    public const string MarkerName = ".syncnexus-endpoint";

    private readonly IStore _store;
    private readonly IgnoreRules _ignoreRules;
    private readonly DeletionGuard _deletionGuard;

    public SyncEngine(IStore store, IgnoreRules? ignoreRules = null, DeletionGuard? deletionGuard = null)
    {
        _store = store;
        _ignoreRules = ignoreRules ?? IgnoreRules.Default;
        _deletionGuard = deletionGuard ?? new DeletionGuard();
    }

    /// <summary>
    /// Checks endpoint folder identity and marker file integrity.
    /// Prevents data loss when drive or folder is swapped or missing.
    /// </summary>
    public IdentityCheckResult CheckIdentity(EndpointConfig cfg, bool writeMarker = false)
    {
        if (!Directory.Exists(cfg.Root))
        {
            return IdentityCheckResult.Offline("資料夾不存在（外接碟未掛載？）");
        }

        var markerPath = Path.Combine(cfg.Root, MarkerName);
        if (File.Exists(markerPath))
        {
            try
            {
                var content = File.ReadAllText(markerPath).Trim();
                if (!string.Equals(content, cfg.Uuid, StringComparison.OrdinalIgnoreCase))
                {
                    return IdentityCheckResult.Offline("標記檔與此端點不符（換了另一個資料夾或磁碟？），已停止，不傳播任何變更");
                }
            }
            catch (Exception ex)
            {
                return IdentityCheckResult.Offline($"無法讀取標記檔：{ex.Message}");
            }
        }
        else if (_store.EndpointHasHistory(cfg.Id))
        {
            return IdentityCheckResult.Offline("標記檔遺失（被清空、重新格式化或換碟？），已停止，不傳播任何刪除");
        }
        else if (writeMarker)
        {
            try
            {
                File.WriteAllText(markerPath, cfg.Uuid);
            }
            catch (Exception ex)
            {
                return IdentityCheckResult.Offline($"無法寫入標記檔：{ex.Message}");
            }
        }

        // Check Volume Serial Number for removable disks
        if (cfg.Removable && !string.IsNullOrEmpty(cfg.VolumeUuid))
        {
            var actualSerial = WindowsVolumeHelper.GetVolumeSerialNumber(cfg.Root);
            if (actualSerial != null && !string.Equals(actualSerial, cfg.VolumeUuid, StringComparison.OrdinalIgnoreCase))
            {
                return IdentityCheckResult.Offline("磁碟區識別碼不符（不是原本那顆磁碟），已停止");
            }
        }

        return IdentityCheckResult.Online();
    }

    /// <summary>
    /// Executes a full synchronization cycle across all configured endpoints.
    /// </summary>
    public SyncReport SyncAll()
    {
        var report = new SyncReport();
        var endpoints = _store.GetEndpoints();
        var onlineEndpoints = new List<EndpointConfig>();

        // 1. Verify identities
        foreach (var ep in endpoints)
        {
            var check = CheckIdentity(ep, writeMarker: true);
            if (check.Status == EndpointStatus.Online)
            {
                onlineEndpoints.Add(ep);
            }
            else
            {
                report.Offline.Add($"{ep.Id}：{check.Reason}");
            }
        }

        if (onlineEndpoints.Count < 2)
        {
            report.Notes.Add("在線端點不足 2 個，略過同步。");
            return report;
        }

        // 2. Scan online endpoints
        var scans = new Dictionary<string, Dictionary<string, ScannedFile>>();
        var allPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var ep in onlineEndpoints)
        {
            var scanned = FileOps.ScanDirectory(ep.Root, _ignoreRules);
            scans[ep.Id] = scanned;
            foreach (var path in scanned.Keys)
            {
                allPaths.Add(path);
            }
        }

        var consensusMap = _store.GetAllConsensus();
        foreach (var path in consensusMap.Keys)
        {
            allPaths.Add(path);
        }

        // 3. Reconcile each path
        foreach (var relPath in allPaths)
        {
            consensusMap.TryGetValue(relPath, out var consensus);
            var pathDecisions = new Dictionary<string, (Decision Decision, ScannedFile? Scanned)>();

            foreach (var ep in onlineEndpoints)
            {
                var row = _store.GetRow(ep.Id, relPath);
                scans[ep.Id].TryGetValue(relPath, out var scanned);

                FileState? current = null;
                if (scanned != null && !scanned.IsPlaceholder)
                {
                    var hash = FileOps.ComputeSha256(scanned.FullPath);
                    current = new FileState(FileKind.File, hash, scanned.Size);
                }

                var obs = new PathObservation(row?.State, current, row?.SeenRev ?? 0);
                var decision = Reconciler.Decide(obs, consensus);
                pathDecisions[ep.Id] = (decision, scanned);
            }

            // Apply decisions
            ProcessPathDecisions(relPath, pathDecisions, onlineEndpoints, scans, ref consensus, report);
        }

        return report;
    }

    private void ProcessPathDecisions(
        string relPath,
        Dictionary<string, (Decision Decision, ScannedFile? Scanned)> decisions,
        List<EndpointConfig> onlineEndpoints,
        Dictionary<string, Dictionary<string, ScannedFile>> scans,
        ref ConsensusEntry? consensus,
        SyncReport report)
    {
        // Check if any endpoint changed and should be adopted
        var adopters = decisions.Where(kv => kv.Value.Decision == Decision.AdoptEndpoint).ToList();
        var conflicts = decisions.Where(kv => kv.Value.Decision == Decision.Conflict).ToList();

        if (conflicts.Count > 0)
        {
            // Conflict occurred: keep existing file, copy new version as conflict file
            foreach (var c in conflicts)
            {
                var epId = c.Key;
                var scanned = c.Value.Scanned;
                if (scanned == null) continue;

                var epCfg = onlineEndpoints.First(e => e.Id == epId);
                var conflictName = ConflictNaming.Name(Path.GetFileName(relPath), epId, DateTime.UtcNow);
                var dir = Path.GetDirectoryName(relPath) ?? "";
                var conflictRelPath = string.IsNullOrEmpty(dir) ? conflictName : Path.Combine(dir, conflictName).Replace('\\', '/');
                var conflictFullPath = Path.Combine(epCfg.Root, conflictRelPath);

                FileOps.CopyAtomically(scanned.FullPath, conflictFullPath);
                _store.AddConflict(epId, relPath, conflictRelPath, DateTime.UtcNow);
                _store.RecordJournal("conflict", epId, relPath, $"保留為 {conflictName}", "done");
                report.Notes.Add($"[{epId}] 衝突 {relPath}：本端版本保留為「{conflictName}」");
            }
            return;
        }

        if (adopters.Count > 0)
        {
            // First adopter establishes the new consensus revision
            var primary = adopters[0];
            var srcEp = onlineEndpoints.First(e => e.Id == primary.Key);
            var scanned = primary.Value.Scanned;

            var newRev = (consensus?.Rev ?? 0) + 1;
            FileState? newState = null;
            if (scanned != null)
            {
                var hash = FileOps.ComputeSha256(scanned.FullPath);
                newState = new FileState(FileKind.File, hash, scanned.Size);
            }

            consensus = new ConsensusEntry(newState, newRev);
            _store.SetConsensus(relPath, newState, newRev);

            // Update row for source endpoint
            _store.SetRow(srcEp.Id, relPath, newState, scanned?.MtimeNs ?? 0, newRev);

            // Propagate to other online endpoints
            foreach (var targetEp in onlineEndpoints.Where(e => e.Id != srcEp.Id))
            {
                var targetFullPath = Path.Combine(targetEp.Root, relPath);
                if (newState == null)
                {
                    // Deleted
                    if (File.Exists(targetFullPath))
                    {
                        FileOps.MoveToTrash(targetFullPath);
                        _store.RecordJournal("trash", targetEp.Id, relPath, null, "done");
                        report.Actions++;
                    }
                    _store.SetRow(targetEp.Id, relPath, null, 0, newRev);
                }
                else
                {
                    // Copy
                    FileOps.CopyAtomically(scanned!.FullPath, targetFullPath);
                    var fi = new FileInfo(targetFullPath);
                    _store.RecordJournal("copy", targetEp.Id, relPath, $"from {srcEp.Id}", "done");
                    _store.SetRow(targetEp.Id, relPath, newState, fi.LastWriteTimeUtc.Ticks * 100L, newRev);
                    report.Actions++;
                }
            }
        }
    }
}
