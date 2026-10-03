import Foundation

/// Long-running owner of the engine: watches the endpoints, debounces events, runs syncs one at a time,
/// and publishes a snapshot for UIs. All engine and database access happens on one serial queue.
public final class SyncService: @unchecked Sendable {
    public enum Phase: Sendable { case idle, syncing, paused }

    public struct EndpointStatus: Sendable {
        public var id: String, root: String, online: Bool, detail: String
        public var removable = false, portableNames = false
        public var role: EndpointRole = .mirror
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
        public var archiveRetentionDays = 365
        /// Health: when everything last synced with nothing skipped, and the results of the periodic deep verification.
        public var lastCleanSync: Date?
        public var lastDeepVerify: Date?
        public var excludePresets: Set<ExcludePreset> = ExcludePreset.defaults
        public var integrityIssues: [IntegrityIssue] = []
        public var duplicateHints: [DuplicateHint] = []
        public var conflictPolicy: ConflictPolicy = .keepBoth
        public var cloudSpaceSaving = false
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
    /// Incremental mode: endpoint-relative paths reported by FSEvents since the last run. Anything doubtful sets `needFull`.
    private var dirty = Set<String>()
    private var needFull = true
    private var rerunFull = false
    private var rootMap: [(root: String, resolved: String)] = []
    private var eventIdTimer: DispatchSourceTimer?
    private let stopLock = NSLock()
    private var stopRequested = false

    private var shouldStop: Bool {
        stopLock.lock(); defer { stopLock.unlock() }
        return stopRequested
    }

    private func setStopRequested(_ requested: Bool) {
        stopLock.lock(); stopRequested = requested; stopLock.unlock()
    }

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
        setStopRequested(false)
        queue.async { [self] in
            do {
                try FileManager.default.createDirectory(atPath: (self.dbPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
                if let log = self.logURL { try FileManager.default.createDirectory(at: log.deletingLastPathComponent(), withIntermediateDirectories: true) }
                var opts = EngineOptions()
                opts.versionsDir = self.versionsDir
                opts.log = { [weak self] in self?.writeLog($0) }
                opts.shouldCancel = { [weak self] in self?.shouldStop ?? true }
                opts.releaseCloudContent = { @Sendable url, completion in
                    CloudSpaceReclaimer.releaseLocalContent(of: url, completion: completion)
                }
                let store = try self.openStoreRecovering()
                opts.cloudSpaceSaving = (try? store.meta("cloudSpaceSaving")) == "1"
                let engine = Engine(store: store, options: opts)
                engine.onContentReady = { [weak self] url in self?.queue.async { self?.markDirty(absolute: url.path); self?.runIfNeeded(confirmed: false, incremental: true) } }
                self.engine = engine
                self.snapshot.conflictPolicy = ConflictPolicy(rawValue: (try? store.meta("conflictPolicy")) ?? "") ?? .keepBoth
                self.snapshot.cloudSpaceSaving = ((try? store.meta("cloudSpaceSaving")) ?? "0") == "1"
                self.snapshot.excludePresets = IgnoreRules.parsePresets(try? store.meta("excludePresets"))
                self.publish()
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
            // Persist the newest FSEvents id regularly: after a restart, the changes made while the app was off are replayed
            // and synced within seconds (a full scan follows later as the safety net).
            let it = DispatchSource.makeTimerSource(queue: self.queue)
            it.schedule(deadline: .now() + 60, repeating: 60)
            it.setEventHandler { [weak self] in self?.saveEventId() }
            it.resume()
            self.eventIdTimer = it
            if let engine = self.engine, let cfgs = try? engine.store.endpoints() {
                #if os(macOS)
                SecurityScopeManager.shared.onBookmarkRenewed = { [weak self] root, newBookmark in
                    guard let self = self else { return }
                    self.queue.async { [weak self] in
                        guard let engine = self?.engine else { return }
                        try? engine.store.updateBookmark(forRoot: root, bookmarkData: newBookmark)
                    }
                }
                #endif
                for cfg in cfgs {
                    SecurityScopeManager.shared.startAccessing(path: cfg.root, bookmarkData: cfg.bookmarkData)
                }
                if cfgs.count >= 2,
                   let saved = (try? engine.store.meta("fsEventId")).flatMap({ $0 }).flatMap(UInt64.init) {
                    self.needFull = false
                    self.startWatcher(cfgs.map(\.root), since: saved)
                    self.queue.asyncAfter(deadline: .now() + 90) { [weak self] in self?.runIfNeeded(confirmed: false) }
                } else {
                    self.runIfNeeded(confirmed: false)
                }
            }
        }
    }

    private func saveEventId() {
        guard let engine, let id = watcher?.lastEventId, id > 0 else { return }
        try? engine.store.setMeta("fsEventId", String(id))
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
        setStopRequested(true)
        queue.sync {
            finishStopping()
        }
    }

    /// Stops after the current filesystem operation reaches a cancellation point, without
    /// blocking the caller (notably the main actor). The database is closed before this returns.
    public func stopAndWait() async {
        setStopRequested(true)
        await withCheckedContinuation { continuation in
            queue.async {
                self.finishStopping()
                continuation.resume()
            }
        }
    }

    private func finishStopping() {
        saveEventId()
        eventIdTimer?.cancel(); eventIdTimer = nil
        watcher?.stop(); watcher = nil
        timer?.cancel(); timer = nil
        engine = nil
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
            SecurityScopeManager.shared.startAccessing(path: cfg.root, bookmarkData: cfg.bookmarkData)
            try FileManager.default.createDirectory(atPath: cfg.root, withIntermediateDirectories: true)
            var c = cfg
            c.volumeUUID = FileOps.volumeUUID(of: URL(fileURLWithPath: cfg.root))
            try store.addEndpoint(c)
        }
    }

    public func relinkEndpoint(id: String, root: String, bookmarkData: Data? = nil, completion: @escaping @Sendable (Error?) -> Void) {
        configure(completion) { store in
            SecurityScopeManager.shared.startAccessing(path: root, bookmarkData: bookmarkData)
            try store.relinkEndpoint(id: id, root: root, volumeUUID: FileOps.volumeUUID(of: URL(fileURLWithPath: root)), bookmarkData: bookmarkData)
        }
    }

    public func removeEndpoint(id: String, completion: @escaping @Sendable (Error?) -> Void) {
        configure(completion) { store in
            if let cfg = try store.endpoints().first(where: { $0.id == id }) {
                // Only our own marker file is removed; the user's files stay untouched.
                try? FileManager.default.removeItem(atPath: cfg.root + "/" + Engine.markerName)
                SecurityScopeManager.shared.stopAccessing(path: cfg.root)
            }
            try store.removeEndpoint(id: id)
        }
    }

    public func setConflictPolicy(_ policy: ConflictPolicy, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do {
                try engine.store.setMeta("conflictPolicy", policy.rawValue)
                self.snapshot.conflictPolicy = policy
                self.publish()
                self.watchedRoots = []
                self.runIfNeeded(confirmed: false)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func setExcludePresets(_ presets: Set<ExcludePreset>, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do {
                try engine.store.setMeta("excludePresets", presets.map(\.rawValue).sorted().joined(separator: ","))
                self.snapshot.excludePresets = presets
                self.publish()
                self.needFull = true
                self.watchedRoots = []
                self.runIfNeeded(confirmed: false)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func setCloudSpaceSaving(_ enabled: Bool, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do {
                try engine.store.setMeta("cloudSpaceSaving", enabled ? "1" : "0")
                engine.options.cloudSpaceSaving = enabled
                self.snapshot.cloudSpaceSaving = enabled
                self.publish()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func trialRun(completion: @escaping @Sendable (SyncReport?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(nil); return }
            do {
                let report = try engine.sync(dryRun: true)
                completion(report)
            } catch {
                completion(nil)
            }
        }
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

    /// Maps an absolute path from FSEvents to the path relative to its endpoint, shared by all endpoints. A change of the root itself means "everything".
    private func markDirty(absolute path: String) {
        for r in rootMap {
            for root in [r.root, r.resolved] where path == root || path.hasPrefix(root + "/") {
                let rel = PortableName.canonical(String(path.dropFirst(root.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/")))
                if rel.isEmpty { needFull = true } else { dirty.insert(rel) }
                return
            }
        }
    }

    private func ingest(_ batch: WatchBatch) {
        if batch.replayDone, snapshot.lastRun == nil, let engine, let cfgs = try? engine.store.endpoints() {
            // Started from stored history: show the real state now instead of "starting…" until the delayed full scan.
            try? fillStatus(engine, cfgs); snapshot.lastRun = Date(); publish()
        }
        if batch.full { needFull = true }
        for p in batch.paths { markDirty(absolute: p) }
        runIfNeeded(confirmed: false, incremental: true)
    }

    private func runIfNeeded(confirmed: Bool, incremental: Bool = false) {
        guard !shouldStop, snapshot.phase != .paused, let engine else { return }
        if running {
            rerun = true; rerunConfirmed = rerunConfirmed || confirmed
            if !incremental { rerunFull = true }
            return
        }
        // Incremental only when asked for by the watcher and nothing doubtful is pending; every other trigger (start, wake,
        // timer, "sync now", confirmation) looks at everything.
        let wantFull = !incremental || needFull || confirmed || forceDeepVerify || rerunFull
        let taken = dirty; dirty = []; rerunFull = false
        if !wantFull && taken.isEmpty { return }
        let scope: SyncScope = wantFull ? .full : .paths(taken)
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
            let report = cfgs.count >= 2 ? try engine.sync(confirmed: confirmed, scope: scope) : SyncReport()
            if report.coveredFullScan { needFull = false }
            if !report.retry.isEmpty {
                let again = report.retry
                queue.asyncAfter(deadline: .now() + 5) { [weak self] in self?.dirty.formUnion(again); self?.runIfNeeded(confirmed: false, incremental: true) }
            }
            if deep && cfgs.count >= 2 && report.needsConfirmation == nil {
                forceDeepVerify = false
                try? engine.store.setMeta("lastDeepVerify", ISO8601DateFormatter().string(from: Date()))
                snapshot.lastDeepVerify = Date()
                snapshot.integrityIssues = report.integrity
                if !report.integrity.isEmpty { writeLog("完整驗證：\(report.integrity.count) 個檔案內容與紀錄不符（疑似損壞）：\(report.integrity.map(\.description).joined(separator: "、"))") }
            }
            if report.coveredFullScan { snapshot.duplicateHints = report.duplicateHints }
            if report.needsConfirmation == nil && report.skipped.isEmpty && report.offline.isEmpty { snapshot.lastCleanSync = Date() }
            snapshot.lastRun = Date()
            snapshot.lastWork = report.work
            let skipped = Array(Set(report.skipped)).sorted()
            if skipped != snapshot.skipped { skipped.forEach { writeLog("略過 \($0)") } }
            for o in report.offline where !snapshot.endpoints.contains(where: { !$0.online && o.hasPrefix($0.id) }) { writeLog("離線 \(o)") }
            snapshot.skipped = skipped
            snapshot.confirmation = report.needsConfirmation.map { Confirmation(reason: $0, preview: report.preview) }
            try fillStatus(engine, cfgs)
            ensureWatching(cfgs.map(\.root))
        } catch is ScanCancelled {
            // Lifecycle operation (restore/import/quit) requested a clean stop. This is neither
            // an endpoint failure nor a reason to retry the interrupted scan.
        } catch is SyncBusy {
            needFull = true
            writeLog("另一個同步正在進行（App 或指令列），5 秒後重試")
            queue.asyncAfter(deadline: .now() + 5) { self.runIfNeeded(confirmed: confirmed) }
        } catch {
            needFull = true
            snapshot.error = "\(error)"
            writeLog("錯誤：\(error)")
        }

        running = false
        snapshot.phase = snapshot.phase == .paused ? .paused : .idle
        publish()
        if rerun && !shouldStop {
            let c = rerunConfirmed
            rerun = false; rerunConfirmed = false
            queue.async { self.runIfNeeded(confirmed: c, incremental: !(c || self.rerunFull)) }
        } else if shouldStop {
            rerun = false; rerunConfirmed = false; rerunFull = false
        }
    }

    private func fillStatus(_ engine: Engine, _ cfgs: [EndpointConfig]) throws {
        snapshot.endpoints = try cfgs.map { cfg in
            if case .offline(let why) = try engine.checkIdentity(cfg) {
                return EndpointStatus(id: cfg.id, root: cfg.root, online: false, detail: why, removable: cfg.removable, portableNames: cfg.portableNames, role: cfg.role)
            }
            return EndpointStatus(id: cfg.id, root: cfg.root, online: true, detail: "在線", removable: cfg.removable, portableNames: cfg.portableNames, role: cfg.role)
        }
        snapshot.trackedFiles = try engine.store.liveConsensusCount()
        snapshot.conflictPolicy = ConflictPolicy(rawValue: try engine.store.meta("conflictPolicy") ?? "") ?? .keepBoth
        snapshot.cloudSpaceSaving = (try engine.store.meta("cloudSpaceSaving") ?? "0") == "1"
        snapshot.excludePresets = IgnoreRules.parsePresets(try engine.store.meta("excludePresets"))
        snapshot.conflicts = try currentConflicts(engine, cfgs)
        let iso = ISO8601DateFormatter()
        snapshot.recent = try engine.store.recentJournal(limit: 12).map {
            Activity(id: $0.id, time: iso.date(from: $0.time) ?? Date(), op: $0.op, endpoint: $0.endpoint, path: $0.path, ok: $0.status == "done")
        }
    }

    // MARK: versions archive

    private func retention(_ engine: Engine) -> (days: Int, maxBytes: Int64) {
        let d = Int((try? engine.store.meta("versionsRetentionDays")) ?? nil ?? "") ?? 30
        let g = Int((try? engine.store.meta("versionsMaxGB")) ?? nil ?? "") ?? 20
        return (d, Int64(g) * 1_073_741_824)
    }

    private func archiveDays(_ engine: Engine) -> Int { Int((try? engine.store.meta("archiveRetentionDays")) ?? nil ?? "") ?? 365 }

    public func setArchiveRetention(days: Int, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do { try engine.store.setMeta("archiveRetentionDays", String(days)); completion(nil) } catch { completion(error) }
            self.refreshVersionsSnapshot(engine); self.publish()
        }
    }

    /// Automatic cleanup: at most every 6 hours, by age and by total size.
    private func maintainVersionsIfDue(_ engine: Engine) {
        guard Date().timeIntervalSince(lastMaintenance) > 6 * 3600 else { return }
        lastMaintenance = Date()
        let r = retention(engine)
        let freed = Versions.purge(versionsDir, olderThanDays: r.days, maxBytes: r.maxBytes)
        if freed.files > 0 { writeLog("自動清理舊版本：移除 \(freed.files) 個檔案，釋出 \(ByteCountFormatter.string(fromByteCount: freed.bytes, countStyle: .file))") }
        for cfg in (try? engine.store.endpoints()) ?? [] where cfg.role == .archive {
            let days = archiveDays(engine)
            if days > 0 {
                let r = Versions.purge(URL(fileURLWithPath: cfg.root).appendingPathComponent(".syncnexus-history"), olderThanDays: days, maxBytes: nil)
                if r.files > 0 { writeLog("備份「\(cfg.id)」的歷史：清除超過 \(days) 天的 \(r.files) 個檔案") }
            }
        }
        refreshVersionsSnapshot(engine)
        backupDatabaseIfDue(engine)
    }

    private func refreshVersionsSnapshot(_ engine: Engine) {
        snapshot.versions = Versions.usage(versionsDir)
        snapshot.versionsRetentionDays = retention(engine).days
        snapshot.archiveRetentionDays = archiveDays(engine)
    }

    public enum PurgeMode: Sendable { case expired, all }

    public func purgeVersions(_ mode: PurgeMode, completion: @escaping @Sendable (Int, Int64) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(0, 0); return }
            let r = self.retention(engine)
            let freed = mode == .all ? Versions.purgeAll(self.versionsDir)
                                     : Versions.purge(self.versionsDir, olderThanDays: r.days, maxBytes: r.maxBytes)
            let freedText = ByteCountFormatter.string(fromByteCount: freed.bytes, countStyle: .file)
            self.writeLog(mode == .all ? "手動清理舊版本（全部）：移除 \(freed.files) 個檔案，釋出 \(freedText)" : "手動清理舊版本（過期）：移除 \(freed.files) 個檔案，釋出 \(freedText)")
            self.refreshVersionsSnapshot(engine)
            self.publish()
            completion(freed.files, freed.bytes)
        }
    }

    public func resolveIntegrity(_ issue: IntegrityIssue, action: IntegrityAction, completion: @escaping @Sendable (Error?) -> Void) {
        queue.async {
            guard let engine = self.engine else { completion(DBError(description: "服務尚未啟動")); return }
            do {
                try engine.resolveIntegrity(issue, action: action)
                self.snapshot.integrityIssues.removeAll { $0 == issue }
                completion(nil)
            } catch { completion(error) }
            self.dirty.insert(issue.path)
            self.runIfNeeded(confirmed: false, incremental: true)       // spreads the accepted content / refreshes the status
            self.publish()
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
        rootMap = roots.map { ($0, URL(fileURLWithPath: $0).resolvingSymlinksInPath().path) }
        guard roots != watchedRoots, snapshot.phase != .paused else { return }
        startWatcher(roots, since: nil)
    }

    private func startWatcher(_ roots: [String], since: UInt64?) {
        rootMap = roots.map { ($0, URL(fileURLWithPath: $0).resolvingSymlinksInPath().path) }
        watcher?.stop()
        let w = Watcher(roots: roots, sinceEventId: since) { [weak self] batch in self?.queue.async { self?.ingest(batch) } }
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
