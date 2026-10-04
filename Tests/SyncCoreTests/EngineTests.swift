import Foundation
import Testing
@testable import SyncCore

private final class Env {
    let base = FileManager.default.temporaryDirectory.appendingPathComponent("sn-\(UUID().uuidString)")
    let store: Store
    let engine: Engine
    let trashDir: URL
    var names: [String] = []

    init(_ endpoints: [(String, Bool)]) throws {   // (name, removable+portable)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        trashDir = base.appendingPathComponent("_trash")
        try FileManager.default.createDirectory(at: trashDir, withIntermediateDirectories: true)
        store = try Store(path: base.appendingPathComponent("state.db").path)
        var opts = EngineOptions()
        opts.settleSeconds = 0
        opts.versionsDir = base.appendingPathComponent("_versions")
        let trash = trashDir
        opts.trash = { try FileManager.default.moveItem(at: $0, to: trash.appendingPathComponent(UUID().uuidString + "-" + $0.lastPathComponent)) }
        engine = Engine(store: store, options: opts)
        for (n, disk) in endpoints {
            let dir = base.appendingPathComponent(n)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try store.addEndpoint(EndpointConfig(id: n, root: dir.path, removable: disk, portableNames: disk))
            names.append(n)
        }
    }
    deinit { try? FileManager.default.removeItem(at: base) }

    func url(_ ep: String, _ rel: String = "") -> URL { base.appendingPathComponent(ep).appendingPathComponent(rel) }
    func write(_ ep: String, _ rel: String, _ text: String) throws {
        let u = url(ep, rel)
        try FileManager.default.createDirectory(at: u.deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: u, atomically: true, encoding: .utf8)
    }
    func read(_ ep: String, _ rel: String) -> String? { try? String(contentsOf: url(ep, rel), encoding: .utf8) }
    func remove(_ ep: String, _ rel: String) throws { try FileManager.default.removeItem(at: url(ep, rel)) }
    @discardableResult func sync(confirmed: Bool = true) throws -> SyncReport { try engine.sync(confirmed: confirmed) }
    func listing(_ ep: String) -> [String] {
        ((try? FileOps.scan(root: url(ep), ignore: .default))?.files.values.filter { !$0.isDirectory }.map(\.rel).sorted()) ?? []
    }
    func dirs(_ ep: String) -> [String] {
        ((try? FileOps.scan(root: url(ep), ignore: .default))?.files.values.filter(\.isDirectory).map(\.rel).sorted()) ?? []
    }
    /// Every file name physically present (including conflict copies, which scans ignore).
    func raw(_ ep: String) -> [String] {
        ((FileManager.default.enumerator(atPath: url(ep).path)?.allObjects as? [String]) ?? [])
            .filter { !$0.hasSuffix(".syncnexus-endpoint") && !$0.hasPrefix(".") }.sorted()
    }
    func setMtime(_ ep: String, _ rel: String, secondsAgo: Double) throws {
        try FileManager.default.setAttributes([.modificationDate: Date().addingTimeInterval(-secondsAgo)], ofItemAtPath: url(ep, rel).path)
    }
    /// Simulate ejecting the disk: the folder disappears from where the engine expects it.
    func eject(_ ep: String) throws { try FileManager.default.moveItem(at: url(ep), to: base.appendingPathComponent("_away-\(ep)")) }
    func reattach(_ ep: String) throws { try FileManager.default.moveItem(at: base.appendingPathComponent("_away-\(ep)"), to: url(ep)) }
    func awayURL(_ ep: String, _ rel: String) -> URL { base.appendingPathComponent("_away-\(ep)").appendingPathComponent(rel) }
}

@Suite("Engine on real folders")
struct EngineTests {
    @Test func newFilePropagatesToAll() throws {
        let e = try Env([("local", false), ("icloud", false), ("drive", false), ("disk", true)])
        try e.write("local", "docs/a.txt", "hello")
        let r = try e.sync()
        #expect(r.needsConfirmation == nil)
        for ep in e.names { #expect(e.read(ep, "docs/a.txt") == "hello") }
        // marker files are not part of the data set
        #expect(e.listing("disk") == ["docs/a.txt"])
    }

    @Test func editAndDeletePropagate_deleteGoesToTrash() throws {
        let e = try Env([("local", false), ("disk", true), ("drive", false)])
        try e.write("local", "a.txt", "v1"); try e.sync()
        try e.write("disk", "a.txt", "v2"); try e.sync()
        #expect(e.read("local", "a.txt") == "v2" && e.read("drive", "a.txt") == "v2")
        try e.remove("drive", "a.txt"); try e.sync()
        #expect(e.read("local", "a.txt") == nil && e.read("disk", "a.txt") == nil)
        #expect(try FileManager.default.contentsOfDirectory(atPath: e.trashDir.path).count == 2)
    }

    @Test func firstRunNeedsConfirmation() throws {
        let e = try Env([("a", false), ("b", false)])
        try e.write("a", "x.txt", "1")
        let r = try e.sync(confirmed: false)
        #expect(r.needsConfirmation != nil && !r.preview.isEmpty)
        #expect(e.read("b", "x.txt") == nil)       // nothing happened yet
        try e.sync()
        #expect(e.read("b", "x.txt") == "1")
    }

    @Test func previewIsTruncatedWhenExceedingLimit() throws {
        let e = try Env([("a", false), ("b", false)])
        for i in 0..<600 {
            try e.write("a", "file_\(i).txt", "c")
        }
        let r = try e.sync(confirmed: false)
        #expect(r.needsConfirmation != nil)
        #expect(r.preview.count == Engine.maxPreviewItems)
        #expect(r.previewTotalCount == 600)
    }

    /// The headline scenario: disk ejected, edited on another machine, edited elsewhere meanwhile, reattached.
    @Test func ejectedDiskEditedElsewhereMergesBack() throws {
        let e = try Env([("local", false), ("drive", false), ("disk", true)])
        try e.write("local", "a.txt", "1"); try e.write("local", "b.txt", "1"); try e.write("local", "c.txt", "1")
        try e.sync()

        try e.eject("disk")
        let r1 = try e.sync()
        #expect(r1.offline.count == 1)
        try e.write("local", "a.txt", "local-edit")                       // while the disk is away
        try e.sync()
        try "disk-edit".write(to: e.awayURL("disk", "b.txt"), atomically: true, encoding: .utf8)   // other machine
        try "from-disk".write(to: e.awayURL("disk", "new.txt"), atomically: true, encoding: .utf8)
        try FileManager.default.removeItem(at: e.awayURL("disk", "c.txt"))                          // deleted there

        try e.reattach("disk")
        try e.sync()
        for ep in e.names {
            #expect(e.read(ep, "a.txt") == "local-edit")
            #expect(e.read(ep, "b.txt") == "disk-edit")
            #expect(e.read(ep, "new.txt") == "from-disk")
            #expect(e.read(ep, "c.txt") == nil)
        }
    }

    @Test func conflictCopyStaysOnlyOnTheConflictingEndpoint() throws {
        let e = try Env([("local", false), ("drive", false), ("disk", true)])
        try e.write("local", "r.txt", "base"); try e.sync()
        try e.eject("disk")
        try e.write("local", "r.txt", "local-version"); try e.sync()
        try "disk-version".write(to: e.awayURL("disk", "r.txt"), atomically: true, encoding: .utf8)
        try e.reattach("disk")
        try e.sync()
        // everyone agrees on the main file; the extra copy exists on the disk only
        for ep in e.names { #expect(e.read(ep, "r.txt") == "local-version") }
        #expect(e.raw("local") == ["r.txt"] && e.raw("drive") == ["r.txt"])
        let extra = e.raw("disk").filter { $0.contains("conflict") }
        #expect(extra.count == 1)
        #expect(e.read("disk", extra[0]) == "disk-version")
        let open = try e.store.openConflicts()
        #expect(open.count == 1 && open[0].endpoint == "disk" && open[0].path == "r.txt")
        // and it is not synced afterwards
        try e.sync()
        #expect(e.raw("local") == ["r.txt"])
    }

    @Test func resolveKeepingTheExtraCopyPropagatesIt() throws {
        let e = try Env([("local", false), ("disk", true)])
        try e.write("local", "r.txt", "base"); try e.sync()
        try e.eject("disk")
        try e.write("local", "r.txt", "local-version"); try e.sync()
        try "disk-version".write(to: e.awayURL("disk", "r.txt"), atomically: true, encoding: .utf8)
        try e.reattach("disk"); try e.sync()
        let c = try #require(e.store.openConflicts().first)
        try e.engine.resolveConflictRecord(c.id, keep: .conflict)
        try e.sync()
        for ep in e.names { #expect(e.read(ep, "r.txt") == "disk-version"); #expect(e.raw(ep) == ["r.txt"]) }
        #expect(try e.store.openConflicts().isEmpty)
        let versions = (FileManager.default.enumerator(atPath: e.base.appendingPathComponent("_versions").path)?.allObjects as? [String]) ?? []
        #expect(!versions.isEmpty)    // the replaced version was archived
    }

    @Test func resolveKeepingTheMainFileTrashesTheExtraCopy() throws {
        let e = try Env([("local", false), ("disk", true)])
        try e.write("local", "r.txt", "base"); try e.sync()
        try e.eject("disk")
        try e.write("local", "r.txt", "local-version"); try e.sync()
        try "disk-version".write(to: e.awayURL("disk", "r.txt"), atomically: true, encoding: .utf8)
        try e.reattach("disk"); try e.sync()
        let c = try #require(e.store.openConflicts().first)
        try e.engine.resolveConflictRecord(c.id, keep: .main)
        for ep in e.names { #expect(e.read(ep, "r.txt") == "local-version"); #expect(e.raw(ep) == ["r.txt"]) }
        #expect(try e.store.openConflicts().isEmpty)
        #expect(try FileManager.default.contentsOfDirectory(atPath: e.trashDir.path).count == 1)
    }

    @Test func newerWinsPicksTheNewerVersionAndArchivesTheOlder() throws {
        let e = try Env([("local", false), ("disk", true)])
        try e.store.setMeta("conflictPolicy", "newerWins")
        try e.write("local", "r.txt", "base"); try e.sync()
        try e.eject("disk")
        try e.write("local", "r.txt", "older-local"); try e.setMtime("local", "r.txt", secondsAgo: 3600)
        try e.sync()
        try "newer-disk".write(to: e.awayURL("disk", "r.txt"), atomically: true, encoding: .utf8)
        try e.reattach("disk"); try e.sync()
        for ep in e.names { #expect(e.read(ep, "r.txt") == "newer-disk"); #expect(e.raw(ep) == ["r.txt"]) }
        #expect(try e.store.openConflicts().isEmpty)
        let versions = (FileManager.default.enumerator(atPath: e.base.appendingPathComponent("_versions").path)?.allObjects as? [String]) ?? []
        #expect(versions.contains(where: { $0.hasSuffix("r.txt") }))
    }

    @Test func newerWinsAlsoWorksWhenTheConsensusIsNewer() throws {
        let e = try Env([("local", false), ("disk", true)])
        try e.store.setMeta("conflictPolicy", "newerWins")
        try e.write("local", "r.txt", "base"); try e.sync()
        try e.eject("disk")
        try e.write("local", "r.txt", "newer-local"); try e.sync()
        try "older-disk".write(to: e.awayURL("disk", "r.txt"), atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.modificationDate: Date().addingTimeInterval(-7200)], ofItemAtPath: e.awayURL("disk", "r.txt").path)
        try e.reattach("disk"); try e.sync()
        for ep in e.names { #expect(e.read(ep, "r.txt") == "newer-local"); #expect(e.raw(ep) == ["r.txt"]) }
    }

    @Test func newerWinsFallsBackToKeepBothWhenTimesAreTooClose() throws {
        let e = try Env([("local", false), ("disk", true)])
        try e.store.setMeta("conflictPolicy", "newerWins")
        try e.write("local", "r.txt", "base"); try e.sync()
        try e.eject("disk")
        try e.write("local", "r.txt", "a"); try e.sync()
        try "b".write(to: e.awayURL("disk", "r.txt"), atomically: true, encoding: .utf8)
        try e.reattach("disk"); try e.sync()
        #expect(try e.store.openConflicts().count == 1)
    }

    @Test func conflictNamesAreRecognised() {
        #expect(ConflictNaming.isConflictName("report (conflict disk 2026-10-02 11-46).txt"))
        #expect(ConflictNaming.isConflictName("noext (conflict disk 2 2026-10-02 11-46)"))
        #expect(!ConflictNaming.isConflictName("my conflict notes.txt"))
        #expect(!ConflictNaming.isConflictName("report.txt"))
    }

    @Test func deleteVersusEditRestoresTheEdit() throws {
        let e = try Env([("local", false), ("disk", true)])
        try e.write("local", "f.txt", "1"); try e.sync()
        try e.eject("disk")
        try e.write("local", "f.txt", "edited"); try e.sync()
        try FileManager.default.removeItem(at: e.awayURL("disk", "f.txt"))
        try e.reattach("disk")
        try e.sync()
        #expect(e.read("disk", "f.txt") == "edited" && e.read("local", "f.txt") == "edited")
    }

    @Test func wipedDiskNeverPropagatesDeletion() throws {
        let e = try Env([("local", false), ("disk", true)])
        for i in 0..<5 { try e.write("local", "f\(i).txt", "x") }
        try e.sync()
        // Disk reformatted: folder exists again but is empty and has no marker.
        try FileManager.default.removeItem(at: e.url("disk"))
        try FileManager.default.createDirectory(at: e.url("disk"), withIntermediateDirectories: true)
        let r = try e.sync()
        #expect(r.offline.count == 1)
        #expect(e.listing("local").count == 5)
    }

    @Test func foreignDiskWithSameFolderIsRejected() throws {
        let e = try Env([("local", false), ("disk", true)])
        try e.write("local", "f.txt", "x"); try e.sync()
        try ".".write(to: e.url("disk", ".syncnexus-endpoint"), atomically: true, encoding: .utf8)   // different identity
        let r = try e.sync()
        #expect(r.offline.count == 1)
    }

    @Test func massDeletionNeedsConfirmation() throws {
        let e = try Env([("a", false), ("b", false)])
        for i in 0..<40 { try e.write("a", "f\(i).txt", "x") }
        try e.sync()
        for i in 0..<40 { try e.remove("a", "f\(i).txt") }
        let r = try e.sync(confirmed: false)
        #expect(r.needsConfirmation != nil)
        #expect(e.listing("b").count == 40)
        try e.sync(confirmed: true)
        #expect(e.listing("b").isEmpty)
    }

    @Test func incompatibleNameIsSkippedOnPortableEndpointOnly() throws {
        let e = try Env([("local", false), ("drive", false), ("disk", true)])
        try e.write("local", "bad:name.txt", "x"); try e.write("local", "ok.txt", "y")
        let r = try e.sync()
        #expect(e.read("drive", "bad:name.txt") == "x")
        #expect(e.read("disk", "bad:name.txt") == nil)
        #expect(e.read("disk", "ok.txt") == "y")
        #expect(r.skipped.contains(where: { $0.contains("bad:name.txt") }))
    }

    @Test func secondSyncIsANoOp() throws {
        let e = try Env([("a", false), ("b", true)])
        try e.write("a", "x.txt", "1"); try e.write("b", "y.txt", "2")
        try e.sync()
        let r = try e.sync()
        #expect(r.work == 0)
    }

    @Test func litterAndTempFilesAreNeverSynced() throws {
        let e = try Env([("a", false), ("disk", true)])
        try e.write("disk", "._x.txt", "junk"); try e.write("disk", ".DS_Store", "junk"); try e.write("disk", "real.txt", "ok")
        try e.sync()
        #expect(e.listing("a") == ["real.txt"])
    }

    @Test func overwrittenVersionsAreArchived() throws {
        let e = try Env([("a", false), ("b", false)])
        try e.write("a", "x.txt", "old"); try e.sync()
        try e.write("a", "x.txt", "new"); try e.sync()
        let versions = e.base.appendingPathComponent("_versions")
        let found = FileManager.default.enumerator(atPath: versions.path)?.allObjects as? [String] ?? []
        #expect(found.contains(where: { $0.hasSuffix("x.txt") }))
    }

    @Test func relinkedEndpointReceivesGroupAndNeverDeletes() throws {
        let e = try Env([("local", false), ("drive", false)])
        try e.write("local", "a.txt", "A"); try e.write("local", "b.txt", "B"); try e.sync()
        // Drive signed in as another account: new folder, already holds an unrelated file and one clashing file.
        let fresh = e.base.appendingPathComponent("drive2")
        try FileManager.default.createDirectory(at: fresh, withIntermediateDirectories: true)
        try "own".write(to: fresh.appendingPathComponent("mine.txt"), atomically: true, encoding: .utf8)
        try "different".write(to: fresh.appendingPathComponent("a.txt"), atomically: true, encoding: .utf8)
        try e.store.relinkEndpoint(id: "drive", root: fresh.path, volumeUUID: nil)
        try e.sync()
        #expect(e.read("local", "b.txt") == "B")
        #expect(try String(contentsOf: fresh.appendingPathComponent("b.txt"), encoding: .utf8) == "B")
        #expect(try String(contentsOf: fresh.appendingPathComponent("mine.txt"), encoding: .utf8) == "own")
        #expect(e.read("local", "mine.txt") == "own")
        // the clashing file: consensus version wins the name everywhere; the newcomer's version stays on the newcomer only
        #expect(try String(contentsOf: fresh.appendingPathComponent("a.txt"), encoding: .utf8) == "A")
        let extras = (FileManager.default.enumerator(atPath: fresh.path)?.allObjects as? [String] ?? []).filter { $0.contains("conflict") }
        #expect(extras.count == 1)
        #expect(e.raw("local").allSatisfy { !$0.contains("conflict") })
    }

    @Test func newlyAddedEndpointNeedsConfirmationBeforeReceivingFiles() throws {
        let e = try Env([("a", false), ("b", false)])
        try e.write("a", "x.txt", "1"); try e.sync()
        let c = e.base.appendingPathComponent("c")
        try FileManager.default.createDirectory(at: c, withIntermediateDirectories: true)
        try e.store.addEndpoint(EndpointConfig(id: "c", root: c.path))
        let r = try e.sync(confirmed: false)
        #expect(r.needsConfirmation?.contains("新端點") == true)
        #expect(!FileManager.default.fileExists(atPath: c.appendingPathComponent("x.txt").path))
        try e.sync(confirmed: true)
        #expect(FileManager.default.fileExists(atPath: c.appendingPathComponent("x.txt").path))
    }
}
