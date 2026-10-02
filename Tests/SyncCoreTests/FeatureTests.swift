import Foundation
import Testing
@testable import SyncCore

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
    @discardableResult func sync() throws -> SyncReport {
        let ph = placeholders
        engine.options.placeholderCheck = { ph.contains($0.lastPathComponent) }
        engine.options.requestDownload = { [unowned self] in self.downloads.append($0) }
        return try engine.sync(confirmed: true)
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
