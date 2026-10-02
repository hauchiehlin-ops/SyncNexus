import Foundation

/// Content identity of one path on one endpoint. `nil` wherever a `FileState?` appears means "absent".
public struct FileState: Equatable, Sendable {
    public enum Kind: Sendable { case file, directory }
    public var kind: Kind
    /// Content hash (SHA-256 hex in production). Empty for directories.
    public var hash: String
    public var size: Int64

    public init(kind: Kind = .file, hash: String, size: Int64) {
        self.kind = kind
        self.hash = hash
        self.size = size
    }
}

/// What one endpoint looks like for one path, from the engine's point of view.
public struct PathObservation: Sendable {
    /// State recorded the last time this endpoint was aligned with the consensus.
    public var snapshot: FileState?
    /// State found on disk right now.
    public var current: FileState?
    /// Consensus revision this endpoint saw at its last alignment.
    public var seenRev: Int

    public init(snapshot: FileState?, current: FileState?, seenRev: Int) {
        self.snapshot = snapshot
        self.current = current
        self.seenRev = seenRev
    }
}

/// Engine-wide agreed state of one path. `state == nil` is a tombstone (deleted).
public struct ConsensusEntry: Sendable {
    public var state: FileState?
    public var rev: Int
    /// Set when this version came into being by renaming `movedFrom`: other endpoints holding that
    /// file can rename it locally instead of transferring the content again.
    public var movedFrom: String?

    public init(state: FileState?, rev: Int, movedFrom: String? = nil) {
        self.state = state
        self.rev = rev
        self.movedFrom = movedFrom
    }
}
