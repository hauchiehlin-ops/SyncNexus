namespace SyncNexus.Core.IO;

public record DiscoveredCloudEndpoint(
    string Provider,
    string Path,
    bool Exists,
    string DisplayName
);

public static class CloudProviderProbe
{
    /// <summary>
    /// Probes Windows system for standard Google Drive, OneDrive, and iCloud Drive paths.
    /// </summary>
    public static List<DiscoveredCloudEndpoint> ProbeAll()
    {
        var result = new List<DiscoveredCloudEndpoint>();
        var userProfile = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);

        // 1. OneDrive
        var oneDrive = Environment.GetEnvironmentVariable("OneDrive") ??
                       Environment.GetEnvironmentVariable("OneDriveConsumer") ??
                       Path.Combine(userProfile, "OneDrive");
        if (Directory.Exists(oneDrive))
        {
            result.Add(new DiscoveredCloudEndpoint("OneDrive", oneDrive, true, "OneDrive 本機資料夾"));
        }

        // 2. Google Drive
        // Check standard virtual drive G:, H:, etc.
        foreach (var letter in new[] { "G", "H", "I", "F" })
        {
            var gDriveRoot = $@"{letter}:\My Drive";
            if (Directory.Exists(gDriveRoot))
            {
                result.Add(new DiscoveredCloudEndpoint("GoogleDrive", gDriveRoot, true, $"Google 雲端硬碟 ({letter}:)"));
                break;
            }
        }

        // Also check mirror folder under user profile
        var gDriveMirror = Path.Combine(userProfile, "Google Drive", "My Drive");
        if (Directory.Exists(gDriveMirror) && !result.Any(r => r.Provider == "GoogleDrive"))
        {
            result.Add(new DiscoveredCloudEndpoint("GoogleDrive", gDriveMirror, true, "Google 雲端硬碟 (本機鏡像)"));
        }

        // 3. iCloud Drive on Windows
        var iCloud = Path.Combine(userProfile, "iCloudDrive");
        if (Directory.Exists(iCloud))
        {
            result.Add(new DiscoveredCloudEndpoint("iCloud", iCloud, true, "iCloud 雲端硬碟 (Windows 版)"));
        }

        return result;
    }
}
