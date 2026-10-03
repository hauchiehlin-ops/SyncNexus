import Foundation
import Testing
@testable import SyncCore

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
}
