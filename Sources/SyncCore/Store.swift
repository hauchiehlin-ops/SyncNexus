import Foundation

public enum EndpointRole: String, Sendable { case mirror, archive }

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
    /// `.archive`: receive-only backup. Changes made inside it are never sent out, files deleted elsewhere are kept, and every
    /// replaced version is kept in `.syncnexus-history` inside the folder.
    public var role: EndpointRole
    /// App Sandbox Security-Scoped Bookmark for persistent access permissions.
    public var bookmarkData: Data?

    public init(id: String, root: String, removable: Bool = false, portableNames: Bool = false,
                uuid: String = UUID().uuidString, volumeUUID: String? = nil, role: EndpointRole = .mirror,
                bookmarkData: Data? = nil) {
        self.id = id; self.root = root; self.removable = removable
        self.portableNames = portableNames; self.uuid = uuid; self.volumeUUID = volumeUUID; self.role = role
        self.bookmarkData = bookmarkData
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

public struct JournalRecord: Sendable {
    public var id: Int64
    public var time: String
    public var op: String
    public var endpoint: String
    public var path: String
    public var detail: String
    public var status: String
    public var size: Int64
    public var duration: Double
    public var speed: Double
    public var sourceEndpoint: String

    public init(id: Int64, time: String, op: String, endpoint: String, path: String, detail: String = "", status: String, size: Int64 = 0, duration: Double = 0, speed: Double = 0, sourceEndpoint: String = "") {
        self.id = id
        self.time = time
        self.op = op
        self.endpoint = endpoint
        self.path = path
        self.detail = detail
        self.status = status
        self.size = size
        self.duration = duration
        self.speed = speed
        self.sourceEndpoint = sourceEndpoint
    }
}

public final class Store {
    public let db: Database
    public let path: String

    public init(path: String) throws {
        self.path = path
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
        // `fold` = case-folded path, indexed: incremental runs must find every spelling of a path, not just the exact one.
        try addColumnIfMissing("endpoints", "role", "TEXT NOT NULL DEFAULT 'mirror'")
        try addColumnIfMissing("endpoints", "bookmark_data", "TEXT")
        try addColumnIfMissing("consensus", "fold", "TEXT NOT NULL DEFAULT ''")
        try addColumnIfMissing("ep_state", "fold", "TEXT NOT NULL DEFAULT ''")
        try addColumnIfMissing("journal", "size", "INTEGER NOT NULL DEFAULT 0")
        try addColumnIfMissing("journal", "duration", "REAL NOT NULL DEFAULT 0")
        try addColumnIfMissing("journal", "speed", "REAL NOT NULL DEFAULT 0")
        try addColumnIfMissing("journal", "source_ep", "TEXT NOT NULL DEFAULT ''")
        try backfillFold(table: "consensus", keyColumns: "path")
        try backfillFold(table: "ep_state", keyColumns: "endpoint, path")
        try db.exec("CREATE INDEX IF NOT EXISTS consensus_fold ON consensus(fold); CREATE INDEX IF NOT EXISTS ep_state_fold ON ep_state(endpoint, fold);")
    }

    private func backfillFold(table: String, keyColumns: String) throws {
        let missing = try db.query("SELECT \(keyColumns) FROM \(table) WHERE fold = ''")
        guard !missing.isEmpty else { return }
        try db.transaction {
            for r in missing {
                let path = r.last!.textValue!
                if table == "consensus" { try db.exec("UPDATE consensus SET fold=? WHERE path=?", [.text(PortableName.fold(path)), .text(path)]) }
                else { try db.exec("UPDATE ep_state SET fold=? WHERE endpoint=? AND path=?", [.text(PortableName.fold(path)), r[0], .text(path)]) }
            }
        }
    }

    private func addColumnIfMissing(_ table: String, _ column: String, _ ddl: String) throws {
        let cols = try db.query("PRAGMA table_info(\(table))").compactMap { $0[1].textValue }
        if !cols.contains(column) { try db.exec("ALTER TABLE \(table) ADD COLUMN \(column) \(ddl)") }
    }

    // MARK: integrity and backup of the state database itself

    /// SQLite's own consistency check; "ok" means the file is sound.
    public func quickCheck() -> Bool {
        (try? db.query("PRAGMA quick_check").first?[0].textValue) == "ok"
    }

    /// A consistent, compacted copy of the database (safe while the app is running).
    public func backup(to url: URL) throws {
        try? FileManager.default.removeItem(at: url)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let quoted = url.path.replacingOccurrences(of: "'", with: "''")
        try db.exec("VACUUM INTO '\(quoted)'")
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

    /// Drops everything written since the last commit (used by tests to emulate a crash).
    public func rollbackBatch() {
        guard inBatch else { return }
        inBatch = false
        _ = try? db.exec("ROLLBACK")
    }

    private func wrote() throws {
        guard inBatch else { return }
        pendingWrites += 1
        if pendingWrites >= 500 { try db.exec("COMMIT"); try db.exec("BEGIN"); pendingWrites = 0 }
    }

    // MARK: endpoints

    public func addEndpoint(_ e: EndpointConfig) throws {
        try db.exec("INSERT OR REPLACE INTO endpoints(id, root, removable, portable, uuid, volume_uuid, role, bookmark_data) VALUES(?,?,?,?,?,?,?,?)",
                    [.text(e.id), .text(e.root), .int(e.removable ? 1 : 0), .int(e.portableNames ? 1 : 0),
                     .text(e.uuid), e.volumeUUID.map { .text($0) } ?? .null, .text(e.role.rawValue),
                     e.bookmarkData.map { .text($0.base64EncodedString()) } ?? .null])
    }

    public func endpoints() throws -> [EndpointConfig] {
        try db.query("SELECT id, root, removable, portable, uuid, volume_uuid, role, bookmark_data FROM endpoints ORDER BY rowid").map {
            EndpointConfig(id: $0[0].textValue!, root: $0[1].textValue!, removable: $0[2].intValue == 1,
                           portableNames: $0[3].intValue == 1, uuid: $0[4].textValue!, volumeUUID: $0[5].textValue,
                           role: EndpointRole(rawValue: $0[6].textValue ?? "") ?? .mirror,
                           bookmarkData: $0[7].textValue.flatMap { Data(base64Encoded: $0) })
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
        try db.exec("INSERT OR REPLACE INTO consensus(path, hash, size, rev, kind, moved_from, fold) VALUES(?,?,?,?,?,?,?)",
                    [.text(path), state.map { .text($0.hash) } ?? .null, .int(state?.size ?? 0), .int(Int64(rev)),
                     .int(state?.kind == .directory ? 1 : 0), movedFrom.map { .text($0) } ?? .null, .text(PortableName.fold(path))])
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

    /// `path` itself and everything below it, for each prefix (index range scan, not a table scan).
    private static func prefixClause(_ column: String, _ prefixes: [String]) -> (sql: String, params: [SQLValue]) {
        var parts: [String] = [], params: [SQLValue] = []
        for raw in prefixes {
            let p = PortableName.fold(raw)
            parts.append("(\(column) = ? OR (\(column) >= ? AND \(column) < ?))")
            params += [.text(p), .text(p + "/"), .text(p + "0")]       // '0' is the character after '/'
        }
        return (parts.isEmpty ? "0" : parts.joined(separator: " OR "), params)
    }

    public func consensusPaths(under prefixes: [String]) throws -> [String] {
        let c = Store.prefixClause("fold", prefixes)
        return try db.query("SELECT path FROM consensus WHERE " + c.sql, c.params).map { $0[0].textValue! }
    }

    public func rows(_ endpoint: String, under prefixes: [String]) throws -> [String: EndpointRow] {
        let c = Store.prefixClause("fold", prefixes)
        var out: [String: EndpointRow] = [:]
        for r in try db.query("SELECT path, hash, size, mtime_ns, seen_rev, kind FROM ep_state WHERE endpoint=? AND (" + c.sql + ")", [.text(endpoint)] + c.params) {
            out[r[0].textValue!] = Store.decode(Array(r.dropFirst()))
        }
        return out
    }

    public func trackedFileCount(_ endpoint: String) throws -> Int {
        Int(try db.query("SELECT COUNT(*) FROM ep_state WHERE endpoint=? AND hash IS NOT NULL AND kind=0", [.text(endpoint)])[0][0].intValue!)
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
        try db.exec("INSERT OR REPLACE INTO ep_state(endpoint, path, hash, size, mtime_ns, seen_rev, kind, fold) VALUES(?,?,?,?,?,?,?,?)",
                    [.text(endpoint), .text(path), state.map { .text($0.hash) } ?? .null,
                     .int(state?.size ?? 0), .int(mtimeNs), .int(Int64(seenRev)), .int(state?.kind == .directory ? 1 : 0), .text(PortableName.fold(path))])
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
    public func relinkEndpoint(id: String, root: String, volumeUUID: String?, bookmarkData: Data? = nil) throws {
        try db.transaction {
            try db.exec("UPDATE endpoints SET root=?, uuid=?, volume_uuid=?, bookmark_data=? WHERE id=?",
                        [.text(root), .text(UUID().uuidString), volumeUUID.map { .text($0) } ?? .null,
                         bookmarkData.map { .text($0.base64EncodedString()) } ?? .null, .text(id)])
            try db.exec("DELETE FROM ep_state WHERE endpoint=?", [.text(id)])
        }
    }

    public func updateBookmark(forRoot root: String, bookmarkData: Data) throws {
        try db.exec("UPDATE endpoints SET bookmark_data=? WHERE root=?",
                    [.text(bookmarkData.base64EncodedString()), .text(root)])
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

    public func journalBegin(op: String, endpoint: String, path: String, detail: String = "",
                             size: Int64 = 0, duration: Double = 0, speed: Double = 0, sourceEndpoint: String = "") throws -> Int64 {
        try db.exec("INSERT INTO journal(ts, op, endpoint, path, detail, status, size, duration, speed, source_ep) VALUES(?,?,?,?,?, 'pending', ?, ?, ?, ?)",
                    [.text(ISO8601DateFormatter().string(from: Date())), .text(op), .text(endpoint), .text(path), .text(detail),
                     .int(size), .double(duration), .double(speed), .text(sourceEndpoint)])
        try wrote()
        return db.lastInsertRowID
    }

    public func journalEnd(_ id: Int64, status: String, size: Int64? = nil, duration: Double? = nil, speed: Double? = nil, sourceEndpoint: String? = nil) throws {
        if let size = size, let duration = duration, let speed = speed {
            let src = sourceEndpoint ?? ""
            try db.exec("UPDATE journal SET status=?, size=?, duration=?, speed=?, source_ep=? WHERE id=?",
                        [.text(status), .int(size), .double(duration), .double(speed), .text(src), .int(id)])
        } else {
            try db.exec("UPDATE journal SET status=? WHERE id=?", [.text(status), .int(id)])
        }
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

    public func recentJournalRecords(limit: Int = 1000) throws -> [JournalRecord] {
        try db.query("SELECT id, ts, op, endpoint, path, detail, status, size, duration, speed, source_ep FROM journal ORDER BY id DESC LIMIT \(limit)").map {
            JournalRecord(
                id: $0[0].intValue ?? 0,
                time: $0[1].textValue ?? "",
                op: $0[2].textValue ?? "",
                endpoint: $0[3].textValue ?? "",
                path: $0[4].textValue ?? "",
                detail: $0[5].textValue ?? "",
                status: $0[6].textValue ?? "",
                size: $0[7].intValue ?? 0,
                duration: $0[8].doubleValue ?? 0,
                speed: $0[9].doubleValue ?? 0,
                sourceEndpoint: $0[10].textValue ?? ""
            )
        }
    }

    private func journal(where clause: String, limit: Int) throws -> [JournalEntry] {
        try db.query("SELECT id, ts, op, endpoint, path, status FROM journal WHERE \(clause) ORDER BY id DESC LIMIT \(limit)").map {
            JournalEntry(id: $0[0].intValue!, time: $0[1].textValue!, op: $0[2].textValue!,
                         endpoint: $0[3].textValue!, path: $0[4].textValue!, status: $0[5].textValue!)
        }
    }
}
