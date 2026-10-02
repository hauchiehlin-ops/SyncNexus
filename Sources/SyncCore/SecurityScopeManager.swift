import Foundation

/// Manages macOS Security-Scoped Bookmarks (App Sandbox requirement for App Store).
/// Keeps track of accessed resources and restores access after app restart.
public final class SecurityScopeManager: @unchecked Sendable {
    public static let shared = SecurityScopeManager()

    private let lock = NSLock()
    private var activeURLs: [String: URL] = [:]

    private init() {}

    #if os(macOS)
    /// Creates a security-scoped bookmark for a URL selected by the user.
    public func createBookmark(for url: URL) -> Data? {
        do {
            return try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
        } catch {
            return nil
        }
    }

    /// Callback invoked when a stale bookmark is automatically renewed by the system.
    public var onBookmarkRenewed: (@Sendable (String, Data) -> Void)?

    /// Resolves and begins accessing a security-scoped bookmark.
    @discardableResult
    public func startAccessing(path: String, bookmarkData: Data?) -> URL? {
        lock.lock()
        defer { lock.unlock() }

        if let active = activeURLs[path] {
            return active
        }

        guard let bookmarkData else {
            let url = URL(fileURLWithPath: path)
            return url
        }

        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if url.startAccessingSecurityScopedResource() {
                activeURLs[path] = url
                if isStale, let renewed = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
                    onBookmarkRenewed?(path, renewed)
                }
                return url
            }
        } catch {
            // Fallback for dev / un-sandboxed environments
        }

        let fallbackURL = URL(fileURLWithPath: path)
        return fallbackURL
    }

    /// Stops accessing a security-scoped bookmark for the specified path.
    public func stopAccessing(path: String) {
        lock.lock()
        defer { lock.unlock() }
        if let url = activeURLs.removeValue(forKey: path) {
            url.stopAccessingSecurityScopedResource()
        }
    }

    /// Stops accessing all active security-scoped resources.
    public func stopAll() {
        lock.lock()
        defer { lock.unlock() }
        for (_, url) in activeURLs {
            url.stopAccessingSecurityScopedResource()
        }
        activeURLs.removeAll()
    }
    #else
    public func createBookmark(for url: URL) -> Data? { nil }
    public func startAccessing(path: String, bookmarkData: Data?) -> URL? { URL(fileURLWithPath: path) }
    public func stopAccessing(path: String) {}
    public func stopAll() {}
    #endif
}
