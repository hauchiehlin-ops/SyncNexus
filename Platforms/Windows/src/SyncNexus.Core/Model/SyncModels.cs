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
    long Id,
    string Endpoint,
    string Path,
    string FullPath,
    DateTime Date,
    long Size = 0,
    string Reason = "replaced"
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

public enum ConflictPolicy
{
    KeepBoth,
    NewerWins
}

public enum ExcludePreset
{
    NodeModules,
    Git,
    Databases,
    PhotosLibraries,
    BuildCaches,
    PythonEnvironments
}

public record PendingConfirmation(
    string GroupId,
    int PlannedDeletions,
    int PlannedUpdates,
    int TotalChanges,
    int ThresholdLimit,
    string Message
);

public enum PlanKind
{
    New,
    Update,
    Conflict
}

public record PlanItem(
    string Path,
    string Source,
    string Target,
    PlanKind Kind,
    bool Overwrites
);

public class PreviewReport
{
    public List<PlanItem> Items { get; set; } = new();
}

public record IntegrityIssue(
    string Endpoint,
    string Path,
    string StoredHash,
    string ActualHash
);

public record VerifyRun(
    DateTime Time,
    int Checked,
    int Issues
);

public class VerifyReport
{
    public int Checked { get; set; }
    public List<IntegrityIssue> Issues { get; set; } = new();
}

public class SyncReport
{
    public int Actions { get; set; }
    public int Work { get; set; }
    public int Skipped { get; set; }
    public int TrackedFiles { get; set; }
    public PendingConfirmation? PendingConfirmation { get; set; }
    public List<string> Offline { get; set; } = new();
    public List<string> Notes { get; set; } = new();

    public bool IsSuccess => Offline.Count == 0 && PendingConfirmation == null;
}

public record SyncGroup(
    string Id,
    string Name,
    string Icon = "folder",
    DateTime? CreatedAt = null,
    int RetentionDays = 30
);

