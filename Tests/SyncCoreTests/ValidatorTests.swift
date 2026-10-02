import Foundation
import Testing
@testable import SyncCore

@Suite("Endpoint validation and newcomers")
struct ValidatorTests {
    private func tmp() throws -> URL {
        let u = FileManager.default.temporaryDirectory.appendingPathComponent("sv-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: u, withIntermediateDirectories: true)
        return u
    }
    private func errors(_ i: [ValidationIssue]) -> [String] { i.filter(\.isError).map(\.message) }

    @Test func acceptsPlainFolder() throws {
        let d = try tmp(); defer { try? FileManager.default.removeItem(at: d) }
        #expect(errors(EndpointValidator.validate(path: d.path, name: "local", existing: [])).isEmpty)
    }
    @Test func rejectsMissingBroadAndBadNames() throws {
        let d = try tmp(); defer { try? FileManager.default.removeItem(at: d) }
        #expect(!errors(EndpointValidator.validate(path: d.path + "/nope", name: "x", existing: [])).isEmpty)
        #expect(!errors(EndpointValidator.validate(path: NSHomeDirectory(), name: "x", existing: [])).isEmpty)
        #expect(!errors(EndpointValidator.validate(path: "/", name: "x", existing: [])).isEmpty)
        #expect(!errors(EndpointValidator.validate(path: d.path, name: "", existing: [])).isEmpty)
        #expect(!errors(EndpointValidator.validate(path: d.path, name: "a/b", existing: [])).isEmpty)
    }
    @Test func rejectsOverlapAndDuplicateName() throws {
        let d = try tmp(); defer { try? FileManager.default.removeItem(at: d) }
        let inner = d.appendingPathComponent("inner")
        try FileManager.default.createDirectory(at: inner, withIntermediateDirectories: true)
        let existing = [EndpointConfig(id: "a", root: d.path)]
        #expect(!errors(EndpointValidator.validate(path: d.path, name: "b", existing: existing)).isEmpty)       // same
        #expect(!errors(EndpointValidator.validate(path: inner.path, name: "b", existing: existing)).isEmpty)   // nested inside
        #expect(!errors(EndpointValidator.validate(path: d.deletingLastPathComponent().path, name: "b", existing: [EndpointConfig(id: "a", root: inner.path)])).isEmpty) // contains
        let other = try tmp(); defer { try? FileManager.default.removeItem(at: other) }
        #expect(!errors(EndpointValidator.validate(path: other.path, name: "a", existing: existing)).isEmpty)   // duplicate name
        #expect(errors(EndpointValidator.validate(path: other.path, name: "b", existing: existing)).isEmpty)
    }
    @Test func relinkingSelfIsNotAnOverlap() throws {
        let d = try tmp(); defer { try? FileManager.default.removeItem(at: d) }
        let existing = [EndpointConfig(id: "a", root: d.path)]
        #expect(errors(EndpointValidator.validate(path: d.path, name: "a", replacing: "a", existing: existing)).isEmpty)
    }
    @Test func removedEndpointKeepsFilesAndStopsSyncing() throws {
        let store = try Store(path: FileManager.default.temporaryDirectory.appendingPathComponent("r-\(UUID().uuidString).db").path)
        try store.addEndpoint(EndpointConfig(id: "x", root: "/tmp/x"))
        try store.setRow("x", "p", state: nil, mtimeNs: 0, seenRev: 1)
        try store.removeEndpoint(id: "x")
        #expect(try store.endpoints().isEmpty)
        #expect(try !store.endpointHasHistory("x"))
    }
}
