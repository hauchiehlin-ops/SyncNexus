namespace SyncNexus.Core.Model;

public class LegacyImportException : Exception
{
    public LegacyImportException() : base("No SyncNexus settings found in that folder.") { }
}

/// <summary>A group found in an old settings folder, with a consistent temp copy of its database.</summary>
public record LegacyItem(SyncGroup Group, string SnapshotDb, int Endpoints);

/// <summary>Reads groups and databases from a folder the user picked (e.g. an old or differently-located data folder).</summary>
public static class LegacyImport
{
    /// <summary>Accepts the settings folder itself or its parent. Throws <see cref="LegacyImportException"/> when nothing is there.</summary>
    public static List<LegacyItem> Read(string folder)
    {
        var src = folder;
        if (!File.Exists(Path.Combine(src, "groups.json")) && !File.Exists(Path.Combine(src, "state.db")))
        {
            src = Path.Combine(folder, "SyncNexus");
        }

        var groupsFile = Path.Combine(src, "groups.json");
        var hasDefaultDb = File.Exists(Path.Combine(src, "state.db"));

        var legacy = File.Exists(groupsFile) ? SyncGroupRegistry.ParseGroups(File.ReadAllText(groupsFile)) ?? new() : new List<SyncGroup>();
        if (legacy.Count == 0 && hasDefaultDb)
        {
            legacy.Add(new SyncGroup(SyncGroupRegistry.DefaultId, SyncGroupRegistry.DefaultMarkerName, "folder", DateTime.UtcNow));
        }
        if (legacy.Count == 0) throw new LegacyImportException();

        var items = new List<LegacyItem>();
        foreach (var g in legacy)
        {
            var srcDb = g.Id == SyncGroupRegistry.DefaultId
                ? Path.Combine(src, "state.db")
                : Path.Combine(src, "Groups", g.Id, "state.db");
            var snap = GroupDatabaseFiles.ConsolidatedCopy(srcDb);
            if (snap == null) continue;
            var count = GroupDatabaseFiles.CountEndpoints(snap);
            if (count == 0)
            {
                try { Directory.Delete(Path.GetDirectoryName(snap)!, recursive: true); } catch (IOException) { }
                continue;
            }
            items.Add(new LegacyItem(g, snap, count));
        }
        return items;
    }

    public static void Cleanup(IEnumerable<LegacyItem> items)
    {
        foreach (var i in items)
        {
            try { Directory.Delete(Path.GetDirectoryName(i.SnapshotDb)!, recursive: true); } catch (IOException) { }
        }
    }
}
