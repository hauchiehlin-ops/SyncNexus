using SyncNexus.Core.Engine;

namespace SyncNexus.Core.IO;

public class WatchBatch
{
    public bool Full { get; set; }
    public HashSet<string> Paths { get; set; } = new(StringComparer.OrdinalIgnoreCase);
}

/// <summary>
/// Monitors endpoint roots with FileSystemWatcher.
/// Mirrors macOS Watcher.swift: implements quietSeconds debouncing and maxWaitSeconds forced flushing.
/// </summary>
public class WindowsFileWatcher : IDisposable
{
    private readonly List<string> _roots;
    private readonly IgnoreRules _ignoreRules;
    private readonly double _quietSeconds;
    private readonly double _maxWaitSeconds;
    private readonly Action<WatchBatch> _onChange;

    private readonly List<FileSystemWatcher> _watchers = new();
    private readonly object _lock = new();
    private Timer? _debounceTimer;
    private DateTime? _firstEventTime;
    private WatchBatch _batch = new();
    private bool _isDisposed;

    public WindowsFileWatcher(
        IEnumerable<string> roots,
        Action<WatchBatch> onChange,
        IgnoreRules? ignoreRules = null,
        double quietSeconds = 2.0,
        double maxWaitSeconds = 30.0)
    {
        _roots = roots.Where(Directory.Exists).Distinct().ToList();
        _onChange = onChange;
        _ignoreRules = ignoreRules ?? IgnoreRules.Default;
        _quietSeconds = quietSeconds;
        _maxWaitSeconds = maxWaitSeconds;
    }

    public void Start()
    {
        lock (_lock)
        {
            Stop();

            foreach (var root in _roots)
            {
                try
                {
                    var watcher = new FileSystemWatcher(root)
                    {
                        IncludeSubdirectories = true,
                        NotifyFilter = NotifyFilters.FileName |
                                     NotifyFilters.DirectoryName |
                                     NotifyFilters.LastWrite |
                                     NotifyFilters.Size,
                        InternalBufferSize = 64 * 1024 // 64KB buffer for high volume events
                    };

                    watcher.Created += OnFileSystemEvent;
                    watcher.Changed += OnFileSystemEvent;
                    watcher.Deleted += OnFileSystemEvent;
                    watcher.Renamed += OnRenamedEvent;
                    watcher.Error += (s, e) =>
                    {
                        lock (_lock)
                        {
                            _batch.Full = true;
                            ScheduleFlush();
                        }
                    };

                    watcher.EnableRaisingEvents = true;
                    _watchers.Add(watcher);
                }
                catch
                {
                    // Fallback to full sync if watcher creation fails
                    _batch.Full = true;
                }
            }
        }
    }

    public void Stop()
    {
        lock (_lock)
        {
            _debounceTimer?.Dispose();
            _debounceTimer = null;

            foreach (var w in _watchers)
            {
                w.EnableRaisingEvents = false;
                w.Dispose();
            }
            _watchers.Clear();
        }
    }

    private void OnFileSystemEvent(object sender, FileSystemEventArgs e)
    {
        HandlePathChange(e.FullPath);
    }

    private void OnRenamedEvent(object sender, RenamedEventArgs e)
    {
        HandlePathChange(e.OldFullPath);
        HandlePathChange(e.FullPath);
    }

    private void HandlePathChange(string fullPath)
    {
        var fileName = Path.GetFileName(fullPath);
        if (_ignoreRules.IsIgnored(fileName)) return;

        lock (_lock)
        {
            if (_isDisposed) return;

            _firstEventTime ??= DateTime.UtcNow;
            _batch.Paths.Add(fullPath);

            var elapsed = (DateTime.UtcNow - _firstEventTime.Value).TotalSeconds;
            if (elapsed >= _maxWaitSeconds)
            {
                FlushImmediate();
            }
            else
            {
                ScheduleFlush();
            }
        }
    }

    private void ScheduleFlush()
    {
        _debounceTimer?.Dispose();
        _debounceTimer = new Timer(
            _ => FlushImmediate(),
            null,
            TimeSpan.FromSeconds(_quietSeconds),
            Timeout.InfiniteTimeSpan
        );
    }

    private void FlushImmediate()
    {
        WatchBatch toSend;
        lock (_lock)
        {
            _debounceTimer?.Dispose();
            _debounceTimer = null;
            _firstEventTime = null;

            if (_batch.Paths.Count == 0 && !_batch.Full) return;

            toSend = _batch;
            _batch = new WatchBatch();
        }

        try
        {
            _onChange(toSend);
        }
        catch
        {
            // Suppress unhandled exceptions in callback
        }
    }

    public void Dispose()
    {
        lock (_lock)
        {
            _isDisposed = true;
            Stop();
        }
    }
}
