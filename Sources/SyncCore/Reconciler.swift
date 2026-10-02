import Foundation

public enum Decision: Equatable, Sendable {
    /// Nothing changed anywhere.
    case noop
    /// The endpoint changed alone (edit, create or delete): record it as the new consensus and fan out.
    case adoptEndpoint
    /// Only the others changed: bring the endpoint up to the consensus (a nil consensus means delete, via Trash).
    case applyConsensus
    /// Both sides already hold the same content: just record the alignment.
    case markSeen
    /// Both sides changed to different content: keep both versions.
    case conflict
}

public enum Reconciler {
    /// Pure three-way decision for one path on one endpoint. Works unchanged for an endpoint
    /// that was offline (an ejected disk edited elsewhere): `seenRev` stays behind while the
    /// consensus moves on, so both kinds of change are detected independently.
    public static func decide(_ obs: PathObservation, consensus: ConsensusEntry?) -> Decision {
        let endpointChanged = obs.current != obs.snapshot
        let cons = consensus ?? ConsensusEntry(state: nil, rev: 0)
        let consensusChanged = cons.rev > obs.seenRev

        switch (endpointChanged, consensusChanged) {
        case (false, false):
            return .noop
        case (true, false):
            return .adoptEndpoint
        case (false, true):
            return .applyConsensus
        case (true, true):
            if obs.current == cons.state { return .markSeen }
            // Delete vs. modify: the modification always wins, in both directions.
            if obs.current == nil { return .applyConsensus }
            if cons.state == nil { return .adoptEndpoint }
            return .conflict
        }
    }
}

/// Guards against turning "disk missing / wrong disk / wiped folder" into mass deletion.
public struct DeletionGuard: Sendable {
    public var maxAbsolute: Int
    public var maxFraction: Double
    /// Below this many tracked files a percentage is meaningless (1 of 3 files is not an incident).
    public var minTrackedForFraction: Int

    public init(maxAbsolute: Int = 25, maxFraction: Double = 0.25, minTrackedForFraction: Int = 20) {
        self.maxAbsolute = maxAbsolute
        self.maxFraction = maxFraction
        self.minTrackedForFraction = minTrackedForFraction
    }

    /// True when the planned deletions (distinct files, not replicas) need explicit confirmation before running.
    public func requiresConfirmation(plannedDeletions: Int, totalTracked: Int) -> Bool {
        guard plannedDeletions > 0 else { return false }
        if plannedDeletions > maxAbsolute { return true }
        guard totalTracked >= minTrackedForFraction else { return false }
        return Double(plannedDeletions) / Double(totalTracked) > maxFraction
    }
}
