import Foundation
import SQLite3

public enum SQLValue: Sendable {
    case null
    case int(Int64)
    case double(Double)
    case text(String)

    public var intValue: Int64? { if case .int(let v) = self { return v } else { return nil } }
    public var doubleValue: Double? {
        if case .double(let v) = self { return v }
        else if case .int(let v) = self { return Double(v) }
        else { return nil }
    }
    public var textValue: String? { if case .text(let v) = self { return v } else { return nil } }
    public var isNull: Bool { if case .null = self { return true } else { return false } }
}

public struct DBError: Error, CustomStringConvertible {
    public let description: String
}

/// Thin wrapper over the system SQLite (public domain). One connection, used from one thread at a time.
public final class Database {
    private var handle: OpaquePointer?
    private static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    public init(path: String) throws {
        let rc = sqlite3_open_v2(path, &handle, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil)
        guard rc == SQLITE_OK else { throw DBError(description: "cannot open \(path): \(String(cString: sqlite3_errstr(rc)))") }
        try exec("PRAGMA journal_mode=WAL; PRAGMA synchronous=FULL; PRAGMA busy_timeout=5000; PRAGMA cache_size=-64000; PRAGMA temp_store=MEMORY;")
    }

    deinit { sqlite3_close(handle) }

    private var lastError: String { String(cString: sqlite3_errmsg(handle)) }

    @discardableResult
    public func exec(_ sql: String, _ params: [SQLValue] = []) throws -> Int {
        if params.isEmpty {
            guard sqlite3_exec(handle, sql, nil, nil, nil) == SQLITE_OK else { throw DBError(description: lastError) }
            return Int(sqlite3_changes(handle))
        }
        _ = try run(sql, params, collect: false)
        return Int(sqlite3_changes(handle))
    }

    public func query(_ sql: String, _ params: [SQLValue] = []) throws -> [[SQLValue]] {
        try run(sql, params, collect: true)
    }

    public var lastInsertRowID: Int64 { sqlite3_last_insert_rowid(handle) }

    public func transaction<T>(_ body: () throws -> T) throws -> T {
        try exec("BEGIN IMMEDIATE")
        do {
            let r = try body()
            try exec("COMMIT")
            return r
        } catch {
            _ = try? exec("ROLLBACK")
            throw error
        }
    }

    private func run(_ sql: String, _ params: [SQLValue], collect: Bool) throws -> [[SQLValue]] {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &stmt, nil) == SQLITE_OK else { throw DBError(description: lastError) }
        defer { sqlite3_finalize(stmt) }
        for (i, p) in params.enumerated() {
            let idx = Int32(i + 1)
            switch p {
            case .null: sqlite3_bind_null(stmt, idx)
            case .int(let v): sqlite3_bind_int64(stmt, idx, v)
            case .double(let v): sqlite3_bind_double(stmt, idx, v)
            case .text(let v): sqlite3_bind_text(stmt, idx, v, -1, Database.transient)
            }
        }
        var rows: [[SQLValue]] = []
        while true {
            let rc = sqlite3_step(stmt)
            if rc == SQLITE_DONE { break }
            guard rc == SQLITE_ROW else { throw DBError(description: lastError) }
            guard collect else { continue }
            var row: [SQLValue] = []
            for c in 0..<sqlite3_column_count(stmt) {
                switch sqlite3_column_type(stmt, c) {
                case SQLITE_INTEGER: row.append(.int(sqlite3_column_int64(stmt, c)))
                case SQLITE_FLOAT: row.append(.double(sqlite3_column_double(stmt, c)))
                case SQLITE_TEXT: row.append(.text(String(cString: sqlite3_column_text(stmt, c))))
                default: row.append(.null)
                }
            }
            rows.append(row)
        }
        return rows
    }
}
