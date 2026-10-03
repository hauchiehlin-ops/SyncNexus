import Foundation

/// Represents a distinct synchronization task/profile comprising 2 or more endpoints.
/// Each group operates independently with its own consensus, reconciliation engine,
/// event pipeline, file lock, and history archives.
public struct SyncGroup: Codable, Identifiable, Sendable, Equatable {
    public var id: String
    public var name: String
    public var icon: String
    public var createdAt: Date
    public var retentionDays: Int

    public init(id: String, name: String, icon: String = "folder", createdAt: Date = Date(), retentionDays: Int = 30) {
        self.id = id
        self.name = name
        self.icon = icon
        self.createdAt = createdAt
        self.retentionDays = retentionDays
    }
}

/// Thread-safe registry that persists and manages SyncGroups across restarts.
public final class SyncGroupRegistry: @unchecked Sendable {
    private let registryURL: URL
    private let baseAppSupportURL: URL
    private let lock = NSLock()
    private var groups: [SyncGroup] = []

    public init(baseAppSupportURL: URL) {
        self.baseAppSupportURL = baseAppSupportURL
        self.registryURL = baseAppSupportURL.appendingPathComponent("groups.json")
        load()
    }

    public func allGroups() -> [SyncGroup] {
        lock.lock()
        defer { lock.unlock() }
        return groups
    }

    public func group(id: String) -> SyncGroup? {
        lock.lock()
        defer { lock.unlock() }
        return groups.first { $0.id == id }
    }

    @discardableResult
    public func addGroup(name: String, icon: String = "folder", retentionDays: Int = 30) -> SyncGroup {
        lock.lock()
        defer { lock.unlock() }
        let id = "group_" + UUID().uuidString.prefix(8).lowercased()
        let group = SyncGroup(id: id, name: name, icon: icon, createdAt: Date(), retentionDays: retentionDays)
        groups.append(group)
        save()
        return group
    }

    public func updateGroup(id: String, name: String, icon: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = groups.firstIndex(where: { $0.id == id }) else { return false }
        groups[idx].name = name
        groups[idx].icon = icon
        save()
        return true
    }

    public func removeGroup(id: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard groups.count > 1 else { return false } // Keep at least one group
        guard let idx = groups.firstIndex(where: { $0.id == id }) else { return false }
        groups.remove(at: idx)
        save()
        return true
    }

    public func dbPath(for groupId: String) -> String {
        if groupId == "default" {
            // Preserves backward compatibility with existing state.db
            return baseAppSupportURL.appendingPathComponent("state.db").path
        }
        return baseAppSupportURL.appendingPathComponent("Groups/\(groupId)/state.db").path
    }

    public func versionsURL(for groupId: String) -> URL {
        if groupId == "default" {
            return baseAppSupportURL.appendingPathComponent("Versions")
        }
        return baseAppSupportURL.appendingPathComponent("Groups/\(groupId)/Versions")
    }

    public func logURL(for groupId: String) -> URL {
        let baseLogs = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs/SyncNexus")
        if groupId == "default" {
            return baseLogs.appendingPathComponent("syncnexus.log")
        }
        return baseLogs.appendingPathComponent("syncnexus_\(groupId).log")
    }

    private func load() {
        lock.lock()
        defer { lock.unlock() }
        let fm = FileManager.default
        if fm.fileExists(atPath: registryURL.path),
           let data = try? Data(contentsOf: registryURL),
           let decoded = try? JSONDecoder().decode([SyncGroup].self, from: data),
           !decoded.isEmpty {
            groups = decoded
        } else {
            // First time setup or migration: default group
            let defaultGroup = SyncGroup(id: "default", name: "預設群組", icon: "folder", createdAt: Date())
            groups = [defaultGroup]
            save()
        }
    }

    private func save() {
        let fm = FileManager.default
        try? fm.createDirectory(at: registryURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(groups) {
            try? data.write(to: registryURL, options: .atomic)
        }
    }
}
