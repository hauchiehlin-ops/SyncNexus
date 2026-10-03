namespace SyncNexus.Core.Model;

public enum FileKind
{
    File,
    Directory
}

public record FileState(FileKind Kind, string Hash, long Size)
{
    public static FileState MakeFile(string hash, long size) => new(FileKind.File, hash, size);
    public static FileState MakeDirectory() => new(FileKind.Directory, string.Empty, 0);
}

public record PathObservation(FileState? Snapshot, FileState? Current, int SeenRev);

public record ConsensusEntry(FileState? State, int Rev, string? MovedFrom = null);

public enum Decision
{
    /// <summary>Nothing changed anywhere.</summary>
    Noop,
    /// <summary>The endpoint changed alone (edit, create, or delete): record as new consensus and fan out.</summary>
    AdoptEndpoint,
    /// <summary>Only other endpoints changed: bring this endpoint up to consensus (null means delete).</summary>
    ApplyConsensus,
    /// <summary>Both sides already hold the same content: record alignment.</summary>
    MarkSeen,
    /// <summary>Both sides changed to different content: keep both versions.</summary>
    Conflict
}

public record ConflictRecord(
    long Id,
    string Endpoint,
    string Path,
    string ConflictPath,
    string Detected,
    string Status = "open"
);

public record VersionItem(
    string Endpoint,
    string Path,
    string FullPath,
    DateTime Date
);

public record JournalEntry(
    long Id,
    string Ts,
    string Op,
    string Endpoint,
    string Path,
    string? Detail,
    string Status
);

public class SyncReport
{
    public int Actions { get; set; }
    public int Work { get; set; }
    public int Skipped { get; set; }
    public List<string> Offline { get; set; } = new();
    public List<string> Notes { get; set; } = new();

    public bool IsSuccess => Offline.Count == 0;
}

public record SyncGroup(
    string Id,
    string Name,
    string Icon = "folder",
    DateTime? CreatedAt = null,
    int RetentionDays = 30
);

