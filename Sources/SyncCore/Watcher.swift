import Foundation

#if canImport(CoreServices)
import CoreServices
#endif

/// What happened since the last quiet moment: either "look at everything" (events were lost, a volume came or went) or the
/// absolute paths that changed.
public struct WatchBatch: Sendable {
    /// Event stream has finished replaying what happened since the stored event id.
    public var replayDone = false
    public var full = false
    public var paths: Set<String> = []
    public init() {}
}

#if canImport(CoreServices)
/// FSEvents over the endpoint roots. Mount availability is checked separately without recursively watching `/Volumes`.
/// Events are only hints about WHERE something changed; the engine always re-reads real state, so unreliable event flags
/// (see docs/PHASE0-FINDINGS.md) do not matter.
public final class Watcher {
    private var stream: FSEventStreamRef?
    private let onChange: (WatchBatch) -> Void
    private let ignore: IgnoreRules
    private var timer: DispatchSourceTimer?
    private var availabilityTimer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "syncnexus.watcher")
    private let quietSeconds: Double
    /// Under continuous activity (a big copy, an editor autosaving) the quiet period never comes; sync at least this often.
    private let maxWaitSeconds: Double = 30
    private var firstEvent: Date?
    private var batch = WatchBatch()
    /// Only endpoint roots belong in the FSEvents stream. Watching `/Volumes` is
    /// recursive and lets unrelated disks turn their traffic into sync work.
    private let endpointRoots: [String]
    private var roots: [String]
    private var rootAvailability: [String: Bool] = [:]
    /// Newest event id seen; stored by the service so a restart can replay what happened while the app was not running.
    public private(set) var lastEventId: UInt64 = 0

    public init(roots: [String], quietSeconds: Double = 2, ignore: IgnoreRules = .default, sinceEventId: UInt64? = nil, onChange: @escaping (WatchBatch) -> Void) {
        self.onChange = onChange
        self.ignore = ignore
        self.quietSeconds = quietSeconds
        self.endpointRoots = Array(Set(roots))
        let resolved = roots.map { URL(fileURLWithPath: $0).resolvingSymlinksInPath().path }
        self.roots = Array(Set(roots + resolved))
        for root in self.endpointRoots { self.rootAvailability[root] = Self.isDirectory(root) }
        var ctx = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        let cb: FSEventStreamCallback = { _, info, n, paths, flags, ids in
            let me = Unmanaged<Watcher>.fromOpaque(info!).takeUnretainedValue()
            let ps = unsafeBitCast(paths, to: NSArray.self) as! [String]
            me.handle(ps, flags: (0..<n).map { flags[$0] }, ids: (0..<n).map { ids[$0] })
        }
        let watched = self.roots
        let since = sinceEventId.map { FSEventStreamEventId($0) } ?? FSEventStreamEventId(kFSEventStreamEventIdSinceNow)
        stream = FSEventStreamCreate(nil, cb, &ctx, watched as CFArray, since, 1.0,
                                     FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes))
        FSEventStreamSetDispatchQueue(stream!, queue)
    }

    public func start() {
        FSEventStreamStart(stream!)
        // An endpoint that was absent when the stream was created may not emit a
        // useful event when its volume returns. Poll only the endpoint directory
        // entries; this is a stat, not a directory scan.
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + 2, repeating: 2)
        t.setEventHandler { [weak self] in self?.checkRootAvailability() }
        t.resume()
        availabilityTimer = t
    }

    public func stop() {
        availabilityTimer?.cancel(); availabilityTimer = nil
        FSEventStreamStop(stream!); FSEventStreamInvalidate(stream!); FSEventStreamRelease(stream!)
    }

    private static func isDirectory(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func checkRootAvailability() {
        var changed = false
        for root in endpointRoots {
            let available = Self.isDirectory(root)
            if rootAvailability[root] != available {
                rootAvailability[root] = available
                changed = true
            }
        }
        if changed {
            batch.full = true
            flush()
        }
    }

    private func handle(_ paths: [String], flags: [FSEventStreamEventFlags], ids: [FSEventStreamEventId]) {
        var touched = false
        var immediate = false
        let mustFull = UInt32(kFSEventStreamEventFlagMustScanSubDirs | kFSEventStreamEventFlagUserDropped | kFSEventStreamEventFlagKernelDropped |
                              kFSEventStreamEventFlagRootChanged | kFSEventStreamEventFlagMount | kFSEventStreamEventFlagUnmount)
        for (i, path) in paths.enumerated() {
            let eventFlags = flags[i]
            if let id = ids.indices.contains(i) ? ids[i] : nil, UInt64(id) > lastEventId { lastEventId = UInt64(id) }
            if eventFlags & UInt32(kFSEventStreamEventFlagHistoryDone) != 0 { batch.replayDone = true; touched = true; immediate = true; continue }
            let comps = path.split(separator: "/")
            guard let matchedRoot = roots.first(where: { path == $0 || path.hasPrefix($0 + "/") }) else { continue }
            // Dropped/root/mount events are only relevant after the event has
            // been proven to belong to one of this group's endpoints.
            if eventFlags & mustFull != 0 { batch.full = true; touched = true; continue }
            if let last = comps.last, ignore.isIgnored(component: String(last)) { continue }
            let rel = String(path.dropFirst(matchedRoot.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            // With file-level events, providers and builds frequently touch only a
            // watched directory's mtime/xattrs as descendants change. The actual
            // child paths arrive separately. Treating these metadata-only directory
            // notifications as content changes collapses the batch to a whole-project
            // (or whole-root) scan and needlessly visits unrelated projects.
            if rel.isEmpty { continue }
            let isDirectory = eventFlags & UInt32(kFSEventStreamEventFlagItemIsDir) != 0
            let structuralDirectoryChange = eventFlags & UInt32(kFSEventStreamEventFlagItemCreated |
                                                                  kFSEventStreamEventFlagItemRemoved |
                                                                  kFSEventStreamEventFlagItemRenamed) != 0
            if isDirectory && !structuralDirectoryChange { continue }
            if !rel.isEmpty && ignore.isIgnored(relativePath: rel) { continue }
            batch.paths.insert(path); touched = true
        }
        if touched { immediate ? flush() : bump() }
    }

    private func flush() {
        timer?.cancel()
        let b = batch
        batch = WatchBatch(); firstEvent = nil
        onChange(b)
    }

    /// Debounce: fire once things have been quiet for `quietSeconds` (but at least every `maxWaitSeconds`).
    private func bump() {
        timer?.cancel()
        let now = Date()
        if firstEvent == nil { firstEvent = now }
        let waited = now.timeIntervalSince(firstEvent!)
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + max(0, min(quietSeconds, maxWaitSeconds - waited)))
        t.setEventHandler { [weak self] in
            guard let self else { return }
            let b = self.batch
            self.batch = WatchBatch(); self.firstEvent = nil
            self.onChange(b)
        }
        t.resume()
        timer = t
    }
}
#else
/// Cross-platform fallback watcher for non-macOS platforms (Linux, Android, etc.).
public final class Watcher {
    private let onChange: (WatchBatch) -> Void
    private let ignore: IgnoreRules
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "syncnexus.watcher")
    private var roots: [String]
    public private(set) var lastEventId: UInt64 = 0

    public init(roots: [String], quietSeconds: Double = 2, ignore: IgnoreRules = .default, sinceEventId: UInt64? = nil, onChange: @escaping (WatchBatch) -> Void) {
        self.roots = roots
        self.ignore = ignore
        self.onChange = onChange
        self.lastEventId = sinceEventId ?? 0
    }

    public func start() {
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + 5, repeating: 5)
        t.setEventHandler { [weak self] in
            guard let self else { return }
            var batch = WatchBatch()
            batch.full = true
            self.onChange(batch)
        }
        t.resume()
        timer = t
    }

    public func stop() {
        timer?.cancel()
        timer = nil
    }
}
#endif
