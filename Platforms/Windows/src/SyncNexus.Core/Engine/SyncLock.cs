namespace SyncNexus.Core.Engine;

/// <summary>
/// Cross-process file lock protecting the sync state database and active file modifications.
/// </summary>
public sealed class SyncLock : IDisposable
{
    private readonly FileStream _stream;

    private SyncLock(FileStream stream)
    {
        _stream = stream;
    }

    public static SyncLock? TryAcquire(string lockFilePath)
    {
        try
        {
            var dir = Path.GetDirectoryName(lockFilePath);
            if (!string.IsNullOrEmpty(dir)) Directory.CreateDirectory(dir);

            var stream = new FileStream(
                lockFilePath,
                FileMode.OpenOrCreate,
                FileAccess.ReadWrite,
                FileShare.None,
                bufferSize: 1,
                FileOptions.DeleteOnClose);

            return new SyncLock(stream);
        }
        catch (IOException)
        {
            return null; // Already locked by another process
        }
    }

    public static SyncLock Acquire(string lockFilePath, TimeSpan timeout)
    {
        var start = DateTime.UtcNow;
        while (DateTime.UtcNow - start < timeout)
        {
            var lk = TryAcquire(lockFilePath);
            if (lk != null) return lk;
            Thread.Sleep(100);
        }
        throw new TimeoutException($"無法獲取同步鎖定（{lockFilePath}），可能已有另一個 SyncNexus 正在對帳中。");
    }

    public void Dispose()
    {
        _stream.Dispose();
    }
}
