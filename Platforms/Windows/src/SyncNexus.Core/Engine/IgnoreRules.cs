using SyncNexus.Core.Model;

namespace SyncNexus.Core.Engine;

public class IgnoreRules
{
    public HashSet<string> ExactNames { get; }
    public List<string> Prefixes { get; }
    public List<string> Suffixes { get; }
    public List<string> CustomPatterns { get; }
    public HashSet<ExcludePreset> EnabledPresets { get; }

    public static readonly IgnoreRules Default = new(
        exactNames: new[]
        {
            ".DS_Store", ".Trashes", ".Spotlight-V100", ".fseventsd", ".TemporaryItems",
            ".DocumentRevisions-V100", "Thumbs.db", "desktop.ini", "$RECYCLE.BIN",
            "System Volume Information", ".syncnexus-endpoint", ".localized", ".syncnexus-history",
            "Icon\r", ".syncnexus-icon.ico"   // custom folder icons (macOS "Icon\r", Windows icon file): local decoration, never synced
        },
        prefixes: new[] { "._", "~$", ".~lock.", ".nexus-" },
        suffixes: new[]
        {
            ".nexus-part", ".tmp", ".crdownload", ".part", ".tmp.drivedownload",
            ".gdoc", ".gsheet", ".gslides", ".gscript", ".gform", ".gdraw",
            ".gsite", ".gmap", ".gjam", ".gtable"
        },
        presets: Enum.GetValues<ExcludePreset>()
    );

    public IgnoreRules(
        IEnumerable<string> exactNames,
        IEnumerable<string> prefixes,
        IEnumerable<string> suffixes,
        IEnumerable<ExcludePreset>? presets = null,
        IEnumerable<string>? customPatterns = null)
    {
        ExactNames = new HashSet<string>(exactNames, StringComparer.OrdinalIgnoreCase);
        Prefixes = new List<string>(prefixes);
        Suffixes = new List<string>(suffixes);
        EnabledPresets = new HashSet<ExcludePreset>(presets ?? Enum.GetValues<ExcludePreset>());
        CustomPatterns = new List<string>(customPatterns ?? Enumerable.Empty<string>());
    }

    /// <summary>
    /// Creates a customized IgnoreRules instance with given presets and custom patterns.
    /// </summary>
    public static IgnoreRules Create(IEnumerable<ExcludePreset> presets, IEnumerable<string>? customPatterns = null)
    {
        return new IgnoreRules(
            Default.ExactNames,
            Default.Prefixes,
            Default.Suffixes,
            presets,
            customPatterns
        );
    }

    /// <summary>
    /// OS litter and partial transfers: safe to discard together with a folder that is being removed.
    /// </summary>
    public bool IsLitter(string component)
    {
        if (ExactNames.Contains(component)) return true;
        if (Prefixes.Any(p => component.StartsWith(p, StringComparison.OrdinalIgnoreCase))) return true;
        // iCloud placeholder files for evicted items look like ".name.ext.icloud"
        if (component.StartsWith('.') && component.EndsWith(".icloud", StringComparison.OrdinalIgnoreCase)) return true;
        return Suffixes.Any(s => component.EndsWith(s, StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Checks preset exclusions.
    /// </summary>
    public bool IsPresetIgnored(string component)
    {
        if (EnabledPresets.Contains(ExcludePreset.NodeModules) &&
            component.Equals("node_modules", StringComparison.OrdinalIgnoreCase))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.Git) &&
            component.Equals(".git", StringComparison.OrdinalIgnoreCase))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.Databases) &&
            (component.EndsWith("-wal", StringComparison.OrdinalIgnoreCase) ||
             component.EndsWith("-shm", StringComparison.OrdinalIgnoreCase) ||
             component.EndsWith("-journal", StringComparison.OrdinalIgnoreCase)))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.PhotosLibraries) &&
            component.EndsWith(".photoslibrary", StringComparison.OrdinalIgnoreCase))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.BuildCaches) &&
            (component.Equals(".build", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("build", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("target", StringComparison.OrdinalIgnoreCase) ||
             component.Equals(".gradle", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("bin", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("obj", StringComparison.OrdinalIgnoreCase)))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.PythonEnvironments) &&
            (component.Equals("venv", StringComparison.OrdinalIgnoreCase) ||
             component.Equals(".venv", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("__pycache__", StringComparison.OrdinalIgnoreCase) ||
             component.Equals(".pytest_cache", StringComparison.OrdinalIgnoreCase)))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.DevArtifacts) &&
            (component.Equals("node_modules", StringComparison.OrdinalIgnoreCase) ||
             component.Equals(".git", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("venv", StringComparison.OrdinalIgnoreCase) ||
             component.Equals(".venv", StringComparison.OrdinalIgnoreCase)))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.BuildOutputs) &&
            (component.Equals("bin", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("obj", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("build", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("target", StringComparison.OrdinalIgnoreCase)))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.OfficeLock) &&
            (component.StartsWith("~$", StringComparison.OrdinalIgnoreCase) ||
             component.StartsWith(".~lock.", StringComparison.OrdinalIgnoreCase)))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.OfficeTemp) &&
            component.EndsWith(".tmp", StringComparison.OrdinalIgnoreCase))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.CloudPlaceholder) &&
            component.EndsWith(".icloud", StringComparison.OrdinalIgnoreCase))
            return true;

        if (EnabledPresets.Contains(ExcludePreset.SystemJunk) &&
            (component.Equals("Thumbs.db", StringComparison.OrdinalIgnoreCase) ||
             component.Equals("desktop.ini", StringComparison.OrdinalIgnoreCase) ||
             component.Equals(".DS_Store", StringComparison.OrdinalIgnoreCase)))
            return true;

        return false;
    }

    /// <summary>
    /// Litter plus conflict copies plus preset exclusions.
    /// </summary>
    public bool IsIgnored(string component)
    {
        return IsLitter(component) || ConflictNaming.IsConflictName(component) || IsPresetIgnored(component);
    }

    /// <summary>
    /// Checks whether any part of a relative path is ignored.
    /// </summary>
    public bool IsIgnoredPath(string relativePath)
    {
        var normalized = relativePath.Replace('\\', '/');

        // Check custom patterns
        foreach (var pattern in CustomPatterns)
        {
            var p = pattern.Trim().Replace('\\', '/').Trim('/');
            if (p.Length > 0 && (normalized.Equals(p, StringComparison.OrdinalIgnoreCase) ||
                                 normalized.StartsWith(p + "/", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }
        }

        var parts = normalized.Split('/', StringSplitOptions.RemoveEmptyEntries);
        return parts.Any(IsIgnored);
    }
}
