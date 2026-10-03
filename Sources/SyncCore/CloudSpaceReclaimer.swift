import Foundation

#if os(macOS)
import FileProvider
#endif

public enum CloudSpaceReclaimer {
    public struct UnsupportedProvider: Error, LocalizedError {
        public var errorDescription: String? { "雲端供應器不支援釋放本機內容" }
    }

    /// Removes only the provider's local cache. The cloud item itself is never deleted.
    public static func releaseLocalContent(of url: URL, completion: @escaping @Sendable (Error?) -> Void) {
        #if os(macOS)
        if EndpointValidator.describe(path: url.path).kind == .icloud {
            DispatchQueue.global(qos: .utility).async {
                do {
                    try FileManager.default.evictUbiquitousItem(at: url)
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
            return
        }

        NSFileProviderManager.getIdentifierForUserVisibleFile(at: url) { identifier, domainIdentifier, error in
            if let error { completion(error); return }
            guard let identifier, let domainIdentifier else { completion(UnsupportedProvider()); return }
            let domain = NSFileProviderDomain(identifier: domainIdentifier, displayName: "")
            guard let manager = NSFileProviderManager(for: domain) else { completion(UnsupportedProvider()); return }
            manager.evictItem(identifier: identifier, completionHandler: completion)
        }
        #else
        completion(UnsupportedProvider())
        #endif
    }
}
