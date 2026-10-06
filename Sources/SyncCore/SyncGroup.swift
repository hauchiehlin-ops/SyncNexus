import Foundation

/// Represents a distinct synchronization task/profile comprising 2 or more endpoints.
/// Each group operates independently with its own consensus, reconciliation engine,
/// event pipeline, file lock, and history archives.
public struct SyncGroup: Codable, Identifiable, Sendable, Equatable {
    public var id: String
    public var name: String
    public var icon: String
    public var createdAt: Date
    public var retentionDays: Int
    public var customExcludes: [String]

    public init(id: String, name: String, icon: String = "folder", createdAt: Date = Date(), retentionDays: Int = 30, customExcludes: [String] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.createdAt = createdAt
        self.retentionDays = retentionDays
        self.customExcludes = customExcludes
    }

    enum CodingKeys: String, CodingKey {
        case id, name, icon, createdAt, retentionDays, customExcludes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? "default"
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "預設群組"
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "folder"
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        self.retentionDays = try container.decodeIfPresent(Int.self, forKey: .retentionDays) ?? 30
        self.customExcludes = try container.decodeIfPresent([String].self, forKey: .customExcludes) ?? []
    }
}

/// Thread-safe registry that persists and manages SyncGroups across restarts.
public final class SyncGroupRegistry: @unchecked Sendable {
    private let registryURL: URL
    private let baseAppSupportURL: URL
    private let lock = NSLock()
    private var groups: [SyncGroup] = []

    public init(baseAppSupportURL: URL) {
        self.baseAppSupportURL = baseAppSupportURL
        self.registryURL = baseAppSupportURL.appendingPathComponent("groups.json")
        load()
        backupNow()
    }

    public func allGroups() -> [SyncGroup] {
        lock.lock()
        defer { lock.unlock() }
        return groups
    }

    public func group(id: String) -> SyncGroup? {
        lock.lock()
        defer { lock.unlock() }
        return groups.first { $0.id == id }
    }

    @discardableResult
    public func addGroup(name: String, icon: String = "folder", retentionDays: Int = 30, customExcludes: [String] = []) -> SyncGroup {
        lock.lock()
        defer { lock.unlock() }
        let id = "group_" + UUID().uuidString.prefix(8).lowercased()
        let group = SyncGroup(id: id, name: name, icon: icon, createdAt: Date(), retentionDays: retentionDays, customExcludes: customExcludes)
        groups.append(group)
        save()
        return group
    }

    public func updateGroup(id: String, name: String, icon: String, customExcludes: [String]? = nil) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = groups.firstIndex(where: { $0.id == id }) else { return false }
        groups[idx].name = name
        groups[idx].icon = icon
        if let customExcludes {
            groups[idx].customExcludes = customExcludes
        }
        save()
        return true
    }

    public func removeGroup(id: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard groups.count > 1 else { return false } // Keep at least one group
        guard let idx = groups.firstIndex(where: { $0.id == id }) else { return false }
        groups.remove(at: idx)
        save()
        return true
    }

    public func dbPath(for groupId: String) -> String {
        if groupId == "default" {
            // Preserves backward compatibility with existing state.db
            return baseAppSupportURL.appendingPathComponent("state.db").path
        }
        return baseAppSupportURL.appendingPathComponent("Groups/\(groupId)/state.db").path
    }

    public func versionsURL(for groupId: String) -> URL {
        if groupId == "default" {
            return baseAppSupportURL.appendingPathComponent("Versions")
        }
        return baseAppSupportURL.appendingPathComponent("Groups/\(groupId)/Versions")
    }

    public func logURL(for groupId: String) -> URL {
        let baseLogs = DataLocations.library
            .appendingPathComponent("Logs/SyncNexus")
        if groupId == "default" {
            return baseLogs.appendingPathComponent("syncnexus.log")
        }
        return baseLogs.appendingPathComponent("syncnexus_\(groupId).log")
    }

    private func migrateFromContainerIfNeeded() {
        let fm = FileManager.default
        let path = baseAppSupportURL.standardizedFileURL.path
        let isStandardAppSupport = path.hasSuffix("/Library/Application Support/SyncNexus")
        guard DataLocations.overrideRoot == nil, isStandardAppSupport && !path.contains("/Containers/") else { return }

        let containerBase = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Containers/com.syncnexus.app/Data/Library/Application Support/SyncNexus")
        let containerGroupsURL = containerBase.appendingPathComponent("groups.json")

        guard fm.fileExists(atPath: containerGroupsURL.path) else { return }

        let decoder = JSONDecoder()
        let currentData = try? Data(contentsOf: registryURL)
        let currentGroups = currentData.flatMap { try? decoder.decode([SyncGroup].self, from: $0) } ?? []

        let containerData = try? Data(contentsOf: containerGroupsURL)
        let containerGroups = containerData.flatMap { try? decoder.decode([SyncGroup].self, from: $0) } ?? []

        let currentIsDefaultOrEmpty = currentGroups.isEmpty || (currentGroups.count == 1 && currentGroups[0].name == "預設群組" && currentGroups[0].id == "default")
        let containerHasCustomData = containerGroups.count > 1 || (containerGroups.count == 1 && containerGroups[0].name != "預設群組")

        if currentIsDefaultOrEmpty && containerHasCustomData {
            NSLog("[SyncGroupRegistry] Discovered customized sync groups in App Sandbox container. Migrating to local environment...")
            try? fm.createDirectory(at: baseAppSupportURL, withIntermediateDirectories: true)

            if fm.fileExists(atPath: registryURL.path) {
                let backupURL = registryURL.appendingPathExtension("bak")
                try? fm.removeItem(at: backupURL)
                try? fm.copyItem(at: registryURL, to: backupURL)
                try? fm.removeItem(at: registryURL)
            }
            try? fm.copyItem(at: containerGroupsURL, to: registryURL)

            let containerGroupsDir = containerBase.appendingPathComponent("Groups")
            let localGroupsDir = baseAppSupportURL.appendingPathComponent("Groups")
            if fm.fileExists(atPath: containerGroupsDir.path) && !fm.fileExists(atPath: localGroupsDir.path) {
                try? fm.copyItem(at: containerGroupsDir, to: localGroupsDir)
            }

            let containerStateDB = containerBase.appendingPathComponent("state.db")
            let localStateDB = baseAppSupportURL.appendingPathComponent("state.db")
            if fm.fileExists(atPath: containerStateDB.path) && !fm.fileExists(atPath: localStateDB.path) {
                try? fm.copyItem(at: containerStateDB, to: localStateDB)
            }
        }
    }

    private func load() {
        lock.lock()
        defer { lock.unlock() }
        let fm = FileManager.default

        migrateFromContainerIfNeeded()

        if fm.fileExists(atPath: registryURL.path) {
            do {
                let data = try Data(contentsOf: registryURL)
                let decoded = try JSONDecoder().decode([SyncGroup].self, from: data)
                if !decoded.isEmpty {
                    groups = decoded
                    return
                }
            } catch {
                NSLog("[SyncGroupRegistry] Warning: Failed to decode groups.json: \(error). Preserving existing file as backup.")
                let backupURL = registryURL.appendingPathExtension("corrupted-\(Int(Date().timeIntervalSince1970))")
                try? fm.copyItem(at: registryURL, to: backupURL)
            }
        }

        // Only create default group if file truly does not exist or is empty
        let defaultGroup = SyncGroup(id: "default", name: "預設群組", icon: "folder", createdAt: Date())
        groups = [defaultGroup]
        if !fm.fileExists(atPath: registryURL.path) {
            save()
        }
    }

    // MARK: manual import of legacy settings (sandbox-safe)

    public enum LegacyImportError: Error { case nothingFound }

    public struct LegacyImportResult: Sendable {
        public var imported: [String] = []      // group names brought in
        public var kept: [String] = []          // group names left untouched (already configured here)
        public var endpointCount = 0            // endpoints imported
    }

    /// Imports sync groups and their endpoint databases from a folder the user picked
    /// (e.g. the non-sandboxed `~/Library/Application Support/SyncNexus`). The caller must hold
    /// security-scoped access to `folder`. Groups already configured here are never overwritten.
    /// Callers must stop the running services of affected groups before calling.
    public func importLegacySettings(from folder: URL) throws -> LegacyImportResult {
        let fm = FileManager.default
        var src = folder
        if !fm.fileExists(atPath: src.appendingPathComponent("groups.json").path),
           !fm.fileExists(atPath: src.appendingPathComponent("state.db").path) {
            src = folder.appendingPathComponent("SyncNexus")
        }
        let legacyGroupsURL = src.appendingPathComponent("groups.json")
        let hasLegacyDefaultDB = fm.fileExists(atPath: src.appendingPathComponent("state.db").path)

        var legacy: [SyncGroup] = []
        if let data = try? Data(contentsOf: legacyGroupsURL) {
            legacy = (try? JSONDecoder().decode([SyncGroup].self, from: data)) ?? []
        }
        if legacy.isEmpty && hasLegacyDefaultDB {
            legacy = [SyncGroup(id: "default", name: "預設群組")]
        }
        guard !legacy.isEmpty else { throw LegacyImportError.nothingFound }

        lock.lock()
        defer { lock.unlock() }
        var result = LegacyImportResult()
        let stamp = Int(Date().timeIntervalSince1970)

        for lg in legacy {
            let srcDB = lg.id == "default" ? src.appendingPathComponent("state.db")
                                           : src.appendingPathComponent("Groups/\(lg.id)/state.db")
            guard fm.fileExists(atPath: srcDB.path),
                  let snapshot = Self.consolidatedCopy(of: srcDB) else { continue }
            defer { try? fm.removeItem(at: snapshot.deletingLastPathComponent()) }
            let incoming = Self.endpointCount(at: snapshot)
            guard incoming > 0 else { continue }

            let dest = URL(fileURLWithPath: dbPath(for: lg.id))
            let existingIdx = groups.firstIndex { $0.id == lg.id }
            if existingIdx != nil, Self.endpointCount(at: dest) > 0 {
                result.kept.append(groups[existingIdx!].name)
                continue
            }
            try fm.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
            for ext in ["", "-wal", "-shm"] {
                let f = URL(fileURLWithPath: dest.path + ext)
                if fm.fileExists(atPath: f.path) {
                    // never destroy: keep what was here as a backup
                    let bak = URL(fileURLWithPath: f.path + ".pre-import-\(stamp)")
                    try? fm.removeItem(at: bak)
                    try fm.moveItem(at: f, to: bak)
                }
            }
            try fm.copyItem(at: snapshot, to: dest)
            if let i = existingIdx {
                groups[i].name = lg.name; groups[i].icon = lg.icon; groups[i].retentionDays = lg.retentionDays
            } else {
                groups.append(lg)
            }
            result.imported.append(lg.name)
            result.endpointCount += incoming
        }
        guard !result.imported.isEmpty || !result.kept.isEmpty else { throw LegacyImportError.nothingFound }
        if !result.imported.isEmpty { save() }
        return result
    }

    /// Copies db(+wal/shm) to a private temp dir and checkpoints it, so a live WAL database yields a consistent single file.
    private static func consolidatedCopy(of db: URL) -> URL? {
        let fm = FileManager.default
        let tmp = fm.temporaryDirectory.appendingPathComponent("syncnexus-import-\(UUID().uuidString)")
        guard (try? fm.createDirectory(at: tmp, withIntermediateDirectories: true)) != nil else { return nil }
        let out = tmp.appendingPathComponent("state.db")
        do {
            for ext in ["", "-wal", "-shm"] {
                let f = URL(fileURLWithPath: db.path + ext)
                if fm.fileExists(atPath: f.path) { try fm.copyItem(at: f, to: URL(fileURLWithPath: out.path + ext)) }
            }
            let d = try Database(path: out.path)
            try d.exec("PRAGMA wal_checkpoint(TRUNCATE)")
        } catch {
            try? fm.removeItem(at: tmp)
            return nil
        }
        for ext in ["-wal", "-shm"] { try? fm.removeItem(atPath: out.path + ext) }
        return out
    }

    private static func endpointCount(at db: URL) -> Int {
        guard FileManager.default.fileExists(atPath: db.path),
              let d = try? Database(path: db.path),
              let r = try? d.query("SELECT COUNT(*) FROM endpoints"),
              let n = r.first?.first?.intValue else { return 0 }
        return Int(n)
    }

    // MARK: automatic backups & one-click restore

    public struct BackupInfo: Identifiable, Sendable {
        public var id: String { url.lastPathComponent }
        public let url: URL
        public let date: Date
        public let groupNames: [String]
        public let endpointCount: Int
    }

    private struct Manifest: Codable {
        var date: Date
        var groups: [Entry]
        var fingerprint: String
        struct Entry: Codable { var id: String; var name: String; var endpoints: Int }
    }

    private var backupsRoot: URL { baseAppSupportURL.appendingPathComponent("Backups/Registry") }
    public static let backupsToKeep = 10

    private func fingerprint() -> (String, [Manifest.Entry]) {
        var fp = (try? Data(contentsOf: registryURL)).map { String(decoding: $0, as: UTF8.self) } ?? ""
        var entries: [Manifest.Entry] = []
        for g in groups {
            let path = dbPath(for: g.id)
            var n = 0
            if let d = try? Database(path: path), FileManager.default.fileExists(atPath: path),
               let rows = try? d.query("SELECT id, root FROM endpoints ORDER BY id") {
                n = rows.count
                fp += rows.map { ($0[0].textValue ?? "") + "=" + ($0[1].textValue ?? "") }.joined(separator: ";")
            }
            entries.append(.init(id: g.id, name: g.name, endpoints: n))
        }
        return (fp, entries)
    }

    /// Snapshots groups.json and every group's state.db into Backups/Registry/<timestamp>/.
    /// Skips when nothing changed, and never lets an empty state push out good backups. Returns the backup made, if any.
    @discardableResult
    public func backupNow(force: Bool = false) -> URL? {
        lock.lock()
        defer { lock.unlock() }
        let fm = FileManager.default
        let (fp, entries) = fingerprint()
        let total = entries.reduce(0) { $0 + $1.endpoints }
        let existing = listBackupURLs()
        if !force {
            if total == 0 && !existing.isEmpty { return nil }
            if let last = existing.last, let m = readManifest(last), m.fingerprint == fp { return nil }
        }
        let fmt = DateFormatter(); fmt.dateFormat = "yyyyMMdd-HHmmss"; fmt.locale = Locale(identifier: "en_US_POSIX")
        let base = fmt.string(from: Date())
        var dir = backupsRoot.appendingPathComponent(base)
        var n = 1
        while fm.fileExists(atPath: dir.path) { n += 1; dir = backupsRoot.appendingPathComponent("\(base)-\(n)") }   // never reuse (or delete) an existing backup
        do {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
            if fm.fileExists(atPath: registryURL.path) { try fm.copyItem(at: registryURL, to: dir.appendingPathComponent("groups.json")) }
            for g in groups {
                let src = URL(fileURLWithPath: dbPath(for: g.id))
                guard fm.fileExists(atPath: src.path), let snap = Self.consolidatedCopy(of: src) else { continue }
                defer { try? fm.removeItem(at: snap.deletingLastPathComponent()) }
                let dst = g.id == "default" ? dir.appendingPathComponent("state.db")
                                            : dir.appendingPathComponent("Groups/\(g.id)/state.db")
                try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
                try fm.copyItem(at: snap, to: dst)
            }
            let enc = JSONEncoder()
            try enc.encode(Manifest(date: Date(), groups: entries, fingerprint: fp)).write(to: dir.appendingPathComponent("manifest.json"))
        } catch {
            NSLog("[SyncGroupRegistry] backup failed: \(error)")
            try? fm.removeItem(at: dir)
            return nil
        }
        // rotate: keep newest N, plus the newest backup that still holds endpoints
        let all = listBackupURLs()
        if all.count > Self.backupsToKeep {
            let keepGood = all.last { (readManifest($0)?.groups.reduce(0) { $0 + $1.endpoints } ?? 0) > 0 }
            for old in all.dropLast(Self.backupsToKeep) where old != keepGood { try? fm.removeItem(at: old) }
        }
        return dir
    }

    private func listBackupURLs() -> [URL] {
        let items = (try? FileManager.default.contentsOfDirectory(at: backupsRoot, includingPropertiesForKeys: nil)) ?? []
        return items.filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("manifest.json").path) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func readManifest(_ dir: URL) -> Manifest? {
        guard let d = try? Data(contentsOf: dir.appendingPathComponent("manifest.json")) else { return nil }
        return try? JSONDecoder().decode(Manifest.self, from: d)
    }

    /// Newest first.
    public func listBackups() -> [BackupInfo] {
        lock.lock(); defer { lock.unlock() }
        return listBackupURLs().reversed().compactMap { u in
            guard let m = readManifest(u) else { return nil }
            return BackupInfo(url: u, date: m.date, groupNames: m.groups.map(\.name), endpointCount: m.groups.reduce(0) { $0 + $1.endpoints })
        }
    }

    /// Replaces the current groups and databases with a backup. The current state is backed up first
    /// and replaced files are kept as `.pre-restore-<stamp>`. Callers must stop services first.
    public func restore(_ backup: BackupInfo) throws {
        backupNow(force: true)
        lock.lock()
        defer { lock.unlock() }
        let fm = FileManager.default
        let stamp = Int(Date().timeIntervalSince1970)
        guard let data = try? Data(contentsOf: backup.url.appendingPathComponent("groups.json")),
              let restored = try? JSONDecoder().decode([SyncGroup].self, from: data), !restored.isEmpty else {
            throw LegacyImportError.nothingFound
        }
        func replace(_ dst: URL, with src: URL) throws {
            try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
            for ext in ["", "-wal", "-shm"] {
                let f = URL(fileURLWithPath: dst.path + ext)
                if fm.fileExists(atPath: f.path) { try fm.moveItem(at: f, to: URL(fileURLWithPath: f.path + ".pre-restore-\(stamp)")) }
            }
            try fm.copyItem(at: src, to: dst)
        }
        for g in restored {
            let src = g.id == "default" ? backup.url.appendingPathComponent("state.db")
                                        : backup.url.appendingPathComponent("Groups/\(g.id)/state.db")
            if fm.fileExists(atPath: src.path) { try replace(URL(fileURLWithPath: dbPath(for: g.id)), with: src) }
        }
        try replace(registryURL, with: backup.url.appendingPathComponent("groups.json"))
        groups = restored
    }

    /// Exports current groups.json and each group's state.db to an external folder chosen by the user.
    public func exportSettings(to targetFolder: URL) throws {
        lock.lock()
        defer { lock.unlock() }
        let fm = FileManager.default
        try fm.createDirectory(at: targetFolder, withIntermediateDirectories: true)
        if fm.fileExists(atPath: registryURL.path) {
            let destGroups = targetFolder.appendingPathComponent("groups.json")
            if fm.fileExists(atPath: destGroups.path) { try? fm.removeItem(at: destGroups) }
            try fm.copyItem(at: registryURL, to: destGroups)
        }
        for g in groups {
            let src = URL(fileURLWithPath: dbPath(for: g.id))
            guard fm.fileExists(atPath: src.path), let snap = Self.consolidatedCopy(of: src) else { continue }
            defer { try? fm.removeItem(at: snap.deletingLastPathComponent()) }
            let dst = g.id == "default" ? targetFolder.appendingPathComponent("state.db")
                                        : targetFolder.appendingPathComponent("Groups/\(g.id)/state.db")
            try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
            if fm.fileExists(atPath: dst.path) { try? fm.removeItem(at: dst) }
            try fm.copyItem(at: snap, to: dst)
        }
    }

    private func save() {
        let fm = FileManager.default
        try? fm.createDirectory(at: registryURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(groups) {
            try? data.write(to: registryURL, options: .atomic)

            // If unsandboxed and container exists, keep container in sync as well
            let path = baseAppSupportURL.standardizedFileURL.path
            if DataLocations.overrideRoot == nil && path.hasSuffix("/Library/Application Support/SyncNexus") && !path.contains("/Containers/") {
                let containerBase = fm.homeDirectoryForCurrentUser
                    .appendingPathComponent("Library/Containers/com.syncnexus.app/Data/Library/Application Support/SyncNexus")
                let containerGroupsURL = containerBase.appendingPathComponent("groups.json")
                if fm.fileExists(atPath: containerBase.path) {
                    try? data.write(to: containerGroupsURL, options: .atomic)
                }
            }
        }
    }
}
