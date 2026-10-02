import Testing
@testable import SyncCore

/// In-memory model of N endpoints + consensus, driven only by `Reconciler.decide`.
/// Content string doubles as its own hash. An "offline" endpoint is edited freely (as if on another
/// device) but is skipped by `sync`, exactly like an ejected disk.
private final class Sim {
    struct Endpoint {
        var files: [String: String] = [:]
        var snapshot: [String: String] = [:]
        var seen: [String: Int] = [:]
        var online = true
    }
    var eps: [Endpoint]
    var consensus: [String: (content: String?, rev: Int)] = [:]

    init(endpoints: Int) { eps = Array(repeating: Endpoint(), count: endpoints) }

    static func state(_ c: String?) -> FileState? { c.map { FileState(hash: $0, size: Int64($0.count)) } }

    /// Returns true if anything changed.
    @discardableResult
    func sync(_ i: Int) -> Bool {
        guard eps[i].online else { return false }
        var changed = false
        let paths = Set(eps[i].files.keys).union(eps[i].snapshot.keys).union(consensus.keys)
        for p in paths.sorted() {
            let cur = eps[i].files[p], snap = eps[i].snapshot[p], seen = eps[i].seen[p] ?? 0
            let c = consensus[p]
            let d = Reconciler.decide(
                PathObservation(snapshot: Sim.state(snap), current: Sim.state(cur), seenRev: seen),
                consensus: c.map { ConsensusEntry(state: Sim.state($0.content), rev: $0.rev) })
            switch d {
            case .noop: break
            case .adoptEndpoint:
                let rev = (c?.rev ?? 0) + 1
                consensus[p] = (cur, rev); eps[i].snapshot[p] = cur; eps[i].seen[p] = rev; changed = true
            case .applyConsensus:
                eps[i].files[p] = c?.content; eps[i].snapshot[p] = c?.content; eps[i].seen[p] = c?.rev ?? 0; changed = true
            case .markSeen:
                eps[i].snapshot[p] = cur; eps[i].seen[p] = c?.rev ?? 0; changed = true
            case .conflict:
                // Keep both: the endpoint's version moves to a conflict name, the consensus takes the original name.
                eps[i].files["\(p).conflict\(i)"] = cur
                eps[i].files[p] = c?.content; eps[i].snapshot[p] = c?.content; eps[i].seen[p] = c?.rev ?? 0; changed = true
            }
        }
        return changed
    }

    func settle() {
        for i in eps.indices { eps[i].online = true }
        for _ in 0..<20 {
            var any = false
            for i in eps.indices { if sync(i) { any = true } }
            if !any { return }
        }
        Issue.record("did not settle within 20 rounds")
    }
}

private struct LCG {
    var s: UInt64
    mutating func next(_ n: Int) -> Int { s = s &* 6364136223846793005 &+ 1442695040888963407; return Int((s >> 33) % UInt64(n)) }
}

@Suite("Convergence")
struct ConvergenceTests {
    @Test func ejectedDiskEditedElsewhereMergesBack() {
        let sim = Sim(endpoints: 4) // 0 local, 1 iCloud, 2 Drive, 3 disk
        sim.eps[0].files = ["a": "1", "b": "1"]
        sim.settle()
        sim.eps[3].online = false
        sim.eps[0].files["a"] = "local-edit"            // while the disk is away
        sim.eps[3].files["b"] = "disk-edit"             // edited on another machine
        sim.eps[3].files["new"] = "from-disk"
        sim.sync(0); sim.sync(1); sim.sync(2)
        sim.settle()
        for ep in sim.eps {
            #expect(ep.files["a"] == "local-edit")
            #expect(ep.files["b"] == "disk-edit")
            #expect(ep.files["new"] == "from-disk")
        }
    }

    @Test func conflictKeepsBothVersions() {
        let sim = Sim(endpoints: 3)
        sim.eps[0].files = ["a": "1"]
        sim.settle()
        sim.eps[2].online = false
        sim.eps[0].files["a"] = "local"
        sim.eps[2].files["a"] = "disk"
        sim.sync(0); sim.sync(1)
        sim.settle()
        let all = Set(sim.eps[0].files.values)
        #expect(all.contains("local") && all.contains("disk"))
        #expect(sim.eps[0].files == sim.eps[1].files && sim.eps[1].files == sim.eps[2].files)
    }

    @Test func randomizedRunsAlwaysConverge() {
        var rng = LCG(s: 42)
        for _ in 0..<300 {
            let sim = Sim(endpoints: 4)
            for _ in 0..<60 {
                let i = rng.next(4), p = ["a", "b", "c"][rng.next(3)]
                switch rng.next(6) {
                case 0, 1: sim.eps[i].files[p] = "v\(rng.next(5))"
                case 2: sim.eps[i].files[p] = nil
                case 3: sim.eps[i].online = rng.next(2) == 0
                default: sim.sync(i)
                }
            }
            sim.settle()
            let reference = sim.eps[0].files
            for ep in sim.eps { #expect(ep.files == reference) }
        }
    }
}
