using System.Text;

namespace SyncNexus.Core.Engine;

public enum NameProblemType
{
    ForbiddenCharacter,
    ControlCharacter,
    ReservedName,
    TrailingDotOrSpace,
    ComponentTooLong,
    PathTooLong
}

public record NameProblem(NameProblemType Type, string Detail);

public static class PortableName
{
    private static readonly HashSet<char> ForbiddenChars = new()
    {
        '<', '>', ':', '"', '/', '\\', '|', '?', '*'
    };

    private static readonly HashSet<string> ReservedNames = new(StringComparer.OrdinalIgnoreCase)
    {
        "CON", "PRN", "AUX", "NUL"
    };

    static PortableName()
    {
        for (int i = 1; i <= 9; i++)
        {
            ReservedNames.Add($"COM{i}");
            ReservedNames.Add($"LPT{i}");
        }
    }

    /// <summary>
    /// Checks for portability problems in a single path component (filename or directory name).
    /// </summary>
    public static List<NameProblem> ProblemsInComponent(string name)
    {
        var problems = new List<NameProblem>();
        foreach (var ch in name)
        {
            if (ForbiddenChars.Contains(ch))
            {
                problems.Add(new NameProblem(NameProblemType.ForbiddenCharacter, ch.ToString()));
            }
            else if (ch < 0x20)
            {
                problems.Add(new NameProblem(NameProblemType.ControlCharacter, $"0x{(int)ch:X2}"));
            }
        }

        // Stem before first dot for checking reserved names
        var dotIndex = name.IndexOf('.');
        var stem = dotIndex >= 0 ? name[..dotIndex] : name;
        if (ReservedNames.Contains(stem))
        {
            problems.Add(new NameProblem(NameProblemType.ReservedName, stem));
        }

        if (name.EndsWith('.') || name.EndsWith(' '))
        {
            problems.Add(new NameProblem(NameProblemType.TrailingDotOrSpace, name));
        }

        if (name.Length > 255)
        {
            problems.Add(new NameProblem(NameProblemType.ComponentTooLong, $"{name.Length} chars"));
        }

        return problems;
    }

    /// <summary>
    /// Checks for problems in a relative path (e.g. "Project/a:b.txt").
    /// </summary>
    public static List<NameProblem> ProblemsInRelativePath(string relativePath, int rootLength = 0)
    {
        var normalized = relativePath.Replace('\\', '/');
        var components = normalized.Split('/', StringSplitOptions.RemoveEmptyEntries);
        var problems = new List<NameProblem>();

        foreach (var comp in components)
        {
            problems.AddRange(ProblemsInComponent(comp));
        }

        if (rootLength + normalized.Length + 1 > 260)
        {
            problems.Add(new NameProblem(NameProblemType.PathTooLong, $"{rootLength + normalized.Length + 1} chars"));
        }

        return problems;
    }

    /// <summary>
    /// Canonical form used for comparing names across endpoints (Unicode NFC).
    /// </summary>
    public static string Canonical(string name)
    {
        return name.Normalize(NormalizationForm.FormC);
    }

    /// <summary>
    /// Identity of a path on case-insensitive volumes: NFC and lower case.
    /// </summary>
    public static string Fold(string path)
    {
        var normalized = path.Replace('\\', '/');
        return Canonical(normalized).ToLowerInvariant();
    }
}
