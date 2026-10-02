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
}
