import Foundation

/// Reads the content of cloud placeholders (iCloud / Google Drive "dataless" files) in the background and remembers the
/// SHA-256, so a sync pass never blocks on the network.
///
/// Measured on this Mac (see docs/PHASE0-FINDINGS.md): an iCloud placeholder is downloaded by a full read (tens of
/// seconds even for tiny files) and then stops being a placeholder; a Google Drive streaming placeholder can be read
/// right away but stays a placeholder. Hashing the whole file in a background job handles both: the result is
/// available when the read has completed, whichever way the provider serves it.
public final class Materializer: @unchecked Sendable {
    struct Key: Hashable { var path: String; var size: Int64; var mtimeNs: Int64 }

    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.name = "syncnexus.materialize"
        q.qualityOfService = .utility
        q.maxConcurrentOperationCount = 2
        return q
    }()
    private let lock = NSLock()
    private var inflight = Set<Key>()
    private var results: [Key: String] = [:]

    /// Called after a read has finished (successfully or not), so the caller can look at the file again.
    public var onFinish: ((URL) -> Void)?

    public init() {}

    public func cancelAll() {
        queue.cancelAllOperations()
        lock.lock()
        inflight.removeAll()
        lock.unlock()
    }

    /// SHA-256 of a placeholder whose content has already been read, if the file is unchanged since.
    public func result(for url: URL, size: Int64, mtimeNs: Int64) -> String? {
        lock.lock(); defer { lock.unlock() }
        return results[Key(path: url.path, size: size, mtimeNs: mtimeNs)]
    }

    public func isDownloading(_ url: URL) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return inflight.contains { $0.path == url.path }
    }

    public func request(_ url: URL, size: Int64, mtimeNs: Int64) {
        let key = Key(path: url.path, size: size, mtimeNs: mtimeNs)
        lock.lock()
        let isNew = results[key] == nil && inflight.insert(key).inserted
        lock.unlock()
        guard isNew else { return }
        queue.addOperation { [weak self] in
            guard let self else { return }
            let hash = try? FileOps.sha256(of: url)
            self.lock.lock()
            self.inflight.remove(key)
            if let hash { self.results[key] = hash }
            self.lock.unlock()
            self.onFinish?(url)
        }
    }

    private static var freeSpaceCache: [String: (free: Int64, at: Date)] = [:]
    private static let cacheLock = NSLock()

    public static func freeBytes(at url: URL) -> Int64? {
        let mountPath = (try? url.resourceValues(forKeys: [.volumeURLKey]))?.volume?.path ?? url.path
        cacheLock.lock()
        if let c = freeSpaceCache[mountPath], Date().timeIntervalSince(c.at) < 20 {
            cacheLock.unlock()
            return c.free
        }
        cacheLock.unlock()

        let v = (try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey]))?.volumeAvailableCapacity
        guard let v else { return nil }
        cacheLock.lock()
        freeSpaceCache[mountPath] = (Int64(v), Date())
        cacheLock.unlock()
        return Int64(v)
    }
}
