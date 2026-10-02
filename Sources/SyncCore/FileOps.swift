import Foundation
import CryptoKit
import Darwin

public struct ScannedFile: Sendable {
    public var rel: String          // NFC-normalised, "/"-separated
    public var url: URL
    public var size: Int64
    public var mtimeNs: Int64
    public var mtime: Date
    /// iCloud / Drive placeholder: reading it would trigger a download, so we do not.
    public var isPlaceholder: Bool
    public var isDirectory = false
}

public struct ScanResult: Sendable {
    public var files: [String: ScannedFile] = [:]
    public var leftovers: [URL] = []   // engine temp files left behind by an interrupted run
}

public enum FileOps {
    static let SF_DATALESS_FLAG: UInt32 = 0x4000_0000

    /// `placeholder` lets tests mark files as not-downloaded; real runs use the file's SF_DATALESS flag.
    public static func scan(root: URL, ignore: IgnoreRules, placeholder: ((URL) -> Bool)? = nil) throws -> ScanResult {
        var result = ScanResult()
        let fm = FileManager.default
        func walk(_ dir: URL, _ prefix: String) throws {
            for name in try fm.contentsOfDirectory(atPath: dir.path) {
                let url = dir.appendingPathComponent(name)
                if name.hasSuffix(".nexus-part") { result.leftovers.append(url); continue }
                if ignore.isIgnored(component: name) { continue }
                var st = Darwin.stat()
                guard lstat(url.path, &st) == 0 else { continue }
                let rel = prefix + PortableName.canonical(name)
                switch st.st_mode & S_IFMT {
                case S_IFDIR:
                    let ns = Int64(st.st_mtimespec.tv_sec) * 1_000_000_000 + Int64(st.st_mtimespec.tv_nsec)
                    result.files[rel] = ScannedFile(rel: rel, url: url, size: 0, mtimeNs: ns,
                                                    mtime: Date(timeIntervalSince1970: Double(ns) / 1e9),
                                                    isPlaceholder: false, isDirectory: true)
                    try walk(url, rel + "/")
                case S_IFREG:
                    let ns = Int64(st.st_mtimespec.tv_sec) * 1_000_000_000 + Int64(st.st_mtimespec.tv_nsec)
                    result.files[rel] = ScannedFile(
                        rel: rel, url: url, size: Int64(st.st_size), mtimeNs: ns,
                        mtime: Date(timeIntervalSince1970: Double(ns) / 1e9),
                        isPlaceholder: placeholder?(url) ?? (st.st_flags & SF_DATALESS_FLAG != 0))
                default: continue   // symlinks, sockets, ...: never followed
                }
            }
        }
        try walk(root, "")
        return result
    }

    public static func sha256(of url: URL) throws -> String {
        let h = try FileHandle(forReadingFrom: url)
        defer { try? h.close() }
        var hasher = SHA256()
        // The pool matters: without it every 1 MB chunk stays alive until the (long) calling block ends.
        var more = true
        while more {
            try autoreleasepool {
                if let chunk = try h.read(upToCount: 1 << 20), !chunk.isEmpty { hasher.update(data: chunk) } else { more = false }
            }
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    public enum CopyError: Error { case sourceChanged, targetIsDirectory }

    /// Copy `src` to `dst` through a temp file in the same directory; verifies the SHA-256 of what was read,
    /// then renames over the destination (atomic on the same volume). A failure never touches `dst`.
    public static func copyAtomically(from src: URL, to dst: URL, expectHash: String, mtime: Date?) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: dst.path, isDirectory: &isDir), isDir.boolValue { throw CopyError.targetIsDirectory }

        let tmp = dst.deletingLastPathComponent().appendingPathComponent(".nexus-\(UUID().uuidString).nexus-part")
        guard fm.createFile(atPath: tmp.path, contents: nil) else { throw CocoaError(.fileWriteUnknown) }
        do {
            let input = try FileHandle(forReadingFrom: src)
            let output = try FileHandle(forWritingTo: tmp)
            defer { try? input.close(); try? output.close() }
            var hasher = SHA256()
            var more = true
            while more {
                try autoreleasepool {
                    if let chunk = try input.read(upToCount: 1 << 20), !chunk.isEmpty {
                        hasher.update(data: chunk)
                        try output.write(contentsOf: chunk)
                    } else { more = false }
                }
            }
            try output.synchronize()
            let got = hasher.finalize().map { String(format: "%02x", $0) }.joined()
            guard got == expectHash else { throw CopyError.sourceChanged }
            if let mtime { try fm.setAttributes([.modificationDate: mtime], ofItemAtPath: tmp.path) }
        } catch {
            try? fm.removeItem(at: tmp)
            throw error
        }
        guard rename(tmp.path, dst.path) == 0 else {
            let err = POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            try? fm.removeItem(at: tmp)
            throw err
        }
    }

    public static func statInfo(_ url: URL) -> (size: Int64, mtimeNs: Int64)? {
        var st = Darwin.stat()
        guard lstat(url.path, &st) == 0 else { return nil }
        return (Int64(st.st_size), Int64(st.st_mtimespec.tv_sec) * 1_000_000_000 + Int64(st.st_mtimespec.tv_nsec))
    }

    /// Mount-level identity of the volume holding `url`.
    public static func volumeUUID(of url: URL) -> String? {
        try? url.resourceValues(forKeys: [.volumeUUIDStringKey]).volumeUUIDString
    }
}
