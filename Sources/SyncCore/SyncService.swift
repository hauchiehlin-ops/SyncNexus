import Foundation

/// Long-running owner of the engine: watches the endpoints, debounces events, runs syncs one at a time,
/// and publishes a snapshot for UIs. All engine and database access happens on one serial queue.
public final class SyncService: @unchecked Sendable {
    public enum Phase: Sendable { case idle, syncing, paused }

    public struct EndpointStatus: Sendable {
        public var id: String, root: String, online: Bool, detail: String
        public var removable = false, portableNames = false
    }

    /// An open conflict: the file in sync with the other endpoints (`mainPath`) and the extra copy kept on one endpoint.
    public struct ConflictItem: Sendable, Identifiable {
        public var id: Int64
        public var endpoint: String
        public var endpointOnline: Bool
        public var path: String
        public var mainPath: String
        public var extraPath: String
        public var mainSize: Int64?, extraSize: Int64?
        public var mainModified: Date?, extraModified: Date?
    }

    public struct Activity: Sendable, Identifiable {
        public var id: Int64
        public var time: Date
        public var op: String
        public var endpoint: String
        public var path: String
        public var ok: Bool
    }

    public struct Confirmation: Sendable {
        public var reason: String
        public var preview: [String]
    }

    public struct Snapshot: Sendable {
        public var phase: Phase = .idle
        public var lastRun: Date?
        public var lastWork = 0
        public var endpoints: [EndpointStatus] = []
        public var trackedFiles = 0
        public var confirmation: Confirmation?
        public var skipped: [String] = []
        public var recent: [Activity] = []
        public var conflicts: [ConflictItem] = []
        public var versions = VersionsUsage()
        public var versionsRetentionDays = 30
        /// Health: when everything last synced with nothing skipped, and the results of the periodic deep verification.
        public var lastCleanSync: Date?
        public var lastDeepVerify: Date?
        public var integrityIssues: [String] = []
        public var conflictPolicy: ConflictPolicy = .keepBoth
        public var error: String?
        public static let initial = Snapshot()
    }

    private let queue = DispatchQueue(label: "syncnexus.service")
    private let dbPath: String
    private let versionsDir: URL
    private let logURL: URL?
    private let onUpdate: @Sendable (Snapshot) -> Void
    private let periodic: TimeInterval

    private var engine: Engine?
    private var watcher: Watcher?
    private var watchedRoots: [String] = []
    private var timer: DispatchSourceTimer?
    private var snapshot = Snapshot()
    private var running = false
    private var rerun = false
    private var rerunConfirmed = false
    private var lastMaintenance = Date.distantPast
    private var forceDeepVerify = false

    public init(dbPath: String, versionsDir: URL, logURL: URL?, periodicSeconds: TimeInterval = 300,
                onUpdate: @escaping @Sendable (Snapshot) -> Void) {
        self.dbPath = dbPath
        self.versionsDir = versionsDir
        self.logURL = logURL
        self.periodic = periodicSeconds
        self.onUpdate = onUpdate
    }

    // MARK: control

    public func start() {
        queue.async {
            do {
                try FileManager.default.createDirectory(atPath: (self.dbPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
                if let log = self.logURL { try FileManager.default.createDirectory(at: log.deletingLastPathComponent(), withIntermediateDirectories: true) }
                var opts = EngineOptions()
                opts.versionsDir = self.versionsDir
                opts.log = { [weak self] in self?.writeLog($0) }
                self.engine = Engine(store: try self.openStoreRecovering(), options: opts)
            } catch {
                self.snapshot.error = "無法開啟資料庫：\(error)"
                self.publish()
                return
            }
            let t = DispatchSource.makeTimerSource(queue: self.queue)
            t.schedule(deadline: .now() + self.periodic, repeating: self.periodic)
            t.setEventHandler { [weak self] in self?.runIfNeeded(confirmed: false) }
            t.resume()
            self.timer = t
            self.runIfNeeded(confirmed: false)
        }
    }

    /// Opens the state database; if it is damaged, keeps the damaged file for inspection and restores the newest daily backup.
    /// Even a fresh database is safe: with no history every endpoint is treated as a newcomer, so files are merged, never deleted.
    private func openStoreRecovering() throws -> Store {
        if let s = try? Store(path: dbPath), s.quickCheck() { return s }
        let fm = FileManager.default
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        for ext in ["", "-wal", "-shm"] where fm.fileExists(atPath: dbPath + ext) {
            try? fm.moveItem(atPath: dbPath + ext, toPath: dbPath + ".corrupt-\(stamp)" + ext)
        }
        let backups = ((try? fm.contentsOfDirectory(atPath: backupsDir.path)) ?? []).filter { $0.hasSuffix(".db") }.sorted()
        if let newest = backups.last {
            try fm.copyItem(at: backupsDir.appendingPathComponent(newest), to: URL(fileURLWithPath: dbPath))
            writeLog("狀態資料庫損壞，已保留損壞檔並從備份 \(newest) 還原；下一輪同步會重新比對（只會合併，不會刪除）")
            if let s = try? Store(path: dbPath), s.quickCheck() { return s }
            for ext in ["", "-wal", "-shm"] { try? fm.removeItem(atPath: dbPath + ext) }
        }
        writeLog("狀態資料庫損壞且沒有可用備份，已建立新的資料庫；端點需要重新加入，加入後只會合併，不會刪除")
        return try Store(path: dbPath)
    }

    private var backupsDir: URL { URL(fileURLWithPath: (dbPath as NSString).deletingLastPathComponent).appendingPathComponent("Backups") }

    /// One consistent copy of the state database per day, the newest 7 kept.
    private func backupDatabaseIfDue(_ engine: Engine) {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        let target = backupsDir.appendingPathComponent("state-\(f.string(from: Date())).db")
        guard !FileManager.default.fileExists(atPath: target.path) else { return }
        do {
            try engine.store.backup(to: target)
            let all = ((try? FileManager.default.contentsOfDirectory(atPath: backupsDir.path)) ?? []).filter { $0.hasSuffix(".db") }.sorted()
            for old in all.dropLast(7) { try? FileManager.default.removeItem(at: backupsDir.appendingPathComponent(old)) }
        } catch { writeLog("備份狀態資料庫失敗：\(error)") }
    }

    /// Re-reads every file once a week (or on request) to catch content that changed without its size or mtime changing.
    public func verifyNow() { queue.async { self.forceDeepVerify = true; self.runIfNeeded(confirmed: false) } }

    private func deepVerifyDue(_ engine: Engine) -> Bool {
        if forceDeepVerify { return true }
        guard let s = try? engine.store.meta("lastDeepVerify"), let d = ISO8601DateFormatter().date(from: s) else { return true }
        return Date().timeIntervalSince(d) > 7 * 86400
    }

    public func stop() {
        queue.sync {
            watcher?.stop(); watcher = nil
            timer?.cancel(); timer = nil
        }
    }

    public func syncNow(confirmed: Bool = false) { queue.async { self.runIfNeeded(confirmed: confirmed) } }

    public func pause() {
        queue.async { self.snapshot.phase = .paused; self.watcher?.stop(); self.watcher = nil; self.watchedRoots = []; self.publish() }
    }

    public func resume() {
        queue.async { self.snapshot.phase = .idle; self.runIfNeeded(confirmed: false) }
    }

    // MARK: configuration (all database access stays on the service queue)

    public func addEndpoint(_ cfg: EndpointConfig, completion: @escaping @Sendable (Error?) -> Void) {
        configure(completion) { store in
            try FileManager.default.createDirectory(atPath: cfg.root, withIntermediateDirectories: true)
            var c = cfg
            c.volumeUUID = FileOps.volumeUUID(of: URL(fileURLWithPath: cfg.root))
            try store.addEndpoint(c)
        }
    }

    public func relinkEndpoint(id: String, root: String, completion: @escaping @Sendable (Error?) -> Void) {
        configure(completion) { store in
            try store.relinkEndpoint(id: id, root: root, volumeUUID: FileOps.volumeUUID(of: URL(fileURLWithPath: root)))
        }
    }

    public func removeEndpoint(id: String, completion: @escaping @Sendable (Error?) -> Void) {
        configure(completion) { store in
            if let cfg = try store.endpoints().first(where: { $0.id == id }) {
                // Only our own marker file is removed; the user's files stay untouched.
                try? FileManager.default.removeItem(atPath: cfg.root + "/" + Engine.markerName)
            }
            try store.removeEndpoint(id: id)
        }
    }

    public func setConflictPolicy(_ policy: ConflictPolicy, completion: @escaping @Sendable (Error?) -> Void) {
        configure(completion) { try $0.setMeta("conflictPolicy", policy.rawValue) }
    }

    public func resolveConflict(id: Int64, keep: ConflictChoice, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do { try engine.resolveConflictRecord(id, keep: keep); completion(nil) } catch { completion(error) }
            self.runIfNeeded(confirmed: false)     // spreads the chosen version and refreshes the list
        }
    }

    private func configure(_ completion: @escaping @Sendable (Error?) -> Void, _ body: @escaping (Store) throws -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do { try body(engine.store); completion(nil) } catch { completion(error) }
            self.watchedRoots = []          // roots changed: re-create the watcher on the next run
            self.runIfNeeded(confirmed: false)
        }
    }

    // MARK: running

    private func runIfNeeded(confirmed: Bool) {
        guard snapshot.phase != .paused, let engine else { return }
        if running { rerun = true; rerunConfirmed = rerunConfirmed || confirmed; return }
        running = true
        snapshot.phase = .syncing
        snapshot.error = nil
        publish()

        maintainVersionsIfDue(engine)
        do {
            let cfgs = try engine.store.endpoints()
            // A group needs at least two endpoints; with fewer there is nothing to keep consistent.
            let deep = cfgs.count >= 2 && deepVerifyDue(engine)
            engine.options.deepVerify = deep
            defer { engine.options.deepVerify = false }
            let report = cfgs.count >= 2 ? try engine.sync(confirmed: confirmed) : SyncReport()
            if deep && cfgs.count >= 2 && report.needsConfirmation == nil {
                forceDeepVerify = false
                try? engine.store.setMeta("lastDeepVerify", ISO8601DateFormatter().string(from: Date()))
                snapshot.lastDeepVerify = Date()
                snapshot.integrityIssues = report.integrity
                if !report.integrity.isEmpty { writeLog("完整驗證：\(report.integrity.count) 個檔案內容與紀錄不符（疑似損壞）：\(report.integrity.joined(separator: "、"))") }
            }
            if report.needsConfirmation == nil && report.skipped.isEmpty && report.offline.isEmpty { snapshot.lastCleanSync = Date() }
            snapshot.lastRun = Date()
            snapshot.lastWork = report.work
            let skipped = Array(Set(report.skipped)).sorted()
            if skipped != snapshot.skipped { skipped.forEach { writeLog("略過 \($0)") } }
            for o in report.offline where !snapshot.endpoints.contains(where: { !$0.online && o.hasPrefix($0.id) }) { writeLog("離線 \(o)") }
            snapshot.skipped = skipped
            snapshot.confirmation = report.needsConfirmation.map { Confirmation(reason: $0, preview: report.preview) }
            snapshot.endpoints = try cfgs.map { cfg in
                if case .offline(let why) = try engine.checkIdentity(cfg) {
                    return EndpointStatus(id: cfg.id, root: cfg.root, online: false, detail: why, removable: cfg.removable, portableNames: cfg.portableNames)
                }
                return EndpointStatus(id: cfg.id, root: cfg.root, online: true, detail: "在線", removable: cfg.removable, portableNames: cfg.portableNames)
            }
            snapshot.trackedFiles = try engine.store.liveConsensusCount()
            snapshot.conflictPolicy = ConflictPolicy(rawValue: try engine.store.meta("conflictPolicy") ?? "") ?? .keepBoth
            snapshot.conflicts = try currentConflicts(engine, cfgs)
            let iso = ISO8601DateFormatter()
            snapshot.recent = try engine.store.recentJournal(limit: 12).map {
                Activity(id: $0.id, time: iso.date(from: $0.time) ?? Date(), op: $0.op, endpoint: $0.endpoint, path: $0.path, ok: $0.status == "done")
            }
            ensureWatching(cfgs.map(\.root))
        } catch is SyncBusy {
            writeLog("另一個同步正在進行（App 或指令列），5 秒後重試")
            queue.asyncAfter(deadline: .now() + 5) { self.runIfNeeded(confirmed: confirmed) }
        } catch {
            snapshot.error = "\(error)"
            writeLog("錯誤：\(error)")
        }

        running = false
        snapshot.phase = snapshot.phase == .paused ? .paused : .idle
        publish()
        if rerun {
            let c = rerunConfirmed
            rerun = false; rerunConfirmed = false
            queue.async { self.runIfNeeded(confirmed: c) }
        }
    }

    // MARK: versions archive

    private func retention(_ engine: Engine) -> (days: Int, maxBytes: Int64) {
        let d = Int((try? engine.store.meta("versionsRetentionDays")) ?? nil ?? "") ?? 30
        let g = Int((try? engine.store.meta("versionsMaxGB")) ?? nil ?? "") ?? 20
        return (d, Int64(g) * 1_073_741_824)
    }

    /// Automatic cleanup: at most every 6 hours, by age and by total size.
    private func maintainVersionsIfDue(_ engine: Engine) {
        guard Date().timeIntervalSince(lastMaintenance) > 6 * 3600 else { return }
        lastMaintenance = Date()
        let r = retention(engine)
        let freed = Versions.purge(versionsDir, olderThanDays: r.days, maxBytes: r.maxBytes)
        if freed.files > 0 { writeLog("自動清理舊版本：移除 \(freed.files) 個檔案，釋出 \(ByteCountFormatter.string(fromByteCount: freed.bytes, countStyle: .file))") }
        refreshVersionsSnapshot(engine)
        backupDatabaseIfDue(engine)
    }

    private func refreshVersionsSnapshot(_ engine: Engine) {
        snapshot.versions = Versions.usage(versionsDir)
        snapshot.versionsRetentionDays = retention(engine).days
    }

    public enum PurgeMode: Sendable { case expired, all }

    public func purgeVersions(_ mode: PurgeMode, completion: @escaping @Sendable (Int, Int64) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(0, 0); return }
            let r = self.retention(engine)
            let freed = mode == .all ? Versions.purgeAll(self.versionsDir)
                                     : Versions.purge(self.versionsDir, olderThanDays: r.days, maxBytes: r.maxBytes)
            self.writeLog("手動清理舊版本（\(mode == .all ? "全部" : "過期")）：移除 \(freed.files) 個檔案，釋出 \(ByteCountFormatter.string(fromByteCount: freed.bytes, countStyle: .file))")
            self.refreshVersionsSnapshot(engine)
            self.publish()
            completion(freed.files, freed.bytes)
        }
    }

    public func listVersions(limit: Int = 300, completion: @escaping @Sendable ([VersionItem]) -> Void) {
        queue.async { completion(Versions.list(self.versionsDir, limit: limit)) }
    }

    public func restoreVersion(_ item: VersionItem, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do { try engine.restoreVersion(item); completion(nil) } catch { completion(error) }
            self.runIfNeeded(confirmed: false)     // spreads the restored file
        }
    }

    public func setVersionsRetention(days: Int, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do { try engine.store.setMeta("versionsRetentionDays", String(days)); completion(nil) } catch { completion(error) }
            self.refreshVersionsSnapshot(engine)
            self.publish()
        }
    }

    public func refreshVersionsUsage() {
        queue.async { if let e = self.engine { self.refreshVersionsSnapshot(e); self.publish() } }
    }

    private func currentConflicts(_ engine: Engine, _ cfgs: [EndpointConfig]) throws -> [ConflictItem] {
        var out: [ConflictItem] = []
        for c in try engine.store.openConflicts() {
            guard let cfg = cfgs.first(where: { $0.id == c.endpoint }) else { continue }
            let root = URL(fileURLWithPath: cfg.root)
            let main = root.appendingPathComponent(c.path), extra = root.appendingPathComponent(c.conflictPath)
            guard FileManager.default.fileExists(atPath: extra.path) else {
                try engine.store.closeConflict(id: c.id, status: "gone")      // the user dealt with it in Finder
                continue
            }
            func info(_ u: URL) -> (Int64?, Date?) {
                let v = try? u.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                return (v?.fileSize.map(Int64.init), v?.contentModificationDate)
            }
            let m = info(main), x = info(extra)
            let online: Bool = { if case .online = (try? engine.checkIdentity(cfg)) { return true } else { return false } }()
            out.append(ConflictItem(id: c.id, endpoint: c.endpoint, endpointOnline: online, path: c.path,
                                    mainPath: main.path, extraPath: extra.path, mainSize: m.0, extraSize: x.0,
                                    mainModified: m.1, extraModified: x.1))
        }
        return out
    }

    private func ensureWatching(_ roots: [String]) {
        guard roots != watchedRoots, snapshot.phase != .paused else { return }
        watcher?.stop()
        let w = Watcher(roots: roots) { [weak self] in self?.queue.async { self?.runIfNeeded(confirmed: false) } }
        w.setVolumeRoots(roots)
        w.start()
        watcher = w
        watchedRoots = roots
    }

    private func publish() { let s = snapshot; onUpdate(s) }

    private func writeLog(_ line: String) {
        guard let url = logURL else { return }
        let text = "\(ISO8601DateFormatter().string(from: Date())) \(line)\n"
        if let h = try? FileHandle(forWritingTo: url) {
            defer { try? h.close() }
            _ = try? h.seekToEnd()
            try? h.write(contentsOf: Data(text.utf8))
        } else {
            try? text.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
