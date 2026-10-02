import Foundation

public struct EndpointConfig: Sendable, Equatable {
    public var id: String
    public var root: String
    /// Can disappear at any time (external disk). Missing or foreign content is never read as "everything deleted".
    public var removable: Bool
    /// Must obey Windows / exFAT file name rules.
    public var portableNames: Bool
    /// Written to `.syncnexus-endpoint` inside the root; proves this is still the same folder.
    public var uuid: String
    public var volumeUUID: String?

    public init(id: String, root: String, removable: Bool = false, portableNames: Bool = false,
                uuid: String = UUID().uuidString, volumeUUID: String? = nil) {
        self.id = id; self.root = root; self.removable = removable
        self.portableNames = portableNames; self.uuid = uuid; self.volumeUUID = volumeUUID
    }
}

public struct EndpointRow: Sendable {
    public var state: FileState?
    public var mtimeNs: Int64
    public var seenRev: Int
}

public struct ConflictRecord: Sendable {
    public var id: Int64, endpoint: String, path: String, conflictPath: String, detected: String
}

public struct JournalEntry: Sendable {
    public var id: Int64, time: String, op: String, endpoint: String, path: String, status: String
}

public final class Store {
    public let db: Database

    public init(path: String) throws {
        db = try Database(path: path)
        try db.exec("""
        CREATE TABLE IF NOT EXISTS endpoints(
          id TEXT PRIMARY KEY, root TEXT NOT NULL, removable INTEGER NOT NULL, portable INTEGER NOT NULL,
          uuid TEXT NOT NULL, volume_uuid TEXT);
        CREATE TABLE IF NOT EXISTS consensus(
          path TEXT PRIMARY KEY, hash TEXT, size INTEGER NOT NULL, rev INTEGER NOT NULL);
        CREATE TABLE IF NOT EXISTS ep_state(
          endpoint TEXT NOT NULL, path TEXT NOT NULL, hash TEXT, size INTEGER NOT NULL,
          mtime_ns INTEGER NOT NULL, seen_rev INTEGER NOT NULL, PRIMARY KEY(endpoint, path));
        CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY, value TEXT NOT NULL);
        CREATE TABLE IF NOT EXISTS conflicts(
          id INTEGER PRIMARY KEY AUTOINCREMENT, endpoint TEXT NOT NULL, path TEXT NOT NULL,
          conflict_path TEXT NOT NULL, detected TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'open');
        CREATE TABLE IF NOT EXISTS journal(
          id INTEGER PRIMARY KEY AUTOINCREMENT, ts TEXT NOT NULL, op TEXT NOT NULL,
          endpoint TEXT NOT NULL, path TEXT NOT NULL, detail TEXT, status TEXT NOT NULL);
        """)
        try addColumnIfMissing("consensus", "kind", "INTEGER NOT NULL DEFAULT 0")
        try addColumnIfMissing("consensus", "moved_from", "TEXT")
        try addColumnIfMissing("ep_state", "kind", "INTEGER NOT NULL DEFAULT 0")
    }

    private func addColumnIfMissing(_ table: String, _ column: String, _ ddl: String) throws {
        let cols = try db.query("PRAGMA table_info(\(table))").compactMap { $0[1].textValue }
        if !cols.contains(column) { try db.exec("ALTER TABLE \(table) ADD COLUMN \(column) \(ddl)") }
    }

    // MARK: batching (one commit per ~500 writes instead of one fsync per write)

    private var inBatch = false
    private var pendingWrites = 0

    public func beginBatch() throws {
        guard !inBatch else { return }
        try db.exec("BEGIN"); inBatch = true; pendingWrites = 0
    }

    public func endBatch() throws {
        guard inBatch else { return }
        inBatch = false
        try db.exec("COMMIT")
    }

    private func wrote() throws {
        guard inBatch else { return }
        pendingWrites += 1
        if pendingWrites >= 500 { try db.exec("COMMIT"); try db.exec("BEGIN"); pendingWrites = 0 }
    }

    // MARK: endpoints

    public func addEndpoint(_ e: EndpointConfig) throws {
        try db.exec("INSERT OR REPLACE INTO endpoints VALUES(?,?,?,?,?,?)",
                    [.text(e.id), .text(e.root), .int(e.removable ? 1 : 0), .int(e.portableNames ? 1 : 0),
                     .text(e.uuid), e.volumeUUID.map { .text($0) } ?? .null])
    }

    public func endpoints() throws -> [EndpointConfig] {
        try db.query("SELECT id, root, removable, portable, uuid, volume_uuid FROM endpoints ORDER BY rowid").map {
            EndpointConfig(id: $0[0].textValue!, root: $0[1].textValue!, removable: $0[2].intValue == 1,
                           portableNames: $0[3].intValue == 1, uuid: $0[4].textValue!, volumeUUID: $0[5].textValue)
        }
    }

    // MARK: consensus

    private static func state(hash: SQLValue, size: SQLValue, kind: SQLValue) -> FileState? {
        hash.textValue.map { FileState(kind: kind.intValue == 1 ? .directory : .file, hash: $0, size: size.intValue ?? 0) }
    }

    public func consensus(_ path: String) throws -> ConsensusEntry? {
        guard let r = try db.query("SELECT hash, size, rev, kind, moved_from FROM consensus WHERE path=?", [.text(path)]).first else { return nil }
        return ConsensusEntry(state: Store.state(hash: r[0], size: r[1], kind: r[3]), rev: Int(r[2].intValue ?? 0), movedFrom: r[4].textValue)
    }

    public func setConsensus(_ path: String, state: FileState?, rev: Int, movedFrom: String? = nil) throws {
        try db.exec("INSERT OR REPLACE INTO consensus(path, hash, size, rev, kind, moved_from) VALUES(?,?,?,?,?,?)",
                    [.text(path), state.map { .text($0.hash) } ?? .null, .int(state?.size ?? 0), .int(Int64(rev)),
                     .int(state?.kind == .directory ? 1 : 0), movedFrom.map { .text($0) } ?? .null])
        try wrote()
    }

    /// Consensus entries created by a rename (see `ConsensusEntry.movedFrom`).
    public func movedEntries() throws -> [(path: String, entry: ConsensusEntry)] {
        try db.query("SELECT path, hash, size, rev, kind, moved_from FROM consensus WHERE moved_from IS NOT NULL AND hash IS NOT NULL").map {
            ($0[0].textValue!, ConsensusEntry(state: Store.state(hash: $0[1], size: $0[2], kind: $0[4]), rev: Int($0[3].intValue ?? 0), movedFrom: $0[5].textValue))
        }
    }

    public func consensusPaths() throws -> [String] {
        try db.query("SELECT path FROM consensus").map { $0[0].textValue! }
    }

    public func consensusCount() throws -> Int {
        Int(try db.query("SELECT COUNT(*) FROM consensus")[0][0].intValue!)
    }

    public func liveConsensusCount() throws -> Int {
        Int(try db.query("SELECT COUNT(*) FROM consensus WHERE hash IS NOT NULL AND kind=0")[0][0].intValue!)
    }

    // MARK: per-endpoint snapshot

    public func row(_ endpoint: String, _ path: String) throws -> EndpointRow? {
        try db.query("SELECT hash, size, mtime_ns, seen_rev, kind FROM ep_state WHERE endpoint=? AND path=?",
                     [.text(endpoint), .text(path)]).first.map(Store.decode)
    }

    public func rows(_ endpoint: String) throws -> [String: EndpointRow] {
        var out: [String: EndpointRow] = [:]
        for r in try db.query("SELECT path, hash, size, mtime_ns, seen_rev, kind FROM ep_state WHERE endpoint=?", [.text(endpoint)]) {
            out[r[0].textValue!] = Store.decode(Array(r.dropFirst()))
        }
        return out
    }

    private static func decode(_ r: [SQLValue]) -> EndpointRow {
        EndpointRow(state: state(hash: r[0], size: r[1], kind: r[4]), mtimeNs: r[2].intValue ?? 0, seenRev: Int(r[3].intValue ?? 0))
    }

    public func setRow(_ endpoint: String, _ path: String, state: FileState?, mtimeNs: Int64, seenRev: Int) throws {
        try db.exec("INSERT OR REPLACE INTO ep_state(endpoint, path, hash, size, mtime_ns, seen_rev, kind) VALUES(?,?,?,?,?,?,?)",
                    [.text(endpoint), .text(path), state.map { .text($0.hash) } ?? .null,
                     .int(state?.size ?? 0), .int(mtimeNs), .int(Int64(seenRev)), .int(state?.kind == .directory ? 1 : 0)])
        try wrote()
    }

    /// Forget an endpoint. Files in its folder are never touched; the group simply stops syncing with it.
    public func removeEndpoint(id: String) throws {
        try db.transaction {
            try db.exec("DELETE FROM endpoints WHERE id=?", [.text(id)])
            try db.exec("DELETE FROM ep_state WHERE endpoint=?", [.text(id)])
        }
    }

    /// Point an existing endpoint at a different folder (e.g. Drive re-signed-in as another account).
    /// Its snapshots are dropped, so the new folder is treated as a newcomer: it receives what the group has,
    /// and anything it already holds is merged in. A fresh folder can never be read as "everything was deleted".
    public func relinkEndpoint(id: String, root: String, volumeUUID: String?) throws {
        try db.transaction {
            try db.exec("UPDATE endpoints SET root=?, uuid=?, volume_uuid=? WHERE id=?",
                        [.text(root), .text(UUID().uuidString), volumeUUID.map { .text($0) } ?? .null, .text(id)])
            try db.exec("DELETE FROM ep_state WHERE endpoint=?", [.text(id)])
        }
    }

    public func endpointHasHistory(_ endpoint: String) throws -> Bool {
        try db.query("SELECT 1 FROM ep_state WHERE endpoint=? LIMIT 1", [.text(endpoint)]).first != nil
    }

    // MARK: settings and conflicts

    public func meta(_ key: String) throws -> String? {
        try db.query("SELECT value FROM meta WHERE key=?", [.text(key)]).first?[0].textValue
    }

    public func setMeta(_ key: String, _ value: String) throws {
        try db.exec("INSERT OR REPLACE INTO meta VALUES(?,?)", [.text(key), .text(value)])
    }

    public func addConflict(endpoint: String, path: String, conflictPath: String, at date: Date = Date()) throws {
        try db.exec("INSERT INTO conflicts(endpoint, path, conflict_path, detected) VALUES(?,?,?,?)",
                    [.text(endpoint), .text(path), .text(conflictPath), .text(ISO8601DateFormatter().string(from: date))])
    }

    public func openConflicts() throws -> [ConflictRecord] {
        try db.query("SELECT id, endpoint, path, conflict_path, detected FROM conflicts WHERE status='open' ORDER BY id").map(Store.conflict)
    }

    public func conflict(id: Int64) throws -> ConflictRecord? {
        try db.query("SELECT id, endpoint, path, conflict_path, detected FROM conflicts WHERE id=?", [.int(id)]).first.map(Store.conflict)
    }

    public func closeConflict(id: Int64, status: String) throws {
        try db.exec("UPDATE conflicts SET status=? WHERE id=?", [.text(status), .int(id)])
    }

    private static func conflict(_ r: [SQLValue]) -> ConflictRecord {
        ConflictRecord(id: r[0].intValue!, endpoint: r[1].textValue!, path: r[2].textValue!,
                       conflictPath: r[3].textValue!, detected: r[4].textValue!)
    }

    // MARK: journal (intent first, outcome after; doubles as the activity log)

    public func journalBegin(op: String, endpoint: String, path: String, detail: String = "") throws -> Int64 {
        try db.exec("INSERT INTO journal(ts, op, endpoint, path, detail, status) VALUES(?,?,?,?,?, 'pending')",
                    [.text(ISO8601DateFormatter().string(from: Date())), .text(op), .text(endpoint), .text(path), .text(detail)])
        try wrote()
        return db.lastInsertRowID
    }

    public func journalEnd(_ id: Int64, status: String) throws {
        try db.exec("UPDATE journal SET status=? WHERE id=?", [.text(status), .int(id)])
        try wrote()
    }

    public func interruptPending() throws -> [JournalEntry] {
        let rows = try journal(where: "status='pending'", limit: 1000)
        try db.exec("UPDATE journal SET status='interrupted' WHERE status='pending'")
        return rows
    }

    public func recentJournal(limit: Int = 20) throws -> [JournalEntry] {
        try journal(where: "1=1", limit: limit)
    }

    private func journal(where clause: String, limit: Int) throws -> [JournalEntry] {
        try db.query("SELECT id, ts, op, endpoint, path, status FROM journal WHERE \(clause) ORDER BY id DESC LIMIT \(limit)").map {
            JournalEntry(id: $0[0].intValue!, time: $0[1].textValue!, op: $0[2].textValue!,
                         endpoint: $0[3].textValue!, path: $0[4].textValue!, status: $0[5].textValue!)
        }
    }
}
