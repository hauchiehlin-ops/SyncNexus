using System.Text.Json;

namespace SyncNexus.Core.Model;

public record BackupInfo(string Name, string Path, DateTime Date, IReadOnlyList<string> GroupNames, int EndpointCount);

/// <summary>
/// Automatic snapshots of groups.json and every group's state database under Backups/Registry/&lt;timestamp&gt;/.
/// Unchanged state is not backed up again, an empty state never pushes out good backups, the newest
/// <see cref="Keep"/> are kept (plus the newest one that still holds folders), and an existing backup is never reused.
/// </summary>
public class GroupBackups
{
    public const int Keep = 10;

    internal record ManifestGroup(string Id, string Name, int Endpoints);
    internal record Manifest(DateTime Date, List<ManifestGroup> Groups, string Fingerprint);

    private readonly SyncGroupRegistry _registry;
    private readonly string _root;

    public GroupBackups(SyncGroupRegistry registry)
    {
        _registry = registry;
        _root = Path.Combine(registry.BaseDir, "Backups", "Registry");
    }

    private (string Fingerprint, List<ManifestGroup> Groups) Describe()
    {
        var fp = File.Exists(_registry.FilePath) ? File.ReadAllText(_registry.FilePath) : string.Empty;
        var groups = new List<ManifestGroup>();
        foreach (var g in _registry.All())
        {
            var eps = GroupDatabaseFiles.ReadEndpoints(_registry.DbPath(g.Id));
            fp += string.Join(";", eps.Select(e => $"{e.Id}={e.Root}"));
            groups.Add(new ManifestGroup(g.Id, g.Name, eps.Count));
        }
        return (fp, groups);
    }

    private List<string> BackupDirs() =>
        !Directory.Exists(_root)
            ? new List<string>()
            : Directory.GetDirectories(_root).Where(d => File.Exists(Path.Combine(d, "manifest.json")))
                .OrderBy(d => Path.GetFileName(d), StringComparer.Ordinal).ToList();

    private static Manifest? ReadManifest(string dir)
    {
        try { return JsonSerializer.Deserialize<Manifest>(File.ReadAllText(Path.Combine(dir, "manifest.json"))); }
        catch (Exception) { return null; }
    }

    /// <summary>Returns the new backup folder, or null when skipped or failed.</summary>
    public string? BackupNow(bool force = false)
    {
        var (fingerprint, groups) = Describe();
        var total = groups.Sum(g => g.Endpoints);
        var existing = BackupDirs();
        if (!force)
        {
            if (total == 0 && existing.Count > 0) return null;
            if (existing.Count > 0 && ReadManifest(existing[^1])?.Fingerprint == fingerprint) return null;
        }

        var baseName = DateTime.Now.ToString("yyyyMMdd-HHmmss");
        var dir = Path.Combine(_root, baseName);
        for (var n = 2; Directory.Exists(dir); n++) dir = Path.Combine(_root, $"{baseName}-{n}");   // never reuse (or delete) an existing backup

        try
        {
            Directory.CreateDirectory(dir);
            if (File.Exists(_registry.FilePath)) File.Copy(_registry.FilePath, Path.Combine(dir, "groups.json"));
            foreach (var g in _registry.All())
            {
                var snap = GroupDatabaseFiles.ConsolidatedCopy(_registry.DbPath(g.Id));
                if (snap == null) continue;
                try
                {
                    var dest = g.Id == SyncGroupRegistry.DefaultId
                        ? Path.Combine(dir, "state.db")
                        : Path.Combine(dir, "Groups", g.Id, "state.db");
                    Directory.CreateDirectory(Path.GetDirectoryName(dest)!);
                    File.Copy(snap, dest);
                }
                finally
                {
                    try { Directory.Delete(Path.GetDirectoryName(snap)!, recursive: true); } catch (IOException) { }
                }
            }
            File.WriteAllText(Path.Combine(dir, "manifest.json"), JsonSerializer.Serialize(new Manifest(DateTime.Now, groups, fingerprint)));
        }
        catch (Exception)
        {
            try { Directory.Delete(dir, recursive: true); } catch (IOException) { }
            return null;
        }

        Rotate();
        return dir;
    }

    private void Rotate()
    {
        var all = BackupDirs();
        if (all.Count <= Keep) return;
        var keepGood = all.LastOrDefault(d => (ReadManifest(d)?.Groups.Sum(g => g.Endpoints) ?? 0) > 0);
        foreach (var old in all.Take(all.Count - Keep).Where(d => d != keepGood))
        {
            try { Directory.Delete(old, recursive: true); } catch (IOException) { }
        }
    }

    /// <summary>Newest first.</summary>
    public List<BackupInfo> ListBackups() =>
        BackupDirs().AsEnumerable().Reverse().Select(d => (Dir: d, M: ReadManifest(d)))
            .Where(x => x.M != null)
            .Select(x => new BackupInfo(Path.GetFileName(x.Dir), x.Dir, x.M!.Date, x.M.Groups.Select(g => g.Name).ToList(), x.M.Groups.Sum(g => g.Endpoints)))
            .ToList();

    /// <summary>
    /// Replaces groups.json and the databases with the backup's files; replaced files are kept as ".pre-restore-&lt;stamp&gt;".
    /// All stores must be closed first. The registry is reloaded afterwards.
    /// </summary>
    public void RestoreFiles(BackupInfo backup)
    {
        var restored = SyncGroupRegistry.ParseGroups(File.ReadAllText(System.IO.Path.Combine(backup.Path, "groups.json")))
            ?? throw new InvalidDataException("backup has no groups");
        var stamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

        void Replace(string dst, string src)
        {
            Directory.CreateDirectory(System.IO.Path.GetDirectoryName(dst)!);
            foreach (var ext in new[] { "", "-wal", "-shm" })
            {
                var f = dst + ext;
                if (File.Exists(f)) File.Move(f, f + $".pre-restore-{stamp}");
            }
            File.Copy(src, dst);
        }

        foreach (var g in restored)
        {
            var src = g.Id == SyncGroupRegistry.DefaultId
                ? System.IO.Path.Combine(backup.Path, "state.db")
                : System.IO.Path.Combine(backup.Path, "Groups", g.Id, "state.db");
            if (File.Exists(src)) Replace(_registry.DbPath(g.Id), src);
        }
        Replace(_registry.FilePath, System.IO.Path.Combine(backup.Path, "groups.json"));
        _registry.Reload();
    }
}
