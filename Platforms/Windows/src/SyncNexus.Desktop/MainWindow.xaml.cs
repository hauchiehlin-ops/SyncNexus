using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Interop;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;
using SyncNexus.Desktop.Localization;
using SyncNexus.Desktop.Services;
using SyncNexus.Desktop.ViewModels;
using SyncNexus.Desktop.Views;

namespace SyncNexus.Desktop;

public partial class MainWindow : Window
{
    private readonly MainViewModel _viewModel;
    private readonly BackgroundSyncService _syncService;
    private readonly GroupManager _groups;
    private readonly FolderIconService _folderIcons =
        new(System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SyncNexus"));

    public MainWindow(MainViewModel viewModel, BackgroundSyncService syncService, GroupManager groups)
    {
        InitializeComponent();
        _viewModel = viewModel;
        _syncService = syncService;
        _groups = groups;
        DataContext = viewModel;

        ChkFolderIcons.IsChecked = _folderIcons.Enabled;
        LoadSavedLanguage();
        ApplyGroupBarTexts();

        _groups.GroupsChanged += () => Dispatcher.Invoke(() =>
        {
            _syncService.ReconfigureFileWatchers();
            RefreshFolderIcons();
        });

        _viewModel.PendingConfirmations.CollectionChanged += (_, _) => Dispatcher.Invoke(UpdateConfirmationsCardVisibility);
        UpdateConfirmationsCardVisibility();
        _viewModel.RetentionDaysLoaded += days => Dispatcher.Invoke(() => UpdateRetentionDropdown(days));

        ChkAutoStart.IsChecked = WindowsStartupHelper.IsRunAtStartup();
        Loaded += MainWindow_Loaded;
    }

    private void UpdateConfirmationsCardVisibility()
    {
        if (CardConfirmations != null)
        {
            CardConfirmations.Visibility = _viewModel.PendingConfirmations.Count > 0 ? Visibility.Visible : Visibility.Collapsed;
        }
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        var helper = new WindowInteropHelper(this);
        _syncService.Start(helper.Handle);
        UpdateTrayTooltip();
        RefreshFolderIcons();

        _syncService.OnStatusChanged += status =>
        {
            Dispatcher.Invoke(() => _viewModel.StatusMessage = status);
        };

        _syncService.OnSyncCompleted += (groupId, report) =>
        {
            Dispatcher.Invoke(() =>
            {
                UpdateTrayTooltip();
                RefreshFolderIcons();
                if (report.PendingConfirmation != null && !_viewModel.PendingConfirmations.Any(p => p.Id == report.PendingConfirmation.Id))
                {
                    _viewModel.PendingConfirmations.Add(report.PendingConfirmation);
                    UpdateConfirmationsCardVisibility();
                }
                if (groupId != _viewModel.SelectedGroupItem?.Id) return;
                _viewModel.LoadEndpoints();
                foreach (var note in report.Notes)
                {
                    _viewModel.RecentLogs.Insert(0, CoreMessages.Localize(note));
                }
            });
        };
    }

    private void BtnAddEndpoint_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new AddEndpointDialog { Owner = this };
        if (dialog.ShowDialog() == true && dialog.ResultConfig != null)
        {
            var active = _viewModel.SelectedGroupItem;
            if (active != null && _groups.NestedInGroup(dialog.ResultConfig.Root, active.Id) != null)
            {
                MessageBox.Show(this, LocalizationService.Instance.Get("folder_nested_in_group"), "SyncNexus",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }
            var otherId = active is null ? null : _groups.GroupUsingFolder(dialog.ResultConfig.Root, active.Id);
            if (otherId != null)
            {
                var other = _viewModel.Groups.FirstOrDefault(g => g.Id == otherId)?.DisplayName ?? otherId;
                MessageBox.Show(this, string.Format(LocalizationService.Instance.Get("group_folder_in_use"), other), "SyncNexus",
                    MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            _viewModel.ActiveStore.SaveEndpoint(dialog.ResultConfig);
            RefreshFolderIcons();
            _syncService.ReconfigureFileWatchers();
            _viewModel.LoadEndpoints();
            _ = _syncService.RequestSyncAsync(LocalizationService.Instance.Get("trigger_added"));
        }
    }

    private void BtnChangeFolder_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not Button btn || btn.Tag is not string endpointId) return;
        var loc = LocalizationService.Instance;
        var dialog = new Microsoft.Win32.OpenFolderDialog
        {
            Title = loc.Get("choose_folder"),
            InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)
        };
        if (dialog.ShowDialog(this) != true || string.IsNullOrWhiteSpace(dialog.FolderName)) return;

        var newPath = dialog.FolderName;
        var active = _viewModel.SelectedGroupItem;
        if (active != null && _groups.NestedInGroup(newPath, active.Id) != null)
        {
            MessageBox.Show(this, loc.Get("folder_nested_in_group"), "SyncNexus", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }
        var otherId = active is null ? null : _groups.GroupUsingFolder(newPath, active.Id);
        if (otherId != null)
        {
            var other = _viewModel.Groups.FirstOrDefault(g => g.Id == otherId)?.DisplayName ?? otherId;
            MessageBox.Show(this, string.Format(loc.Get("group_folder_in_use"), other), "SyncNexus", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        _viewModel.ChangeEndpointFolder(endpointId, newPath);
        _syncService.ReconfigureFileWatchers();
        RefreshFolderIcons();
    }

    private void BtnRemoveEndpoint_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not Button btn || btn.Tag is not string endpointId) return;
        var loc = LocalizationService.Instance;
        var answer = MessageBox.Show(this, loc.Get("endpoint_remove_confirm_desc"),
            string.Format(loc.Get("endpoint_remove_confirm_title"), endpointId),
            MessageBoxButton.OKCancel, MessageBoxImage.Warning);

        if (answer == MessageBoxResult.OK)
        {
            _viewModel.RemoveEndpoint(endpointId);
            _syncService.ReconfigureFileWatchers();
            RefreshFolderIcons();
        }
    }

    private void BtnKeepMain_Click(object sender, RoutedEventArgs e)
    {
        if (ListConflictsView.SelectedItem is not ConflictRecord selected)
        {
            MessageBox.Show(this, LocalizationService.Instance.Get("cf_select_first"), LocalizationService.Instance.Get("dlg_hint_title"),
                MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }
        _viewModel.KeepMainConflict(selected);
    }

    private void BtnKeepConflict_Click(object sender, RoutedEventArgs e)
    {
        if (ListConflictsView.SelectedItem is not ConflictRecord selected)
        {
            MessageBox.Show(this, LocalizationService.Instance.Get("cf_select_first"), LocalizationService.Instance.Get("dlg_hint_title"),
                MessageBoxButton.OK, MessageBoxImage.Information);
            return;
        }
        _viewModel.KeepCopyConflict(selected);
    }

    private void BtnPurgeAll_Click(object sender, RoutedEventArgs e)
    {
        var loc = LocalizationService.Instance;
        var answer = MessageBox.Show(this, loc.Get("versions_purge_confirm_desc"), loc.Get("versions_purge_confirm_title"),
            MessageBoxButton.OKCancel, MessageBoxImage.Warning);
        if (answer == MessageBoxResult.OK)
        {
            _viewModel.PurgeAllVersions();
        }
    }

    private bool _suppressRetentionChanged;
    public void UpdateRetentionDropdown(int retentionDays)
    {
        if (CmbRetention is null) return;
        _suppressRetentionChanged = true;
        try
        {
            CmbRetention.SelectedIndex = retentionDays switch
            {
                7 => 0,
                30 => 1,
                90 => 2,
                0 => 3,
                _ => 1
            };
        }
        finally
        {
            _suppressRetentionChanged = false;
        }
    }

    private void CmbRetention_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_suppressRetentionChanged || CmbRetention.SelectedItem is not ComboBoxItem item) return;
        if (int.TryParse(item.Tag?.ToString(), out var days))
        {
            _viewModel.UpdateRetentionDays(days);
        }
    }

    private void SettingsChanged_Handler(object sender, RoutedEventArgs e)
    {
        _viewModel.SaveCurrentGroupSettings();
    }

    private void RefreshFolderIcons()
    {
        var desired = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var rt in _groups.Runtimes)
        {
            if (rt.Group.Icon == "folder") continue;
            var symbol = GroupItemViewModel.EmojiFor(rt.Group.Icon);
            foreach (var ep in rt.Store.GetEndpoints())
            {
                if (Directory.Exists(ep.Root)) desired[ep.Root] = symbol;
            }
        }
        _folderIcons.Sync(desired);
    }

    private void ChkFolderIcons_Click(object sender, RoutedEventArgs e)
    {
        _folderIcons.SetEnabled(ChkFolderIcons.IsChecked == true);
        RefreshFolderIcons();
    }

    private void ChkAutoStart_Click(object sender, RoutedEventArgs e)
    {
        WindowsStartupHelper.SetRunAtStartup(ChkAutoStart.IsChecked == true);
    }

    private static string LanguageFile =>
        System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SyncNexus", "language.txt");

    private static readonly AppLanguage[] LanguageOrder =
        { AppLanguage.ZhHant, AppLanguage.ZhHans, AppLanguage.En, AppLanguage.Ja, AppLanguage.Ko, AppLanguage.Th };

    private void LoadSavedLanguage()
    {
        try
        {
            if (File.Exists(LanguageFile) &&
                Enum.TryParse<AppLanguage>(File.ReadAllText(LanguageFile).Trim(), out var saved))
            {
                LocalizationService.Instance.CurrentLanguage = saved;
            }
        }
        catch { }
        CmbLanguage.SelectedIndex = Array.IndexOf(LanguageOrder, LocalizationService.Instance.CurrentLanguage);
    }

    private void CmbLanguage_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (CmbLanguage.SelectedIndex < 0 || CmbLanguage.SelectedIndex >= LanguageOrder.Length) return;

        LocalizationService.Instance.CurrentLanguage = LanguageOrder[CmbLanguage.SelectedIndex];
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(LanguageFile)!);
            File.WriteAllText(LanguageFile, LocalizationService.Instance.CurrentLanguage.ToString());
        }
        catch { }

        if (_viewModel is null || TxtSubtitle is null) return;

        ApplyGroupBarTexts();
        _viewModel.RefreshGroupNames();
    }

    private void NavList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (ViewOverview is null || ViewPreview is null || ViewFolders is null || ActivityBox is null ||
            ViewConflicts is null || ViewVersions is null || ViewVerify is null || ViewSettings is null)
            return;

        var idx = NavList.SelectedIndex;
        ViewOverview.Visibility = idx == 0 ? Visibility.Visible : Visibility.Collapsed;
        ViewPreview.Visibility = idx == 1 ? Visibility.Visible : Visibility.Collapsed;
        ViewFolders.Visibility = idx == 2 ? Visibility.Visible : Visibility.Collapsed;
        ActivityBox.Visibility = idx == 3 ? Visibility.Visible : Visibility.Collapsed;
        ViewConflicts.Visibility = idx == 4 ? Visibility.Visible : Visibility.Collapsed;
        ViewVersions.Visibility = idx == 5 ? Visibility.Visible : Visibility.Collapsed;
        ViewVerify.Visibility = idx == 6 ? Visibility.Visible : Visibility.Collapsed;
        ViewSettings.Visibility = idx == 7 ? Visibility.Visible : Visibility.Collapsed;

        if (idx == 4) _viewModel.LoadConflicts();
        if (idx == 5) _viewModel.LoadVersions();
        if (idx == 6) _viewModel.LoadIntegrityState();
        if (idx == 7) _viewModel.LoadGroupSettings();
    }

    private void ApplyGroupBarTexts()
    {
        var loc = LocalizationService.Instance;
        UpdateTrayTooltip();

        // Nav
        NavOverview.Content = "🏠 " + loc.Get("nav_overview");
        NavPreview.Content = "📋 " + loc.Get("nav_preview");
        NavFolders.Content = "📁 " + loc.Get("nav_folders");
        NavActivity.Content = "📈 " + loc.Get("nav_activity");
        NavConflicts.Content = "⚡ " + loc.Get("nav_conflicts");
        NavVersions.Content = "🕒 " + loc.Get("nav_versions");
        NavVerify.Content = "🛡️ " + loc.Get("nav_verify");
        NavSettings.Content = "⚙️ " + loc.Get("nav_settings");
        NavBtnManual.Content = "📖 " + loc.Get("nav_manual");
        NavBtnPrivacy.Content = "🛡️ " + loc.Get("nav_privacy");

        // Header
        TxtSubtitle.Text = loc.Get("app_subtitle");
        BtnAddEndpoint.Content = "+ " + loc.Get("add_endpoint");
        BtnSyncNow.Content = loc.Get("sync_now");

        // Overview
        TxtLanLabel.Text = loc.Get("status_lan_label");
        TxtLanValue.Text = loc.Get("status_lan_online");
        TxtConfirmTitle.Text = "⚠️ " + loc.Get("confirm_card_title");
        TxtConfirmDesc.Text = loc.Get("confirm_card_desc");
        BtnApproveAll.Content = loc.Get("confirm_approve_all");
        TileTrackedTitle.Text = "📁 " + loc.Get("status_tracked_files");
        TileTrackedSub.Text = loc.Get("tile_tracked_sub");
        TileVerifyTitle.Text = "🛡️ " + loc.Get("tile_verify_title");
        TileVersionsTitle.Text = "🕒 " + loc.Get("tile_versions_title");
        TxtPeerTitle.Text = loc.Get("peer_title");
        TxtPeerDesc.Text = loc.Get("peer_desc");

        // Preview
        TxtPreviewHeader.Text = loc.Get("preview_header");
        TxtPreviewDesc.Text = loc.Get("preview_desc");
        BtnRunPreview.Content = loc.Get("preview_btn_scan");
        BtnExecutePreviewSync.Content = loc.Get("preview_btn_sync");
        TxtPreviewMore.Text = loc.Get("preview_more_items");

        // Folders
        TxtGroupTitle.Text = loc.Get("group_selector_title");
        BtnGroupNew.Content = loc.Get("group_add_button");
        BtnGroupRestore.Content = loc.Get("backup_restore_menu");
        BtnGroupImport.Content = loc.Get("import_legacy_button");
        BtnGroupEdit.Content = loc.Get("group_edit_title");
        BtnGroupDelete.Content = loc.Get("group_delete_button");
        BtnTogglePause.Content = loc.Get("group_btn_pause_toggle");
        EndpointsBox.Header = loc.Get("endpoints_header");

        // Activity
        ActivityBox.Header = loc.Get("nav_activity");
        TxtActivityEmpty.Text = loc.Get("activity_empty");

        // Conflicts
        TxtConflictHeader.Text = loc.Get("cf_header");
        TxtConflictDesc.Text = loc.Get("cf_desc");
        BtnKeepMain.Content = loc.Get("cf_keep_main_btn");
        BtnKeepConflict.Content = loc.Get("cf_keep_copy_btn");

        // Versions
        TxtVersionsHeader.Text = loc.Get("versions_header");
        if (LblRetentionPolicy != null) LblRetentionPolicy.Text = loc.Get("versions_retention_policy");
        BtnPurgeExpired.Content = loc.Get("versions_btn_clean_expired");
        BtnPurgeAll.Content = loc.Get("versions_btn_clear_all");

        // Verify
        TxtVerifyHeader.Text = loc.Get("verify_header");
        BtnRunVerify.Content = loc.Get("verify_btn_start");

        // Settings
        TxtSettingConflictHeader.Text = loc.Get("settings_conflict_policy");
        RadioConflictKeepBoth.Content = loc.Get("settings_policy_keep_both");
        RadioConflictNewerWins.Content = loc.Get("settings_policy_newer_wins");
        TxtSettingPresetsHeader.Text = loc.Get("settings_presets_header");
        TxtSettingPresetsDesc.Text = loc.Get("settings_presets_desc");
        ChkPresetSystem.Content = loc.Get("settings_preset_system");
        ChkPresetOfficeLock.Content = loc.Get("settings_preset_office_lock");
        ChkPresetDev.Content = loc.Get("settings_preset_dev");
        ChkPresetBuild.Content = loc.Get("settings_preset_build");
        ChkPresetOfficeTemp.Content = loc.Get("settings_preset_office_temp");
        ChkPresetCloud.Content = loc.Get("settings_preset_cloud");
        TxtSettingAdvancedHeader.Text = loc.Get("settings_advanced_header");
        ChkAutoExcludeNested.Content = loc.Get("settings_auto_exclude_nested");
        ChkCloudSpaceSaving.Content = loc.Get("settings_cloud_space_saving");
        TxtSettingSystemHeader.Text = loc.Get("settings_system_header");
        ChkAutoStart.Content = loc.Get("autostart_title");
        ChkFolderIcons.Content = loc.Get("folder_icons_title");
        ChkFolderIcons.ToolTip = loc.Get("folder_icons_desc");

        // Footer
        TxtFooter.Text = loc.Get("footer_status");
    }

    private void BtnGroupNew_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new GroupDialog("group_add_title", string.Empty, "folder", allowEmptyName: true) { Owner = this };
        if (dialog.ShowDialog() == true)
        {
            _viewModel.CreateGroup(dialog.ResultName, dialog.ResultIcon);
        }
    }

    private void BtnGroupEdit_Click(object sender, RoutedEventArgs e)
    {
        var item = _viewModel.SelectedGroupItem;
        if (item is null) return;
        var isMarker = item.Group.Id == "default" && item.DisplayName != item.Group.Name;
        var dialog = new GroupDialog("group_edit_title", isMarker ? string.Empty : item.Group.Name, item.Group.Icon,
            allowEmptyName: item.Group.Name.Length == 0 || isMarker) { Owner = this };
        if (dialog.ShowDialog() == true)
        {
            _viewModel.UpdateGroup(item.Id, dialog.ResultName.Length == 0 && isMarker ? item.Group.Name : dialog.ResultName, dialog.ResultIcon);
            RefreshFolderIcons();
        }
    }

    private void BtnGroupRestore_Click(object sender, RoutedEventArgs e)
    {
        var loc = LocalizationService.Instance;
        var menu = new ContextMenu();
        var backups = _groups.Backups.ListBackups();
        if (backups.Count == 0)
        {
            menu.Items.Add(new MenuItem { Header = loc.Get("backup_none"), IsEnabled = false });
        }
        foreach (var b in backups)
        {
            var info = b;
            var item = new MenuItem { Header = $"{info.Date:g}　{string.Join("、", info.GroupNames)}（{info.EndpointCount}）" };
            item.Click += async (_, _) => await RestoreBackupAsync(info);
            menu.Items.Add(item);
        }
        menu.PlacementTarget = BtnGroupRestore;
        menu.IsOpen = true;
    }

    private async Task RestoreBackupAsync(BackupInfo backup)
    {
        var loc = LocalizationService.Instance;
        var answer = MessageBox.Show(this, loc.Get("backup_restore_confirm_desc"),
            string.Format(loc.Get("backup_restore_confirm_title"), $"{backup.Date:g}"),
            MessageBoxButton.OKCancel, MessageBoxImage.Question);
        if (answer != MessageBoxResult.OK) return;

        try
        {
            await _syncService.RunExclusiveAsync(() => _groups.Restore(backup));
            _viewModel.StatusMessage = string.Format(loc.Get("backup_restore_ok"), backup.GroupNames.Count, backup.EndpointCount);
        }
        catch (Exception ex)
        {
            _viewModel.StatusMessage = string.Format(loc.Get("import_legacy_failed"), ex.Message);
        }
    }

    private async void BtnGroupImport_Click(object sender, RoutedEventArgs e)
    {
        var loc = LocalizationService.Instance;
        var dialog = new Microsoft.Win32.OpenFolderDialog
        {
            Title = loc.Get("import_legacy_prompt"),
            InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData)
        };
        if (dialog.ShowDialog(this) != true) return;

        try
        {
            GroupManager.LegacyImportResult? result = null;
            await _syncService.RunExclusiveAsync(() => result = _groups.ImportLegacy(dialog.FolderName));
            _viewModel.StatusMessage = result is null || result.Imported.Count == 0
                ? loc.Get("import_legacy_nothing_new")
                : string.Format(loc.Get("import_legacy_ok"), result.Imported.Count, result.EndpointCount);
        }
        catch (LegacyImportException)
        {
            _viewModel.StatusMessage = loc.Get("import_legacy_not_found");
        }
        catch (Exception ex)
        {
            _viewModel.StatusMessage = string.Format(loc.Get("import_legacy_failed"), ex.Message);
        }
    }

    private void BtnGroupDelete_Click(object sender, RoutedEventArgs e)
    {
        var item = _viewModel.SelectedGroupItem;
        if (item is null) return;
        if (_viewModel.Groups.Count <= 1)
        {
            _viewModel.StatusMessage = LocalizationService.Instance.Get("group_cannot_delete_last");
            return;
        }

        var loc = LocalizationService.Instance;
        var answer = MessageBox.Show(this, loc.Get("group_delete_confirm_desc"),
            string.Format(loc.Get("group_delete_confirm_title"), item.DisplayName),
            MessageBoxButton.OKCancel, MessageBoxImage.Warning);
        if (answer == MessageBoxResult.OK) _viewModel.DeleteGroup(item.Id);
    }

    private void BtnManual_Click(object sender, RoutedEventArgs e)
    {
        var loc = LocalizationService.Instance;
        new DocumentViewerDialog(loc.Get("manual_title"), loc.Get("manual_body")) { Owner = this }.ShowDialog();
    }

    private void BtnPrivacy_Click(object sender, RoutedEventArgs e)
    {
        var loc = LocalizationService.Instance;
        new DocumentViewerDialog(loc.Get("privacy_title"), loc.Get("privacy_body")) { Owner = this }.ShowDialog();
    }

    #region System Tray & Close-to-Tray

    private sealed record TrayGroup(
        GroupItemViewModel Item,
        List<(string Id, string Root, bool Online)> Folders,
        int Conflicts,
        GroupHealth Health);

    private List<TrayGroup> BuildTrayGroups()
    {
        var result = new List<TrayGroup>();
        foreach (var item in _viewModel.Groups)
        {
            var rt = _groups.Get(item.Id);
            if (rt is null) continue;
            var folders = new List<(string, string, bool)>();
            foreach (var cfg in rt.Store.GetEndpoints())
            {
                var online = rt.Engine.CheckIdentity(cfg, writeMarker: false).Status == EndpointStatus.Online;
                folders.Add((cfg.Id, cfg.Root, online));
            }
            var conflicts = rt.Store.GetOpenConflicts().Count;
            var health = GroupStatusLogic.Evaluate(folders.Count, folders.Count(f => !f.Item3), conflicts);
            result.Add(new TrayGroup(item, folders, conflicts, health));
        }
        return result;
    }

    private static string HealthText(TrayGroup g)
    {
        var loc = LocalizationService.Instance;
        return g.Health switch
        {
            GroupHealth.Ok => loc.Get("tray_status_ok"),
            GroupHealth.NeedsFolders => loc.Get("tray_status_needs_folders"),
            _ => g.Conflicts > 0 ? string.Format(loc.Get("tray_conflicts"), g.Conflicts) : loc.Get("tray_status_attention")
        };
    }

    private void UpdateTrayTooltip()
    {
        var loc = LocalizationService.Instance;
        var groups = BuildTrayGroups();
        var text = GroupStatusLogic.Overall(groups.Select(g => g.Health)) switch
        {
            GroupHealth.Attention => string.Format(loc.Get("tray_tip_attention"), groups.Count(g => g.Health == GroupHealth.Attention)),
            GroupHealth.NeedsFolders => loc.Get("tray_status_needs_folders"),
            _ => loc.Get("tray_status_ok")
        };
        MyTaskbarIcon.ToolTipText = $"SyncNexus — {text}";
    }

    private void TrayMenu_Opened(object sender, RoutedEventArgs e) => RebuildTrayMenu();

    private void RebuildTrayMenu()
    {
        var loc = LocalizationService.Instance;
        TrayMenu.Items.Clear();

        var open = new MenuItem { Header = loc.Get("tray_open_main"), FontWeight = FontWeights.Bold };
        open.Click += MenuOpen_Click;
        TrayMenu.Items.Add(open);

        var sync = new MenuItem { Header = loc.Get("tray_sync_now") };
        sync.Click += MenuSync_Click;
        TrayMenu.Items.Add(sync);

        var groups = BuildTrayGroups();
        if (groups.Count > 0) TrayMenu.Items.Add(new Separator());
        foreach (var g in groups)
        {
            var header = new MenuItem
            {
                Header = $"{g.Item.IconEmoji} {g.Item.DisplayName} ({g.Folders.Count})　{HealthText(g)}",
                FontWeight = FontWeights.SemiBold
            };

            var item = g.Item;
            var view = new MenuItem { Header = loc.Get("tray_open_group") };
            view.Click += (_, _) =>
            {
                _viewModel.SelectedGroupItem = item;
                MenuOpen_Click(this, new RoutedEventArgs());
            };
            header.Items.Add(view);
            header.Items.Add(new Separator());

            if (g.Folders.Count == 0)
            {
                header.Items.Add(new MenuItem { Header = loc.Get("tray_no_folders"), IsEnabled = false });
            }
            foreach (var f in g.Folders)
            {
                header.Items.Add(new MenuItem
                {
                    Header = $"{(f.Online ? "●" : "○")} {f.Id}　{f.Root}　{(f.Online ? loc.Get("online") : loc.Get("offline"))}",
                    IsEnabled = false
                });
            }
            TrayMenu.Items.Add(header);
        }

        TrayMenu.Items.Add(new Separator());
        var exit = new MenuItem { Header = loc.Get("tray_exit") };
        exit.Click += MenuExit_Click;
        TrayMenu.Items.Add(exit);
    }

    private bool _isRealExit;

    protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
    {
        if (!_isRealExit)
        {
            e.Cancel = true;
            Hide();
            MyTaskbarIcon.ShowNotification("SyncNexus", LocalizationService.Instance.Get("tray_minimized"));
            return;
        }

        MyTaskbarIcon.Dispose();
        base.OnClosing(e);
    }

    private void MyTaskbarIcon_TrayMouseDoubleClick(object sender, RoutedEventArgs e)
    {
        Show();
        WindowState = WindowState.Normal;
        Activate();
    }

    private void MenuOpen_Click(object sender, RoutedEventArgs e)
    {
        Show();
        WindowState = WindowState.Normal;
        Activate();
    }

    private void MenuSync_Click(object sender, RoutedEventArgs e)
    {
        _ = _syncService.RequestSyncAsync(LocalizationService.Instance.Get("trigger_manual"));
    }

    private void MenuExit_Click(object sender, RoutedEventArgs e)
    {
        _isRealExit = true;
        Close();
        Application.Current.Shutdown();
    }

    #endregion
}
