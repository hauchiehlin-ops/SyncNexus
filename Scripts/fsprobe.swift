// Phase 0: print FSEvents for the given directories. Usage: swift Scripts/fsprobe.swift <seconds> <dir>...
import Foundation
import CoreServices

let secs = Double(CommandLine.arguments[1]) ?? 30
let dirs = Array(CommandLine.arguments.dropFirst(2))
let t0 = Date()
let cb: FSEventStreamCallback = { _, _, n, paths, flags, _ in
    let ps = unsafeBitCast(paths, to: NSArray.self) as! [String]
    for i in 0..<n {
        let f = flags[i]
        var tags: [String] = []
        if f & UInt32(kFSEventStreamEventFlagItemCreated) != 0 { tags.append("created") }
        if f & UInt32(kFSEventStreamEventFlagItemModified) != 0 { tags.append("modified") }
        if f & UInt32(kFSEventStreamEventFlagItemRemoved) != 0 { tags.append("removed") }
        if f & UInt32(kFSEventStreamEventFlagItemRenamed) != 0 { tags.append("renamed") }
        if f & UInt32(kFSEventStreamEventFlagItemXattrMod) != 0 { tags.append("xattr") }
        if f & UInt32(kFSEventStreamEventFlagItemIsDir) != 0 { tags.append("dir") }
        if f & UInt32(kFSEventStreamEventFlagMustScanSubDirs) != 0 { tags.append("MUSTSCAN") }
        print(String(format: "+%6.2fs", Date().timeIntervalSince(t0)), tags.joined(separator: ","), ps[i])
    }
    fflush(stdout)
}
let s = FSEventStreamCreate(nil, cb, nil, dirs as CFArray, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), 1.0,
                            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes))!
FSEventStreamSetDispatchQueue(s, DispatchQueue.main)
FSEventStreamStart(s)
print("watching \(dirs.count) dirs for \(secs)s"); fflush(stdout)
DispatchQueue.main.asyncAfter(deadline: .now() + secs) { FSEventStreamStop(s); exit(0) }
RunLoop.main.run()
