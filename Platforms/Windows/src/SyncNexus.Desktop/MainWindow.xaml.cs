using System.Windows;
using System.Windows.Interop;
using SyncNexus.Desktop.Services;
using SyncNexus.Desktop.ViewModels;

namespace SyncNexus.Desktop;

public partial class MainWindow : Window
{
    private readonly MainViewModel _viewModel;
    private readonly BackgroundSyncService _syncService;

    public MainWindow(MainViewModel viewModel, BackgroundSyncService syncService)
    {
        InitializeComponent();
        _viewModel = viewModel;
        _syncService = syncService;
        DataContext = viewModel;

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
}
