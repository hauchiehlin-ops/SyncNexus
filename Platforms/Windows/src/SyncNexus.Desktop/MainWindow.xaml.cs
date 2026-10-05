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
        // creating / deleting a group changes which folders must be watched (and which icons they carry)
        _groups.GroupsChanged += () => Dispatcher.Invoke(() =>
        {
            _syncService.ReconfigureFileWatchers();
            RefreshFolderIcons();
        });

        ChkAutoStart.IsChecked = WindowsStartupHelper.IsRunAtStartup();
        Loaded += MainWindow_Loaded;
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
                UpdateTrayTooltip();   // the tray covers every group
                RefreshFolderIcons();  // diff-based: does nothing unless a folder or a group icon changed
                if (groupId != _viewModel.SelectedGroupItem?.Id) return;   // only the shown group updates the screen
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
        var dialog = new AddEndpointDialog
        {
            Owner = this
        };
        if (dialog.ShowDialog() == true && dialog.ResultConfig != null)
        {
            // the same folder must not belong to two groups, or both would sync the same files
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

    private void BtnConflicts_Click(object sender, RoutedEventArgs e)
    {
        var window = new ConflictsWindow(_viewModel.ActiveStore)
        {
            Owner = this
        };
        window.ShowDialog();
        _viewModel.LoadEndpoints();
    }

    /// <summary>Folder path -> symbol of its group, for every existing folder of every group whose icon is not the plain folder.</summary>
    private void RefreshFolderIcons()
    {
        var desired = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var rt in _groups.Runtimes)
        {
            if (rt.Group.Icon == "folder") continue;
            var symbol = GroupItemViewModel.EmojiFor(rt.Group.Icon);
            foreach (var ep in rt.Store.GetEndpoints())
            {
                if (System.IO.Directory.Exists(ep.Root)) desired[ep.Root] = symbol;
            }
        }
        _folderIcons.Sync(desired);
    }

    private void ChkFolderIcons_Click(object sender, RoutedEventArgs e)
    {
        _folderIcons.SetEnabled(ChkFolderIcons.IsChecked == true);
        RefreshFolderIcons();   // off: restores the normal icons
    }

    private void ChkAutoStart_Click(object sender, RoutedEventArgs e)
    {
        WindowsStartupHelper.SetRunAtStartup(ChkAutoStart.IsChecked == true);
    }

    private static string LanguageFile =>
        System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "SyncNexus", "language.txt");

    private static readonly AppLanguage[] LanguageOrder =
        { AppLanguage.ZhHant, AppLanguage.ZhHans, AppLanguage.En, AppLanguage.Ja, AppLanguage.Ko, AppLanguage.Th };

    /// <summary>The picker shows the language actually in use (saved choice, else the system language) instead of always "繁體中文".</summary>
    private void LoadSavedLanguage()
    {
        try
        {
            if (System.IO.File.Exists(LanguageFile) &&
                Enum.TryParse<AppLanguage>(System.IO.File.ReadAllText(LanguageFile).Trim(), out var saved))
            {
                LocalizationService.Instance.CurrentLanguage = saved;
            }
        }
        catch { /* an unreadable preference just means: follow the system language */ }
        CmbLanguage.SelectedIndex = Array.IndexOf(LanguageOrder, LocalizationService.Instance.CurrentLanguage);
    }

    private void CmbLanguage_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (CmbLanguage.SelectedIndex < 0 || CmbLanguage.SelectedIndex >= LanguageOrder.Length) return;

        LocalizationService.Instance.CurrentLanguage = LanguageOrder[CmbLanguage.SelectedIndex];
        try
        {
            System.IO.Directory.CreateDirectory(System.IO.Path.GetDirectoryName(LanguageFile)!);
            System.IO.File.WriteAllText(LanguageFile, LocalizationService.Instance.CurrentLanguage.ToString());
        }
        catch { /* not being able to remember the choice must not break switching */ }

        // this handler can fire while the XAML is still being loaded: nothing else exists yet
        if (_viewModel is null || TxtGroupTitle is null) return;

        ApplyGroupBarTexts();
        _viewModel.RefreshGroupNames();   // built-in / unnamed groups follow the language
    }

    private void NavList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        // fires once while the XAML is loading, before the panels exist
        if (EndpointsBox is null || ActivityBox is null || SettingsBar is null || StatusCard is null || GroupBar is null) return;

        var index = NavList.SelectedIndex;
        var overview = index <= 0;
        StatusCard.Visibility = GroupBar.Visibility = EndpointsBox.Visibility = overview ? Visibility.Visible : Visibility.Collapsed;
        ActivityBox.Visibility = index == 1 ? Visibility.Visible : Visibility.Collapsed;
        SettingsBar.Visibility = index == 2 ? Visibility.Visible : Visibility.Collapsed;
    }

    private void ApplyGroupBarTexts()
    {
        var loc = LocalizationService.Instance;
        UpdateTrayTooltip();
        TxtGroupTitle.Text = loc.Get("group_selector_title");
        BtnGroupNew.Content = loc.Get("group_add_button");
        ChkFolderIcons.Content = loc.Get("folder_icons_title");
        ChkFolderIcons.ToolTip = loc.Get("folder_icons_desc");
        BtnGroupRestore.Content = loc.Get("backup_restore_menu");
        BtnGroupImport.Content = loc.Get("import_legacy_button");
        BtnGroupEdit.Content = loc.Get("group_edit_title");
        BtnGroupDelete.Content = loc.Get("group_delete_button");

        // everything else on the main window follows the language too
        TxtSubtitle.Text = loc.Get("app_subtitle");
        BtnAddEndpoint.Content = "+ " + loc.Get("add_endpoint");
        BtnSyncNow.Content = loc.Get("sync_now");
        TxtTrackedLabel.Text = loc.Get("status_tracked_files");
        TxtLanLabel.Text = loc.Get("status_lan_label");
        TxtLanValue.Text = loc.Get("status_lan_online");
        EndpointsBox.Header = loc.Get("endpoints_header");
        ActivityBox.Header = loc.Get("nav_activity");
        TxtActivityEmpty.Text = loc.Get("activity_empty");
        ChkAutoStart.Content = loc.Get("autostart_title");
        TxtDaemon.Text = loc.Get("daemon_running");
        TxtFooter.Text = loc.Get("footer_status");
        NavOverview.Content = "🏠 " + loc.Get("nav_overview");
        NavActivity.Content = "📈 " + loc.Get("nav_activity");
        NavSettings.Content = "⚙️ " + loc.Get("nav_settings");
        NavBtnConflicts.Content = "⚡ " + loc.Get("nav_conflicts");
        NavBtnManual.Content = "📖 " + loc.Get("nav_manual");
        NavBtnPrivacy.Content = "🛡️ " + loc.Get("nav_privacy");
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
        // a built-in group shown in the current language starts with an empty box, not with its marker text
        var isMarker = item.Group.Id == "default" && item.DisplayName != item.Group.Name;
        var dialog = new GroupDialog("group_edit_title", isMarker ? string.Empty : item.Group.Name, item.Group.Icon,
            allowEmptyName: item.Group.Name.Length == 0 || isMarker) { Owner = this };
        if (dialog.ShowDialog() == true)
        {
            _viewModel.UpdateGroup(item.Id, dialog.ResultName.Length == 0 && isMarker ? item.Group.Name : dialog.ResultName, dialog.ResultIcon);
            RefreshFolderIcons();   // a new group icon applies to its folders right away
        }
    }

    /// <summary>Shows the automatic backups; picking one replaces the current groups (after a confirmation).</summary>
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

    /// <summary>The user picks an old settings folder; groups are merged in, configured groups are never overwritten.</summary>
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

    /// <summary>A sync group as the tray sees it: its folders with online state, open conflicts and overall health.</summary>
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

    /// <summary>Tooltip = state of the whole app across all groups.</summary>
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
