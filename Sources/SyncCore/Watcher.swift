import Foundation
import CoreServices

/// What happened since the last quiet moment: either "look at everything" (events were lost, a volume came or went) or the
/// absolute paths that changed.
public struct WatchBatch: Sendable {
    /// FSEvents has finished replaying what happened since the stored event id (events before this were from the past).
    public var replayDone = false
    public var full = false
    public var paths: Set<String> = []
}

/// FSEvents over the endpoint roots plus the first level of /Volumes (mount / unmount). Events are only hints about WHERE
/// something changed; the engine always re-reads real state, so unreliable event flags (see docs/PHASE0-FINDINGS.md) do not matter.
public final class Watcher {
    private var stream: FSEventStreamRef?
    private let onChange: (WatchBatch) -> Void
    private let ignore: IgnoreRules
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "syncnexus.watcher")
    private let quietSeconds: Double
    /// Under continuous activity (a big copy, an editor autosaving) the quiet period never comes; sync at least this often.
    private let maxWaitSeconds: Double = 30
    private var firstEvent: Date?
    private var batch = WatchBatch()
    private var roots: [String]
    /// Newest event id seen; stored by the service so a restart can replay what happened while the app was not running.
    public private(set) var lastEventId: UInt64 = 0

    public init(roots: [String], quietSeconds: Double = 2, ignore: IgnoreRules = .default, sinceEventId: UInt64? = nil, onChange: @escaping (WatchBatch) -> Void) {
        self.onChange = onChange
        self.ignore = ignore
        self.quietSeconds = quietSeconds
        let resolved = roots.map { URL(fileURLWithPath: $0).resolvingSymlinksInPath().path }
        self.roots = Array(Set(roots + resolved))
        var ctx = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        let cb: FSEventStreamCallback = { _, info, n, paths, flags, ids in
            let me = Unmanaged<Watcher>.fromOpaque(info!).takeUnretainedValue()
            let ps = unsafeBitCast(paths, to: NSArray.self) as! [String]
            me.handle(ps, flags: (0..<n).map { flags[$0] }, ids: (0..<n).map { ids[$0] })
        }
        let watched = Array(Set(self.roots + ["/Volumes"]))
        let since = sinceEventId.map { FSEventStreamEventId($0) } ?? FSEventStreamEventId(kFSEventStreamEventIdSinceNow)
        stream = FSEventStreamCreate(nil, cb, &ctx, watched as CFArray, since, 1.0,
                                     FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes))
        FSEventStreamSetDispatchQueue(stream!, queue)
    }

    public func start() { FSEventStreamStart(stream!) }
    public func stop() { FSEventStreamStop(stream!); FSEventStreamInvalidate(stream!); FSEventStreamRelease(stream!) }

    private func handle(_ paths: [String], flags: [FSEventStreamEventFlags], ids: [FSEventStreamEventId]) {
        var touched = false
        var immediate = false
        let mustFull = UInt32(kFSEventStreamEventFlagMustScanSubDirs | kFSEventStreamEventFlagUserDropped | kFSEventStreamEventFlagKernelDropped |
                              kFSEventStreamEventFlagRootChanged | kFSEventStreamEventFlagMount | kFSEventStreamEventFlagUnmount)
        for (i, path) in paths.enumerated() {
            if let id = ids.indices.contains(i) ? ids[i] : nil, UInt64(id) > lastEventId { lastEventId = UInt64(id) }
            if flags[i] & UInt32(kFSEventStreamEventFlagHistoryDone) != 0 { batch.replayDone = true; touched = true; immediate = true; continue }
            let comps = path.split(separator: "/")
            if comps.first == "Volumes" && comps.count == 2 { batch.full = true; touched = true; continue }      // a volume appeared or went away
            if flags[i] & mustFull != 0 { batch.full = true; touched = true; continue }
            guard roots.contains(where: { path == $0 || path.hasPrefix($0 + "/") }) else { continue }
            if let last = comps.last, ignore.isIgnored(component: String(last)) { continue }
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
