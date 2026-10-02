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
        var lang = LocalizationService.Instance.CurrentLanguage switch
        {
            AppLanguage.ZhHant => "zh-Hant",
            AppLanguage.ZhHans => "zh-Hant", // fallback or specific
            _ => "en"
        };
        var url = $"https://github.com/hauchiehlin-ops/SyncNexus/blob/main/docs/manual/windows/MANUAL_windows_{lang}.md";
        try
        {
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = url,
                UseShellExecute = true
            });
        }
        catch { }
    }

    private void BtnPrivacy_Click(object sender, RoutedEventArgs e)
    {
        var lang = LocalizationService.Instance.CurrentLanguage switch
        {
            AppLanguage.ZhHant => "zh-Hant",
            _ => "en"
        };
        var url = $"https://github.com/hauchiehlin-ops/SyncNexus/blob/main/docs/privacy/windows/PRIVACY_windows_{lang}.md";
        try
        {
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = url,
                UseShellExecute = true
            });
        }
        catch { }
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
