using System.Runtime.InteropServices;
using System.Security.Cryptography;
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
    // Windows file attributes
    private const int FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400;
    private const int FILE_ATTRIBUTE_OFFLINE = 0x00001000;
    private const int FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS = 0x00400000;

    public bool IsPlaceholder(string fullPath)
    {
        try
        {
            if (!File.Exists(fullPath)) return false;
            var attr = (int)File.GetAttributes(fullPath);

            // In OneDrive and Google Drive Streaming mode, uncached / unhydrated files
            // carry RECALL_ON_DATA_ACCESS or OFFLINE or REPARSE_POINT flags
            if ((attr & FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS) != 0) return true;
            if ((attr & FILE_ATTRIBUTE_OFFLINE) != 0) return true;

            // Also check for iCloud-style placeholders on Windows
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

    public static string ComputeSha256(string filePath)
    {
        using var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
        using var sha256 = SHA256.Create();
        var hashBytes = sha256.ComputeHash(stream);
        return Convert.ToHexString(hashBytes).ToLowerInvariant();
    }

    public static Dictionary<string, ScannedFile> ScanDirectory(string rootPath, IgnoreRules ignoreRules)
    {
        var result = new Dictionary<string, ScannedFile>(StringComparer.OrdinalIgnoreCase);
        if (!Directory.Exists(rootPath)) return result;

        var rootUri = new Uri(rootPath.TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar);
        var dirInfo = new DirectoryInfo(rootPath);

        void ScanSubdir(DirectoryInfo dir)
        {
            // Skip ignored directory names (e.g. .git, $RECYCLE.BIN, System Volume Information)
            if (ignoreRules.IsIgnored(dir.Name)) return;

            try
            {
                foreach (var file in dir.GetFiles())
                {
                    if (ignoreRules.IsIgnored(file.Name)) continue;

                    var fileUri = new Uri(file.FullName);
                    var relPath = Uri.UnescapeDataString(rootUri.MakeRelativeUri(fileUri).ToString()).Replace('\\', '/');

                    var isPlaceholder = PlaceholderDetector.IsPlaceholder(file.FullName);
                    var mtime = file.LastWriteTimeUtc;
                    var mtimeNs = mtime.Ticks * 100L; // DateTime.Ticks is 100ns

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
                    ScanSubdir(sub);
                }
            }
            catch (UnauthorizedAccessException)
            {
                // Skip directories without permissions
            }
        }

        ScanSubdir(dirInfo);
        return result;
    }

    /// <summary>
    /// Atomically copy file via temp file + replace.
    /// </summary>
    public static void CopyAtomically(string sourcePath, string destPath)
    {
        var destDir = Path.GetDirectoryName(destPath);
        if (!string.IsNullOrEmpty(destDir)) Directory.CreateDirectory(destDir);

        var tempPath = Path.Combine(destDir ?? "", $".nexus-{Guid.NewGuid():N}.nexus-part");
        try
        {
            File.Copy(sourcePath, tempPath, overwrite: true);
            var mtime = File.GetLastWriteTimeUtc(sourcePath);
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
    /// Safely move a file to local recycle bin / trash or rename with .trashed timestamp.
    /// </summary>
    public static void MoveToTrash(string filePath)
    {
        if (!File.Exists(filePath)) return;

        // Windows Shell IFileOperation or fallback to safe archive
        try
        {
            // Simple reliable fallback: move to .syncnexus-history / trash dir
            var dir = Path.GetDirectoryName(filePath) ?? "";
            var trashDir = Path.Combine(dir, ".syncnexus-history");
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
        System.Text.StringBuilder? volumeNameBuffer,
        int volumeNameSize,
        out uint volumeSerialNumber,
        out uint maximumComponentLength,
        out uint fileSystemFlags,
        System.Text.StringBuilder? fileSystemNameBuffer,
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
