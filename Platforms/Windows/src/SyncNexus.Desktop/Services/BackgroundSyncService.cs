using System.IO;
using SyncNexus.Core.Engine;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;

namespace SyncNexus.Desktop.Services;

public class BackgroundSyncService : IDisposable
{
    private readonly IStore _store;
    private readonly SyncEngine _engine;
    private readonly WindowsDeviceWatcher _deviceWatcher;
    private readonly LocalPeerDiscovery _peerDiscovery;
    private WindowsFileWatcher? _fileWatcher;
    private readonly Timer _periodicTimer;
    private readonly SemaphoreSlim _syncLock = new(1, 1);
    private bool _isDisposed;

    public event Action<SyncReport>? OnSyncCompleted;
    public event Action<string>? OnStatusChanged;

    public BackgroundSyncService(IStore store, SyncEngine engine)
    {
        _store = store;
        _engine = engine;
        _deviceWatcher = new WindowsDeviceWatcher(store);
        _peerDiscovery = new LocalPeerDiscovery();

        // 60-second periodic heartbeat
        _periodicTimer = new Timer(
            async _ => await RequestSyncAsync("定時排程"),
            null,
            TimeSpan.FromSeconds(15),
            TimeSpan.FromSeconds(60)
        );

        _deviceWatcher.OnDeviceChanged += async () =>
        {
            await RequestSyncAsync("外接磁碟變更");
        };
    }

    public void Start(IntPtr windowHandle)
    {
        _deviceWatcher.Hook(windowHandle);
        _peerDiscovery.Start();
        ReconfigureFileWatchers();
    }

    public void ReconfigureFileWatchers()
    {
        _fileWatcher?.Dispose();

        var endpoints = _store.GetEndpoints();
        var validRoots = endpoints.Select(e => e.Root).Where(Directory.Exists).ToList();

        if (validRoots.Count > 0)
        {
            _fileWatcher = new WindowsFileWatcher(
                validRoots,
                async batch =>
                {
                    var reason = batch.Full ? "檔案結構異動" : $"偵測到 {batch.Paths.Count} 處檔案變更";
                    await RequestSyncAsync(reason);
                }
            );
            _fileWatcher.Start();
        }
    }

    public async Task RequestSyncAsync(string triggerReason)
    {
        if (_isDisposed) return;
        if (!await _syncLock.WaitAsync(0))
        {
            // Another sync is currently in progress; skip or coalesce
            return;
        }

        try
        {
            OnStatusChanged?.Invoke($"同步中 ({triggerReason})...");
            var report = await Task.Run(() => _engine.SyncAll());
            OnSyncCompleted?.Invoke(report);
            OnStatusChanged?.Invoke(report.IsSuccess ? "就緒" : "部分端點離線");
        }
        catch (Exception ex)
        {
            OnStatusChanged?.Invoke($"同步錯誤：{ex.Message}");
        }
        finally
        {
            _syncLock.Release();
        }
    }

    public void Dispose()
    {
        _isDisposed = true;
        _periodicTimer.Dispose();
        _fileWatcher?.Dispose();
        _deviceWatcher.Dispose();
        _peerDiscovery.Dispose();
        _syncLock.Dispose();
    }
}
