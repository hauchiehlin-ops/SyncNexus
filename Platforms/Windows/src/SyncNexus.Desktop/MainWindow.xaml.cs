using System.Windows;
using System.Windows.Controls;
using System.Windows.Interop;
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
    private readonly IStore _store;

    public MainWindow(MainViewModel viewModel, BackgroundSyncService syncService, IStore store)
    {
        InitializeComponent();
        _viewModel = viewModel;
        _syncService = syncService;
        _store = store;
        DataContext = viewModel;

        ChkAutoStart.IsChecked = WindowsStartupHelper.IsRunAtStartup();
        Loaded += MainWindow_Loaded;
    }

    private void MainWindow_Loaded(object sender, RoutedEventArgs e)
    {
        var helper = new WindowInteropHelper(this);
        _syncService.Start(helper.Handle);

        _syncService.OnStatusChanged += status =>
        {
            Dispatcher.Invoke(() => _viewModel.StatusMessage = status);
        };

        _syncService.OnSyncCompleted += report =>
        {
            Dispatcher.Invoke(() =>
            {
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
            _store.SaveEndpoint(dialog.ResultConfig);
            _syncService.ReconfigureFileWatchers();
            _viewModel.LoadEndpoints();
            _ = _syncService.RequestSyncAsync("新增端點");
        }
    }

    private void BtnConflicts_Click(object sender, RoutedEventArgs e)
    {
        var window = new ConflictsWindow(_store)
        {
            Owner = this
        };
        window.ShowDialog();
        _viewModel.LoadEndpoints();
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
