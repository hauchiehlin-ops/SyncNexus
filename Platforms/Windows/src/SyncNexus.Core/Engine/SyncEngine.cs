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
    /// Executes a full, robust synchronization cycle across all configured endpoints.
    /// Fully implements 3-way reconciliation, deletion guard, version archiving, and atomic transfers.
    /// </summary>
    public SyncReport SyncAll(bool confirmed = false)
    {
        var lockPath = _store.DbPath + ".lock";
        using var syncLock = SyncLock.Acquire(lockPath, TimeSpan.FromSeconds(10));

        var report = new SyncReport();
        var endpoints = _store.GetEndpoints();
        var onlineEndpoints = new List<EndpointConfig>();

        // 1. Verify identities and markers
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

        // 3. Pre-calculate decisions for all paths
        var pathDecisions = new Dictionary<string, Dictionary<string, (Decision Decision, FileState? Current, ScannedFile? Scanned)>>();
        var plannedDeletions = 0;
        var totalTracked = consensusMap.Count(c => c.Value.State != null);

        foreach (var relPath in allPaths)
        {
            consensusMap.TryGetValue(relPath, out var consensus);
            var epDecisions = new Dictionary<string, (Decision Decision, FileState? Current, ScannedFile? Scanned)>();

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
                epDecisions[ep.Id] = (decision, current, scanned);

                // Track planned deletions
                if (decision == Decision.AdoptEndpoint && current == null && (consensus?.State != null || row?.State != null))
                {
                    plannedDeletions++;
                }
                else if (decision == Decision.ApplyConsensus && consensus?.State == null && current != null)
                {
                    plannedDeletions++;
                }
            }

            pathDecisions[relPath] = epDecisions;
        }

        // 4. Deletion Guard check
        if (_deletionGuard.RequiresConfirmation(plannedDeletions, totalTracked) && !confirmed)
        {
            var warning = $"預計刪除 {plannedDeletions} 個檔案（共追蹤 {totalTracked} 個），超過安全防護門檻，已安全暫停，需使用者確認後方可執行。";
            report.Notes.Add(warning);
            report.Offline.Add(warning);
            return report;
        }

        // 5. Execute reconciliation passes
        foreach (var (relPath, epDecisions) in pathDecisions)
        {
            consensusMap.TryGetValue(relPath, out var consensus);

            // Phase A: Handle Conflicts
            var conflicts = epDecisions.Where(kv => kv.Value.Decision == Decision.Conflict).ToList();
            if (conflicts.Count > 0)
            {
                foreach (var c in conflicts)
                {
                    var epId = c.Key;
                    var scanned = c.Value.Scanned;
                    if (scanned == null) continue;

                    var epCfg = onlineEndpoints.First(e => e.Id == epId);
                    var conflictName = ConflictNaming.Name(Path.GetFileName(relPath), epId, DateTime.UtcNow);
                    var dir = Path.GetDirectoryName(relPath) ?? "";
                    var conflictRel = string.IsNullOrEmpty(dir) ? conflictName : $"{dir.Replace('\\', '/')}/{conflictName}";
                    var conflictFull = Path.Combine(epCfg.Root, conflictRel);

                    FileOps.CopyAtomically(scanned.FullPath, conflictFull, scanned.Mtime);
                    _store.AddConflict(epId, relPath, conflictRel, DateTime.UtcNow);
                    _store.RecordJournal("conflict", epId, relPath, $"保留為 {conflictName}", "done");
                    report.Notes.Add($"[{epId}] 衝突 {relPath}：本端版本保留為「{conflictName}」");
                    report.Actions++;
                }
            }

            // Phase B: Handle AdoptEndpoint (local modifications, creations, deletions)
            var adopters = epDecisions.Where(kv => kv.Value.Decision == Decision.AdoptEndpoint).ToList();
            if (adopters.Count > 0)
            {
                var primary = adopters[0];
                var srcEp = onlineEndpoints.First(e => e.Id == primary.Key);
                var newState = primary.Value.Current;
                var scanned = primary.Value.Scanned;

                var newRev = (consensus?.Rev ?? 0) + 1;
                consensus = new ConsensusEntry(newState, newRev);
                _store.SetConsensus(relPath, newState, newRev);

                var mtimeNs = scanned?.MtimeNs ?? 0;
                _store.SetRow(srcEp.Id, relPath, newState, mtimeNs, newRev);

                if (newState != null)
                {
                    _store.RecordJournal("adopt", srcEp.Id, relPath, $"hash={newState.Hash[..Math.Min(8, newState.Hash.Length)]}", "done");
                    report.Notes.Add($"[{srcEp.Id}] 新增/修改 {relPath}（版號 {newRev}）");
                }
                else
                {
                    _store.RecordJournal("delete", srcEp.Id, relPath, null, "done");
                    report.Notes.Add($"[{srcEp.Id}] 刪除 {relPath}（版號 {newRev}）");
                }
                report.Work++;
            }

            // Phase C: Handle ApplyConsensus (propagate consensus to endpoints that are behind)
            if (consensus != null)
            {
                foreach (var ep in onlineEndpoints)
                {
                    if (epDecisions.TryGetValue(ep.Id, out var dec) &&
                        (dec.Decision == Decision.ApplyConsensus ||
                         (adopters.Count > 0 && dec.Decision != Decision.AdoptEndpoint)))
                    {
                        ApplyConsensusToEndpoint(ep, relPath, consensus, scans, onlineEndpoints, report);
                    }
                    else if (epDecisions.TryGetValue(ep.Id, out var markDec) && markDec.Decision == Decision.MarkSeen)
                    {
                        var scanned = markDec.Scanned;
                        _store.SetRow(ep.Id, relPath, consensus.State, scanned?.MtimeNs ?? 0, consensus.Rev);
                    }
                }
            }
        }

        return report;
    }

    private void ApplyConsensusToEndpoint(
        EndpointConfig targetEp,
        string relPath,
        ConsensusEntry consensus,
        Dictionary<string, Dictionary<string, ScannedFile>> scans,
        List<EndpointConfig> onlineEndpoints,
        SyncReport report)
    {
        var targetFullPath = Path.Combine(targetEp.Root, relPath);

        if (consensus.State == null)
        {
            // Consensus is deleted -> move to trash
            if (File.Exists(targetFullPath))
            {
                FileOps.ArchiveVersion(targetEp.Root, relPath);
                FileOps.MoveToTrash(targetFullPath);
                _store.RecordJournal("trash", targetEp.Id, relPath, null, "done");
                report.Actions++;
                report.Notes.Add($"[{targetEp.Id}] 移到資源回收筒 {relPath}");
            }
            _store.SetRow(targetEp.Id, relPath, null, 0, consensus.Rev);
        }
        else
        {
            // Consensus has file content -> find online holder
            ScannedFile? holderFile = null;
            string? holderEpId = null;

            foreach (var ep in onlineEndpoints.Where(e => e.Id != targetEp.Id))
            {
                if (scans[ep.Id].TryGetValue(relPath, out var sf) &&
                    !sf.IsPlaceholder &&
                    FileOps.ComputeSha256(sf.FullPath) == consensus.State.Hash)
                {
                    holderFile = sf;
                    holderEpId = ep.Id;
                    break;
                }
            }

            if (holderFile != null)
            {
                if (File.Exists(targetFullPath))
                {
                    FileOps.ArchiveVersion(targetEp.Root, relPath);
                }

                FileOps.CopyAtomically(holderFile.FullPath, targetFullPath, holderFile.Mtime);
                var fi = new FileInfo(targetFullPath);
                var mtimeNs = fi.LastWriteTimeUtc.Ticks * 100L;

                _store.RecordJournal("copy", targetEp.Id, relPath, $"from {holderEpId}", "done");
                _store.SetRow(targetEp.Id, relPath, consensus.State, mtimeNs, consensus.Rev);
                report.Actions++;
                report.Notes.Add($"[{targetEp.Id}] 寫入 {relPath}（來源：{holderEpId}）");
            }
            else
            {
                report.Skipped++;
                report.Notes.Add($"[{targetEp.Id}] {relPath}：目前無其他在線端點持有有效副本，稍後重試");
            }
        }
    }
}
