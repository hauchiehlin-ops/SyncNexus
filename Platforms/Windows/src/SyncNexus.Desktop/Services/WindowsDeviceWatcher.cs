using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Interop;
using SyncNexus.Core.IO;
using SyncNexus.Core.Model;
using SyncNexus.Core.Storage;

namespace SyncNexus.Desktop.Services;

public class WindowsDeviceWatcher : IDisposable
{
    private const int WM_DEVICECHANGE = 0x0219;
    private const int DBT_DEVICEARRIVAL = 0x8000;
    private const int DBT_DEVICEREMOVECOMPLETE = 0x8004;

    private readonly Func<IReadOnlyList<IStore>> _stores;
    private HwndSource? _hwndSource;

    public event Action? OnDeviceChanged;

    public WindowsDeviceWatcher(Func<IReadOnlyList<IStore>> stores)
    {
        _stores = stores;
    }

    /// <summary>
    /// Hooks window message loop to capture WM_DEVICECHANGE.
    /// </summary>
    public void Hook(IntPtr windowHandle)
    {
        _hwndSource = HwndSource.FromHwnd(windowHandle);
        _hwndSource?.AddHook(WndProc);
    }

    private IntPtr WndProc(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled)
    {
        if (msg == WM_DEVICECHANGE)
        {
            var eventType = wParam.ToInt32();
            if (eventType == DBT_DEVICEARRIVAL || eventType == DBT_DEVICEREMOVECOMPLETE)
            {
                CheckDriveLetterShifts();
                OnDeviceChanged?.Invoke();
            }
        }
        return IntPtr.Zero;
    }

    /// <summary>
    /// Scans removable endpoints and aligns drive letters if an external disk changed its drive letter.
    /// (e.g. from E:\SyncNexusTest to F:\SyncNexusTest).
    /// </summary>
    public void CheckDriveLetterShifts()
    {
        foreach (var store in _stores()) CheckDriveLetterShifts(store);
    }

    private void CheckDriveLetterShifts(IStore store)
    {
        var endpoints = store.GetEndpoints().Where(e => e.Removable && !string.IsNullOrEmpty(e.VolumeUuid)).ToList();
        if (endpoints.Count == 0) return;

        var currentDrives = DriveInfo.GetDrives()
            .Where(d => d.IsReady && (d.DriveType == DriveType.Removable || d.DriveType == DriveType.Fixed))
            .ToList();

        foreach (var ep in endpoints)
        {
            var currentRoot = ep.Root;
            var currentSerial = WindowsVolumeHelper.GetVolumeSerialNumber(currentRoot);

            if (currentSerial != ep.VolumeUuid)
            {
                // The expected disk is not at currentRoot; search all ready drives
                foreach (var drive in currentDrives)
                {
                    var serial = WindowsVolumeHelper.GetVolumeSerialNumber(drive.RootDirectory.FullName);
                    if (serial == ep.VolumeUuid)
                    {
                        // Found the disk! Extract relative subfolder
                        var oldDriveRoot = Path.GetPathRoot(currentRoot);
                        var subPath = string.IsNullOrEmpty(oldDriveRoot)
                            ? ""
                            : currentRoot.Substring(oldDriveRoot.Length).TrimStart(Path.DirectorySeparatorChar);

                        var newRoot = Path.Combine(drive.RootDirectory.FullName, subPath);
                        if (Directory.Exists(newRoot))
                        {
                            ep.Root = newRoot;
                            store.SaveEndpoint(ep);
                            store.RecordJournal("remount", ep.Id, newRoot, $"Drive letter shifted to {drive.Name}", "done");
                            break;
                        }
                    }
                }
            }
        }
    }

    public void Dispose()
    {
        _hwndSource?.RemoveHook(WndProc);
        _hwndSource = null;
    }
}
