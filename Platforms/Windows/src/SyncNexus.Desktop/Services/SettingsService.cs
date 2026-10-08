using System.IO;
using System.Text.Json;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;

namespace SyncNexus.Desktop.Services;

public class GroupSettings
{
    public ConflictPolicy ConflictPolicy { get; set; } = ConflictPolicy.KeepBoth;
    public List<ExcludePreset> ExcludePresets { get; set; } = new()
    {
        ExcludePreset.SystemJunk,
        ExcludePreset.OfficeLock,
        ExcludePreset.OfficeTemp,
        ExcludePreset.CloudPlaceholder
    };
    public bool AutoExcludeNestedGroups { get; set; } = true;
    public bool CloudSpaceSaving { get; set; } = true;
    public int RetentionDays { get; set; } = 30;
    public bool IsPaused { get; set; } = false;
    public DateTime? LastDeepVerify { get; set; }
    public List<string> CustomPatterns { get; set; } = new();
}

public class SettingsData
{
    public Dictionary<string, GroupSettings> Groups { get; set; } = new();
}

public sealed class SettingsService
{
    private static readonly Lazy<SettingsService> _lazy = new(() => new SettingsService());
    public static SettingsService Instance => _lazy.Value;

    private readonly string _filePath;
    private readonly object _lock = new();
    private SettingsData _data;

    public SettingsService()
    {
        var appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        var dir = Path.Combine(appData, "SyncNexus");
        Directory.CreateDirectory(dir);
        _filePath = Path.Combine(dir, "settings.json");
        _data = LoadSettings();
    }

    private SettingsData LoadSettings()
    {
        try
        {
            if (File.Exists(_filePath))
            {
                var json = File.ReadAllText(_filePath);
                var loaded = JsonSerializer.Deserialize<SettingsData>(json);
                if (loaded != null) return loaded;
            }
        }
        catch { /* Fallback to default */ }
        return new SettingsData();
    }

    public void Save()
    {
        lock (_lock)
        {
            try
            {
                var json = JsonSerializer.Serialize(_data, new JsonSerializerOptions { WriteIndented = true });
                File.WriteAllText(_filePath, json);
            }
            catch { /* Ignore write errors */ }
        }
    }

    public GroupSettings GetGroup(string groupId)
    {
        lock (_lock)
        {
            if (!_data.Groups.TryGetValue(groupId, out var s))
            {
                s = new GroupSettings();
                _data.Groups[groupId] = s;
                Save();
            }
            return s;
        }
    }

    public void ApplyToEngine(string groupId, SyncEngine engine)
    {
        var s = GetGroup(groupId);
        engine.ConflictPolicy = s.ConflictPolicy;
        engine.IgnoreRules = IgnoreRules.Create(s.ExcludePresets, s.CustomPatterns);
    }
}
