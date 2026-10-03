namespace SyncNexus.Core.Model;

/// <summary>Two folders overlap when they are the same or one lies inside the other: they would sync the same files twice.</summary>
public static class FolderOverlap
{
    private static string Norm(string path) =>
        Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);

    public static bool Overlaps(string a, string b)
    {
        var x = Norm(a);
        var y = Norm(b);
        var sep = Path.DirectorySeparatorChar;
        return string.Equals(x, y, StringComparison.OrdinalIgnoreCase)
            || x.StartsWith(y + sep, StringComparison.OrdinalIgnoreCase)
            || y.StartsWith(x + sep, StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>True for a folder that lies inside, or contains, the other one, but is not identical to it.</summary>
    public static bool IsNested(string a, string b) =>
        Overlaps(a, b) && !string.Equals(Norm(a), Norm(b), StringComparison.OrdinalIgnoreCase);
}
