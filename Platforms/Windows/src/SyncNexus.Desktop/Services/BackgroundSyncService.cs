using SyncNexus.Desktop.Localization;
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
            async _ => await RequestSyncAsync(LocalizationService.Instance.Get("trigger_periodic")),
            null,
            TimeSpan.FromSeconds(15),
            TimeSpan.FromSeconds(60)
        );

        _deviceWatcher.OnDeviceChanged += async () =>
        {
            await RequestSyncAsync(LocalizationService.Instance.Get("trigger_drive"));
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
                    var loc = LocalizationService.Instance;
                    var reason = batch.Full ? loc.Get("trigger_structure") : string.Format(loc.Get("trigger_paths"), batch.Paths.Count);
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
            OnStatusChanged?.Invoke(string.Format(LocalizationService.Instance.Get("sync_running_fmt"), triggerReason));
            var allOk = true;
            foreach (var rt in _groups.Runtimes)
            {
                var settings = SettingsService.Instance.GetGroup(rt.Group.Id);
                if (settings.IsPaused) continue;
                SettingsService.Instance.ApplyToEngine(rt.Group.Id, rt.Engine);

                var report = await Task.Run(() => rt.Engine.SyncAll());
                allOk &= report.IsSuccess;
                OnSyncCompleted?.Invoke(rt.Group.Id, report);
            }
            OnStatusChanged?.Invoke(LocalizationService.Instance.Get(allOk ? "status_ready" : "status_partial_offline"));
        }
        catch (Exception ex)
        {
            OnStatusChanged?.Invoke(string.Format(LocalizationService.Instance.Get("sync_error"), CoreMessages.Localize(ex.Message)));
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
