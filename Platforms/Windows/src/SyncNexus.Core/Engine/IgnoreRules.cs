namespace SyncNexus.Core.Engine;

public class IgnoreRules
{
    public HashSet<string> ExactNames { get; }
    public List<string> Prefixes { get; }
    public List<string> Suffixes { get; }

    public static readonly IgnoreRules Default = new(
        exactNames: new[]
        {
            ".DS_Store", ".Trashes", ".Spotlight-V100", ".fseventsd", ".TemporaryItems",
            ".DocumentRevisions-V100", "Thumbs.db", "desktop.ini", "$RECYCLE.BIN",
            "System Volume Information", ".syncnexus-endpoint", ".localized", ".syncnexus-history"
        },
        prefixes: new[] { "._", "~$", ".~lock.", ".nexus-" },
        suffixes: new[]
        {
            ".nexus-part", ".tmp", ".crdownload", ".part", ".tmp.drivedownload",
            ".gdoc", ".gsheet", ".gslides", ".gscript", ".gform", ".gdraw",
            ".gsite", ".gmap", ".gjam", ".gtable"
        }
    );

    public IgnoreRules(IEnumerable<string> exactNames, IEnumerable<string> prefixes, IEnumerable<string> suffixes)
    {
        ExactNames = new HashSet<string>(exactNames, StringComparer.OrdinalIgnoreCase);
        Prefixes = new List<string>(prefixes);
        Suffixes = new List<string>(suffixes);
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
    /// Litter plus conflict copies (which stay on their endpoint until resolved).
    /// </summary>
    public bool IsIgnored(string component)
    {
        return IsLitter(component) || ConflictNaming.IsConflictName(component);
    }

    /// <summary>
    /// Checks whether any part of a relative path is ignored.
    /// </summary>
    public bool IsIgnoredPath(string relativePath)
    {
        var normalized = relativePath.Replace('\\', '/');
        var parts = normalized.Split('/', StringSplitOptions.RemoveEmptyEntries);
        return parts.Any(IsIgnored);
    }
}
