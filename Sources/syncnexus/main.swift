import Foundation
import SyncCore

func fail(_ msg: String) -> Never { FileHandle.standardError.write(Data((msg + "\n").utf8)); exit(2) }

setvbuf(stdout, nil, _IOLBF, 0)
var args = Array(CommandLine.arguments.dropFirst())
let command = args.isEmpty ? "help" : args.removeFirst()

func flag(_ name: String) -> Bool {
    if let i = args.firstIndex(of: name) { args.remove(at: i); return true }
    return false
}
func option(_ name: String) -> String? {
    guard let i = args.firstIndex(of: name), i + 1 < args.count else { return nil }
    let v = args[i + 1]; args.removeSubrange(i...i + 1); return v
}
func values(_ name: String) -> [String] {
    var out: [String] = []
    while let v = option(name) { out.append(v) }
    return out
}

let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("SyncNexus")
let dbPath = option("--db") ?? appSupport.appendingPathComponent("state.db").path

func openEngine() throws -> Engine {
    try FileManager.default.createDirectory(atPath: (dbPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
    let store = try Store(path: dbPath)
    var opts = EngineOptions()
    opts.versionsDir = appSupport.appendingPathComponent("Versions")
    opts.log = { print("  \($0)") }
    return Engine(store: store, options: opts)
}

func printReport(_ r: SyncReport, dryRun: Bool) {
    for o in r.offline { print("⚠︎ 離線/停止  \(o)") }
    for n in r.notes { print("ℹ︎ \(n)") }
    if dryRun || r.needsConfirmation != nil {
        print(dryRun ? "— 預覽（以目前狀態逐端點計算，傳播後的二次動作未列出）—" : "— 預覽 —")
        if r.preview.isEmpty { print("  沒有需要執行的變更") }
        r.preview.forEach { print("  \($0)") }
    }
    for s in Set(r.skipped).sorted() { print("↷ 略過  \(s)") }
    for i in r.integrity { print("‼︎ 內容與紀錄不符（疑似損壞）：\(i)") }
    if let c = r.needsConfirmation { print("✋ \(c)"); return }
    if !dryRun { print("完成：\(r.work) 個動作，\(r.passes) 輪") }
}

do {
    switch command {
    case "init":
        // --endpoint name=/path[,removable][,portable]
        let specs = values("--endpoint")
        guard specs.count >= 2 else { fail("至少需要兩個 --endpoint name=/path[,removable][,portable]") }
        let engine = try openEngine()
        for spec in specs {
            let parts = spec.split(separator: ",").map(String.init)
            guard let eq = parts[0].firstIndex(of: "=") else { fail("格式錯誤：\(spec)") }
            let name = String(parts[0][..<eq]), root = String(parts[0][parts[0].index(after: eq)...])
            try FileManager.default.createDirectory(atPath: root, withIntermediateDirectories: true)
            let cfg = EndpointConfig(id: name, root: root, removable: parts.contains("removable"),
                                     portableNames: parts.contains("portable"),
                                     volumeUUID: FileOps.volumeUUID(of: URL(fileURLWithPath: root)))
            try engine.store.addEndpoint(cfg)
            print("端點 \(name) → \(root)\(cfg.removable ? "（可移除）" : "")\(cfg.portableNames ? "（檔名須相容 exFAT/Windows）" : "")")
        }
        print("資料庫：\(dbPath)")

    case "relink":
        // relink <name>=/new/path : keep the group's data, point one endpoint at a new folder
        guard let spec = args.first, let eq = spec.firstIndex(of: "=") else { fail("用法：relink name=/新路徑") }
        let name = String(spec[..<eq]), root = String(spec[spec.index(after: eq)...])
        let engine = try openEngine()
        guard try engine.store.endpoints().contains(where: { $0.id == name }) else { fail("沒有名為 \(name) 的端點") }
        try FileManager.default.createDirectory(atPath: root, withIntermediateDirectories: true)
        try engine.store.relinkEndpoint(id: name, root: root, volumeUUID: FileOps.volumeUUID(of: URL(fileURLWithPath: root)))
        print("端點 \(name) 已改指向 \(root)；下次同步會把群組內容補進去，不會推導任何刪除。建議先執行 sync --dry-run 檢視。")

    case "versions":
        let engine = try openEngine()
        let dir = appSupport.appendingPathComponent("Versions")
        let days = Int((try engine.store.meta("versionsRetentionDays")) ?? "") ?? 30
        if let v = option("--retention") { try engine.store.setMeta("versionsRetentionDays", v); print("保留天數：\(v)（0 = 永久）") }
        if flag("--purge-all") {
            let r = Versions.purgeAll(dir); print("已全部清除：\(r.files) 個檔案，\(ByteCountFormatter.string(fromByteCount: r.bytes, countStyle: .file))")
        } else if flag("--purge") {
            let r = Versions.purge(dir, olderThanDays: days, maxBytes: 20 * 1_073_741_824)
            print("已清除過期版本：\(r.files) 個檔案，\(ByteCountFormatter.string(fromByteCount: r.bytes, countStyle: .file))")
        }
        let u = Versions.usage(dir)
        print("舊版本：\(u.files) 個檔案，\(ByteCountFormatter.string(fromByteCount: u.bytes, countStyle: .file))，保留 \(days) 天，位置 \(dir.path)")

    case "policy":
        let engine = try openEngine()
        if let v = args.first {
            guard let p = ["keep-both": ConflictPolicy.keepBoth, "newer-wins": .newerWins][v] else { fail("用法：policy keep-both|newer-wins") }
            try engine.store.setMeta("conflictPolicy", p.rawValue)
        }
        let cur = ConflictPolicy(rawValue: try engine.store.meta("conflictPolicy") ?? "") ?? .keepBoth
        print("衝突策略：\(cur == .keepBoth ? "保留兩份 (keep-both)" : "採用較新的 (newer-wins)")")

    case "conflicts":
        let engine = try openEngine()
        let list = try engine.store.openConflicts()
        if list.isEmpty { print("沒有待處理的衝突") }
        for c in list { print("#\(c.id)\t[\(c.endpoint)] \(c.path)\t額外副本：\(c.conflictPath)") }

    case "resolve":
        guard args.count == 2, let id = Int64(args[0]), let keep = ["main": ConflictChoice.main, "copy": .conflict][args[1]] else {
            fail("用法：resolve <編號> main|copy   （main=保留原檔，copy=改用衝突副本）")
        }
        let engine = try openEngine()
        try engine.resolveConflictRecord(id, keep: keep)
        print("已處理衝突 #\(id)；執行 sync 讓選定的版本傳到其他端點")

    case "sync":
        let dry = flag("--dry-run"), yes = flag("--yes"), deep = flag("--deep")
        let only = option("--paths")      // incremental: comma-separated paths relative to the folders
        let engine = try openEngine()
        engine.options.deepVerify = deep
        let scope: SyncScope = only.map { .paths(Set($0.split(separator: ",").map(String.init))) } ?? .full
        printReport(try engine.sync(dryRun: dry, confirmed: yes, scope: scope), dryRun: dry)

    case "status":
        let engine = try openEngine()
        for e in try engine.store.endpoints() {
            let st = try engine.checkIdentity(e)
            let label: String = { if case .offline(let w) = st { return "離線：\(w)" } else { return "在線" } }()
            print("\(e.id)\t\(e.root)\t\(label)")
        }
        print("追蹤中檔案：\(try engine.store.liveConsensusCount())")
        print("最近活動：")
        for j in try engine.store.recentJournal(limit: 10) { print("  \(j.time) \(j.op) [\(j.endpoint)] \(j.path) \(j.status)") }

    case "watch":
        let engine = try openEngine()
        engine.options.settleSeconds = 2
        let roots = try engine.store.endpoints().map(\.root)
        let work = DispatchQueue(label: "syncnexus.sync")
        func run() {
            work.async {
                do {
                    let r = try engine.sync(confirmed: false)
                    if let c = r.needsConfirmation { print("✋ \(c)\n   請先手動執行 syncnexus sync --yes") }
                    else if r.work > 0 { print("[\(Date())] \(r.work) 個動作") }
                    for o in r.offline { print("⚠︎ \(o)") }
                } catch { print("錯誤：\(error)") }
            }
        }
        let watcher = Watcher(roots: roots) { _ in run() }
        watcher.start()
        print("監看中（Ctrl-C 結束）：\(roots.joined(separator: ", "))")
        run()
        RunLoop.main.run()

    case "serve":
        // Runs the same service as the menu bar app, headless (for tests and servers). Ctrl-C to stop.
        let logPath = option("--log") ?? appSupport.appendingPathComponent("serve.log").path
        let service = SyncService(dbPath: dbPath, versionsDir: appSupport.appendingPathComponent("Versions"), logURL: URL(fileURLWithPath: logPath)) { snap in
            print("[\(Date().formatted(date: .omitted, time: .standard))] phase=\(snap.phase) work=\(snap.lastWork) tracked=\(snap.trackedFiles) conflicts=\(snap.conflicts.count) skipped=\(snap.skipped.count)")
        }
        service.start()
        print("serving; log: \(logPath)")
        RunLoop.main.run()

    case "probe-placeholders":
        // Read-only inspection of a folder: how many cloud placeholders, and (optionally) fetch one to see it arrive.
        let download = option("--download")
        guard let dir = args.first else { fail("用法：probe-placeholders <資料夾> [--download 相對路徑]") }
        let scan = try FileOps.scan(root: URL(fileURLWithPath: dir), ignore: .default)
        let files = scan.files.values.filter { !$0.isDirectory }
        let ph = files.filter(\.isPlaceholder)
        print("檔案 \(files.count) 個；未下載的占位檔 \(ph.count) 個（\(ByteCountFormatter.string(fromByteCount: ph.reduce(0) { $0 + $1.size }, countStyle: .file))）；資料夾 \(scan.files.count - files.count) 個")
        for f in ph.sorted(by: { $0.rel < $1.rel }).prefix(8) { print("  ☁︎ \(f.rel)  \(ByteCountFormatter.string(fromByteCount: f.size, countStyle: .file))") }
        if let rel = download {
            let url = URL(fileURLWithPath: dir).appendingPathComponent(rel)
            func isDataless() -> Bool { (FileOps.statInfo(url) != nil) && (try? FileOps.scan(root: url.deletingLastPathComponent(), ignore: .default))?.files[url.lastPathComponent]?.isPlaceholder == true }
            let before = scan.files[rel]
            guard let f = before, f.isPlaceholder else { print("這個檔案已在本機，無需下載"); break }
            let t0 = Date(); let m = Materializer(); m.request(url, size: f.size, mtimeNs: f.mtimeNs)
            var hash: String?
            while hash == nil && Date().timeIntervalSince(t0) < 180 {
                Thread.sleep(forTimeInterval: 0.5)
                hash = m.result(for: url, size: f.size, mtimeNs: f.mtimeNs)
            }
            let still = (try? FileOps.scan(root: url.deletingLastPathComponent(), ignore: .default))?.files[url.lastPathComponent]?.isPlaceholder == true
            print(hash == nil ? "180 秒內未讀完" : "讀取完成，耗時 \(String(format: "%.1f", Date().timeIntervalSince(t0))) 秒，SHA-256 \(hash!.prefix(12))…；讀完後\(still ? "仍是占位檔（雲端串流）" : "已變成本機檔案")")
        }

    case "check-name":
        var bad = false
        for name in args {
            let issues = PortableName.problems(inRelativePath: name)
            print(issues.isEmpty ? "OK    \(name)" : "BAD   \(name)  \(issues)")
            bad = bad || !issues.isEmpty
        }
        exit(bad ? 1 : 0)

    default:
        print("""
        syncnexus
          init  --endpoint name=/path[,removable][,portable] ... [--db file]
          relink name=/新路徑 [--db file]
          versions [--purge] [--purge-all] [--retention 天數]
          policy [keep-both|newer-wins]
          conflicts
          resolve <編號> main|copy
          sync  [--dry-run] [--yes] [--deep] [--paths a,b] [--db file]    (--deep: 重新讀取每個檔案驗證內容)
          status [--db file]
          watch [--db file]
          check-name <relative-path>...
        """)
    }
} catch {
    fail("錯誤：\(error)")
}
