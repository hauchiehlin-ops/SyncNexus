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
    public static func scan(root: URL, ignore: IgnoreRules, placeholder: ((URL) -> Bool)? = nil, only prefixes: [String]? = nil) throws -> ScanResult {
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
        if let prefixes {
            // Incremental: only these paths (a file, or a folder with everything below it), as reported by FSEvents.
            for p in prefixes where !p.isEmpty {
                if p.split(separator: "/").contains(where: { ignore.isIgnored(component: String($0)) }) { continue }
                let url = root.appendingPathComponent(p)
                var st = Darwin.stat()
                guard lstat(url.path, &st) == 0 else { continue }          // gone: the engine sees it as absent
                let ns = Int64(st.st_mtimespec.tv_sec) * 1_000_000_000 + Int64(st.st_mtimespec.tv_nsec)
                let rel = PortableName.canonical(p)
                switch st.st_mode & S_IFMT {
                case S_IFDIR:
                    result.files[rel] = ScannedFile(rel: rel, url: url, size: 0, mtimeNs: ns, mtime: Date(timeIntervalSince1970: Double(ns) / 1e9), isPlaceholder: false, isDirectory: true)
                    try walk(url, rel + "/")
                case S_IFREG:
                    result.files[rel] = ScannedFile(rel: rel, url: url, size: Int64(st.st_size), mtimeNs: ns, mtime: Date(timeIntervalSince1970: Double(ns) / 1e9),
                                                    isPlaceholder: placeholder?(url) ?? (st.st_flags & SF_DATALESS_FLAG != 0))
                default: continue
                }
            }
            return result
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

    public enum CopyError: Error { case sourceChanged, targetIsDirectory, verificationFailed }

    /// SHA-256 of a file, or nil if it was modified while being read (size / mtime differ before and after):
    /// such a hash describes a torn read and must never become a sync state.
    public static func hashIfStable(_ url: URL, size: Int64, mtimeNs: Int64) throws -> String? {
        let h = try sha256(of: url)
        guard let after = statInfo(url), after.size == size, after.mtimeNs == mtimeNs else { return nil }
        return h
    }

    /// Flushes to the physical medium (fsync alone only reaches the drive's cache on macOS).
    static let fullSyncThreshold: Int64 = 4 * 1024 * 1024

    static func fullSync(fd: Int32) { if fcntl(fd, F_FULLFSYNC) != 0 { fsync(fd) } }

    public static func syncDirectory(_ dir: URL) {
        let fd = open(dir.path, O_RDONLY)
        if fd >= 0 { fullSync(fd: fd); close(fd) }
    }

    /// Re-reads a file bypassing the page cache, so the check sees what the medium really holds.
    static func sha256OnMedia(of url: URL) throws -> String {
        let fd = open(url.path, O_RDONLY)
        guard fd >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        _ = fcntl(fd, F_NOCACHE, 1)
        let h = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
        var hasher = SHA256()
        var more = true
        while more {
            try autoreleasepool {
                if let chunk = try h.read(upToCount: 1 << 20), !chunk.isEmpty { hasher.update(data: chunk) } else { more = false }
            }
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    /// Copy `src` to `dst` through a temp file in the same directory; verifies the SHA-256 of what was read,
    /// then renames over the destination (atomic on the same volume). A failure never touches `dst`.
    ///
    /// `durable` (used for removable disks, which can be unplugged at any moment) flushes file and folder to the medium and
    /// re-reads the stored bytes to prove they match. POSIX permissions, ACLs and extended attributes are carried over.
    public static func copyAtomically(from src: URL, to dst: URL, expectHash: String, mtime: Date?, durable: Bool = false) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: dst.path, isDirectory: &isDir), isDir.boolValue { throw CopyError.targetIsDirectory }

        var written: Int64 = 0
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
                        written += Int64(chunk.count)
                    } else { more = false }
                }
            }
            // A full flush costs ~25 ms per call: only for big files. Small files get fsync plus one flush per pass (Engine).
            if durable && written >= fullSyncThreshold { fullSync(fd: output.fileDescriptor) } else { try output.synchronize() }
            let got = hasher.finalize().map { String(format: "%02x", $0) }.joined()
            guard got == expectHash else { throw CopyError.sourceChanged }
            // mode bits (e.g. the executable bit), ACLs and extended attributes; best effort (exFAT cannot store all of them)
            _ = copyfile(src.path, tmp.path, nil, copyfile_flags_t(COPYFILE_SECURITY | COPYFILE_XATTR))
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
        if durable {
            if written >= fullSyncThreshold { syncDirectory(dst.deletingLastPathComponent()) }
            guard (try? sha256OnMedia(of: dst)) == expectHash else {
                try? fm.removeItem(at: dst)               // never leave bytes that do not match what was verified
                throw CopyError.verificationFailed
            }
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
