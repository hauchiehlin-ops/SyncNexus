using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using SyncNexus.Core.Engine;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Desktop.Localization;
using SyncNexus.Desktop.Services;

namespace SyncNexus.Desktop.ViewModels;

public partial class EndpointItemViewModel : ObservableObject
{
    [ObservableProperty] private string _id = string.Empty;
    [ObservableProperty] private string _root = string.Empty;
    [ObservableProperty] private bool _isOnline;
    [ObservableProperty] private string _statusText = LocalizationService.Instance.Get("offline");
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
        StatusText = IsOnline ? LocalizationService.Instance.Get("online") : (result.Reason is { } why ? CoreMessages.Localize(why) : LocalizationService.Instance.Get("offline"));
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
    [ObservableProperty] private string _statusMessage = LocalizationService.Instance.Get("status_ready");
    [ObservableProperty] private int _trackedFilesCount = 0;
    [ObservableProperty] private bool _isSyncing = false;
    [ObservableProperty] private GroupItemViewModel? _selectedGroupItem;

    // Stat tiles
    [ObservableProperty] private string _lastDeepVerifyText = "—";
    [ObservableProperty] private string _integrityStatusText = "正常";
    [ObservableProperty] private string _versionsCountText = "0 個版本快照";
    [ObservableProperty] private string _versionsRetentionText = "保留 30 天";

    // Group Banner state
    [ObservableProperty] private bool _isGroupPaused = false;
    [ObservableProperty] private string _groupStatusBadgeText = "正常";

    // Preview
    [ObservableProperty] private bool _isPreviewRunning = false;
    [ObservableProperty] private string _previewSummaryText = string.Empty;
    [ObservableProperty] private bool _previewHasMore = false;

    // Verify
    [ObservableProperty] private bool _isVerifying = false;
    [ObservableProperty] private string _verifySummaryText = string.Empty;

    // Settings observable properties
    [ObservableProperty] private bool _isConflictKeepBoth = true;
    [ObservableProperty] private bool _isConflictNewerWins = false;
    [ObservableProperty] private bool _presetSystemJunk = true;
    [ObservableProperty] private bool _presetOfficeLock = true;
    [ObservableProperty] private bool _presetDevArtifacts = false;
    [ObservableProperty] private bool _presetBuildOutputs = false;
    [ObservableProperty] private bool _presetOfficeTemp = true;
    [ObservableProperty] private bool _presetCloudPlaceholder = true;
    [ObservableProperty] private bool _autoExcludeNestedGroups = true;
    [ObservableProperty] private bool _cloudSpaceSaving = true;

    public ObservableCollection<GroupItemViewModel> Groups { get; } = new();
    public ObservableCollection<EndpointItemViewModel> Endpoints { get; } = new();
    public ObservableCollection<string> RecentLogs { get; } = new();
    public ObservableCollection<PendingConfirmation> PendingConfirmations { get; } = new();
    public ObservableCollection<PlanItem> PreviewItems { get; } = new();
    public ObservableCollection<ConflictRecord> OpenConflicts { get; } = new();
    public ObservableCollection<VersionItem> VersionsList { get; } = new();
    public ObservableCollection<IntegrityIssue> IntegrityIssues { get; } = new();
    public ObservableCollection<VerifyRun> VerifyRuns { get; } = new();

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

    partial void OnSelectedGroupItemChanged(GroupItemViewModel? value)
    {
        LoadEndpoints();
        LoadGroupSettings();
        LoadConflicts();
        LoadVersions();
        LoadIntegrityState();
    }

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
        var rt = _groups.Create(name, icon);
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

        var shownName = Groups.FirstOrDefault(g => g.Id == id)?.DisplayName ?? id;
        if (_groups.Delete(id))
        {
            StatusMessage = string.Format(LocalizationService.Instance.Get("group_deleted_toast"), shownName);
        }
    }

    public void LoadEndpoints()
    {
        Endpoints.Clear();
        var rt = ActiveRuntime;
        if (rt is null)
        {
            TrackedFilesCount = 0;
            return;
        }

        foreach (var cfg in rt.Store.GetEndpoints())
        {
            var vm = new EndpointItemViewModel(cfg);
            var status = rt.Engine.CheckIdentity(cfg, writeMarker: false);
            vm.UpdateStatus(status);
            Endpoints.Add(vm);
        }
        TrackedFilesCount = rt.Store.GetAllConsensus().Count(c => c.Value.State != null);
        UpdateGroupStatusBadge();
    }

    public void UpdateGroupStatusBadge()
    {
        var loc = LocalizationService.Instance;
        if (IsGroupPaused)
        {
            GroupStatusBadgeText = loc.Get("group_status_paused");
        }
        else if (IsSyncing)
        {
            GroupStatusBadgeText = loc.Get("group_status_syncing");
        }
        else if (PendingConfirmations.Count > 0)
        {
            GroupStatusBadgeText = loc.Get("group_status_pending");
        }
        else
        {
            GroupStatusBadgeText = loc.Get("group_status_healthy");
        }
    }

    // --- Deletion Guard Confirmations ---
    [RelayCommand]
    public async Task ApproveConfirmationAsync(PendingConfirmation item)
    {
        PendingConfirmations.Remove(item);
        UpdateGroupStatusBadge();
        var rt = ActiveRuntime;
        if (rt != null)
        {
            await Task.Run(() => rt.Engine.SyncAll(confirmed: true));
            LoadEndpoints();
        }
    }

    [RelayCommand]
    public void DeclineConfirmation(PendingConfirmation item)
    {
        PendingConfirmations.Remove(item);
        UpdateGroupStatusBadge();
    }

    [RelayCommand]
    public async Task ApproveAllConfirmationsAsync()
    {
        PendingConfirmations.Clear();
        UpdateGroupStatusBadge();
        var rt = ActiveRuntime;
        if (rt != null)
        {
            await Task.Run(() => rt.Engine.SyncAll(confirmed: true));
            LoadEndpoints();
        }
    }

    // --- Group Banner: Pause / Resume ---
    [RelayCommand]
    public void TogglePauseGroup()
    {
        if (SelectedGroupItem is null) return;
        var s = SettingsService.Instance.GetGroup(SelectedGroupItem.Id);
        s.IsPaused = !s.IsPaused;
        SettingsService.Instance.Save();
        IsGroupPaused = s.IsPaused;
        UpdateGroupStatusBadge();
        var loc = LocalizationService.Instance;
        StatusMessage = s.IsPaused ? loc.Get("group_paused_toast") : loc.Get("group_resumed_toast");
    }

    // --- Endpoint Actions ---
    public void ChangeEndpointFolder(string endpointId, string newRoot)
    {
        var rt = ActiveRuntime;
        if (rt is null) return;
        var ep = rt.Store.GetEndpoints().FirstOrDefault(e => e.Id == endpointId);
        if (ep is null) return;

        ep.Root = newRoot;
        rt.Store.SaveEndpoint(ep);
        LoadEndpoints();
        StatusMessage = string.Format(LocalizationService.Instance.Get("endpoint_changed_toast"), endpointId, newRoot);
    }

    public void RemoveEndpoint(string endpointId)
    {
        var rt = ActiveRuntime;
        if (rt is null) return;
        rt.Store.DeleteEndpoint(endpointId);
        LoadEndpoints();
        StatusMessage = string.Format(LocalizationService.Instance.Get("endpoint_removed_toast"), endpointId);
    }

    // --- Preview Section ---
    [RelayCommand]
    public async Task RunPreviewAsync()
    {
        var rt = ActiveRuntime;
        if (rt is null || IsPreviewRunning) return;
        IsPreviewRunning = true;
        PreviewItems.Clear();
        var loc = LocalizationService.Instance;
        PreviewSummaryText = loc.Get("preview_running");

        try
        {
            SettingsService.Instance.ApplyToEngine(rt.Group.Id, rt.Engine);
            var report = await Task.Run(() => rt.Engine.Preview());
            var itemsToShow = report.Items.Take(100).ToList();
            foreach (var item in itemsToShow) PreviewItems.Add(item);
            PreviewHasMore = report.Items.Count > 100;
            PreviewSummaryText = string.Format(loc.Get("preview_summary_count"), report.TotalChanges);
        }
        catch (Exception ex)
        {
            PreviewSummaryText = string.Format(loc.Get("sync_error"), ex.Message);
        }
        finally
        {
            IsPreviewRunning = false;
        }
    }

    [RelayCommand]
    public async Task ExecutePreviewSyncAsync()
    {
        await TriggerSyncAsync();
        await RunPreviewAsync();
    }

    // --- Conflicts Section ---
    public void LoadConflicts()
    {
        OpenConflicts.Clear();
        var rt = ActiveRuntime;
        if (rt is null) return;
        foreach (var c in rt.Store.GetOpenConflicts()) OpenConflicts.Add(c);
    }

    [RelayCommand]
    public void KeepMainConflict(ConflictRecord selected)
    {
        var rt = ActiveRuntime;
        if (rt is null || selected is null) return;
        var ep = rt.Store.GetEndpoints().FirstOrDefault(x => x.Id == selected.Endpoint);
        if (ep != null)
        {
            var conflictFull = System.IO.Path.Combine(ep.Root, selected.ConflictPath);
            if (System.IO.File.Exists(conflictFull)) FileOps.MoveToTrash(conflictFull);
        }
        rt.Store.CloseConflict(selected.Id, "resolved_main");
        rt.Store.RecordJournal("conflict-keep-main", selected.Endpoint, selected.Path, null, "done");
        LoadConflicts();
    }

    [RelayCommand]
    public void KeepCopyConflict(ConflictRecord selected)
    {
        var rt = ActiveRuntime;
        if (rt is null || selected is null) return;
        var ep = rt.Store.GetEndpoints().FirstOrDefault(x => x.Id == selected.Endpoint);
        if (ep != null)
        {
            var mainFull = System.IO.Path.Combine(ep.Root, selected.Path);
            var conflictFull = System.IO.Path.Combine(ep.Root, selected.ConflictPath);
            if (System.IO.File.Exists(conflictFull))
            {
                FileOps.CopyAtomically(conflictFull, mainFull);
                FileOps.MoveToTrash(conflictFull);
            }
        }
        rt.Store.CloseConflict(selected.Id, "resolved_conflict");
        rt.Store.RecordJournal("conflict-keep-copy", selected.Endpoint, selected.Path, null, "done");
        LoadConflicts();
    }

    // --- Versions Section ---
    public event Action<int>? RetentionDaysLoaded;

    public void UpdateRetentionDays(int days)
    {
        var rt = ActiveRuntime;
        if (rt is null) return;
        var s = SettingsService.Instance.GetGroup(rt.Group.Id);
        s.RetentionDays = days;
        SettingsService.Instance.Save();
        VersionsRetentionText = string.Format(LocalizationService.Instance.Get("versions_retention_label"), s.RetentionDays);
    }

    public void LoadVersions()
    {
        VersionsList.Clear();
        var rt = ActiveRuntime;
        if (rt is null)
        {
            VersionsCountText = "0 個版本快照";
            return;
        }
        var s = SettingsService.Instance.GetGroup(rt.Group.Id);
        VersionsRetentionText = string.Format(LocalizationService.Instance.Get("versions_retention_label"), s.RetentionDays);
        RetentionDaysLoaded?.Invoke(s.RetentionDays);
        var versions = rt.Engine.GetVersions();
        foreach (var v in versions) VersionsList.Add(v);
        VersionsCountText = string.Format(LocalizationService.Instance.Get("versions_count_label"), versions.Count);
    }

    [RelayCommand]
    public void RestoreVersion(VersionItem item)
    {
        var rt = ActiveRuntime;
        if (rt is null || item is null) return;
        var ok = rt.Engine.RestoreVersion(item);
        if (ok)
        {
            LoadVersions();
            LoadEndpoints();
            StatusMessage = LocalizationService.Instance.Get("versions_restore_success");
        }
    }

    [RelayCommand]
    public void DeleteVersion(VersionItem item)
    {
        var rt = ActiveRuntime;
        if (rt is null || item is null) return;
        rt.Engine.DeleteVersion(item);
        LoadVersions();
    }

    [RelayCommand]
    public void PurgeExpiredVersions()
    {
        var rt = ActiveRuntime;
        if (rt is null) return;
        var s = SettingsService.Instance.GetGroup(rt.Group.Id);
        var count = rt.Engine.PurgeExpiredVersions(s.RetentionDays);
        LoadVersions();
        StatusMessage = string.Format(LocalizationService.Instance.Get("versions_purged_toast"), count);
    }

    [RelayCommand]
    public void PurgeAllVersions()
    {
        var rt = ActiveRuntime;
        if (rt is null) return;
        var count = rt.Engine.PurgeAllVersions();
        LoadVersions();
        StatusMessage = string.Format(LocalizationService.Instance.Get("versions_purged_toast"), count);
    }

    // --- Verify Section ---
    public void LoadIntegrityState()
    {
        IntegrityIssues.Clear();
        var rt = ActiveRuntime;
        if (rt is null) return;
        var s = SettingsService.Instance.GetGroup(rt.Group.Id);
        LastDeepVerifyText = s.LastDeepVerify.HasValue ? s.LastDeepVerify.Value.ToLocalTime().ToString("yyyy-MM-dd HH:mm") : LocalizationService.Instance.Get("verify_never");
    }

    [RelayCommand]
    public async Task RunDeepVerificationAsync()
    {
        var rt = ActiveRuntime;
        if (rt is null || IsVerifying) return;
        IsVerifying = true;
        IntegrityIssues.Clear();
        StatusMessage = LocalizationService.Instance.Get("verify_running");

        try
        {
            var report = await Task.Run(() => rt.Engine.Verify());
            foreach (var issue in report.Issues) IntegrityIssues.Add(issue);

            var s = SettingsService.Instance.GetGroup(rt.Group.Id);
            s.LastDeepVerify = report.Timestamp;
            SettingsService.Instance.Save();
            LastDeepVerifyText = report.Timestamp.ToLocalTime().ToString("yyyy-MM-dd HH:mm");
            IntegrityStatusText = report.IsHealthy ? LocalizationService.Instance.Get("verify_status_healthy") : string.Format(LocalizationService.Instance.Get("verify_status_issues"), report.Issues.Count);

            var run = new VerifyRun
            {
                Id = Guid.NewGuid().ToString("N")[..8],
                GroupId = rt.Group.Id,
                Timestamp = report.Timestamp,
                FilesChecked = report.FilesChecked,
                IssuesFound = report.Issues.Count,
                Success = report.IsHealthy,
                Summary = string.Format(LocalizationService.Instance.Get("verify_summary_fmt"), report.FilesChecked, report.Issues.Count)
            };
            VerifyRuns.Insert(0, run);
            StatusMessage = run.Summary;
        }
        catch (Exception ex)
        {
            StatusMessage = string.Format(LocalizationService.Instance.Get("sync_error"), ex.Message);
        }
        finally
        {
            IsVerifying = false;
        }
    }

    // --- Settings Section ---
    public void LoadGroupSettings()
    {
        if (SelectedGroupItem is null) return;
        var s = SettingsService.Instance.GetGroup(SelectedGroupItem.Id);
        IsConflictKeepBoth = s.ConflictPolicy == ConflictPolicy.KeepBoth;
        IsConflictNewerWins = s.ConflictPolicy == ConflictPolicy.NewerWins;

        PresetSystemJunk = s.ExcludePresets.Contains(ExcludePreset.SystemJunk);
        PresetOfficeLock = s.ExcludePresets.Contains(ExcludePreset.OfficeLock);
        PresetDevArtifacts = s.ExcludePresets.Contains(ExcludePreset.DevArtifacts);
        PresetBuildOutputs = s.ExcludePresets.Contains(ExcludePreset.BuildOutputs);
        PresetOfficeTemp = s.ExcludePresets.Contains(ExcludePreset.OfficeTemp);
        PresetCloudPlaceholder = s.ExcludePresets.Contains(ExcludePreset.CloudPlaceholder);

        AutoExcludeNestedGroups = s.AutoExcludeNestedGroups;
        CloudSpaceSaving = s.CloudSpaceSaving;
        IsGroupPaused = s.IsPaused;
        UpdateGroupStatusBadge();
    }

    public void SaveCurrentGroupSettings()
    {
        if (SelectedGroupItem is null) return;
        var s = SettingsService.Instance.GetGroup(SelectedGroupItem.Id);
        s.ConflictPolicy = IsConflictNewerWins ? ConflictPolicy.NewerWins : ConflictPolicy.KeepBoth;

        var presets = new List<ExcludePreset>();
        if (PresetSystemJunk) presets.Add(ExcludePreset.SystemJunk);
        if (PresetOfficeLock) presets.Add(ExcludePreset.OfficeLock);
        if (PresetDevArtifacts) presets.Add(ExcludePreset.DevArtifacts);
        if (PresetBuildOutputs) presets.Add(ExcludePreset.BuildOutputs);
        if (PresetOfficeTemp) presets.Add(ExcludePreset.OfficeTemp);
        if (PresetCloudPlaceholder) presets.Add(ExcludePreset.CloudPlaceholder);
        s.ExcludePresets = presets;

        s.AutoExcludeNestedGroups = AutoExcludeNestedGroups;
        s.CloudSpaceSaving = CloudSpaceSaving;
        SettingsService.Instance.Save();

        var rt = ActiveRuntime;
        if (rt != null) SettingsService.Instance.ApplyToEngine(rt.Group.Id, rt.Engine);
    }

    // --- Sync Trigger ---
    [RelayCommand]
    public async Task TriggerSyncAsync()
    {
        if (IsSyncing) return;
        IsSyncing = true;
        UpdateGroupStatusBadge();
        StatusMessage = LocalizationService.Instance.Get("sync_running");

        try
        {
            var actions = 0;
            var allOk = true;
            foreach (var rt in _groups.Runtimes)
            {
                var s = SettingsService.Instance.GetGroup(rt.Group.Id);
                if (s.IsPaused) continue;

                SettingsService.Instance.ApplyToEngine(rt.Group.Id, rt.Engine);
                var report = await Task.Run(() => rt.Engine.SyncAll());
                actions += report.Actions;
                allOk &= report.IsSuccess;

                if (report.PendingConfirmation != null && !PendingConfirmations.Any(p => p.Id == report.PendingConfirmation.Id))
                {
                    PendingConfirmations.Add(report.PendingConfirmation);
                }

                if (rt.Group.Id == SelectedGroupItem?.Id)
                {
                    foreach (var note in report.Notes) RecentLogs.Insert(0, CoreMessages.Localize(note));
                }
            }
            LoadEndpoints();
            LoadConflicts();
            LoadVersions();
            StatusMessage = allOk
                ? string.Format(LocalizationService.Instance.Get("sync_done"), actions)
                : LocalizationService.Instance.Get("sync_done_partial");
        }
        catch (Exception ex)
        {
            StatusMessage = string.Format(LocalizationService.Instance.Get("sync_error"), ex.Message);
        }
        finally
        {
            IsSyncing = false;
            UpdateGroupStatusBadge();
        }
    }
}
