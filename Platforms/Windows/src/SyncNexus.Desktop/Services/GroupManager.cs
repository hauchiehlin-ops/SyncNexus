using System.IO;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;

namespace SyncNexus.Desktop.Services;

/// <summary>One sync group at runtime: its own state database and reconciliation engine.</summary>
public sealed class GroupRuntime
{
    public required SyncGroup Group { get; set; }
    public required IStore Store { get; init; }
    public required SyncEngine Engine { get; init; }
}

/// <summary>Owns the registry and a store + engine per group, so groups sync independently.</summary>
public sealed class GroupManager : IDisposable
{
    private readonly Dictionary<string, GroupRuntime> _runtimes = new();
    private readonly object _lock = new();

    public SyncGroupRegistry Registry { get; }

    public GroupBackups Backups { get; }

    public event Action? GroupsChanged;

    public GroupManager(string baseDir)
    {
        Registry = new SyncGroupRegistry(baseDir);
        Backups = new GroupBackups(Registry);
        Backups.BackupNow();   // every start: skipped when nothing changed (or when the state is empty and backups exist)
        foreach (var g in Registry.All()) Open(g);
    }

    public IReadOnlyList<GroupRuntime> Runtimes
    {
        get
        {
            lock (_lock) return Registry.All().Where(g => _runtimes.ContainsKey(g.Id)).Select(g => _runtimes[g.Id]).ToList();
        }
    }

    public GroupRuntime? Get(string id)
    {
        lock (_lock) return _runtimes.TryGetValue(id, out var r) ? r : null;
    }

    public GroupRuntime Create(string name, string icon)
    {
        var group = Registry.Add(name, icon);
        var rt = Open(group);
        GroupsChanged?.Invoke();
        return rt;
    }

    public bool Update(string id, string name, string icon)
    {
        if (!Registry.Update(id, name, icon)) return false;
        lock (_lock)
        {
            if (_runtimes.TryGetValue(id, out var rt) && Registry.Get(id) is { } g) rt.Group = g;
        }
        return true;
    }

    /// <summary>Removes only the group's settings and database; the folders' files are never touched.</summary>
    public bool Delete(string id)
    {
        if (!Registry.Remove(id)) return false;
        GroupRuntime? rt;
        lock (_lock)
        {
            _runtimes.Remove(id, out rt);
        }
        rt?.Store.Dispose();
        Microsoft.Data.Sqlite.SqliteConnection.ClearAllPools();   // release the database file before deleting it
        if (id != SyncGroupRegistry.DefaultId)
        {
            try { Directory.Delete(Registry.GroupDirectory(id), recursive: true); } catch (IOException) { } catch (UnauthorizedAccessException) { }
        }
        GroupsChanged?.Invoke();
        return true;
    }

    /// <summary>The id of another group that already uses this folder (the same one, or one containing / inside it), or null.</summary>
    public string? GroupUsingFolder(string root, string exceptGroupId)
    {
        foreach (var rt in Runtimes.Where(r => r.Group.Id != exceptGroupId))
        {
            if (rt.Store.GetEndpoints().Any(ep => FolderOverlap.Overlaps(ep.Root, root))) return rt.Group.Id;
        }
        return null;
    }

    /// <summary>Another folder of the same group that contains, or lies inside, this one (the identical folder does not count).</summary>
    public string? NestedInGroup(string root, string groupId)
    {
        var rt = Get(groupId);
        return rt?.Store.GetEndpoints().FirstOrDefault(ep => FolderOverlap.IsNested(ep.Root, root))?.Id;
    }

    // ---- backups, restore, import ----

    private void CloseAllStores()
    {
        List<GroupRuntime> all;
        lock (_lock)
        {
            all = _runtimes.Values.ToList();
            _runtimes.Clear();
        }
        foreach (var rt in all) rt.Store.Dispose();
        Microsoft.Data.Sqlite.SqliteConnection.ClearAllPools();
    }

    /// <summary>
    /// Replaces the current groups with a backup. The current state is backed up first and replaced files are kept as
    /// ".pre-restore-*", so a restore can be undone. Callers must make sure no sync is running.
    /// </summary>
    public void Restore(BackupInfo backup)
    {
        Backups.BackupNow(force: true);
        CloseAllStores();
        try
        {
            Backups.RestoreFiles(backup);
        }
        finally
        {
            foreach (var g in Registry.All()) Open(g);   // always reopen, even when the restore failed half-way
        }
        GroupsChanged?.Invoke();
    }

    public sealed class LegacyImportResult
    {
        public List<string> Imported { get; } = new();
        public List<string> Kept { get; } = new();
        public int EndpointCount { get; set; }
    }

    /// <summary>
    /// Imports groups and their databases from a folder the user picked. Groups that already have folders are never
    /// overwritten; empty ones are filled and unknown ones are added. Throws <see cref="LegacyImportException"/> when nothing is there.
    /// Callers must make sure no sync is running.
    /// </summary>
    public LegacyImportResult ImportLegacy(string folder)
    {
        var items = LegacyImport.Read(folder);
        try
        {
            var result = new LegacyImportResult();
            if (items.Count == 0) return result;
            Backups.BackupNow(force: true);
            var stamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();

            foreach (var item in items)
            {
                var id = item.Group.Id;
                var destDb = Registry.DbPath(id);
                var existing = Registry.Get(id);
                if (existing != null && GroupDatabaseFiles.CountEndpoints(destDb) > 0)
                {
                    result.Kept.Add(existing.Name);
                    continue;
                }

                GroupRuntime? rt;
                lock (_lock) { _runtimes.Remove(id, out rt); }
                rt?.Store.Dispose();
                Microsoft.Data.Sqlite.SqliteConnection.ClearAllPools();

                Directory.CreateDirectory(Path.GetDirectoryName(destDb)!);
                foreach (var ext in new[] { "", "-wal", "-shm" })
                {
                    var f = destDb + ext;
                    if (File.Exists(f)) File.Move(f, f + $".pre-import-{stamp}");   // never destroy: keep what was here
                }
                File.Copy(item.SnapshotDb, destDb);
                Registry.Upsert(item.Group);
                Open(Registry.Get(id)!);

                result.Imported.Add(item.Group.Name);
                result.EndpointCount += item.Endpoints;
            }

            if (result.Imported.Count > 0) GroupsChanged?.Invoke();
            return result;
        }
        finally
        {
            LegacyImport.Cleanup(items);
        }
    }

    private GroupRuntime Open(SyncGroup group)
    {
        var store = new SqliteStore(Registry.DbPath(group.Id));
        var rt = new GroupRuntime { Group = group, Store = store, Engine = new SyncEngine(store) };
        lock (_lock) _runtimes[group.Id] = rt;
        return rt;
    }

    public void Dispose()
    {
        lock (_lock)
        {
            foreach (var rt in _runtimes.Values) rt.Store.Dispose();
            _runtimes.Clear();
        }
    }
}
