import Foundation
import Testing
@testable import SyncCore

@Suite("Multi-Folder Sync Groups")
struct SyncGroupTests {
    private func tmpDir() throws -> URL {
        let u = FileManager.default.temporaryDirectory.appendingPathComponent("sg-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }

    @Test func registryInitializesWithDefaultGroup() throws {
        let dir = try tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let reg = SyncGroupRegistry(baseAppSupportURL: dir)
        let groups = reg.allGroups()
        #expect(groups.count == 1)
        #expect(groups[0].id == "default")
        #expect(groups[0].icon == "folder")
        #expect(reg.dbPath(for: "default").hasSuffix("state.db"))
    }

    @Test func addAndRetrieveGroups() throws {
        let dir = try tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let reg = SyncGroupRegistry(baseAppSupportURL: dir)
        let newGroup = reg.addGroup(name: "工作專案", icon: "briefcase")
        #expect(newGroup.id.starts(with: "group_"))
        #expect(newGroup.name == "工作專案")
        #expect(newGroup.icon == "briefcase")

        let all = reg.allGroups()
        #expect(all.count == 2)
        #expect(reg.group(id: newGroup.id)?.name == "工作專案")

        let customDb = reg.dbPath(for: newGroup.id)
        #expect(customDb.contains("Groups/\(newGroup.id)/state.db"))
    }

    @Test func updateAndPersistAcrossInstances() throws {
        let dir = try tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let reg1 = SyncGroupRegistry(baseAppSupportURL: dir)
        let g = reg1.addGroup(name: "相片", icon: "camera")
        _ = reg1.updateGroup(id: g.id, name: "家庭相片", icon: "photo")

        // Reload from disk in a fresh registry instance
        let reg2 = SyncGroupRegistry(baseAppSupportURL: dir)
        let reloaded = reg2.group(id: g.id)
        #expect(reloaded?.name == "家庭相片")
        #expect(reloaded?.icon == "photo")
    }

    @Test func cannotRemoveLastRemainingGroup() throws {
        let dir = try tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let reg = SyncGroupRegistry(baseAppSupportURL: dir)
        #expect(reg.allGroups().count == 1)
        let removed = reg.removeGroup(id: "default")
        #expect(!removed)
        #expect(reg.allGroups().count == 1)

        let g = reg.addGroup(name: "測試群組")
        #expect(reg.allGroups().count == 2)
        let removedSecond = reg.removeGroup(id: g.id)
        #expect(removedSecond)
        #expect(reg.allGroups().count == 1)
    }

    // MARK: manual legacy import

    private func makeLegacy(_ dir: URL, groups: [SyncGroup], endpoints: [String: Int]) throws {
        let enc = JSONEncoder()
        try enc.encode(groups).write(to: dir.appendingPathComponent("groups.json"))
        for (gid, n) in endpoints {
            let db = gid == "default" ? dir.appendingPathComponent("state.db")
                                      : dir.appendingPathComponent("Groups/\(gid)/state.db")
            try FileManager.default.createDirectory(at: db.deletingLastPathComponent(), withIntermediateDirectories: true)
            let d = try Database(path: db.path)
            try d.exec("CREATE TABLE endpoints(id TEXT, root TEXT)")
            for i in 0..<n { try d.exec("INSERT INTO endpoints(id, root) VALUES(?,?)", [.text("e\(i)"), .text("/r\(i)")]) }
        }
    }

    @Test func importRestoresFirstGroupAndKeepsExistingSecond() throws {
        let legacy = try tmpDir(), cur = try tmpDir()
        defer { try? FileManager.default.removeItem(at: legacy); try? FileManager.default.removeItem(at: cur) }
        // current (sandbox) state: empty default + a configured second group
        let reg = SyncGroupRegistry(baseAppSupportURL: cur)
        reg.addGroup(name: "第二次測試")
        let second = reg.allGroups()[1]
        try makeLegacy(legacy, groups: [SyncGroup(id: "default", name: "測試群組", icon: "doc.text"),
                                        SyncGroup(id: second.id, name: "第二次測試")],
                       endpoints: ["default": 4, second.id: 4])
        try FileManager.default.createDirectory(at: URL(fileURLWithPath: reg.dbPath(for: second.id)).deletingLastPathComponent(), withIntermediateDirectories: true)
        let curDB = try Database(path: reg.dbPath(for: second.id))
        try curDB.exec("CREATE TABLE endpoints(id TEXT)")
        for i in 0..<2 { try curDB.exec("INSERT INTO endpoints(id) VALUES(?)", [.text("e\(i)")]) }

        let r = try reg.importLegacySettings(from: legacy)
        #expect(r.imported == ["測試群組"])
        #expect(r.endpointCount == 4)
        #expect(reg.group(id: "default")?.name == "測試群組")
        let d = try Database(path: reg.dbPath(for: "default"))
        #expect(try d.query("SELECT COUNT(*) FROM endpoints")[0][0].intValue == 4)
        // existing second group untouched (still its own 2 endpoints)
        let d2 = try Database(path: reg.dbPath(for: second.id))
        #expect(try d2.query("SELECT COUNT(*) FROM endpoints")[0][0].intValue == 2)
        #expect(reg.allGroups().count == 2)
    }

    @Test func importAcceptsParentFolderAndRejectsEmpty() throws {
        let parent = try tmpDir(), cur = try tmpDir()
        defer { try? FileManager.default.removeItem(at: parent); try? FileManager.default.removeItem(at: cur) }
        let reg = SyncGroupRegistry(baseAppSupportURL: cur)
        #expect(throws: SyncGroupRegistry.LegacyImportError.self) { try reg.importLegacySettings(from: parent) }
        let inner = parent.appendingPathComponent("SyncNexus")
        try FileManager.default.createDirectory(at: inner, withIntermediateDirectories: true)
        try makeLegacy(inner, groups: [SyncGroup(id: "default", name: "A")], endpoints: ["default": 3])
        let r = try reg.importLegacySettings(from: parent)
        #expect(r.imported == ["A"])
    }

    @Test func backupAndRestoreRoundTrip() throws {
        let dir = try tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let reg = SyncGroupRegistry(baseAppSupportURL: dir)
        #expect(reg.listBackups().count == 1)                 // first launch snapshot
        try makeLegacy(dir, groups: reg.allGroups(), endpoints: ["default": 3])
        #expect(reg.backupNow() != nil)
        #expect(reg.backupNow() == nil)                       // unchanged -> no duplicate
        #expect(reg.listBackups().first?.endpointCount == 3)

        // simulate the overwrite: DB wiped, group renamed
        for ext in ["", "-wal", "-shm"] { try? FileManager.default.removeItem(atPath: dir.appendingPathComponent("state.db").path + ext) }
        _ = reg.updateGroup(id: "default", name: "被覆蓋", icon: "folder")
        #expect(reg.backupNow() == nil)                       // empty state must not evict the good backup

        try reg.restore(reg.listBackups()[0])
        #expect(reg.group(id: "default")?.name == "預設群組")
        let d = try Database(path: reg.dbPath(for: "default"))
        #expect(try d.query("SELECT COUNT(*) FROM endpoints")[0][0].intValue == 3)
    }

    @Test func unnamedGroupKeepsEmptyNameOnDisk() throws {
        let dir = try tmpDir()
        defer { try? FileManager.default.removeItem(at: dir) }
        let reg = SyncGroupRegistry(baseAppSupportURL: dir)
        let g = reg.addGroup(name: "")
        #expect(SyncGroupRegistry(baseAppSupportURL: dir).group(id: g.id)?.name == "")   // survives reload, not frozen to a language
    }
}
