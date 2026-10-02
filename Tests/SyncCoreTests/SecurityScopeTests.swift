import Testing
import Foundation
@testable import SyncCore

@Suite("Security-scoped bookmarks and Store persistence")
struct SecurityScopeTests {

    @Test func bookmarkDataPersistsInStore() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("ssb-test-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let dbPath = tmp.appendingPathComponent("test.db").path
        let store = try Store(path: dbPath)

        let fakeBookmark = "FakeBookmarkBytes12345".data(using: .utf8)!
        let ep = EndpointConfig(
            id: "LocalDir",
            root: "/Users/test/Documents",
            removable: false,
            portableNames: true,
            bookmarkData: fakeBookmark
        )

        try store.addEndpoint(ep)

        let loaded = try store.endpoints()
        #expect(loaded.count == 1)
        #expect(loaded[0].id == "LocalDir")
        #expect(loaded[0].bookmarkData == fakeBookmark)

        // Test update renewed bookmark
        let newBookmark = "RenewedBookmarkBytes67890".data(using: .utf8)!
        try store.updateBookmark(forRoot: "/Users/test/Documents", bookmarkData: newBookmark)

        let reloaded = try store.endpoints()
        #expect(reloaded[0].bookmarkData == newBookmark)

        // Test relink with bookmark
        let relinkedBookmark = "RelinkedBookmarkBytes99999".data(using: .utf8)!
        try store.relinkEndpoint(id: "LocalDir", root: "/Users/test/NewDocs", volumeUUID: nil, bookmarkData: relinkedBookmark)

        let afterRelink = try store.endpoints()
        #expect(afterRelink[0].root == "/Users/test/NewDocs")
        #expect(afterRelink[0].bookmarkData == relinkedBookmark)
    }

    @Test func securityScopeManagerAccessAndStop() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("ssb-dir-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let manager = SecurityScopeManager.shared
        let url = URL(fileURLWithPath: tmp.path)

        #if os(macOS)
        let bookmark = manager.createBookmark(for: url)
        // In local non-app-sandbox test environment, bookmarkData may return standard or security bookmark
        let accessedURL = manager.startAccessing(path: tmp.path, bookmarkData: bookmark)
        #expect(accessedURL != nil)
        manager.stopAccessing(path: tmp.path)
        #else
        let accessedURL = manager.startAccessing(path: tmp.path, bookmarkData: nil)
        #expect(accessedURL != nil)
        manager.stopAccessing(path: tmp.path)
        #endif
    }
}
