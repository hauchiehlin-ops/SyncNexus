using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using SyncNexus.Core.Engine;
using SyncNexus.Core.Model;

namespace SyncNexus.Core.IO;

public record ScannedFile(
    string Rel,
    string FullPath,
    long Size,
    long MtimeNs,
    DateTime Mtime,
    bool IsPlaceholder
);

public interface ICloudPlaceholderDetector
{
    bool IsPlaceholder(string fullPath);
}

public class WindowsCloudPlaceholderDetector : ICloudPlaceholderDetector
{
    private const int FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400;
    private const int FILE_ATTRIBUTE_OFFLINE = 0x00001000;
    private const int FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS = 0x00400000;

    public bool IsPlaceholder(string fullPath)
    {
        try
        {
            if (!File.Exists(fullPath)) return false;
            var attr = (int)File.GetAttributes(fullPath);

            if ((attr & FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS) != 0) return true;
            if ((attr & FILE_ATTRIBUTE_OFFLINE) != 0) return true;

            var name = Path.GetFileName(fullPath);
            if (name.StartsWith('.') && name.EndsWith(".icloud", StringComparison.OrdinalIgnoreCase)) return true;

            return false;
        }
        catch
        {
            return false;
        }
    }
}

public static class FileOps
{
    private static readonly ICloudPlaceholderDetector PlaceholderDetector = new WindowsCloudPlaceholderDetector();

    #region Win32 Shell Recycle Bin

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct SHFILEOPSTRUCT
    {
        public IntPtr hwnd;
        public uint wFunc;
        public string pFrom;
        public string? pTo;
        public ushort fFlags;
        public bool fAnyOperationsAborted;
        public IntPtr hNameMappings;
        public string? lpszProgressTitle;
    }

    private const uint FO_DELETE = 0x0003;
    private const ushort FOF_ALLOWUNDO = 0x0040;
    private const ushort FOF_NOCONFIRMATION = 0x0010;
    private const ushort FOF_SILENT = 0x0004;

    [DllImport("shell32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern int SHFileOperation(ref SHFILEOPSTRUCT lpFileOp);

    #endregion

    /// <summary>
    /// Computes SHA-256 hash using streaming buffer.
    /// </summary>
    public static string ComputeSha256(string filePath)
    {
        using var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
        using var sha256 = SHA256.Create();
        var hashBytes = sha256.ComputeHash(stream);
        return Convert.ToHexString(hashBytes).ToLowerInvariant();
    }

    /// <summary>
    /// Recursively scans directory, normalizing relative paths to Unicode NFC and POSIX slashes '/'.
    /// </summary>
    public static Dictionary<string, ScannedFile> ScanDirectory(string rootPath, IgnoreRules ignoreRules)
    {
        var result = new Dictionary<string, ScannedFile>(StringComparer.OrdinalIgnoreCase);
        if (!Directory.Exists(rootPath)) return result;

        var cleanRoot = Path.GetFullPath(rootPath).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        var dirInfo = new DirectoryInfo(cleanRoot);

        void ScanSubdir(DirectoryInfo dir, string currentRelPrefix)
        {
            if (ignoreRules.IsIgnored(dir.Name)) return;

            try
            {
                foreach (var file in dir.GetFiles())
                {
                    if (ignoreRules.IsIgnored(file.Name)) continue;

                    var rawRel = string.IsNullOrEmpty(currentRelPrefix) ? file.Name : $"{currentRelPrefix}/{file.Name}";
                    var relPath = PortableName.Canonical(rawRel.Replace('\\', '/'));

                    var isPlaceholder = PlaceholderDetector.IsPlaceholder(file.FullName);
                    var mtime = file.LastWriteTimeUtc;
                    var mtimeNs = mtime.Ticks * 100L;

                    result[relPath] = new ScannedFile(
                        Rel: relPath,
                        FullPath: file.FullName,
                        Size: file.Length,
                        MtimeNs: mtimeNs,
                        Mtime: mtime,
                        IsPlaceholder: isPlaceholder
                    );
                }

                foreach (var sub in dir.GetDirectories())
                {
                    var subPrefix = string.IsNullOrEmpty(currentRelPrefix) ? sub.Name : $"{currentRelPrefix}/{sub.Name}";
                    ScanSubdir(sub, subPrefix);
                }
            }
            catch (UnauthorizedAccessException)
            {
                // Skip directories without permission
            }
        }

        ScanSubdir(dirInfo, string.Empty);
        return result;
    }

    /// <summary>
    /// Copies file atomically via temporary part file, ensuring directory existence and preserving mtime.
    /// </summary>
    public static void CopyAtomically(string sourcePath, string destPath, DateTime? expectedMtime = null)
    {
        var destDir = Path.GetDirectoryName(destPath);
        if (!string.IsNullOrEmpty(destDir))
        {
            Directory.CreateDirectory(destDir);
        }

        var tempPath = Path.Combine(destDir ?? "", $".nexus-{Guid.NewGuid():N}.nexus-part");
        try
        {
            File.Copy(sourcePath, tempPath, overwrite: true);
            var mtime = expectedMtime ?? File.GetLastWriteTimeUtc(sourcePath);
            File.SetLastWriteTimeUtc(tempPath, mtime);

            if (File.Exists(destPath))
            {
                File.Replace(tempPath, destPath, null);
            }
            else
            {
                File.Move(tempPath, destPath);
            }
        }
        catch
        {
            if (File.Exists(tempPath))
            {
                try { File.Delete(tempPath); } catch { }
            }
            throw;
        }
    }

    /// <summary>
    /// Archives an existing file version to .syncnexus-history before it is replaced or deleted.
    /// </summary>
    public static void ArchiveVersion(string rootPath, string relPath)
    {
        var sourceFile = Path.Combine(rootPath, relPath);
        if (!File.Exists(sourceFile)) return;

        try
        {
            var historyDir = Path.Combine(rootPath, ".syncnexus-history");
            var stamp = DateTime.UtcNow.ToString("yyyy-MM-dd HH-mm-ss");
            var destDir = Path.Combine(historyDir, stamp, Path.GetDirectoryName(relPath) ?? "");
            Directory.CreateDirectory(destDir);

            var fileName = Path.GetFileName(relPath);
            var destFile = Path.Combine(destDir, fileName);
            File.Copy(sourceFile, destFile, overwrite: true);
        }
        catch
        {
            // Do not fail the sync if archiving encounters minor permissions issue
        }
    }

    /// <summary>
    /// Moves a file to the native Windows Recycle Bin (回收桶).
    /// If Recycle Bin is unavailable (e.g. external USB without trash), falls back to .syncnexus-history.
    /// </summary>
    public static void MoveToTrash(string filePath)
    {
        if (!File.Exists(filePath)) return;

        try
        {
            // Windows native Recycle Bin via SHFileOperationW
            var shf = new SHFILEOPSTRUCT
            {
                wFunc = FO_DELETE,
                pFrom = filePath + '\0' + '\0', // Must be double-null terminated
                fFlags = FOF_ALLOWUNDO | FOF_NOCONFIRMATION | FOF_SILENT
            };

            var res = SHFileOperation(ref shf);
            if (res == 0 && !shf.fAnyOperationsAborted && !File.Exists(filePath))
            {
                return; // Successfully moved to Windows Recycle Bin!
            }
        }
        catch
        {
            // Fallback below
        }

        // Safe Fallback: move to local .syncnexus-history folder
        try
        {
            var dir = Path.GetDirectoryName(filePath) ?? "";
            var trashDir = Path.Combine(dir, ".syncnexus-history", "trash");
            Directory.CreateDirectory(trashDir);
            var name = Path.GetFileName(filePath);
            var dest = Path.Combine(trashDir, $"{DateTime.UtcNow:yyyyMMdd_HHmmss}_{name}");
            File.Move(filePath, dest, overwrite: true);
        }
        catch
        {
            File.Delete(filePath);
        }
    }
}

public static class WindowsVolumeHelper
{
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern bool GetVolumeInformation(
        string rootPathName,
        StringBuilder? volumeNameBuffer,
        int volumeNameSize,
        out uint volumeSerialNumber,
        out uint maximumComponentLength,
        out uint fileSystemFlags,
        StringBuilder? fileSystemNameBuffer,
        int nFileSystemNameSize);

    /// <summary>
    /// Gets the Volume Serial Number string (e.g. "1A2B-3C4D") for an external disk or drive root.
    /// </summary>
    public static string? GetVolumeSerialNumber(string rootPath)
    {
        try
        {
            var driveRoot = Path.GetPathRoot(rootPath);
            if (string.IsNullOrEmpty(driveRoot)) return null;

            if (GetVolumeInformation(driveRoot, null, 0, out var serial, out _, out _, null, 0))
            {
                return $"{serial >> 16:X4}-{serial & 0xFFFF:X4}";
            }
        }
        catch
        {
            // Ignore on non-Windows test environments
        }
        return null;
    }
}
