using System.IO;
using System.Windows;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Storage;
using SyncNexus.Desktop.Services;
using SyncNexus.Desktop.ViewModels;

namespace SyncNexus.Desktop;

public partial class App : Application
{
    private IStore? _store;
    private SyncEngine? _engine;
    private BackgroundSyncService? _syncService;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        var dbPath = Path.Combine(appData, "SyncNexus", "state.db");

        _store = new SqliteStore(dbPath);
        _engine = new SyncEngine(_store);
        _syncService = new BackgroundSyncService(_store, _engine);

        var viewModel = new MainViewModel(_store, _engine);
        var mainWindow = new MainWindow(viewModel, _syncService);
        mainWindow.Show();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _syncService?.Dispose();
        _store?.Dispose();
        base.OnExit(e);
    }
}
