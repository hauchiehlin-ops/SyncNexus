using System.IO;
using System.Windows;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Storage;
using SyncNexus.Desktop.Services;
using SyncNexus.Desktop.ViewModels;

namespace SyncNexus.Desktop;

public partial class App : Application
{
    private GroupManager? _groups;
    private BackgroundSyncService? _syncService;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        _groups = new GroupManager(Path.Combine(appData, "SyncNexus"));
        _syncService = new BackgroundSyncService(_groups);

        var viewModel = new MainViewModel(_groups);
        var mainWindow = new MainWindow(viewModel, _syncService, _groups);
        mainWindow.Show();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _syncService?.Dispose();
        _groups?.Dispose();
        base.OnExit(e);
    }
}
