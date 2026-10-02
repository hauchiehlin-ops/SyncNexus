import Foundation
import Testing
@testable import SyncCore

/// Adversarial randomized test on real folders: random user operations on four endpoints (one of them an "ejectable disk"),
/// random simulated crashes in the middle of syncs, and then two invariants:
///   1. CONVERGENCE  – after everything is online and synced, all endpoints hold the same files and folders.
///   2. NO SILENT LOSS – every piece of content that ever existed is still somewhere (an endpoint, a conflict copy, the
///      Versions archive or the Trash), unless the user's own action destroyed its last copy.
private final class World {
    struct Rng { var s: UInt64
        mutating func next(_ n: Int) -> Int { s = s &* 6364136223846793005 &+ 1442695040888963407; return Int((s >> 33) % UInt64(n)) } }

    let base = FileManager.default.temporaryDirectory.appendingPathComponent("fz-\(UUID().uuidString)")
    let trash: URL, versions: URL
    let store: Store
    let engine: Engine
    let names = ["A", "B", "C", "D"]
    var offline: Set<String> = []
    var rng: Rng
    var counter = 0
    var created = Set<String>()
    var forgiven = Set<String>()
    var log: [String] = []
    let paths: [String]
    var crashAt: Int?
    var calls = 0
    var crashes = 0
    var lastReport = SyncReport()
    var dirty = Set<String>()          // what FSEvents would have reported since the last sync
    var needFull = true

    init(seed: UInt64, caseVariants: Bool) throws {
        rng = Rng(s: seed &* 7919 &+ 17)
        trash = base.appendingPathComponent("_trash"); versions = base.appendingPathComponent("_versions")
        try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
        store = try Store(path: base.appendingPathComponent("state.db").path)
        var o = EngineOptions()
        o.settleSeconds = 0; o.versionsDir = versions
        let t = trash
        o.trash = { try FileManager.default.moveItem(at: $0, to: t.appendingPathComponent(UUID().uuidString + "-" + $0.lastPathComponent)) }
        engine = Engine(store: store, options: o)
        paths = ["a.txt", "b.txt", "c.txt", "d1/x.txt", "d1/y.txt", "d1/sub/z.txt", "d2/w.txt"] + (caseVariants ? ["Case.txt", "case.txt"] : [])
        for n in names {
            try FileManager.default.createDirectory(at: base.appendingPathComponent(n), withIntermediateDirectories: true)
            try store.addEndpoint(EndpointConfig(id: n, root: base.appendingPathComponent(n).path, removable: n == "D"))
        }
        engine.options.failpoint = { [unowned self] _ in
            self.calls += 1
            if let k = self.crashAt, self.calls == k { self.crashAt = nil; throw SimulatedCrash() }
        }
    }
    deinit { try? FileManager.default.removeItem(at: base) }

    func root(_ e: String) -> URL { offline.contains(e) ? base.appendingPathComponent("_away-\(e)") : base.appendingPathComponent(e) }
    func url(_ e: String, _ p: String) -> URL { root(e).appendingPathComponent(p) }
    func allContents(in dirs: [URL]) -> [String: Int] {
        var out: [String: Int] = [:]
        for d in dirs {
            guard let en = FileManager.default.enumerator(at: d, includingPropertiesForKeys: [.isRegularFileKey]) else { continue }
            for case let u as URL in en {
                if (try? u.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true,
                   !u.lastPathComponent.hasPrefix("."), let s = try? String(contentsOf: u, encoding: .utf8) { out[s, default: 0] += 1 }
            }
        }
        return out
    }
    var endpointDirs: [URL] { names.map { root($0) } }

    /// Forgive the loss of `content` only if the user's action removed its last copy anywhere.
    func userDestroys(_ content: String?) {
        guard let content else { return }
        let others = allContents(in: endpointDirs + [versions, trash])
        if (others[content] ?? 0) <= 1 { forgiven.insert(content) }      // the copy about to disappear is the only one
    }

    func write(_ e: String, _ p: String) throws {
        counter += 1; let c = "tok\(counter)-\(String(repeating: "x", count: rng.next(30)))"
        let u = url(e, p)
        try FileManager.default.createDirectory(at: u.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let old = try? String(contentsOf: u, encoding: .utf8) { userDestroys(old) }
        try c.write(to: u, atomically: false, encoding: .utf8)
        created.insert(c); dirty.insert(p); log.append("write \(e):\(p)=\(c.prefix(8))")
    }

    func step() throws {
        let e = names[rng.next(4)], p = paths[rng.next(paths.count)]
        switch rng.next(12) {
        case 0, 1, 2, 3: try write(e, p)
        case 4: if let s = try? String(contentsOf: url(e, p), encoding: .utf8) { userDestroys(s); try FileManager.default.removeItem(at: url(e, p)); dirty.insert(p); log.append("delete \(e):\(p)") }
        case 5:
            let q = paths[rng.next(paths.count)]
            if FileManager.default.fileExists(atPath: url(e, p).path), !FileManager.default.fileExists(atPath: url(e, q).path), p != q,
               (try? url(e, p).resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true {
                try FileManager.default.createDirectory(at: url(e, q).deletingLastPathComponent(), withIntermediateDirectories: true)
                try FileManager.default.moveItem(at: url(e, p), to: url(e, q)); dirty.insert(p); dirty.insert(q); log.append("move \(e):\(p)->\(q)")
            }
        case 6:
            let d = ["d1", "d2"][rng.next(2)]
            if FileManager.default.fileExists(atPath: url(e, d).path) {
                for (c, n) in allContents(in: [url(e, d)]) where n > 0 { userDestroys(c) }
                try FileManager.default.removeItem(at: url(e, d)); dirty.insert(d); log.append("rmdir \(e):\(d)")
            }
        case 7: let d = ["d3", "d3/inner", "d2"][rng.next(3)]; try FileManager.default.createDirectory(at: url(e, d), withIntermediateDirectories: true); dirty.insert(d); log.append("mkdir \(e)")
        case 8:
            if offline.contains("D") { try FileManager.default.moveItem(at: root("D"), to: base.appendingPathComponent("D")); offline.remove("D"); needFull = true; log.append("reattach D") }
            else { try FileManager.default.moveItem(at: base.appendingPathComponent("D"), to: base.appendingPathComponent("_away-D")); offline.insert("D"); log.append("eject D") }
        default: try sync(allowCrash: true)
        }
    }

    func sync(allowCrash: Bool) throws {
        calls = 0
        crashAt = (allowCrash && rng.next(3) == 0) ? 1 + rng.next(12) : nil
        let incremental = !needFull && !dirty.isEmpty && rng.next(3) != 0 && allowCrash   // a third of the runs are periodic full scans
        let scope: SyncScope = incremental ? .paths(dirty) : .full
        dirty = []
        if !incremental { needFull = false }
        do { lastReport = try engine.sync(confirmed: true, scope: scope); log.append(incremental ? "sync(inc)" : "sync") }
        catch is SimulatedCrash { crashes += 1; needFull = true; log.append("CRASH@\(calls)") }
        crashAt = nil
    }

    func fileMap(_ e: String) -> [String: String] {
        var m: [String: String] = [:]
        let scan = (try? FileOps.scan(root: base.appendingPathComponent(e), ignore: .default)) ?? ScanResult()
        for f in scan.files.values where !f.isDirectory { m[f.rel.lowercased()] = try? String(contentsOf: f.url, encoding: .utf8) }   // case-only spelling differences are cosmetic
        return m
    }
    /// Folders that legitimately survive on one endpoint because they hold a conflict copy awaiting the user.
    func conflictFolders(_ e: String) -> Set<String> {
        var keep = Set<String>()
        if let en = FileManager.default.enumerator(atPath: base.appendingPathComponent(e).path) {
            for case let rel as String in en where ConflictNaming.isConflictName((rel as NSString).lastPathComponent) {
                var d = (rel as NSString).deletingLastPathComponent
                while !d.isEmpty { keep.insert(d.lowercased()); d = (d as NSString).deletingLastPathComponent }
            }
        }
        return keep
    }
    func dirSet(_ e: String) -> Set<String> {
        Set(((try? FileOps.scan(root: base.appendingPathComponent(e), ignore: .default)) ?? ScanResult()).files.values.filter(\.isDirectory).map { $0.rel.lowercased() })
    }

    func finish() throws -> [String] {
        if offline.contains("D") { try FileManager.default.moveItem(at: root("D"), to: base.appendingPathComponent("D")); offline.remove("D") }
        for _ in 0..<8 { try sync(allowCrash: false) }
        var problems: [String] = []
        let keep = names.reduce(Set<String>()) { $0.union(conflictFolders($1)) }
        let ref = fileMap("A"), refDirs = dirSet("A").subtracting(keep)
        for e in ["B", "C", "D"] {
            if fileMap(e) != ref { problems.append("files differ A vs \(e): A=\(ref.mapValues { String($0.prefix(8)) }) \(e)=\(fileMap(e).mapValues { String($0.prefix(8)) })") }
            if dirSet(e).subtracting(keep) != refDirs { problems.append("folders differ A vs \(e): \(refDirs.sorted()) vs \(dirSet(e).sorted())") }
        }
        if !problems.isEmpty { problems.append("last report: skipped=\(lastReport.skipped) offline=\(lastReport.offline) notes=\(lastReport.notes)") }
        let present = Set(allContents(in: endpointDirs + [versions, trash]).keys)
        let lost = created.subtracting(present).subtracting(forgiven)
        if !lost.isEmpty { problems.append("LOST CONTENT: \(lost.sorted().map { String($0.prefix(8)) })") }
        return problems
    }
}

@Suite("Fuzz: convergence and no silent loss")
struct FuzzTests {
    private func run(seeds: Range<UInt64>, steps: Int, caseVariants: Bool) throws {
        var failures: [String] = []
        for seed in seeds {
            let w = try World(seed: seed, caseVariants: caseVariants)
            for _ in 0..<steps { try w.step() }
            let problems = try w.finish()
            if !problems.isEmpty { failures.append("seed \(seed) (crashes \(w.crashes)): \(problems.joined(separator: " | "))\n   ops: \(w.log.suffix(25).joined(separator: "; "))") }
        }
        #expect(failures.isEmpty, Comment(rawValue: "\n" + failures.prefix(4).joined(separator: "\n")))
        if !failures.isEmpty { print("FUZZ FAILURES: \(failures.count) of \(seeds.count)") }
    }

    /// FUZZ_SCALE=10 swift test --filter FuzzTests   runs a much longer soak (default scale 1 keeps the suite fast).
    private var scale: UInt64 { UInt64(ProcessInfo.processInfo.environment["FUZZ_SCALE"] ?? "") ?? 1 }
    private var steps: Int { scale > 1 ? 70 : 40 }

    @Test func randomOperationsWithCrashesConverge() throws { try run(seeds: 0..<(60 * scale), steps: steps, caseVariants: false) }
    @Test func caseOnlyNameDifferencesAreSafe() throws { try run(seeds: 100_000..<(100_000 + 40 * scale), steps: steps, caseVariants: true) }
}
