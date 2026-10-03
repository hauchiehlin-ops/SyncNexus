using System.IO;
using SyncNexus.Core.Engine;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;

namespace SyncNexus.Desktop.Services;

public class BackgroundSyncService : IDisposable
{
    private readonly GroupManager _groups;
    private readonly WindowsDeviceWatcher _deviceWatcher;
    private readonly LocalPeerDiscovery _peerDiscovery;
    private readonly List<WindowsFileWatcher> _fileWatchers = new();
    private readonly Timer _periodicTimer;
    private readonly SemaphoreSlim _syncLock = new(1, 1);
    private bool _isDisposed;

    /// <summary>Raised once per group after it was reconciled: (groupId, report).</summary>
    public event Action<string, SyncReport>? OnSyncCompleted;
    public event Action<string>? OnStatusChanged;

    public BackgroundSyncService(GroupManager groups)
    {
        _groups = groups;
        _deviceWatcher = new WindowsDeviceWatcher(() => _groups.Runtimes.Select(r => r.Store).ToList());
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

    /// <summary>Rebuilds the file watchers: one per group, each watching that group's folders.</summary>
    public void ReconfigureFileWatchers()
    {
        foreach (var w in _fileWatchers) w.Dispose();
        _fileWatchers.Clear();

        foreach (var rt in _groups.Runtimes)
        {
            var validRoots = rt.Store.GetEndpoints().Select(e => e.Root).Where(Directory.Exists).ToList();
            if (validRoots.Count == 0) continue;

            var watcher = new WindowsFileWatcher(
                validRoots,
                async batch =>
                {
                    var reason = batch.Full ? "檔案結構異動" : $"偵測到 {batch.Paths.Count} 處檔案變更";
                    await RequestSyncAsync(reason);
                }
            );
            watcher.Start();
            _fileWatchers.Add(watcher);
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
            var allOk = true;
            // groups are reconciled one after another; each has its own database and engine
            foreach (var rt in _groups.Runtimes)
            {
                var report = await Task.Run(() => rt.Engine.SyncAll());
                allOk &= report.IsSuccess;
                OnSyncCompleted?.Invoke(rt.Group.Id, report);
            }
            OnStatusChanged?.Invoke(allOk ? "就緒" : "部分端點離線");
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

    /// <summary>
    /// Runs an action while no reconciliation is running (waits for a running one to finish) and blocks new ones meanwhile.
    /// Used for restore / import, which replace the databases. File watchers are rebuilt afterwards.
    /// </summary>
    public async Task RunExclusiveAsync(Action action)
    {
        await _syncLock.WaitAsync();
        try
        {
            await Task.Run(action);
        }
        finally
        {
            _syncLock.Release();
        }
        ReconfigureFileWatchers();
    }

    public void Dispose()
    {
        _isDisposed = true;
        _periodicTimer.Dispose();
        foreach (var w in _fileWatchers) w.Dispose();
        _fileWatchers.Clear();
        _deviceWatcher.Dispose();
        _peerDiscovery.Dispose();
        _syncLock.Dispose();
    }
}
