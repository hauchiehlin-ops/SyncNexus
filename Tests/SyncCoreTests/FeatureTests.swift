import Foundation
import Testing
@testable import SyncCore

private final class ReleasedCloudFiles: @unchecked Sendable {
    private let lock = NSLock()
    private var urls: [URL] = []
    func append(_ url: URL) { lock.lock(); urls.append(url); lock.unlock() }
    func paths() -> [String] { lock.lock(); defer { lock.unlock() }; return urls.map(\.path) }
    var count: Int { lock.lock(); defer { lock.unlock() }; return urls.count }
}

private final class Env2 {
    let base = FileManager.default.temporaryDirectory.appendingPathComponent("sf-\(UUID().uuidString)")
    let store: Store
    let engine: Engine
    let trashDir: URL
    var names: [String] = []
    var downloads: [URL] = []
    var placeholders: Set<String> = []     // file names treated as not-downloaded cloud placeholders

    init(_ eps: [String]) throws {
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        trashDir = base.appendingPathComponent("_trash")
        try FileManager.default.createDirectory(at: trashDir, withIntermediateDirectories: true)
        store = try Store(path: base.appendingPathComponent("state.db").path)
        var o = EngineOptions()
        o.settleSeconds = 0
        o.versionsDir = base.appendingPathComponent("_versions")
        let t = trashDir
        o.trash = { try FileManager.default.moveItem(at: $0, to: t.appendingPathComponent(UUID().uuidString + "-" + $0.lastPathComponent)) }
        engine = Engine(store: store, options: o)
        for n in eps {
            try FileManager.default.createDirectory(at: base.appendingPathComponent(n), withIntermediateDirectories: true)
            try store.addEndpoint(EndpointConfig(id: n, root: base.appendingPathComponent(n).path))
            names.append(n)
        }
    }
    deinit { try? FileManager.default.removeItem(at: base) }

    func url(_ ep: String, _ rel: String = "") -> URL { base.appendingPathComponent(ep).appendingPathComponent(rel) }
    func write(_ ep: String, _ rel: String, _ text: String) throws {
        try FileManager.default.createDirectory(at: url(ep, rel).deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: url(ep, rel), atomically: true, encoding: .utf8)
    }
    func read(_ ep: String, _ rel: String) -> String? { try? String(contentsOf: url(ep, rel), encoding: .utf8) }
    func mkdir(_ ep: String, _ rel: String) throws { try FileManager.default.createDirectory(at: url(ep, rel), withIntermediateDirectories: true) }
    func exists(_ ep: String, _ rel: String) -> Bool { FileManager.default.fileExists(atPath: url(ep, rel).path) }
    func move(_ ep: String, _ a: String, _ b: String) throws {
        try FileManager.default.createDirectory(at: url(ep, b).deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.moveItem(at: url(ep, a), to: url(ep, b))
    }
    func makeArchive(_ name: String) throws {
        var cfg = try #require(store.endpoints().first(where: { $0.id == name }))
        cfg.role = .archive
        try store.addEndpoint(cfg)
    }
    @discardableResult func sync() throws -> SyncReport {
        let ph = placeholders
        engine.options.placeholderCheck = { ph.contains($0.lastPathComponent) }
        engine.options.requestDownload = { [unowned self] in self.downloads.append($0) }
        return try engine.sync(confirmed: true)
    }
    @discardableResult func syncPaths(_ ps: Set<String>) throws -> SyncReport {
        try engine.sync(confirmed: true, scope: .paths(ps))
    }
    func ops(_ op: String) -> [String] {
        ((try? store.recentJournal(limit: 1000)) ?? []).filter { $0.op == op }.map { "\($0.endpoint):\($0.path)" }
    }
    func clearJournal() throws { try store.db.exec("DELETE FROM journal") }
}

@Suite("Renames")
struct RenameTests {
    @Test func renamedFileIsRenamedEverywhereWithoutTransfer() throws {
        let e = try Env2(["a", "b", "c"])
        try e.write("a", "big.bin", String(repeating: "x", count: 5000)); try e.sync()
        try e.clearJournal()
        try e.move("a", "big.bin", "renamed.bin")
        let r = try e.sync()
        for ep in e.names { #expect(e.exists(ep, "renamed.bin")); #expect(!e.exists(ep, "big.bin")) }
        #expect(e.ops("copy").isEmpty)                              // nothing re-transferred
        #expect(Set(e.ops("move")) == ["b:renamed.bin", "c:renamed.bin"])
        #expect(e.ops("trash").isEmpty)                             // and nothing sent to the Trash
        #expect(r.work > 0)
        #expect(try e.sync().work == 0)
    }

    @Test func renameIntoNewFolderAndFolderRename() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "proj/one.txt", "11111"); try e.write("a", "proj/two.txt", "22222"); try e.sync()
        try e.clearJournal()
        try e.move("a", "proj", "project2")                          // whole folder renamed
        try e.sync()
        #expect(e.read("b", "project2/one.txt") == "11111" && e.read("b", "project2/two.txt") == "22222")
        #expect(!e.exists("b", "proj"))
        #expect(e.ops("copy").isEmpty)
    }

    @Test func renameOnRemoteSideThatAlsoEditedFallsBackSafely() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "f.txt", "original"); try e.sync()
        try e.move("a", "f.txt", "g.txt")
        try e.write("b", "f.txt", "edited on b")                     // b modified the old name meanwhile
        try e.sync()
        // nothing is lost: b's edit survives under the old name, the renamed file exists everywhere
        #expect(e.read("a", "g.txt") != nil && e.read("b", "g.txt") != nil)
        #expect(e.read("a", "f.txt") == "edited on b" && e.read("b", "f.txt") == "edited on b")
    }

    @Test func renameIsNotCountedAsMassDeletion() throws {
        let e = try Env2(["a", "b"])
        for i in 0..<40 { try e.write("a", "d/f\(i).txt", "content-\(i)") }
        try e.sync()
        try e.move("a", "d", "d2")
        let r = try e.engine.sync(confirmed: false)
        #expect(r.needsConfirmation == nil)
        #expect(e.read("b", "d2/f7.txt") == "content-7")
    }
}

@Suite("Folders")
struct FolderTests {
    @Test func emptyFolderIsCreatedEverywhere() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "x.txt", "1"); try e.mkdir("a", "empty/nested"); try e.sync()
        #expect(e.exists("b", "empty/nested"))
    }

    @Test func deletedFolderIsRemovedEverywhere() throws {
        let e = try Env2(["a", "b", "c"])
        try e.write("a", "dir/sub/f.txt", "1"); try e.write("a", "dir/g.txt", "2"); try e.mkdir("a", "dir/empty")
        try e.sync()
        #expect(e.exists("c", "dir/sub/f.txt"))
        try FileManager.default.removeItem(at: e.url("a", "dir"))
        try e.sync()
        for ep in e.names { #expect(!e.exists(ep, "dir")) }
    }

    @Test func folderWithUnsyncedContentIsNotRemoved() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "dir/f.txt", "1"); try e.sync()
        try FileManager.default.removeItem(at: e.url("a", "dir"))
        try e.write("b", "dir/new.txt", "added on b meanwhile")
        try e.sync()
        // b's new file is spread everywhere and the folder survives for it
        #expect(e.read("a", "dir/new.txt") == "added on b meanwhile")
        #expect(!e.exists("a", "dir/f.txt") && !e.exists("b", "dir/f.txt"))
    }

    @Test func folderWithOnlyLitterIsRemoved() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "dir/f.txt", "1"); try e.sync()
        try e.write("b", "dir/.DS_Store", "junk")
        try FileManager.default.removeItem(at: e.url("a", "dir")); try e.sync()
        #expect(!e.exists("b", "dir"))
    }
}

@Suite("Cloud placeholders")
struct PlaceholderTests {
    @Test func newPlaceholderIsDownloadedFirstAndNotHashedBlindly() throws {
        let e = try Env2(["a", "icloud"])
        try e.write("icloud", "from-phone.txt", "cloud content")
        e.placeholders = ["from-phone.txt"]
        let r = try e.sync()
        #expect(e.downloads.count >= 1)
        #expect(!e.exists("a", "from-phone.txt"))                              // waits for the download
        #expect(r.skipped.contains(where: { $0.contains("讀取雲端") }))
        e.placeholders = []                                                    // download finished
        try e.sync()
        #expect(e.read("a", "from-phone.txt") == "cloud content")
    }

    @Test func unchangedPlaceholderNeedsNoDownloadAndIsNotDeleted() throws {
        let e = try Env2(["a", "icloud"])
        try e.write("icloud", "old.txt", "stuff"); try e.sync()
        e.placeholders = ["old.txt"]                                           // macOS evicted it later
        e.downloads = []
        try e.sync()
        #expect(e.downloads.isEmpty)
        #expect(e.read("a", "old.txt") == "stuff" && e.exists("icloud", "old.txt"))
    }

    @Test func streamedPlaceholderWhoseContentWasReadIsSynced() throws {
        // Google Drive streaming: the file stays a placeholder but its content can be read.
        let e = try Env2(["a", "drive"])
        try e.write("drive", "doc.txt", "streamed")
        e.placeholders = ["doc.txt"]
        let hash = try FileOps.sha256(of: e.url("drive", "doc.txt"))
        e.engine.options.placeholderHash = { $0.lastPathComponent == "doc.txt" ? hash : nil }
        try e.sync()
        #expect(e.read("a", "doc.txt") == "streamed")
    }

    @Test func oversizedPlaceholderIsLeftForTheUser() throws {
        let e = try Env2(["a", "icloud"])
        e.engine.options.autoDownloadMaxBytes = 4
        try e.write("icloud", "huge.txt", "0123456789")
        e.placeholders = ["huge.txt"]
        let r = try e.sync()
        #expect(e.downloads.isEmpty)
        #expect(r.skipped.contains(where: { $0.contains("上限") }))
    }

    @Test func spaceSavingReleasesOnlyPlaceholderSourcesAfterVerifiedCopy() throws {
        let e = try Env2(["local", "icloud"])
        try e.write("icloud", "cloud.txt", "cloud content")
        e.placeholders = ["cloud.txt"]
        let hash = try FileOps.sha256(of: e.url("icloud", "cloud.txt"))
        e.engine.options.placeholderHash = { $0.lastPathComponent == "cloud.txt" ? hash : nil }
        e.engine.options.cloudSpaceSaving = true
        let released = ReleasedCloudFiles()
        e.engine.options.releaseCloudContent = { url, completion in
            released.append(url)
            completion(nil)
        }

        try e.sync()

        #expect(e.read("local", "cloud.txt") == "cloud content")
        #expect(released.paths() == [e.url("icloud", "cloud.txt").path])
    }

    @Test func spaceSavingNeverEvictsAFileThatWasAlreadyLocal() throws {
        let e = try Env2(["local", "icloud"])
        try e.write("icloud", "kept-offline.txt", "content")
        e.engine.options.cloudSpaceSaving = true
        let released = ReleasedCloudFiles()
        e.engine.options.releaseCloudContent = { url, completion in
            released.append(url)
            completion(nil)
        }

        try e.sync()

        #expect(released.count == 0)
    }
}

@Suite("Versions retention and dry run")
struct HousekeepingTests {
    private func makeStamp(_ dir: URL, daysAgo: Double, bytes: Int, now: Date) throws {
        let name = Versions.stampFormat.string(from: now.addingTimeInterval(-daysAgo * 86400))
        let f = dir.appendingPathComponent(name).appendingPathComponent("ep/file.bin")
        try FileManager.default.createDirectory(at: f.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(count: bytes).write(to: f)
    }

    @Test func purgesByAgeAndByTotalSize() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("v-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: dir) }
        let now = Date()
        try makeStamp(dir, daysAgo: 40, bytes: 1000, now: now)
        try makeStamp(dir, daysAgo: 20, bytes: 1000, now: now)
        try makeStamp(dir, daysAgo: 5, bytes: 1000, now: now)
        #expect(Versions.usage(dir).files == 3 && Versions.usage(dir).bytes == 3000)
        let r1 = Versions.purge(dir, olderThanDays: 30, maxBytes: nil, now: now)
        #expect(r1.files == 1 && Versions.usage(dir).files == 2)
        let r2 = Versions.purge(dir, olderThanDays: nil, maxBytes: 1500, now: now)      // keep newest within the budget
        #expect(r2.files == 1 && Versions.usage(dir).files == 1)
        #expect(Versions.purgeAll(dir).files == 1 && Versions.usage(dir).files == 0)
    }

    @Test func dryRunNeverWritesMarkersIntoFolders() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "x.txt", "1")
        _ = try e.engine.sync(dryRun: true)
        #expect(!e.exists("a", ".syncnexus-endpoint") && !e.exists("b", ".syncnexus-endpoint"))
    }
}

@Suite("Hardening")
struct HardeningTests {
    @Test func editMadeAfterTheScanIsNotTrashedByAPropagatedDelete() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "f.txt", "v1"); try e.sync()
        try FileManager.default.removeItem(at: e.url("a", "f.txt"))          // A deletes
        e.engine.options.afterScan = { try? "edited on b right now".write(to: e.url("b", "f.txt"), atomically: false, encoding: .utf8) }
        try e.sync()
        e.engine.options.afterScan = nil
        try e.sync()
        // the late edit must survive everywhere (edit beats delete), not end up in the Trash
        #expect(e.read("b", "f.txt") == "edited on b right now" && e.read("a", "f.txt") == "edited on b right now")
    }

    @Test func executableBitAndExtendedAttributesSurviveACopy() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "run.sh", "#!/bin/sh\necho hi\n")
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: e.url("a", "run.sh").path)
        _ = e.url("a", "run.sh").path.withCString { p in setxattr(p, "com.example.tag", "blue", 4, 0, 0) }
        try e.sync()
        let mode = try FileManager.default.attributesOfItem(atPath: e.url("b", "run.sh").path)[.posixPermissions] as? Int
        #expect(mode == 0o755)
        var buf = [CChar](repeating: 0, count: 16)
        let n = e.url("b", "run.sh").path.withCString { getxattr($0, "com.example.tag", &buf, 16, 0, 0) }
        #expect(n == 4)
    }

    @Test func secondSyncAtTheSameTimeIsRefused() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "x.txt", "1")
        let other = try Engine(store: Store(path: e.store.path))              // e.g. the command line tool
        let lock = try SyncLock.acquire(path: e.store.path + ".lock")         // the menu bar app is syncing
        #expect(throws: SyncBusy.self) { _ = try other.sync(confirmed: true) }
        _ = lock
    }

    @Test func lockIsReleasedAfterwards() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "x.txt", "1")
        try e.sync()
        _ = try e.sync()           // would throw SyncBusy if the first run kept the lock
    }

    @Test func sudden_disappearanceOfMostFilesNeedsConfirmationEvenWhenSmall() throws {
        let e = try Env2(["a", "b"])
        for i in 0..<6 { try e.write("a", "f\(i).txt", "c\(i)") }
        try e.sync()
        for i in 0..<5 { try FileManager.default.removeItem(at: e.url("a", "f\(i).txt")) }
        let r = try e.engine.sync(confirmed: false)
        #expect(r.needsConfirmation?.contains("同時消失") == true)
        #expect(e.read("b", "f0.txt") == "c0")                                // nothing was deleted yet
        try e.engine.sync(confirmed: true)
        #expect(!e.exists("b", "f0.txt"))
    }

    @Test func deletingOneOfSixIsNotAlarming() throws {
        let e = try Env2(["a", "b"])
        for i in 0..<6 { try e.write("a", "f\(i).txt", "c\(i)") }
        try e.sync()
        try FileManager.default.removeItem(at: e.url("a", "f0.txt"))
        #expect(try e.engine.sync(confirmed: false).needsConfirmation == nil)
    }

    @Test func deepVerifyFlagsSilentChangeAndDoesNotSpreadIt() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "data.bin", "AAAAAAAA"); try e.sync()
        let url = e.url("b", "data.bin")
        let mtime = try FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as! Date
        try "BBBBBBBB".write(to: url, atomically: false, encoding: .utf8)     // same size …
        try FileManager.default.setAttributes([.modificationDate: mtime], ofItemAtPath: url.path)   // … same mtime
        // normal sync trusts size + mtime: documented limitation
        #expect(try e.sync().work == 0)
        // deep verify catches it, reports it, and the bad bytes are not propagated
        e.engine.options.deepVerify = true
        let r = try e.sync()
        e.engine.options.deepVerify = false
        #expect(r.integrity == [IntegrityIssue(endpoint: "b", path: "data.bin")])
        #expect(e.read("a", "data.bin") == "AAAAAAAA")
    }

    @Test func tornReadIsNeverAccepted() throws {
        let e = try Env2(["a"])
        try e.write("a", "f.txt", "content")
        let st = try #require(FileOps.statInfo(e.url("a", "f.txt")))
        #expect(try FileOps.hashIfStable(e.url("a", "f.txt"), size: st.size, mtimeNs: st.mtimeNs) != nil)
        #expect(try FileOps.hashIfStable(e.url("a", "f.txt"), size: st.size, mtimeNs: st.mtimeNs - 1) == nil)   // changed meanwhile
    }

    @Test func deletedFilesAreArchivedBeforeGoingToTheTrash() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "precious.txt", "do not lose me"); try e.sync()
        try FileManager.default.removeItem(at: e.url("a", "precious.txt"))
        try e.sync()
        let kept = (FileManager.default.enumerator(atPath: e.base.appendingPathComponent("_versions").path)?.allObjects as? [String]) ?? []
        #expect(kept.contains(where: { $0.hasSuffix("precious.txt") }))
    }

    @Test func fullDiskIsReportedNotHammered() throws {
        let e = try Env2(["a", "b"])
        e.engine.options.freeSpace = { _ in 1024 }
        try e.write("a", "big.txt", "x"); 
        let r1 = try e.sync()
        #expect(r1.skipped.contains(where: { $0.contains("空間不足") }))
        #expect(!e.exists("b", "big.txt"))
        e.engine.options.freeSpace = nil
        let r2 = try e.sync()                      // within the back-off window: not retried yet
        #expect(r2.skipped.contains(where: { $0.contains("稍後自動重試") }))
        e.engine.options.now = { Date().addingTimeInterval(3600) }
        try e.sync()
        #expect(e.read("b", "big.txt") == "x")
    }

    @Test func archiveNeverCollidesWithinOneSecond() throws {
        let e = try Env2(["a", "b"])
        e.engine.options.now = { Date(timeIntervalSince1970: 1_000_000) }      // frozen clock: same stamp every time
        try e.write("a", "f.txt", "v1"); try e.sync()
        for i in 2...4 { try e.write("a", "f.txt", "v\(i)"); try e.sync() }
        #expect(e.read("b", "f.txt") == "v4")
    }

    @Test func fileWithAFutureTimestampStillSyncs() throws {
        let e = try Env2(["a", "b"])
        e.engine.options.settleSeconds = 2
        try e.write("a", "skewed.txt", "from a machine with a wrong clock")
        try FileManager.default.setAttributes([.modificationDate: Date().addingTimeInterval(86400 * 30)], ofItemAtPath: e.url("a", "skewed.txt").path)
        // first sight: watched; the sync waits one settle window, sees it unchanged, and then trusts it
        _ = try e.engine.sync(confirmed: true)
        #expect(e.read("b", "skewed.txt") == "from a machine with a wrong clock")
    }

    @Test func databaseBackupIsConsistentAndCorruptionIsDetected() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("db-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = try Store(path: dir.appendingPathComponent("state.db").path)
        try store.addEndpoint(EndpointConfig(id: "a", root: "/tmp/a"))
        try store.setConsensus("x.txt", state: FileState(hash: "abc", size: 3), rev: 1)
        #expect(store.quickCheck())
        let copy = dir.appendingPathComponent("Backups/state-1.db")
        try store.backup(to: copy)
        let restored = try Store(path: copy.path)
        #expect(restored.quickCheck())
        #expect(try restored.endpoints().map(\.id) == ["a"])
        #expect(try restored.consensus("x.txt")?.rev == 1)
        // garbage in place of a database is either refused or fails the check, never trusted
        let junk = dir.appendingPathComponent("junk.db")
        try Data((0..<4096).map { _ in UInt8.random(in: 0...255) }).write(to: junk)
        let opened = try? Store(path: junk.path)
        #expect(opened == nil || opened!.quickCheck() == false)
    }

    @Test func archivedVersionCanBeListedAndRestoredAndSpreads() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "doc.txt", "first"); try e.sync()
        try e.write("a", "doc.txt", "second"); try e.sync()
        let items = Versions.list(e.base.appendingPathComponent("_versions"))
        let old = try #require(items.first(where: { $0.path == "doc.txt" && (try? String(contentsOf: $0.url, encoding: .utf8)) == "first" }))
        #expect(old.endpoint == "a" || old.endpoint == "b")
        try e.engine.restoreVersion(old)
        try e.sync()
        #expect(e.read(old.endpoint, "doc.txt") == "first")
        #expect(e.read("a", "doc.txt") == "first" && e.read("b", "doc.txt") == "first")    // the restore spread like any edit
        #expect(Versions.restorePath("dir/report (2).docx") == "dir/report.docx")
        #expect(Versions.restorePath("dir/report.docx") == "dir/report.docx")
    }
}

@Suite("Incremental sync")
struct IncrementalTests {
    @Test func onlyTheReportedPathsAreLookedAt() throws {
        let e = try Env2(["a", "b", "c"])
        try e.write("a", "x.txt", "1"); try e.write("a", "y.txt", "1"); try e.sync()
        try e.write("b", "x.txt", "x changed"); try e.write("c", "y.txt", "y changed")
        let r = try e.syncPaths(["x.txt"])                       // FSEvents only told us about x.txt
        #expect(r.coveredFullScan == false)
        #expect(e.read("a", "x.txt") == "x changed" && e.read("c", "x.txt") == "x changed")
        #expect(e.read("a", "y.txt") == "1")                      // y.txt was not part of this run …
        try e.sync()                                              // … the periodic full scan catches it
        #expect(e.read("a", "y.txt") == "y changed" && e.read("b", "y.txt") == "y changed")
    }

    @Test func incrementalHandlesDeleteRenameAndFolders() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "d/one.txt", "11111"); try e.write("a", "d/two.txt", "22222"); try e.write("a", "gone.txt", "33333"); try e.sync()
        try FileManager.default.removeItem(at: e.url("a", "gone.txt"))
        try e.move("a", "d/one.txt", "d/uno.txt")
        try e.mkdir("a", "fresh/inner")
        try e.clearJournal()
        try e.syncPaths(["gone.txt", "d/one.txt", "d/uno.txt", "fresh"])
        #expect(!e.exists("b", "gone.txt") && !e.exists("b", "d/one.txt"))
        #expect(e.read("b", "d/uno.txt") == "11111" && e.exists("b", "fresh/inner"))
        #expect(e.ops("copy").isEmpty)                            // the rename was a rename here too
    }

    @Test func incrementalConflictStillKeepsBothVersions() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "r.txt", "base"); try e.sync()
        try e.write("a", "r.txt", "from a"); try e.write("b", "r.txt", "from b")
        try e.syncPaths(["r.txt"])
        let open = try e.store.openConflicts()
        #expect(open.count == 1)
        #expect(e.read("a", "r.txt") == e.read("b", "r.txt"))
    }

    @Test func firstRunAndNewcomersAlwaysScanEverything() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "x.txt", "1"); try e.write("a", "other.txt", "2")
        let r = try e.syncPaths(["x.txt"])                       // nothing is established yet
        #expect(r.coveredFullScan == true)
        #expect(e.read("b", "other.txt") == "2")
    }

    @Test func manyPathsFallBackToAFullScan() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "x.txt", "1"); try e.sync()
        let r = try e.syncPaths(Set((0..<250).map { "p\($0).txt" }))
        #expect(r.coveredFullScan == true)
    }

    @Test func transientSkipsAreReportedForAQuickRetry() {
        let r = Engine.retryPaths(from: ["[a] docs/f.txt：仍在寫入（穩定窗口）", "[b] x.txt：先前失敗 2 次，稍後自動重試", "[c] y.txt：大小寫衝突，暫不處理"])
        #expect(r == ["docs/f.txt", "x.txt"])
        #expect(Engine.collapse(["a", "a/b", "a/b/c", "z"]) == ["a", "z"])
    }
}

@Suite("Backup (receive-only) endpoint")
struct ArchiveTests {
    private func history(_ e: Env2, _ ep: String) -> [String] {
        (FileManager.default.enumerator(atPath: e.url(ep, ".syncnexus-history").path)?.allObjects as? [String]) ?? []
    }

    @Test func receivesNewAndChangedFilesAndKeepsTheOldContentInHistory() throws {
        let e = try Env2(["a", "b", "bak"]); try e.makeArchive("bak")
        try e.write("a", "doc.txt", "v1"); try e.sync()
        #expect(e.read("bak", "doc.txt") == "v1")
        try e.write("a", "doc.txt", "v2"); try e.sync()
        #expect(e.read("bak", "doc.txt") == "v2")
        #expect(history(e, "bak").contains(where: { $0.hasSuffix("doc.txt") }))
        // the archive's history never travels to the other folders
        #expect(!e.exists("a", ".syncnexus-history") && !e.exists("b", ".syncnexus-history"))
    }

    @Test func filesDeletedElsewhereAreKept() throws {
        let e = try Env2(["a", "b", "bak"]); try e.makeArchive("bak")
        try e.write("a", "old.txt", "keep me"); try e.sync()
        try FileManager.default.removeItem(at: e.url("a", "old.txt")); try e.sync()
        #expect(!e.exists("b", "old.txt"))                       // mirrors follow the deletion …
        #expect(e.read("bak", "old.txt") == "keep me")           // … the backup does not
        try e.sync()
        #expect(e.read("bak", "old.txt") == "keep me")
    }

    @Test func changesInsideTheBackupAreNotSentOutAndAreUndone() throws {
        let e = try Env2(["a", "b", "bak"]); try e.makeArchive("bak")
        try e.write("a", "doc.txt", "original"); try e.write("a", "other.txt", "other"); try e.sync()
        try e.write("bak", "doc.txt", "tampered")                 // edit inside the backup
        try FileManager.default.removeItem(at: e.url("bak", "other.txt"))   // delete inside the backup
        try e.write("bak", "stray.txt", "put here by accident")  // unknown file
        try e.sync()
        #expect(e.read("a", "doc.txt") == "original" && e.read("b", "doc.txt") == "original")
        #expect(e.read("bak", "doc.txt") == "original")           // restored
        #expect(e.read("bak", "other.txt") == "other")            // restored
        #expect(!e.exists("a", "stray.txt") && !e.exists("b", "stray.txt"))     // never leaks out
        #expect(e.read("bak", "stray.txt") == "put here by accident")           // and is left alone
        #expect(history(e, "bak").contains(where: { $0.hasSuffix("doc.txt") }))  // the tampered version is kept too
    }

    @Test func aConflictHereNeverCreatesConflictCopies() throws {
        let e = try Env2(["a", "bak"]); try e.makeArchive("bak")
        try e.write("a", "r.txt", "base"); try e.sync()
        try e.write("a", "r.txt", "from a"); try e.write("bak", "r.txt", "from bak")
        try e.sync()
        #expect(e.read("bak", "r.txt") == "from a" && e.read("a", "r.txt") == "from a")
        #expect(try e.store.openConflicts().isEmpty)
    }

    @Test func aFileDeletedAndLaterRecreatedAtTheSourceReachesTheBackupAgain() throws {
        let e = try Env2(["a", "bak"]); try e.makeArchive("bak")
        try e.write("a", "f.txt", "one"); try e.sync()
        try FileManager.default.removeItem(at: e.url("a", "f.txt")); try e.sync()
        try e.write("a", "f.txt", "two"); try e.sync()
        #expect(e.read("bak", "f.txt") == "two")
    }
}

@Suite("Integrity repair")
struct IntegrityRepairTests {
    private func corrupted() throws -> (Env2, IntegrityIssue) {
        let e = try Env2(["a", "b"])
        try e.write("a", "data.bin", "AAAAAAAA"); try e.sync()
        let url = e.url("b", "data.bin")
        let mtime = try FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as! Date
        try "BBBBBBBB".write(to: url, atomically: false, encoding: .utf8)
        try FileManager.default.setAttributes([.modificationDate: mtime], ofItemAtPath: url.path)
        e.engine.options.deepVerify = true
        let r = try e.sync()
        e.engine.options.deepVerify = false
        return (e, try #require(r.integrity.first))
    }

    @Test func restoreFromOthersPutsTheGoodVersionBackAndKeepsTheDamagedOne() throws {
        let (e, issue) = try corrupted()
        try e.engine.resolveIntegrity(issue, action: .restoreFromOthers)
        #expect(e.read("b", "data.bin") == "AAAAAAAA" && e.read("a", "data.bin") == "AAAAAAAA")
        let kept = (FileManager.default.enumerator(atPath: e.base.appendingPathComponent("_versions").path)?.allObjects as? [String]) ?? []
        #expect(kept.contains(where: { $0.hasSuffix("data.bin") }))
        e.engine.options.deepVerify = true
        #expect(try e.sync().integrity.isEmpty)                  // verified clean now
    }

    @Test func acceptCurrentMakesTheNewContentTheRealOne() throws {
        let (e, issue) = try corrupted()
        try e.engine.resolveIntegrity(issue, action: .acceptCurrent)
        try e.sync()
        #expect(e.read("a", "data.bin") == "BBBBBBBB" && e.read("b", "data.bin") == "BBBBBBBB")
    }
}

@Suite("Cloud duplicate hints")
struct DuplicateHintTests {
    @Test func flagsNumberedCopiesWithDifferentContentOnCloudEndpointsOnly() throws {
        let e = try Env2(["local", "icloud"])
        e.engine.options.isCloudEndpoint = { $0.id == "icloud" }
        try e.write("icloud", "report.docx", "version one")
        try e.write("icloud", "report 2.docx", "version two")        // looks like iCloud's conflict copy
        try e.write("icloud", "notes.txt", "same"); try e.write("icloud", "notes (1).txt", "same")   // identical: not a conflict
        try e.write("local", "plan.txt", "a"); try e.write("local", "plan 2.txt", "b")                 // not a cloud folder
        let r = try e.sync()
        // "plan 2.txt" comes from the local folder but now also sits in the iCloud folder, where it looks like a cloud copy
        #expect(Set(r.duplicateHints.map(\.path)) == ["report 2.docx", "plan 2.txt"])
        #expect(r.duplicateHints.first(where: { $0.path == "report 2.docx" })?.basePath == "report.docx")
        #expect(e.exists("local", "report 2.docx"))                  // and nothing was removed or renamed automatically
    }
}

@Suite("Exclude presets")
struct ExcludeTests {
    @Test func defaultsKeepPackageFoldersAndDatabasesOut() throws {
        let e = try Env2(["a", "b"])
        try e.write("a", "app/node_modules/pkg/index.js", "x"); try e.write("a", "app/main.js", "m")
        try e.write("a", "data.sqlite-wal", "w"); try e.write("a", "Pics.photoslibrary/db", "d"); try e.write("a", "repo/.git/HEAD", "ref")
        try e.sync()
        #expect(e.read("b", "app/main.js") == "m")
        #expect(!e.exists("b", "app/node_modules") && !e.exists("b", "data.sqlite-wal") && !e.exists("b", "Pics.photoslibrary"))
        #expect(!e.exists("b", "repo/.git"))
    }

    @Test func legacyPreferencesMigrateToMandatoryProtectionWithoutDeletingExistingFiles() throws {
        let e = try Env2(["a", "b"])
        try e.store.setMeta("excludePresets", "")                  // legacy setting with all switches off
        try e.write("a", "repo/.git/HEAD", "from-a")
        try e.write("b", "repo/.git/HEAD", "from-b")               // pre-existing data is never touched
        try e.write("a", "keep.txt", "k")
        try e.sync()
        #expect(e.read("a", "repo/.git/HEAD") == "from-a" && e.read("b", "repo/.git/HEAD") == "from-b")
        #expect(e.read("b", "keep.txt") == "k")
        try FileManager.default.removeItem(at: e.url("a", "repo/.git"))
        try e.sync()
        #expect(e.read("b", "repo/.git/HEAD") == "from-b")
    }

    @Test func serviceExcludePresetsAndConflictPolicyPersistAndPublish() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("svc-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let db = dir.appendingPathComponent("state.db").path
        let ver = dir.appendingPathComponent("versions")

        var latestSnapshot = SyncService.Snapshot.initial
        let svc = SyncService(dbPath: db, versionsDir: ver, logURL: nil) { snap in
            latestSnapshot = snap
        }
        svc.start()

        let expExclude = await withCheckedContinuation { (continuation: CheckedContinuation<Set<ExcludePreset>, Never>) in
            svc.setExcludePresets([.git, .nodeModules]) { _ in
                continuation.resume(returning: latestSnapshot.excludePresets)
            }
        }
        #expect(expExclude == ExcludePreset.defaults)

        let expPolicy = await withCheckedContinuation { (continuation: CheckedContinuation<ConflictPolicy, Never>) in
            svc.setConflictPolicy(.newerWins) { _ in
                continuation.resume(returning: latestSnapshot.conflictPolicy)
            }
        }
        #expect(expPolicy == .newerWins)

        await svc.stopAndWait()

        // Restart service to verify it loads persisted configuration immediately into snapshot on startup
        var reloadedSnapshot = SyncService.Snapshot.initial
        let svc2 = SyncService(dbPath: db, versionsDir: ver, logURL: nil) { snap in
            reloadedSnapshot = snap
        }
        svc2.start()
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(reloadedSnapshot.excludePresets == ExcludePreset.defaults)
        #expect(reloadedSnapshot.conflictPolicy == .newerWins)
        await svc2.stopAndWait()
    }
}
