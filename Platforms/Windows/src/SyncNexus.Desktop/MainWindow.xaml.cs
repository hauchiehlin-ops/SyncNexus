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
                    _viewModel.RecentLogs.Insert(0, note);
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
            _ = _syncService.RequestSyncAsync("新增端點");
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

    private void CmbLanguage_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (CmbLanguage.SelectedIndex < 0) return;

        LocalizationService.Instance.CurrentLanguage = CmbLanguage.SelectedIndex switch
        {
            0 => AppLanguage.ZhHant,
            1 => AppLanguage.ZhHans,
            2 => AppLanguage.En,
            3 => AppLanguage.Ja,
            4 => AppLanguage.Ko,
            5 => AppLanguage.Th,
            _ => AppLanguage.ZhHant
        };

        // this handler already fires while the XAML is still being loaded (ComboBoxItem IsSelected): nothing else exists yet
        if (_viewModel is null || TxtGroupTitle is null) return;

        ApplyGroupBarTexts();
        _viewModel.RefreshGroupNames();   // built-in / unnamed groups follow the language
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
        var title = "SyncNexus 操作使用手冊";
        var content = @"【快速上手：如何加入同步資料夾？】
點擊主畫面「新增同步端點...」，選取您準備要同步的目錄：

1. 電腦本機資料夾：
   打開「檔案總管」，點擊左側側邊欄的「文件」或進入 C: 槽選取您想要同步的資料夾。

2. iCloud 雲碟：
   打開「檔案總管」，點擊左側側邊欄的「iCloud 雲碟」圖示，選取準備要同步的資料夾。

3. Google 雲端硬碟 (Google Drive)：
   打開「檔案總管」，點擊左側側邊欄的「Google Drive」，點擊「我的雲端硬碟」，選取準備要同步的資料夾。

4. OneDrive 雲端硬碟：
   打開「檔案總管」，點擊左側側邊欄的「OneDrive」，選取準備要同步的資料夾。

5. 外接隨身碟 / 行動硬碟：
   插上隨身碟，打開「檔案總管」，點擊左側「本機」下方的隨身硬碟磁碟機代號（如 D: 或 E:），選取準備要同步的資料夾。格式建議為 ExFAT，方便同時與 Mac 互相插拔共用！

【全自動即時同步與保護】
• 平時完全免手動：任一資料夾檔案變更，2 秒內自動同步到其他所有端點。
• 衝突雙向保留：離線雙向修改時，自動另存衝突複本，絕不覆蓋您的檔案。
• 安全刪除：同步刪除時優先移入 Windows 資源回收筒，安全防手殘。";

        var dialog = new DocumentViewerDialog(title, content)
        {
            Owner = this
        };
        dialog.ShowDialog();
    }

    private void BtnPrivacy_Click(object sender, RoutedEventArgs e)
    {
        var title = "SyncNexus 隱私權保護政策";
        var content = @"【SyncNexus 隱私權承諾】

1. 100% 本地優先，無雲端中繼伺服器：
   所有檔案比對、同步傳輸與特徵碼比對皆完全在您的電腦本地執行。SyncNexus 沒有經營任何雲端伺服器，絕不會上傳您的檔案內容。

2. 嚴格遵循微軟應用商店與系統最小權限原則：
   本軟體僅存取您在選取視窗中明確指定的資料夾，絕無法擅自存取您電腦中的其他私人檔案。

3. 零診斷追蹤，零廣告，無任何資料收集：
   我們不收集檔案清單、資料夾名稱、硬體序號、IP 位址或任何分析數據。程式內未植入任何廣告追蹤 SDK 或第三方數據分析工具。

4. 安全刪除機制：優先移至系統資源回收筒：
   在進行同步刪除時，檔案會優先移至 Windows 系統「資源回收筒」而非永久抹除，確保隨時可撤銷操作。您擁有資料處置的最高決定權。";

        var dialog = new DocumentViewerDialog(title, content)
        {
            Owner = this
        };
        dialog.ShowDialog();
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
            MyTaskbarIcon.ShowNotification("SyncNexus", "已最小化至系統匣，持續在背景進行檔案即時同步與對帳。");
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
        _ = _syncService.RequestSyncAsync("手動觸發");
    }

    private void MenuExit_Click(object sender, RoutedEventArgs e)
    {
        _isRealExit = true;
        Close();
        Application.Current.Shutdown();
    }

    #endregion
}
