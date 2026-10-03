using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;
using SyncNexus.Desktop.Localization;
using SyncNexus.Desktop.Services;

namespace SyncNexus.Desktop.ViewModels;

public partial class EndpointItemViewModel : ObservableObject
{
    [ObservableProperty] private string _id = string.Empty;
    [ObservableProperty] private string _root = string.Empty;
    [ObservableProperty] private bool _isOnline;
    [ObservableProperty] private string _statusText = "離線";
    [ObservableProperty] private string _icon = "📁";
    [ObservableProperty] private bool _isRemovable;
    [ObservableProperty] private string? _volumeUuid;

    public EndpointConfig Config { get; set; }

    public EndpointItemViewModel(EndpointConfig cfg)
    {
        Config = cfg;
        Id = cfg.Id;
        Root = cfg.Root;
        IsRemovable = cfg.Removable;
        VolumeUuid = cfg.VolumeUuid;

        if (cfg.Removable) Icon = "💾";
        else if (cfg.Root.Contains("Google", StringComparison.OrdinalIgnoreCase)) Icon = "☁️";
        else if (cfg.Root.Contains("OneDrive", StringComparison.OrdinalIgnoreCase)) Icon = "⛅";
        else Icon = "📁";
    }

    public void UpdateStatus(IdentityCheckResult result)
    {
        IsOnline = result.Status == EndpointStatus.Online;
        StatusText = IsOnline ? "在線" : (result.Reason ?? "離線");
    }
}

/// <summary>A group as shown in the group bar.</summary>
public partial class GroupItemViewModel : ObservableObject
{
    private static readonly Dictionary<string, string> Emoji = new()
    {
        ["folder"] = "📁", ["briefcase"] = "💼", ["doc.text"] = "📄", ["camera"] = "📷", ["graduationcap"] = "🎓",
        ["heart"] = "❤️", ["externaldrive"] = "💾", ["building.2"] = "🏢", ["tag"] = "🏷️", ["star"] = "⭐"
    };

    public static IReadOnlyList<string> IconKeys { get; } = Emoji.Keys.ToList();
    public static string EmojiFor(string icon) => Emoji.TryGetValue(icon, out var e) ? e : "📁";

    public string Id { get; }
    [ObservableProperty]
    [NotifyPropertyChangedFor(nameof(IconEmoji))]
    private SyncGroup _group;
    [ObservableProperty] private string _displayName = string.Empty;

    public string IconEmoji => EmojiFor(Group.Icon);

    public GroupItemViewModel(SyncGroup group)
    {
        _group = group;
        Id = group.Id;
    }
}

public partial class MainViewModel : ObservableObject
{
    private readonly GroupManager _groups;

    [ObservableProperty] private string _appTitle = "SyncNexus (Windows)";
    [ObservableProperty] private string _statusMessage = "就緒";
    [ObservableProperty] private int _trackedFilesCount = 0;
    [ObservableProperty] private bool _isSyncing = false;
    [ObservableProperty] private GroupItemViewModel? _selectedGroupItem;

    public ObservableCollection<GroupItemViewModel> Groups { get; } = new();
    public ObservableCollection<EndpointItemViewModel> Endpoints { get; } = new();
    public ObservableCollection<string> RecentLogs { get; } = new();

    public MainViewModel(GroupManager groups)
    {
        _groups = groups;
        _groups.GroupsChanged += () => System.Windows.Application.Current?.Dispatcher.Invoke(ReloadGroups);
        ReloadGroups();
    }

    /// <summary>The group whose folders are shown.</summary>
    public GroupRuntime? ActiveRuntime => SelectedGroupItem is null ? null : _groups.Get(SelectedGroupItem.Id);

    public SyncNexus.Core.Storage.IStore ActiveStore =>
        ActiveRuntime?.Store ?? _groups.Runtimes[0].Store;

    private void ReloadGroups()
    {
        var keep = SelectedGroupItem?.Id;
        Groups.Clear();
        foreach (var rt in _groups.Runtimes) Groups.Add(new GroupItemViewModel(rt.Group));
        RefreshGroupNames();
        SelectedGroupItem = Groups.FirstOrDefault(g => g.Id == keep) ?? Groups.FirstOrDefault();
    }

    partial void OnSelectedGroupItemChanged(GroupItemViewModel? value) => LoadEndpoints();

    /// <summary>Call after the interface language changed (and after creating / renaming groups).</summary>
    public void RefreshGroupNames()
    {
        foreach (var item in Groups) item.DisplayName = GroupDisplayName(item.Group);
    }

    /// <summary>Name shown in the UI: user-typed names unchanged, unnamed / built-in groups in the selected language.</summary>
    public string GroupDisplayName(SyncGroup group)
    {
        var loc = LocalizationService.Instance;
        return SyncGroupNaming.Display(
            group,
            _groups.Registry.All(),
            loc.Get("group_default_name"),
            loc.Get("group_new_default_name"),
            loc.GetAllLanguages("group_default_name").Append("預設同步群組"));
    }

    public void CreateGroup(string name, string icon = "folder")
    {
        // An unnamed group stores no text; its name is chosen per language when shown.
        var rt = _groups.Create(name, icon);   // raises GroupsChanged -> ReloadGroups
        SelectedGroupItem = Groups.FirstOrDefault(g => g.Id == rt.Group.Id) ?? SelectedGroupItem;
        StatusMessage = string.Format(LocalizationService.Instance.Get("group_created_toast"), GroupDisplayName(rt.Group));
    }

    public void UpdateGroup(string id, string name, string icon)
    {
        if (!_groups.Update(id, name, icon)) return;
        var item = Groups.FirstOrDefault(g => g.Id == id);
        if (item is not null && _groups.Registry.Get(id) is { } g)
        {
            item.Group = g;
            item.DisplayName = GroupDisplayName(g);
            OnPropertyChanged(nameof(SelectedGroupItem));
        }
        RefreshGroupNames();
    }

    public void DeleteGroup(string id)
    {
        if (Groups.Count <= 1)
        {
            StatusMessage = LocalizationService.Instance.Get("group_cannot_delete_last");
            return;
        }

        var shownName = Groups.FirstOrDefault(g => g.Id == id)?.DisplayName ?? id;   // before removal, so numbering stays right
        if (_groups.Delete(id))   // raises GroupsChanged -> ReloadGroups (selection falls back to the first group)
        {
            StatusMessage = string.Format(LocalizationService.Instance.Get("group_deleted_toast"), shownName);
        }
    }

    public void LoadEndpoints()
    {
        Endpoints.Clear();
        var rt = ActiveRuntime;
        if (rt is null) { TrackedFilesCount = 0; return; }

        foreach (var cfg in rt.Store.GetEndpoints())
        {
            var vm = new EndpointItemViewModel(cfg);
            var status = rt.Engine.CheckIdentity(cfg, writeMarker: false);
            vm.UpdateStatus(status);
            Endpoints.Add(vm);
        }
        TrackedFilesCount = rt.Store.GetAllConsensus().Count(c => c.Value.State != null);
    }

    [RelayCommand]
    public async Task TriggerSyncAsync()
    {
        if (IsSyncing) return;
        IsSyncing = true;
        StatusMessage = "同步中...";

        try
        {
            var actions = 0;
            var allOk = true;
            foreach (var rt in _groups.Runtimes)
            {
                var report = await Task.Run(() => rt.Engine.SyncAll());
                actions += report.Actions;
                allOk &= report.IsSuccess;
                if (rt.Group.Id == SelectedGroupItem?.Id)
                {
                    foreach (var note in report.Notes) RecentLogs.Insert(0, note);
                }
            }
            LoadEndpoints();
            StatusMessage = allOk
                ? $"同步完成（處理 {actions} 項變更）"
                : $"同步完成（部分端點離線）";
        }
        catch (Exception ex)
        {
            StatusMessage = $"同步錯誤：{ex.Message}";
        }
        finally
        {
            IsSyncing = false;
        }
    }
}
