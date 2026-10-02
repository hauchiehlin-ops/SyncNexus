import Foundation
import Testing
@testable import SyncCore

private func f(_ h: String) -> FileState { FileState(hash: h, size: Int64(h.count)) }
private func obs(_ snap: String?, _ cur: String?, seen: Int) -> PathObservation {
    PathObservation(snapshot: snap.map(f), current: cur.map(f), seenRev: seen)
}
private func cons(_ s: String?, rev: Int) -> ConsensusEntry { ConsensusEntry(state: s.map(f), rev: rev) }

@Suite("Reconciler decision table")
struct ReconcilerTests {
    @Test func nothingChanged() {
        #expect(Reconciler.decide(obs("a", "a", seen: 3), consensus: cons("a", rev: 3)) == .noop)
    }
    @Test func onlyEndpointEdited() {
        #expect(Reconciler.decide(obs("a", "b", seen: 3), consensus: cons("a", rev: 3)) == .adoptEndpoint)
    }
    @Test func onlyOthersEdited() {
        #expect(Reconciler.decide(obs("a", "a", seen: 3), consensus: cons("b", rev: 4)) == .applyConsensus)
    }
    @Test func bothSameContent() {
        #expect(Reconciler.decide(obs("a", "c", seen: 3), consensus: cons("c", rev: 4)) == .markSeen)
    }
    @Test func bothDifferentIsConflict() {
        #expect(Reconciler.decide(obs("a", "b", seen: 3), consensus: cons("c", rev: 4)) == .conflict)
    }
    @Test func endpointDeletedAlone() {
        #expect(Reconciler.decide(obs("a", nil, seen: 3), consensus: cons("a", rev: 3)) == .adoptEndpoint)
    }
    @Test func deleteVersusModifyRestores() {
        // Disk deleted F while another endpoint edited it: the edit wins and returns to the disk.
        #expect(Reconciler.decide(obs("a", nil, seen: 3), consensus: cons("b", rev: 4)) == .applyConsensus)
    }
    @Test func modifyVersusRemoteDeleteResurrects() {
        #expect(Reconciler.decide(obs("a", "b", seen: 3), consensus: cons(nil, rev: 4)) == .adoptEndpoint)
    }
    @Test func bothDeleted() {
        #expect(Reconciler.decide(obs("a", nil, seen: 3), consensus: cons(nil, rev: 4)) == .markSeen)
    }
    @Test func newFileOnEndpoint() {
        #expect(Reconciler.decide(obs(nil, "a", seen: 0), consensus: nil) == .adoptEndpoint)
    }
    @Test func newFileBothSidesSameContent() {
        #expect(Reconciler.decide(obs(nil, "a", seen: 0), consensus: cons("a", rev: 1)) == .markSeen)
    }
    @Test func newFileBothSidesDifferentContent() {
        #expect(Reconciler.decide(obs(nil, "a", seen: 0), consensus: cons("b", rev: 1)) == .conflict)
    }
    @Test func firstSyncMissingIsNeverADeletion() {
        // A fresh endpoint (no snapshot) lacking a file others have must receive it, not delete it.
        #expect(Reconciler.decide(obs(nil, nil, seen: 0), consensus: cons("a", rev: 1)) == .applyConsensus)
    }
}

@Suite("Safety helpers")
struct SafetyTests {
    @Test func deletionGuard() {
        let g = DeletionGuard()
        #expect(!g.requiresConfirmation(plannedDeletions: 0, totalTracked: 100))
        #expect(!g.requiresConfirmation(plannedDeletions: 5, totalTracked: 100))
        #expect(g.requiresConfirmation(plannedDeletions: 26, totalTracked: 1000))
        #expect(g.requiresConfirmation(plannedDeletions: 10, totalTracked: 20)) // >25 %
    }
    @Test func portableNames() {
        #expect(PortableName.problems(inComponent: "report.docx").isEmpty)
        #expect(PortableName.problems(inComponent: "a:b.txt") == [.forbiddenCharacter(":")])
        #expect(PortableName.problems(inComponent: "CON.txt") == [.reservedName("CON")])
        #expect(PortableName.problems(inComponent: "name.") == [.trailingDotOrSpace])
        #expect(PortableName.problems(inComponent: String(repeating: "x", count: 256)) == [.componentTooLong])
        #expect(PortableName.problems(inRelativePath: "ok/dir/file.txt").isEmpty)
    }
    @Test func unicodeCanonicalization() {
        let nfd = "e\u{0301}.txt", nfc = "\u{00E9}.txt"
        #expect(PortableName.canonical(nfd) == PortableName.canonical(nfc))
    }
    @Test func ignoreRules() {
        let r = IgnoreRules.default
        #expect(r.isIgnored(relativePath: "a/.DS_Store"))
        #expect(r.isIgnored(relativePath: "a/._photo.jpg"))
        #expect(r.isIgnored(relativePath: ".report.pdf.icloud"))
        #expect(r.isIgnored(relativePath: "x/file.nexus-part"))
        #expect(!r.isIgnored(relativePath: "docs/report.pdf"))
    }
    @Test func conflictName() {
        let n = ConflictNaming.name(for: "report.docx", endpoint: "Disk", date: Date(timeIntervalSince1970: 0),
                                    timeZone: TimeZone(identifier: "UTC")!)
        #expect(n == "report (conflict Disk 1970-01-01 00-00).docx")
        #expect(PortableName.problems(inComponent: n).isEmpty)
    }
}
