using System.Text.Json;

namespace SyncNexus.Core.Model;

/// <summary>
/// Persists the list of sync groups (groups.json) next to the databases. Each group has its own state database:
/// the built-in group keeps the original state.db, every other group uses Groups/&lt;id&gt;/state.db.
/// A damaged groups.json is copied aside and never overwritten by a fresh default.
/// </summary>
public class SyncGroupRegistry
{
    public const string DefaultId = "default";
    public const string DefaultMarkerName = "預設群組";   // fixed marker; displayed in the current language by SyncGroupNaming

    internal static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true, PropertyNameCaseInsensitive = true };

    private readonly string _baseDir;
    private readonly string _file;
    private readonly object _lock = new();
    private List<SyncGroup> _groups = new();

    public SyncGroupRegistry(string baseDir)
    {
        _baseDir = baseDir;
        _file = Path.Combine(baseDir, "groups.json");
        Load();
    }

    public IReadOnlyList<SyncGroup> All()
    {
        lock (_lock) return _groups.ToList();
    }

    public SyncGroup? Get(string id)
    {
        lock (_lock) return _groups.FirstOrDefault(g => g.Id == id);
    }

    public string DbPath(string groupId) =>
        groupId == DefaultId
            ? Path.Combine(_baseDir, "state.db")
            : Path.Combine(_baseDir, "Groups", groupId, "state.db");

    public string BaseDir => _baseDir;

    public string FilePath => _file;

    /// <summary>Tolerant parse of a groups.json text: missing fields fall back to defaults. Null when it is not a group list.</summary>
    internal static List<SyncGroup>? ParseGroups(string json)
    {
        try
        {
            var decoded = JsonSerializer.Deserialize<List<SyncGroup>>(json, JsonOptions);
            if (decoded is not { Count: > 0 }) return null;
            return decoded
                .Select(g => g with { Id = string.IsNullOrEmpty(g.Id) ? DefaultId : g.Id, Name = g.Name ?? string.Empty, Icon = string.IsNullOrEmpty(g.Icon) ? "folder" : g.Icon })
                .ToList();
        }
        catch (Exception)
        {
            return null;
        }
    }

    /// <summary>Adds the group, or replaces the group with the same id.</summary>
    public void Upsert(SyncGroup group)
    {
        lock (_lock)
        {
            var idx = _groups.FindIndex(g => g.Id == group.Id);
            if (idx >= 0) _groups[idx] = group; else _groups.Add(group);
            Save();
        }
    }

    /// <summary>Re-reads groups.json (after a restore replaced the file).</summary>
    public void Reload() => Load();

    public string GroupDirectory(string groupId) => Path.Combine(_baseDir, "Groups", groupId);

    /// <summary>An empty name stays empty: the group is then shown as "New Group" in the current language.</summary>
    public SyncGroup Add(string name, string icon = "folder")
    {
        lock (_lock)
        {
            var group = new SyncGroup($"group_{Guid.NewGuid().ToString("N")[..8]}", (name ?? string.Empty).Trim(), icon, DateTime.UtcNow);
            _groups.Add(group);
            Save();
            return group;
        }
    }

    public bool Update(string id, string name, string icon)
    {
        lock (_lock)
        {
            var idx = _groups.FindIndex(g => g.Id == id);
            if (idx < 0) return false;
            var trimmed = (name ?? string.Empty).Trim();
            // an unnamed group may stay unnamed; a named one needs text
            if (trimmed.Length == 0 && _groups[idx].Name.Length > 0) return false;
            _groups[idx] = _groups[idx] with { Name = trimmed, Icon = icon };
            Save();
            return true;
        }
    }

    /// <summary>Never removes the last group.</summary>
    public bool Remove(string id)
    {
        lock (_lock)
        {
            if (_groups.Count <= 1) return false;
            var removed = _groups.RemoveAll(g => g.Id == id) > 0;
            if (removed) Save();
            return removed;
        }
    }

    private void Load()
    {
        lock (_lock)
        {
            if (File.Exists(_file))
            {
                var parsed = ParseGroups(File.ReadAllText(_file));
                if (parsed != null)
                {
                    _groups = parsed;
                    return;
                }
                // damaged or empty: keep a copy, never overwrite it with a fresh default
                try { File.Copy(_file, _file + $".corrupted-{DateTimeOffset.UtcNow.ToUnixTimeSeconds()}", overwrite: false); } catch { /* best effort */ }
            }

            _groups = new List<SyncGroup> { new(DefaultId, DefaultMarkerName, "folder", DateTime.UtcNow) };
            if (!File.Exists(_file)) Save();
        }
    }

    private void Save()
    {
        Directory.CreateDirectory(_baseDir);
        var tmp = _file + ".tmp";
        File.WriteAllText(tmp, JsonSerializer.Serialize(_groups, JsonOptions));
        File.Move(tmp, _file, overwrite: true);
    }
}
