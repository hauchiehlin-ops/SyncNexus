using System.Globalization;
using System.Text.RegularExpressions;

namespace SyncNexus.Core.Engine;

public static class ConflictNaming
{
    private static readonly Regex ConflictRegex = new(
        @" \(conflict .+ \d{4}-\d{2}-\d{2} \d{2}-\d{2}\)(\.[^./\\]*)?$",
        RegexOptions.Compiled | RegexOptions.CultureInvariant
    );

    /// <summary>
    /// Generates conflict filename. E.g. "report.docx" -> "report (conflict Disk 2026-10-02 14-30).docx".
    /// Uses hyphen instead of colon so that it is valid on exFAT/Windows.
    /// </summary>
    public static string Name(string original, string endpoint, DateTime date)
    {
        var stamp = date.ToString("yyyy-MM-dd HH-mm", CultureInfo.InvariantCulture);
        var ext = Path.GetExtension(original);
        var stem = string.IsNullOrEmpty(ext) ? original : Path.GetFileNameWithoutExtension(original);

        var problems = PortableName.ProblemsInComponent(endpoint);
        var safeEndpoint = problems.Count == 0
            ? endpoint
            : string.Concat(endpoint.Select(c => "<>:\"/\\|?*".Contains(c) ? '_' : c));

        var suffix = $" (conflict {safeEndpoint} {stamp})";
        return string.IsNullOrEmpty(ext) ? $"{stem}{suffix}" : $"{stem}{suffix}{ext}";
    }

    /// <summary>
    /// Checks whether a filename represents an unresolved conflict copy.
    /// </summary>
    public static bool IsConflictName(string name)
    {
        return ConflictRegex.IsMatch(name);
    }
}
