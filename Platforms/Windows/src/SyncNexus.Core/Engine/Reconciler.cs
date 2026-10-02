using SyncNexus.Core.Model;

namespace SyncNexus.Core.Engine;

public static class Reconciler
{
    /// <summary>
    /// Pure three-way decision for one path on one endpoint.
    /// Works unchanged for an endpoint that was offline (e.g. an ejected external disk or offline PC).
    /// </summary>
    public static Decision Decide(PathObservation obs, ConsensusEntry? consensus)
    {
        var endpointChanged = obs.Current != obs.Snapshot;
        var cons = consensus ?? new ConsensusEntry(null, 0);
        var consensusChanged = cons.Rev > obs.SeenRev;

        return (endpointChanged, consensusChanged) switch
        {
            (false, false) => Decision.Noop,
            (true, false) => Decision.AdoptEndpoint,
            (false, true) => Decision.ApplyConsensus,
            (true, true) => ResolveConcurrent(obs.Current, cons.State)
        };
    }

    private static Decision ResolveConcurrent(FileState? current, FileState? consensusState)
    {
        // Both sides already hold the same content
        if (current == consensusState) return Decision.MarkSeen;

        // Delete vs. Modify: the modification always wins in both directions!
        if (current == null) return Decision.ApplyConsensus;
        if (consensusState == null) return Decision.AdoptEndpoint;

        // Different edits on both sides: conflict!
        return Decision.Conflict;
    }
}

public class DeletionGuard
{
    public int MaxAbsolute { get; set; }
    public double MaxFraction { get; set; }
    public int MinTrackedForFraction { get; set; }

    public DeletionGuard(int maxAbsolute = 25, double maxFraction = 0.25, int minTrackedForFraction = 20)
    {
        MaxAbsolute = maxAbsolute;
        MaxFraction = maxFraction;
        MinTrackedForFraction = minTrackedForFraction;
    }

    /// <summary>
    /// True when planned deletions exceed the safety threshold and require explicit confirmation.
    /// </summary>
    public bool RequiresConfirmation(int plannedDeletions, int totalTracked)
    {
        if (plannedDeletions <= 0) return false;
        if (plannedDeletions > MaxAbsolute) return true;
        if (totalTracked < MinTrackedForFraction) return false;
        return (double)plannedDeletions / totalTracked > MaxFraction;
    }
}
