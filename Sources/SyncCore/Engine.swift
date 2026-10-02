import Foundation

public enum ConflictPolicy: String, Sendable, CaseIterable {
    /// Both versions are kept; the extra copy stays on the endpoint where the conflict happened.
    case keepBoth
    /// The version with the newer modification time wins; the older one is archived in Versions.
    /// When the times are within 2 s of each other (or unusable) it falls back to keepBoth.
    case newerWins
}

/// Thrown by test failpoints to emulate the process dying mid-sync (never thrown in production).
public struct SimulatedCrash: Error {}

public enum ConflictChoice: Sendable, Equatable { case main, conflict }

public struct EngineOptions {
    public var ignore = IgnoreRules.default
    /// A file modified less than this many seconds ago is considered still being written and skipped for now.
    public var settleSeconds: Double = 2
    public var deletionGuard = DeletionGuard()
    /// Where overwritten versions are kept. `nil` disables the archive.
    public var versionsDir: URL?
    public var maxVersionBytes: Int64 = 500 * 1024 * 1024
    /// Deletion goes through the OS Trash by default, so every removal can be undone from Finder.
    public var trash: (URL) throws -> Void = { try FileManager.default.trashItem(at: $0, resultingItemURL: nil) }
    public var now: () -> Date = Date.init
    public var log: (String) -> Void = { _ in }
    /// Placeholders (not-downloaded cloud files) up to this size are downloaded automatically when their content is needed.
    public var autoDownloadMaxBytes: Int64 = 500 * 1024 * 1024
    /// Test hooks: mark files as placeholders / replace the download request.
    public var placeholderCheck: ((URL) -> Bool)?
    public var requestDownload: ((URL) -> Void)?
    /// Test hook: pretend a placeholder's content has already been read.
    public var placeholderHash: ((URL) -> String?)?
    /// Test hooks: called at every file-system operation boundary / right after each scan.
    public var failpoint: ((String) throws -> Void)?
    public var afterScan: (() -> Void)?
    /// Re-hash everything instead of trusting size + mtime, and flag content that changed without its mtime changing.
    public var deepVerify = false
    /// Test hook: free bytes on a volume.
    public var freeSpace: ((URL) -> Int64?)?

    public init() {}
}

public struct SyncReport {
    public var actions: [String] = []
    public var skipped: [String] = []
    public var offline: [String] = []
    public var notes: [String] = []
    public var work = 0
    public var passes = 0
    /// Set when the run was stopped before doing anything and needs the user's go-ahead.
    public var needsConfirmation: String?
    public var preview: [String] = []
    /// Files whose content differs from what was recorded although size and mtime are unchanged (possible silent corruption).
    public var integrity: [String] = []
}

public final class Engine {
    public let store: Store
    public var options: EngineOptions

    public init(store: Store, options: EngineOptions = EngineOptions()) {
        self.store = store
        self.options = options
    }

    private var policy: ConflictPolicy = .keepBoth

    public static let markerName = ".syncnexus-endpoint"

    // MARK: identity

    public enum Status { case online, offline(String) }

    public func checkIdentity(_ cfg: EndpointConfig, writeMarker: Bool = false) throws -> Status {
        let root = URL(fileURLWithPath: cfg.root)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: root.path, isDirectory: &isDir), isDir.boolValue else {
            return .offline("資料夾不存在（外接碟未掛載？）")
        }
        let markerURL = root.appendingPathComponent(Engine.markerName)
        let marker = (try? String(contentsOf: markerURL, encoding: .utf8))?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let marker {
            guard marker == cfg.uuid else { return .offline("標記檔與此端點不符（換了另一個資料夾或磁碟？），已停止，不傳播任何變更") }
        } else if try store.endpointHasHistory(cfg.id) {
            return .offline("標記檔遺失（被清空、重新格式化或換碟？），已停止，不傳播任何刪除")
        } else {
            if writeMarker { try cfg.uuid.write(to: markerURL, atomically: true, encoding: .utf8) }   // never during a preview
        }
        if cfg.removable, let expected = cfg.volumeUUID, let actual = FileOps.volumeUUID(of: root), expected != actual {
            return .offline("磁碟區 UUID 不符（不是原本那顆碟），已停止")
        }
        return .online
    }

    // MARK: context

    private enum Live { case absent, present(FileState, ScannedFile), skip(String) }

    private final class Context {
        var online: [EndpointConfig] = []
        var files: [String: [String: ScannedFile]] = [:]
        var hashes: [String: FileState] = [:]
        var rows: [String: [String: EndpointRow]] = [:]
        var integrity: Set<String> = []
        var wroteToRemovable: Set<String> = []
        var blocked: [String: Set<String>] = [:]      // paths that must not be touched on an endpoint (case collisions)
    }

    private func buildContext(_ cfgs: [EndpointConfig], writeMarker: Bool, into report: inout SyncReport) throws -> Context {
        let ctx = Context()
        for cfg in cfgs {
            switch try checkIdentity(cfg, writeMarker: writeMarker) {
            case .offline(let why):
                report.offline.append("\(cfg.id)：\(why)")
            case .online:
                let scan: ScanResult
                do { scan = try FileOps.scan(root: URL(fileURLWithPath: cfg.root), ignore: options.ignore, placeholder: options.placeholderCheck) }
                catch {
                    // Unreadable (missing permission, I/O error): never treat a partial listing as "files are gone".
                    report.offline.append("\(cfg.id)：無法完整讀取，已停止此端點（請檢查「系統設定 > 隱私權與安全性」的檔案存取授權）。\(error.localizedDescription)")
                    continue
                }
                for left in scan.leftovers {
                    let age = options.now().timeIntervalSince((try? left.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast)
                    if age > 60 { try? FileManager.default.removeItem(at: left); report.notes.append("[\(cfg.id)] 清除上次中斷的暫存檔 \(left.lastPathComponent)") }
                }
                ctx.online.append(cfg)
                ctx.files[cfg.id] = scan.files
                ctx.rows[cfg.id] = try store.rows(cfg.id)
            }
        }
        try canonicalizeCase(ctx, &report)
        return ctx
    }

    // MARK: case-insensitive identity

    static func fold(_ path: String) -> String { PortableName.canonical(path).lowercased() }

    /// macOS (APFS default), exFAT, iCloud and Google Drive folders are case-insensitive, so "Report.docx" and
    /// "report.docx" are ONE file there. Without this, two spellings become two sync entries that overwrite each other
    /// on the next endpoint (found by the fuzz test as silent content loss). Every path gets one canonical spelling for
    /// the whole group; case-only renames are therefore cosmetic and not propagated. Two files that differ only by case
    /// inside one endpoint (possible on a case-sensitive volume) are left alone and reported.
    private func canonicalizeCase(_ ctx: Context, _ report: inout SyncReport) throws {
        var canon: [String: String] = [:]
        var ambiguous = Set<String>()
        for p in try store.consensusPaths().sorted() {
            let f = Engine.fold(p)
            if let ex = canon[f], ex != p { ambiguous.insert(f) } else { canon[f] = p }
        }
        for cfg in ctx.online {
            for rel in ctx.files[cfg.id]!.keys.sorted() where canon[Engine.fold(rel)] == nil { canon[Engine.fold(rel)] = rel }
        }
        for cfg in ctx.online {
            var files: [String: ScannedFile] = [:]
            var clash = Set<String>()
            for (rel, f) in ctx.files[cfg.id]! {
                let fold = Engine.fold(rel), key = canon[fold]!
                if ambiguous.contains(fold) { clash.insert(key); continue }
                if files[key] != nil { clash.insert(key); continue }
                var g = f; g.rel = key
                files[key] = g
            }
            for key in clash {
                files[key] = nil
                report.skipped.append("[\(cfg.id)] \(key)：有檔名只差大小寫的項目（此資料夾區分大小寫，其他端點不區分），為避免互相覆蓋已略過，請改名其中一個")
            }
            ctx.files[cfg.id] = files
            var rows: [String: EndpointRow] = [:]
            for (k, r) in ctx.rows[cfg.id]! { rows[canon[Engine.fold(k)] ?? k] = r }
            ctx.rows[cfg.id] = rows
            ctx.blocked[cfg.id] = clash
        }
        for f in ambiguous { if let k = canon[f] { for cfg in ctx.online { ctx.blocked[cfg.id, default: []].insert(k) } } }
    }

    private static let dirState = FileState(kind: .directory, hash: "", size: 0)

    private func live(_ ctx: Context, _ ep: String, _ path: String) throws -> Live {
        if ctx.blocked[ep]?.contains(path) == true { return .skip("大小寫衝突，暫不處理") }
        guard let f = ctx.files[ep]?[path] else { return .absent }
        if f.isDirectory { return .present(Engine.dirState, f) }
        let key = "\(ep)\u{0}\(path)"
        if let row = ctx.rows[ep]?[path], let st = row.state, st.kind == .file, st.size == f.size, row.mtimeNs == f.mtimeNs {
            if options.deepVerify && !f.isPlaceholder {
                guard let h = try FileOps.hashIfStable(f.url, size: f.size, mtimeNs: f.mtimeNs) else { return .skip("仍在寫入（穩定窗口）") }
                if h != st.hash {
                    ctx.integrity.insert("[\(ep)] \(path)")
                    return .skip("內容與紀錄不符，但修改時間與大小沒變（疑似損壞）。已略過，不會傳播；其他端點仍持有正確版本")
                }
            }
            ctx.hashes[key] = st        // unchanged since last alignment: no hashing, and a placeholder needs no download
            return .present(st, f)
        }
        if f.isPlaceholder {
            if let h = placeholderContentHash(f) {
                let st = FileState(hash: h, size: f.size)      // content already read in the background
                ctx.hashes[key] = st
                return .present(st, f)
            }
            if f.size > options.autoDownloadMaxBytes {
                return .skip("雲端檔案 \(ByteCountFormatter.string(fromByteCount: f.size, countStyle: .file)) 超過自動下載上限，請在 Finder 手動下載")
            }
            if let free = Materializer.freeBytes(at: f.url), free < f.size + 2 * 1024 * 1024 * 1024 {
                return .skip("磁碟可用空間不足，無法下載雲端檔案")
            }
            requestDownload(f)
            return .skip("正在讀取雲端檔案內容，完成後自動繼續")
        }
        if options.settleSeconds > 0 {
            let now = options.now(), age = now.timeIntervalSince(f.mtime)
            if age < options.settleSeconds {
                // An mtime in the future (wrong clock on the machine that wrote it, timezone slips) says nothing about whether
                // the file is still being written; waiting for that "age" would postpone the sync forever. Watch it instead.
                guard age < 0, let seen = observedFuture[key], seen.size == f.size, seen.mtimeNs == f.mtimeNs,
                      now.timeIntervalSince(seen.at) >= options.settleSeconds else {
                    if age < 0, observedFuture[key].map({ $0.size != f.size || $0.mtimeNs != f.mtimeNs }) ?? true {
                        observedFuture[key] = (f.size, f.mtimeNs, now)
                    }
                    return .skip("仍在寫入（穩定窗口）")
                }
            }
        }
        if let s = ctx.hashes[key], s.size == f.size { return .present(s, f) }
        guard let h = try FileOps.hashIfStable(f.url, size: f.size, mtimeNs: f.mtimeNs) else { return .skip("仍在寫入（穩定窗口）") }
        let st = FileState(hash: h, size: f.size)
        ctx.hashes[key] = st
        return .present(st, f)
    }

    private var observedFuture: [String: (size: Int64, mtimeNs: Int64, at: Date)] = [:]
    private lazy var materializer = Materializer()
    /// True while building a preview: a preview must not trigger downloads (or anything else).
    private var previewing = false
    private func requestDownload(_ f: ScannedFile) {
        if previewing { return }
        if let hook = options.requestDownload { hook(f.url) } else { materializer.request(f.url, size: f.size, mtimeNs: f.mtimeNs) }
    }

    private func placeholderContentHash(_ f: ScannedFile) -> String? {
        if let hook = options.placeholderHash { return hook(f.url) }
        return materializer.result(for: f.url, size: f.size, mtimeNs: f.mtimeNs)
    }

    private func allPaths(_ ctx: Context) throws -> [String] {
        var set = Set(try store.consensusPaths())
        for cfg in ctx.online {
            set.formUnion(ctx.files[cfg.id]!.keys)
            set.formUnion(ctx.rows[cfg.id]!.keys)
        }
        return set.sorted()
    }

    // MARK: public entry

    public func sync(dryRun: Bool = false, confirmed: Bool = false) throws -> SyncReport {
        var report = SyncReport()
        let interrupted = try store.interruptPending()
        if !interrupted.isEmpty {
            report.notes.append("上次有 \(interrupted.count) 個操作中斷，已安全重新評估（每個動作皆冪等）")
        }
        policy = ConflictPolicy(rawValue: try store.meta("conflictPolicy") ?? "") ?? .keepBoth
        let cfgs = try store.endpoints()
        let firstRun = try store.consensusCount() == 0

        // Preview on the current state; also drives the confirmation gates.
        var previewReport = SyncReport()
        let pctx = try buildContext(cfgs, writeMarker: false, into: &previewReport)
        report.offline = previewReport.offline
        report.notes += previewReport.notes
        previewing = true
        defer { previewing = false }
        let (planned, deletions, wipes) = try plan(pctx)
        previewing = false
        report.preview = planned
        let tracked = try store.liveConsensusCount()

        if dryRun { return report }
        let lock = try SyncLock.acquire(path: store.path + ".lock")
        defer { _ = lock }
        let newcomers = try pctx.online.filter { try !store.endpointHasHistory($0.id) }.map(\.id)
        if (firstRun || !newcomers.isEmpty) && !confirmed && !planned.isEmpty {
            report.needsConfirmation = firstRun
                ? "首次同步：以下變更尚未執行，請確認預覽後再執行"
                : "新端點（\(newcomers.joined(separator: "、"))）首次加入：以下變更尚未執行，請確認預覽後再執行"
            return report
        }
        if let w = wipes.first, !confirmed {
            report.needsConfirmation = "「\(w.ep)」的 \(w.tracked) 個檔案中有 \(w.deleted) 個同時消失（一半以上）。這可能是誤刪、磁碟或資料夾異常，請確認後再執行；確認後會把這些刪除傳到其他端點（先存入舊版本與垃圾桶）"
            return report
        }
        if options.deletionGuard.requiresConfirmation(plannedDeletions: deletions, totalTracked: tracked) && !confirmed {
            report.needsConfirmation = "預計刪除 \(deletions) 個檔案（共追蹤 \(tracked) 個），超過安全門檻，請確認後再執行"
            return report
        }

        try store.beginBatch()
        defer { try? store.endBatch() }
        for pass in 1...6 {
            var scratch = SyncReport()
            let ctx = try buildContext(cfgs, writeMarker: true, into: &scratch)
            options.afterScan?()
            let before = report.work
            do { try runPass(ctx, &report) }
            catch let c as SimulatedCrash { store.rollbackBatch(); throw c }   // a real crash would lose the uncommitted writes
            report.passes = pass
            if report.work == before {
                if report.skipped.contains(where: { $0.contains("穩定窗口") }) && pass < 6 {
                    report.skipped.removeAll(where: { $0.contains("穩定窗口") })
                    Thread.sleep(forTimeInterval: options.settleSeconds)
                    continue
                }
                break
            }
        }
        return report
    }

    // MARK: planning (no mutation)

    private func plan(_ ctx: Context) throws -> ([String], Int, [(ep: String, deleted: Int, tracked: Int)]) {
        var lines: [String] = [], deleted = Set<String>()
        var deletedAt: [String: Int] = [:]
        var skipPaths: [String: Set<String>] = [:]            // renamed paths are described once, not as delete + new
        for cfg in ctx.online {
            for m in try detectMoves(ctx, cfg) {
                skipPaths[cfg.id, default: []].formUnion([m.from, m.to])
                lines.append("[\(cfg.id)] 重新命名 \(m.from) → \(m.to)（其他端點直接改名，不重新傳輸）")
            }
        }
        for path in try allPaths(ctx) {
            let cons = try store.consensus(path)
            for cfg in ctx.online {
                if skipPaths[cfg.id]?.contains(path) == true { continue }
                guard case let l = try live(ctx, cfg.id, path), !isSkip(l) else { continue }
                let row = ctx.rows[cfg.id]![path]
                let cur = state(of: l)
                let isDir = (cur ?? row?.state ?? cons?.state)?.kind == .directory
                let what = isDir ? "資料夾 " : ""
                let d = Reconciler.decide(PathObservation(snapshot: row?.state, current: cur, seenRev: row?.seenRev ?? 0), consensus: cons)
                switch d {
                case .noop, .markSeen: continue
                case .adoptEndpoint:
                    if cur == nil {
                        let others = ctx.online.filter { $0.id != cfg.id && ctx.files[$0.id]![path] != nil }.count
                        if !isDir { deleted.insert(path); deletedAt[cfg.id, default: 0] += 1 }
                        lines.append("[\(cfg.id)] 刪除\(what)\(path)（將移除其他 \(others) 端的副本）")
                    } else {
                        lines.append("[\(cfg.id)] 新增/修改\(what)\(path) → 其他端點")
                    }
                case .applyConsensus:
                    if cons?.state == nil { if cur != nil { if !isDir { deleted.insert(path) }; lines.append("[\(cfg.id)] 移到垃圾桶 \(what)\(path)") } }
                    else { lines.append("[\(cfg.id)] 取得\(what)\(path)") }
                case .conflict:
                    lines.append("[\(cfg.id)] 衝突 \(path)")
                }
            }
        }
        let wipes = ctx.online.compactMap { cfg -> (ep: String, deleted: Int, tracked: Int)? in
            let tracked = (ctx.rows[cfg.id] ?? [:]).values.filter { $0.state?.kind == .file }.count
            let d = deletedAt[cfg.id] ?? 0
            return (d >= 3 && d * 2 >= tracked) ? (cfg.id, d, tracked) : nil
        }
        return (lines, deleted.count, wipes)
    }

    private func isSkip(_ l: Live) -> Bool { if case .skip = l { return true } else { return false } }
    private func state(of l: Live) -> FileState? { if case .present(let s, _) = l { return s } else { return nil } }

    // MARK: one pass

    private func runPass(_ ctx: Context, _ report: inout SyncReport) throws {
        // 1) Renames made on an endpoint are adopted as one move, not as "delete + new file".
        for cfg in ctx.online { try adoptMoves(ctx, cfg, &report) }
        // 2) The other endpoints repeat the rename locally, so nothing is transferred again.
        try applyMoves(ctx, &report)

        // 3) Everything else, parents before children.
        var removedDirs: [(cfg: EndpointConfig, path: String, file: ScannedFile, rev: Int)] = []
        for path in try allPaths(ctx) {
            for cfg in ctx.online {
                let l = try live(ctx, cfg.id, path)
                if case .skip(let why) = l { report.skipped.append("[\(cfg.id)] \(path)：\(why)"); continue }
                let cur = state(of: l)
                let file: ScannedFile? = { if case .present(_, let f) = l { return f } else { return nil } }()
                let row = try store.row(cfg.id, path)
                let cons = try store.consensus(path)
                var decision = Reconciler.decide(PathObservation(snapshot: row?.state, current: cur, seenRev: row?.seenRev ?? 0), consensus: cons)
                if decision == .applyConsensus, cur == cons?.state { decision = .markSeen }
                if decision == .applyConsensus, cons?.state == nil, let f = file, f.isDirectory {
                    removedDirs.append((cfg, path, f, cons?.rev ?? 0)); continue
                }
                do {
                    try applyDecision(decision, ctx, cfg, path, cur, file, row, cons, &report)
                } catch let c as SimulatedCrash { throw c
                } catch {
                    // One failing file (permission, I/O) must not stop the rest of the sync.
                    report.skipped.append("[\(cfg.id)] \(path)：操作失敗，稍後重試（\(error.localizedDescription)）")
                }
            }
        }

        report.integrity = Array(Set(report.integrity).union(ctx.integrity)).sorted()
        for root in ctx.wroteToRemovable { FileOps.syncDirectory(URL(fileURLWithPath: root)) }   // one drive-cache flush per pass

        // 4) Folders removed elsewhere: last, deepest first, and only once nothing but litter is left inside.
        for d in removedDirs.sorted(by: { $0.path > $1.path }) {
            do { try removeDirectory(ctx, d.cfg, d.path, d.file, d.rev, &report) }
            catch let c as SimulatedCrash { throw c }
            catch { report.skipped.append("[\(d.cfg.id)] \(d.path)：刪除資料夾失敗，稍後重試（\(error.localizedDescription)）") }
        }
    }

    private func removeDirectory(_ ctx: Context, _ cfg: EndpointConfig, _ path: String, _ f: ScannedFile, _ rev: Int,
                                 _ report: inout SyncReport) throws {
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: f.url.path)) ?? []
        guard contents.allSatisfy({ options.ignore.isLitter(component: $0) }) else {
            report.skipped.append("[\(cfg.id)] \(path)：資料夾內還有尚未同步的項目，暫不刪除"); return
        }
        try perform("trash", cfg.id, path) { try options.trash(f.url) }
        ctx.files[cfg.id]![path] = nil
        try store.setRow(cfg.id, path, state: nil, mtimeNs: 0, seenRev: rev)
        report.work += 1
        note(&report, "[\(cfg.id)] 移到垃圾桶（資料夾）\(path)")
    }

    // MARK: renames

    /// Pairs "deleted P" with "new Q" on one endpoint when the content is identical. Pure: no mutation.
    private func detectMoves(_ ctx: Context, _ cfg: EndpointConfig) throws -> [(from: String, to: String, state: FileState, file: ScannedFile)] {
        let rows = ctx.rows[cfg.id] ?? [:]
        let files = ctx.files[cfg.id] ?? [:]
        var gone: [Int64: [String]] = [:]
        for (p, row) in rows {
            guard let st = row.state, st.kind == .file, st.size > 0, files[p] == nil else { continue }
            if (try store.consensus(p)?.rev ?? 0) > row.seenRev { continue }       // changed elsewhere too: not a plain rename
            gone[st.size, default: []].append(p)
        }
        if gone.isEmpty { return [] }
        for k in gone.keys { gone[k]!.sort() }
        var out: [(String, String, FileState, ScannedFile)] = []
        for q in files.keys.sorted() {
            guard let f = files[q], !f.isDirectory, gone[f.size]?.isEmpty == false else { continue }
            if rows[q]?.state != nil { continue }                                  // Q is already known: not new
            if (try store.consensus(q)?.rev ?? 0) > (rows[q]?.seenRev ?? 0) { continue }
            guard case .present(let st, _) = try live(ctx, cfg.id, q), st.kind == .file else { continue }
            if let i = gone[f.size]!.firstIndex(where: { rows[$0]!.state!.hash == st.hash }) {
                let p = gone[f.size]!.remove(at: i)
                out.append((p, q, st, f))
            }
        }
        return out
    }

    private func adoptMoves(_ ctx: Context, _ cfg: EndpointConfig, _ report: inout SyncReport) throws {
        for m in try detectMoves(ctx, cfg) {
            let revP = (try store.consensus(m.from)?.rev ?? 0) + 1
            try store.setConsensus(m.from, state: nil, rev: revP)
            try store.setRow(cfg.id, m.from, state: nil, mtimeNs: 0, seenRev: revP)
            let revQ = (try store.consensus(m.to)?.rev ?? 0) + 1
            try store.setConsensus(m.to, state: m.state, rev: revQ, movedFrom: m.from)
            try store.setRow(cfg.id, m.to, state: m.state, mtimeNs: m.file.mtimeNs, seenRev: revQ)
            report.work += 1
            note(&report, "[\(cfg.id)] 偵測到重新命名 \(m.from) → \(m.to)")
        }
    }

    private func applyMoves(_ ctx: Context, _ report: inout SyncReport) throws {
        for (q, cons) in try store.movedEntries() {
            guard let p = cons.movedFrom, let want = cons.state, want.kind == .file,
                  let consP = try store.consensus(p), consP.state == nil else { continue }
            for cfg in ctx.online {
                if (try store.row(cfg.id, q)?.seenRev ?? 0) >= cons.rev { continue }          // already applied here
                guard ctx.files[cfg.id]?[q] == nil, let fp = ctx.files[cfg.id]?[p], !fp.isDirectory, fp.size == want.size,
                      let rowP = try store.row(cfg.id, p), rowP.state == want, rowP.mtimeNs == fp.mtimeNs,   // P is untouched since alignment
                      unchanged(fp), portableProblem(cfg, q) == nil else { continue }
                let dst = URL(fileURLWithPath: cfg.root).appendingPathComponent(q)
                do {
                    try perform("move", cfg.id, q, detail: "from \(p)") {
                        try FileManager.default.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
                        guard rename(fp.url.path, dst.path) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
                    }
                } catch let c as SimulatedCrash { throw c
                } catch {
                    report.skipped.append("[\(cfg.id)] \(p) → \(q)：改名失敗，改用一般流程（\(error.localizedDescription)）"); continue
                }
                let st = FileOps.statInfo(dst)
                ctx.files[cfg.id]![p] = nil
                ctx.files[cfg.id]![q] = ScannedFile(rel: q, url: dst, size: want.size, mtimeNs: st?.mtimeNs ?? fp.mtimeNs, mtime: fp.mtime, isPlaceholder: fp.isPlaceholder)
                ctx.hashes["\(cfg.id)\u{0}\(q)"] = want
                try store.setRow(cfg.id, q, state: want, mtimeNs: st?.mtimeNs ?? fp.mtimeNs, seenRev: cons.rev)
                try store.setRow(cfg.id, p, state: nil, mtimeNs: 0, seenRev: consP.rev)
                report.work += 1
                note(&report, "[\(cfg.id)] 改名 \(p) → \(q)（未重新傳輸）")
            }
        }
    }

    private func applyDecision(_ decision: Decision, _ ctx: Context, _ cfg: EndpointConfig, _ path: String,
                               _ cur: FileState?, _ file: ScannedFile?, _ row: EndpointRow?, _ cons: ConsensusEntry?,
                               _ report: inout SyncReport) throws {
        switch decision {
        case .noop:
            if let row, let file, row.mtimeNs != file.mtimeNs, row.state == cur {
                try store.setRow(cfg.id, path, state: cur, mtimeNs: file.mtimeNs, seenRev: row.seenRev)
            }
        case .markSeen:
            try store.setRow(cfg.id, path, state: cur, mtimeNs: file?.mtimeNs ?? 0, seenRev: cons?.rev ?? 0)
        case .adoptEndpoint:
            let rev = (cons?.rev ?? 0) + 1
            try store.setConsensus(path, state: cur, rev: rev)
            try store.setRow(cfg.id, path, state: cur, mtimeNs: file?.mtimeNs ?? 0, seenRev: rev)
            report.work += 1
            note(&report, "[\(cfg.id)] \(cur == nil ? "偵測到刪除" : "偵測到變更") \(path)")
        case .applyConsensus:
            try applyConsensus(ctx, cfg, path, cons, file, &report)
        case .conflict:
            try resolveConflict(ctx, cfg, path, cons!, file!, cur!, &report)
        }
    }

    /// A destructive step (trash, rename, overwrite) acts on the file as it was when scanned. If the user touched it since
    /// (a scan of a big tree takes a while), the step is abandoned and the file is evaluated again on the next pass.
    private func unchanged(_ f: ScannedFile) -> Bool {
        guard let st = FileOps.statInfo(f.url) else { return false }
        return st.size == f.size && st.mtimeNs == f.mtimeNs
    }

    /// Free space of a volume, cached for 20 s and reduced by what this engine has written since: the system call that
    /// includes purgeable space costs milliseconds, which added up to a minute on a 12,000-file first sync.
    private var spaceCache: [String: (free: Int64, at: Date)] = [:]
    private var spaceUsed: [String: Int64] = [:]
    private func freeBytes(_ root: String) -> Int64? {
        if let hook = options.freeSpace { return hook(URL(fileURLWithPath: root)) }
        let now = options.now()
        if let c = spaceCache[root], now.timeIntervalSince(c.at) < 20 { return c.free - (spaceUsed[root] ?? 0) }
        let v = (try? URL(fileURLWithPath: root).resourceValues(forKeys: [.volumeAvailableCapacityKey]))?.volumeAvailableCapacity
        guard let v else { return nil }
        spaceCache[root] = (Int64(v), now); spaceUsed[root] = 0
        return Int64(v)
    }

    private var failures: [String: (count: Int, retryAt: Date)] = [:]
    private func failed(_ key: String) {
        let n = (failures[key]?.count ?? 0) + 1
        failures[key] = (n, options.now().addingTimeInterval(min(1800, 10 * pow(2, Double(n - 1)))))
    }

    private func note(_ report: inout SyncReport, _ line: String) {
        report.actions.append(line)
        options.log(line)
    }

    private func perform(_ op: String, _ ep: String, _ path: String, detail: String = "", _ body: () throws -> Void) throws {
        let id = try store.journalBegin(op: op, endpoint: ep, path: path, detail: detail)
        do {
            try options.failpoint?("\(op):before")
            try body()
            try options.failpoint?("\(op):after")
            try store.journalEnd(id, status: "done")
        } catch { try? store.journalEnd(id, status: "failed: \(error)"); throw error }
    }

    private func holder(_ ctx: Context, excluding ep: String, _ path: String, _ want: FileState) throws -> ScannedFile? {
        for other in ctx.online where other.id != ep {
            if case .present(let s, let f) = try live(ctx, other.id, path), s.hash == want.hash, !f.isDirectory {
                if f.isPlaceholder && placeholderContentHash(f) == nil { requestDownload(f); continue }   // content still in the cloud: read it first
                return f
            }
        }
        return nil
    }

    private func portableProblem(_ cfg: EndpointConfig, _ path: String) -> String? {
        guard cfg.portableNames else { return nil }
        let p = PortableName.problems(inRelativePath: path, rootLength: cfg.root.utf16.count)
        return p.isEmpty ? nil : "檔名不相容 exFAT/Windows \(p)"
    }

    private func applyConsensus(_ ctx: Context, _ cfg: EndpointConfig, _ path: String, _ cons: ConsensusEntry?,
                                _ file: ScannedFile?, _ report: inout SyncReport) throws {
        let rev = cons?.rev ?? 0
        if let want = cons?.state, want.kind == .directory {
            if let f = file, !f.isDirectory { report.skipped.append("[\(cfg.id)] \(path)：本端是檔案、其他端點是資料夾（類型衝突），請手動處理"); return }
            if file == nil {
                if let why = portableProblem(cfg, path) { report.skipped.append("[\(cfg.id)] \(path)：\(why)"); return }
                let url = URL(fileURLWithPath: cfg.root).appendingPathComponent(path)
                try perform("mkdir", cfg.id, path) { try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
                ctx.files[cfg.id]![path] = ScannedFile(rel: path, url: url, size: 0, mtimeNs: 0, mtime: Date(), isPlaceholder: false, isDirectory: true)
                report.work += 1
                note(&report, "[\(cfg.id)] 建立資料夾 \(path)")
            }
            try store.setRow(cfg.id, path, state: want, mtimeNs: 0, seenRev: rev)
            return
        }
        if file?.isDirectory == true { report.skipped.append("[\(cfg.id)] \(path)：本端是資料夾、其他端點是檔案（類型衝突），請手動處理"); return }
        guard let want = cons?.state else {
            if let file {
                guard unchanged(file) else { report.skipped.append("[\(cfg.id)] \(path)：刪除前發現檔案又被改動，已取消，下一輪重新評估"); return }
                try archiveVersion(file, endpoint: cfg.id)       // Trash can be emptied at any time: keep our own copy too
                try perform("trash", cfg.id, path) { try options.trash(file.url) }
                ctx.files[cfg.id]![path] = nil
                report.work += 1
                note(&report, "[\(cfg.id)] 移到垃圾桶 \(path)")
            }
            try store.setRow(cfg.id, path, state: nil, mtimeNs: 0, seenRev: rev)
            return
        }
        if let why = portableProblem(cfg, path) { report.skipped.append("[\(cfg.id)] \(path)：\(why)"); return }
        guard let src = try holder(ctx, excluding: cfg.id, path, want) else {
            report.skipped.append("[\(cfg.id)] \(path)：目前沒有在線端點持有此版本內容，稍後重試"); return
        }
        let dst = URL(fileURLWithPath: cfg.root).appendingPathComponent(path)
        if let file, !unchanged(file) {
            report.skipped.append("[\(cfg.id)] \(path)：目標在準備期間被改動，下一輪重新評估"); return
        }
        let failKey = "\(cfg.id)\u{0}\(path)"
        if let f = failures[failKey], options.now() < f.retryAt {
            report.skipped.append("[\(cfg.id)] \(path)：先前失敗 \(f.count) 次，稍後自動重試"); return
        }
        let free = freeBytes(cfg.root)
        if let free, free < want.size + 64 * 1024 * 1024 {
            failed(failKey)
            report.skipped.append("[\(cfg.id)] \(path)：磁碟可用空間不足（需要 \(ByteCountFormatter.string(fromByteCount: want.size, countStyle: .file))）"); return
        }
        do {
            try perform("copy", cfg.id, path, detail: "from \(src.url.path)") {
                if let file { try archiveVersion(file, endpoint: cfg.id) }
                try FileOps.copyAtomically(from: src.url, to: dst, expectHash: want.hash, mtime: src.mtime, durable: cfg.removable)
            }
            failures[failKey] = nil
            spaceUsed[cfg.root, default: 0] += want.size
            if cfg.removable { ctx.wroteToRemovable.insert(cfg.root) }
        } catch FileOps.CopyError.sourceChanged {
            report.skipped.append("[\(cfg.id)] \(path)：來源在複製途中改變，稍後重試"); return
        } catch let c as SimulatedCrash { throw c
        } catch {
            failed(failKey)
            report.skipped.append("[\(cfg.id)] \(path)：複製失敗 \(error)"); return
        }
        let st = FileOps.statInfo(dst)
        let sf = ScannedFile(rel: path, url: dst, size: st?.size ?? want.size, mtimeNs: st?.mtimeNs ?? 0,
                             mtime: src.mtime, isPlaceholder: false)
        ctx.files[cfg.id]![path] = sf
        ctx.hashes["\(cfg.id)\u{0}\(path)"] = want
        try store.setRow(cfg.id, path, state: want, mtimeNs: sf.mtimeNs, seenRev: rev)
        report.work += 1
        note(&report, "[\(cfg.id)] 寫入 \(path)")
    }

    private func resolveConflict(_ ctx: Context, _ cfg: EndpointConfig, _ path: String, _ cons: ConsensusEntry,
                                 _ file: ScannedFile, _ cur: FileState, _ report: inout SyncReport) throws {
        guard let want = cons.state else { return }
        if cur.kind == .directory || want.kind == .directory {
            report.skipped.append("[\(cfg.id)] \(path)：檔案與資料夾的類型衝突，請手動處理"); return
        }
        guard let src = try holder(ctx, excluding: cfg.id, path, want) else {
            report.skipped.append("[\(cfg.id)] \(path)：衝突，但目前沒有在線端點持有對方版本，稍後重試"); return
        }

        if policy == .newerWins {
            let diff = file.mtime.timeIntervalSince(src.mtime)
            if abs(diff) > 2 {   // inside 2 s (exFAT granularity, clock noise) nobody can say which is newer
                if diff > 0 {
                    // This endpoint's version is newer: it becomes the consensus; older copies are archived as they are replaced.
                    let rev = cons.rev + 1
                    try store.setConsensus(path, state: cur, rev: rev)
                    try store.setRow(cfg.id, path, state: cur, mtimeNs: file.mtimeNs, seenRev: rev)
                    report.work += 1
                    note(&report, "[\(cfg.id)] 衝突 \(path)：本端版本較新，採用；其他端點的舊版會存入 Versions")
                } else {
                    // The consensus version is newer: it replaces this endpoint's file, which is archived first.
                    var r2 = SyncReport()
                    try applyConsensus(ctx, cfg, path, cons, file, &r2)
                    report.skipped += r2.skipped; report.actions += r2.actions; report.work += r2.work
                    if r2.work > 0 { note(&report, "[\(cfg.id)] 衝突 \(path)：其他端點版本較新，採用；本端舊版已存入 Versions") }
                }
                return
            }
        }

        let ns = path as NSString
        let dir = ns.deletingLastPathComponent
        var name = ConflictNaming.name(for: ns.lastPathComponent, endpoint: cfg.id, date: options.now())
        var target = URL(fileURLWithPath: cfg.root).appendingPathComponent(dir).appendingPathComponent(name)
        var n = 2
        while FileManager.default.fileExists(atPath: target.path) {
            name = ConflictNaming.name(for: ns.lastPathComponent, endpoint: "\(cfg.id) \(n)", date: options.now())
            target = target.deletingLastPathComponent().appendingPathComponent(name); n += 1
        }
        guard unchanged(file) else { report.skipped.append("[\(cfg.id)] \(path)：處理衝突前發現檔案又被改動，下一輪重新評估"); return }
        try perform("conflict-rename", cfg.id, path, detail: name) {
            try FileManager.default.moveItem(at: file.url, to: target)
        }
        ctx.files[cfg.id]![path] = nil
        try store.setRow(cfg.id, path, state: nil, mtimeNs: 0, seenRev: 0)   // forces a clean fetch of the consensus version
        var r2 = SyncReport()
        try applyConsensus(ctx, cfg, path, cons, nil, &r2)
        report.skipped += r2.skipped; report.actions += r2.actions; report.work += r2.work + 1
        // The extra copy is recorded and stays on this endpoint only (see ConflictNaming.isConflictName).
        try store.addConflict(endpoint: cfg.id, path: path, conflictPath: dir.isEmpty ? name : dir + "/" + name, at: options.now())
        note(&report, "[\(cfg.id)] 衝突 \(path)：本端版本保留為「\(name)」，只留在此端點")
    }

    /// Puts an archived version back at its original place on its endpoint. The file it replaces is archived first, and the
    /// restored file counts as an ordinary edit there, so the next sync spreads it to the other endpoints.
    public func restoreVersion(_ item: VersionItem) throws {
        let lock = try SyncLock.acquire(path: store.path + ".lock")
        defer { _ = lock }
        guard let cfg = try store.endpoints().first(where: { $0.id == item.endpoint }) else {
            throw DBError(description: "端點「\(item.endpoint)」已不存在")
        }
        if case .offline(let why) = try checkIdentity(cfg) { throw DBError(description: "端點「\(cfg.id)」目前離線：\(why)") }
        let dst = URL(fileURLWithPath: cfg.root).appendingPathComponent(item.path)
        if let why = portableProblem(cfg, item.path) { throw DBError(description: why) }
        let hash = try FileOps.sha256(of: item.url)
        try perform("restore", cfg.id, item.path, detail: "from \(item.url.lastPathComponent)") {
            if let st = FileOps.statInfo(dst) {
                try archiveVersion(ScannedFile(rel: item.path, url: dst, size: st.size, mtimeNs: st.mtimeNs, mtime: Date(), isPlaceholder: false), endpoint: cfg.id)
            }
            try FileOps.copyAtomically(from: item.url, to: dst, expectHash: hash, mtime: nil, durable: cfg.removable)
        }
    }

    /// Resolve one recorded conflict on its endpoint. `.main` keeps the file that is in sync with the other
    /// endpoints and trashes the extra copy; `.conflict` makes the extra copy the real file (the previous
    /// version goes to Versions) and the next sync spreads it to every endpoint.
    public func resolveConflictRecord(_ id: Int64, keep: ConflictChoice) throws {
        let lock = try SyncLock.acquire(path: store.path + ".lock")
        defer { _ = lock }
        guard let c = try store.conflict(id: id) else { throw DBError(description: "找不到這個衝突紀錄") }
        guard let cfg = try store.endpoints().first(where: { $0.id == c.endpoint }) else {
            throw DBError(description: "端點「\(c.endpoint)」已不存在")
        }
        if case .offline(let why) = try checkIdentity(cfg) { throw DBError(description: "端點「\(c.endpoint)」目前離線：\(why)") }
        let root = URL(fileURLWithPath: cfg.root)
        let mainURL = root.appendingPathComponent(c.path), extraURL = root.appendingPathComponent(c.conflictPath)
        guard FileManager.default.fileExists(atPath: extraURL.path) else {
            try store.closeConflict(id: id, status: "gone"); return
        }
        switch keep {
        case .main:
            try perform("conflict-keep-main", c.endpoint, c.path) { try options.trash(extraURL) }
        case .conflict:
            let hash = try FileOps.sha256(of: extraURL)
            let mtime = (try? extraURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
            try perform("conflict-keep-copy", c.endpoint, c.path) {
                if let st = FileOps.statInfo(mainURL) {
                    try archiveVersion(ScannedFile(rel: c.path, url: mainURL, size: st.size, mtimeNs: st.mtimeNs, mtime: Date(), isPlaceholder: false),
                                       endpoint: c.endpoint)
                }
                try FileOps.copyAtomically(from: extraURL, to: mainURL, expectHash: hash, mtime: mtime)
                try options.trash(extraURL)
            }
        }
        let closed = keep == .main ? "kept-main" : "kept-copy"
        try store.closeConflict(id: id, status: closed)
    }

    /// Copies `file` into the Versions archive. Never overwrites an earlier archived copy: two replacements of the same
    /// file within one second used to collide ("File exists"), which made the replacement itself fail and retry forever.
    private func archiveVersion(_ file: ScannedFile, endpoint: String) throws {
        guard let base = options.versionsDir, file.size <= options.maxVersionBytes else { return }
        let stamp = ISO8601DateFormatter().string(from: options.now()).replacingOccurrences(of: ":", with: "-")
        var dest = base.appendingPathComponent(stamp).appendingPathComponent(endpoint).appendingPathComponent(file.rel)
        try FileManager.default.createDirectory(at: dest.deletingLastPathComponent(), withIntermediateDirectories: true)
        var n = 2
        while FileManager.default.fileExists(atPath: dest.path) {
            let ns = file.rel as NSString
            let name = ns.pathExtension.isEmpty ? "\(ns.lastPathComponent) (\(n))" : "\((ns.lastPathComponent as NSString).deletingPathExtension) (\(n)).\(ns.pathExtension)"
            dest = dest.deletingLastPathComponent().appendingPathComponent(name)
            n += 1
        }
        try FileManager.default.copyItem(at: file.url, to: dest)
    }
}
