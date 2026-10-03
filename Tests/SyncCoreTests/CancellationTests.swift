import Foundation
import Testing
@testable import SyncCore

private final class ProgressRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [SyncProgress] = []
    func append(_ value: SyncProgress) { lock.lock(); values.append(value); lock.unlock() }
    func snapshot() -> [SyncProgress] { lock.lock(); defer { lock.unlock() }; return values }
}

@Suite("Cooperative scan cancellation")
struct CancellationTests {
    @Test func fileScanStopsBeforeWalkingACloudTree() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("cancel-scan-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root.appendingPathComponent("nested"), withIntermediateDirectories: true)
        try "data".write(to: root.appendingPathComponent("nested/file.txt"), atomically: true, encoding: .utf8)

        #expect(throws: ScanCancelled.self) {
            _ = try FileOps.scan(root: root, ignore: .default, shouldCancel: { true })
        }
    }

    @Test func enginePropagatesCancellationInsteadOfReportingAnEndpointOffline() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("cancel-engine-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root.appendingPathComponent("a"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("b"), withIntermediateDirectories: true)

        let store = try Store(path: root.appendingPathComponent("state.db").path)
        try store.addEndpoint(EndpointConfig(id: "a", root: root.appendingPathComponent("a").path))
        try store.addEndpoint(EndpointConfig(id: "b", root: root.appendingPathComponent("b").path))
        var options = EngineOptions()
        options.shouldCancel = { true }
        let engine = Engine(store: store, options: options)

        #expect(throws: ScanCancelled.self) {
            _ = try engine.sync(confirmed: true)
        }
    }

    @Test func enginePublishesMonotonicStagesAndCurrentPaths() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("progress-engine-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let a = root.appendingPathComponent("a"), b = root.appendingPathComponent("b")
        try FileManager.default.createDirectory(at: a, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: b, withIntermediateDirectories: true)
        try "data".write(to: a.appendingPathComponent("visible.txt"), atomically: true, encoding: .utf8)

        let store = try Store(path: root.appendingPathComponent("state.db").path)
        try store.addEndpoint(EndpointConfig(id: "a", root: a.path))
        try store.addEndpoint(EndpointConfig(id: "b", root: b.path))
        let recorder = ProgressRecorder()
        var options = EngineOptions()
        options.settleSeconds = 0
        options.progress = { recorder.append($0) }
        let engine = Engine(store: store, options: options)

        _ = try engine.sync(confirmed: true)
        let values = recorder.snapshot()
        #expect(values.first?.stage == .preparing)
        #expect(values.last?.stage == .finalizing)
        #expect(values.last?.fraction == 1)
        #expect(values.contains { $0.stage == .scanning && $0.currentPath == "visible.txt" })
        #expect(values.contains { $0.stage == .comparing })
        #expect(zip(values, values.dropFirst()).allSatisfy { pair in pair.0.fraction <= pair.1.fraction })
    }

    @Test func cancellingLargeCopyLeavesNoPartialDestination() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("cancel-copy-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let source = root.appendingPathComponent("source.bin")
        let target = root.appendingPathComponent("target.bin")
        try Data(repeating: 0x5a, count: 4 * 1024 * 1024).write(to: source)
        let hash = try FileOps.sha256(of: source)
        var cancel = false

        #expect(throws: ScanCancelled.self) {
            try FileOps.copyAtomically(from: source, to: target, expectHash: hash, mtime: nil,
                                       shouldCancel: { cancel }, progress: { _, _ in cancel = true })
        }
        #expect(!FileManager.default.fileExists(atPath: target.path))
        let leftovers = try FileManager.default.contentsOfDirectory(atPath: root.path).filter { $0.hasSuffix(".nexus-part") }
        #expect(leftovers.isEmpty)
    }
}
