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
}
