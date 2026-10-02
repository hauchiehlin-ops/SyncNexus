import Foundation
import CoreServices

/// FSEvents over the endpoint roots plus the first level of /Volumes (mount / unmount).
/// Events are only a hint that "something changed": the engine always re-reads real state, so
/// unreliable event flags (see docs/PHASE0-FINDINGS.md) do not matter.
public final class Watcher {
    private var stream: FSEventStreamRef?
    private let onChange: () -> Void
    private let ignore: IgnoreRules
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "syncnexus.watcher")
    private let quietSeconds: Double
    /// Under continuous activity (a big copy, an editor autosaving) the quiet period never comes; sync at least this often.
    private let maxWaitSeconds: Double = 30
    private var firstEvent: Date?

    public init(roots: [String], quietSeconds: Double = 2, ignore: IgnoreRules = .default, onChange: @escaping () -> Void) {
        self.onChange = onChange
        self.ignore = ignore
        self.quietSeconds = quietSeconds
        var ctx = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        let cb: FSEventStreamCallback = { _, info, n, paths, _, _ in
            let me = Unmanaged<Watcher>.fromOpaque(info!).takeUnretainedValue()
            let ps = unsafeBitCast(paths, to: NSArray.self) as! [String]
            for p in ps.prefix(n) where me.relevant(p) { me.bump(); break }
        }
        let watched = Array(Set(roots + ["/Volumes"]))
        stream = FSEventStreamCreate(nil, cb, &ctx, watched as CFArray, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), 1.0,
                                     FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes))
        FSEventStreamSetDispatchQueue(stream!, queue)
    }

    public func start() { FSEventStreamStart(stream!) }
    public func stop() { FSEventStreamStop(stream!); FSEventStreamInvalidate(stream!); FSEventStreamRelease(stream!) }

    private func relevant(_ path: String) -> Bool {
        let comps = path.split(separator: "/")
        if comps.first == "Volumes" { if comps.count == 2 { return true } }   // a volume appeared or went away
        guard let last = comps.last else { return false }
        return !ignore.isIgnored(component: String(last)) && !(comps.first == "Volumes" && comps.count > 2 && !watchedUnderVolume(path))
    }

    private var volumeRoots: [String] = []
    public func setVolumeRoots(_ roots: [String]) { volumeRoots = roots }
    private func watchedUnderVolume(_ path: String) -> Bool { volumeRoots.contains { path.hasPrefix($0) } }

    /// Debounce: fire once things have been quiet for `quietSeconds`.
    private func bump() {
        timer?.cancel()
        let now = Date()
        if firstEvent == nil { firstEvent = now }
        let waited = now.timeIntervalSince(firstEvent!)
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + max(0, min(quietSeconds, maxWaitSeconds - waited)))
        t.setEventHandler { [weak self, onChange] in self?.firstEvent = nil; onChange() }
        t.resume()
        timer = t
    }
}
