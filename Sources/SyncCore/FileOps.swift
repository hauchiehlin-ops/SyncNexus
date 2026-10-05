import Foundation
import CryptoKit

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

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

/// A cooperative cancellation requested while walking a potentially slow cloud-backed tree.
/// Callers must treat this differently from an unreadable endpoint: it is an intentional stop,
/// not evidence that files disappeared.
public struct ScanCancelled: Error, Sendable {}

public enum FileOps {
    #if canImport(Darwin)
    static let SF_DATALESS_FLAG: UInt32 = 0x4000_0000
    #endif

    private static func getStat(path: String) -> (size: Int64, mtimeNs: Int64, isDir: Bool, isReg: Bool, isDataless: Bool)? {
        #if canImport(Darwin)
        var st = Darwin.stat()
        guard lstat(path, &st) == 0 else { return nil }
        let isDir = (st.st_mode & S_IFMT) == S_IFDIR
        let isReg = (st.st_mode & S_IFMT) == S_IFREG
        let isDataless = (st.st_flags & SF_DATALESS_FLAG) != 0
        let ns = Int64(st.st_mtimespec.tv_sec) * 1_000_000_000 + Int64(st.st_mtimespec.tv_nsec)
        return (Int64(st.st_size), ns, isDir, isReg, isDataless)
        #elseif canImport(Glibc)
        var st = stat()
        guard lstat(path, &st) == 0 else { return nil }
        let isDir = (st.st_mode & S_IFMT) == S_IFDIR
        let isReg = (st.st_mode & S_IFMT) == S_IFREG
        let ns = Int64(st.st_mtim.tv_sec) * 1_000_000_000 + Int64(st.st_mtim.tv_nsec)
        return (Int64(st.st_size), ns, isDir, isReg, false)
        #else
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
              let size = attrs[.size] as? Int64,
              let date = attrs[.modificationDate] as? Date,
              let type = attrs[.type] as? FileAttributeType else { return nil }
        let ns = Int64(date.timeIntervalSince1970 * 1_000_000_000)
        return (size, ns, type == .typeDirectory, type == .typeRegular, false)
        #endif
    }

    /// `placeholder` lets tests mark files as not-downloaded; real runs use the file's dataless flag.
    public static func scan(root: URL, ignore: IgnoreRules, placeholder: ((URL) -> Bool)? = nil,
                            only prefixes: [String]? = nil, shouldCancel: (() -> Bool)? = nil,
                            progress: ((String, Int) -> Void)? = nil) throws -> ScanResult {
        var result = ScanResult()
        var discovered = 0
        let fm = FileManager.default
        func walk(_ dir: URL, _ prefix: String) throws {
            if shouldCancel?() == true { throw ScanCancelled() }
            let names = try fm.contentsOfDirectory(atPath: dir.path)
            if shouldCancel?() == true { throw ScanCancelled() }
            for name in names {
                if shouldCancel?() == true { throw ScanCancelled() }
                let url = dir.appendingPathComponent(name)
                if name.hasSuffix(".nexus-part") { result.leftovers.append(url); continue }
                if ignore.isIgnored(component: name) { continue }
                let rel = prefix + PortableName.canonical(name)
                if ignore.isIgnored(relativePath: rel) { continue }
                guard let st = getStat(path: url.path) else { continue }
                discovered += 1
                progress?(rel, discovered)
                if st.isDir {
                    // Early pruning: Never descend into ignored directories (e.g. target, .build, node_modules, .git, or excluded sub-groups)
                    result.files[rel] = ScannedFile(rel: rel, url: url, size: 0, mtimeNs: st.mtimeNs,
                                                    mtime: Date(timeIntervalSince1970: Double(st.mtimeNs) / 1e9),
                                                    isPlaceholder: false, isDirectory: true)
                    try walk(url, rel + "/")
                } else if st.isReg {
                    result.files[rel] = ScannedFile(
                        rel: rel, url: url, size: st.size, mtimeNs: st.mtimeNs,
                        mtime: Date(timeIntervalSince1970: Double(st.mtimeNs) / 1e9),
                        isPlaceholder: placeholder?(url) ?? st.isDataless)
                }
            }
        }
        if let prefixes {
            // Incremental: only these paths (a file, or a folder with everything below it), as reported by event stream.
            for p in prefixes where !p.isEmpty {
                if shouldCancel?() == true { throw ScanCancelled() }
                let rel = PortableName.canonical(p)
                if ignore.isIgnored(relativePath: rel) { continue }
                let url = root.appendingPathComponent(p)
                guard let st = getStat(path: url.path) else { continue }
                discovered += 1
                progress?(rel, discovered)
                if st.isDir {
                    result.files[rel] = ScannedFile(rel: rel, url: url, size: 0, mtimeNs: st.mtimeNs,
                                                    mtime: Date(timeIntervalSince1970: Double(st.mtimeNs) / 1e9),
                                                    isPlaceholder: false, isDirectory: true)
                    try walk(url, rel + "/")
                } else if st.isReg {
                    result.files[rel] = ScannedFile(rel: rel, url: url, size: st.size, mtimeNs: st.mtimeNs,
                                                    mtime: Date(timeIntervalSince1970: Double(st.mtimeNs) / 1e9),
                                                    isPlaceholder: placeholder?(url) ?? st.isDataless)
                }
            }
            return result
        }
        try walk(root, "")
        return result
    }

    public static func sha256(of url: URL, shouldCancel: (() -> Bool)? = nil,
                              progress: ((Int64) -> Void)? = nil) throws -> String {
        let h = try FileHandle(forReadingFrom: url)
        defer { try? h.close() }
        var hasher = SHA256()
        var more = true
        var read: Int64 = 0
        while more {
            if shouldCancel?() == true { throw ScanCancelled() }
            try autoreleasepool {
                if let chunk = try h.read(upToCount: 1 << 20), !chunk.isEmpty {
                    hasher.update(data: chunk)
                    read += Int64(chunk.count)
                    progress?(read)
                } else { more = false }
            }
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    public enum CopyError: Error { case sourceChanged, targetIsDirectory, verificationFailed }

    /// SHA-256 of a file, or nil if it was modified while being read (size / mtime differ before and after):
    /// such a hash describes a torn read and must never become a sync state.
    public static func hashIfStable(_ url: URL, size: Int64, mtimeNs: Int64,
                                    shouldCancel: (() -> Bool)? = nil, progress: ((Int64) -> Void)? = nil) throws -> String? {
        let h = try sha256(of: url, shouldCancel: shouldCancel, progress: progress)
        guard let after = statInfo(url), after.size == size, after.mtimeNs == mtimeNs else { return nil }
        return h
    }

    /// Flushes to the physical medium (fsync alone only reaches the drive's cache on macOS).
    static let fullSyncThreshold: Int64 = 4 * 1024 * 1024

    static func fullSync(fd: Int32) {
        #if canImport(Darwin)
        if fcntl(fd, F_FULLFSYNC) != 0 { fsync(fd) }
        #elseif canImport(Glibc)
        fdatasync(fd)
        fsync(fd)
        #else
        fsync(fd)
        #endif
    }

    public static func syncDirectory(_ dir: URL) {
        let fd = open(dir.path, O_RDONLY)
        if fd >= 0 { fullSync(fd: fd); close(fd) }
    }

    /// Re-reads a file bypassing the page cache, so the check sees what the medium really holds.
    static func sha256OnMedia(of url: URL) throws -> String {
        let fd = open(url.path, O_RDONLY)
        guard fd >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        #if canImport(Darwin)
        _ = fcntl(fd, F_NOCACHE, 1)
        #elseif canImport(Glibc)
        _ = posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED)
        #endif
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
    public static func copyAtomically(from src: URL, to dst: URL, expectHash: String, mtime: Date?, durable: Bool = false,
                                      shouldCancel: (() -> Bool)? = nil,
                                      progress: ((Int64, Int64) -> Void)? = nil) throws {
        let fm = FileManager.default
        try fm.createDirectory(at: dst.deletingLastPathComponent(), withIntermediateDirectories: true)
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: dst.path, isDirectory: &isDir), isDir.boolValue { throw CopyError.targetIsDirectory }

        var written: Int64 = 0
        let totalBytes = max(1, statInfo(src)?.size ?? 1)
        let tmp = dst.deletingLastPathComponent().appendingPathComponent(".nexus-\(UUID().uuidString).nexus-part")
        var cloned = false

        #if canImport(Darwin)
        if !durable, shouldCancel?() != true {
            let before = statInfo(src)
            if clonefile(src.path, tmp.path, 0) == 0 {
                let after = statInfo(src)
                if let before, let after, before.size == after.size, before.mtimeNs == after.mtimeNs {
                    cloned = true
                    written = totalBytes
                    progress?(written, totalBytes)
                    _ = copyfile(src.path, tmp.path, nil, copyfile_flags_t(COPYFILE_SECURITY | COPYFILE_XATTR))
                    if let mtime { try? fm.setAttributes([.modificationDate: mtime], ofItemAtPath: tmp.path) }
                } else {
                    try? fm.removeItem(at: tmp)
                    throw CopyError.sourceChanged
                }
            }
        }
        #endif

        if !cloned {
            guard fm.createFile(atPath: tmp.path, contents: nil) else { throw CocoaError(.fileWriteUnknown) }
            do {
                let input = try FileHandle(forReadingFrom: src)
                let output = try FileHandle(forWritingTo: tmp)
                defer { try? input.close(); try? output.close() }
                var hasher = SHA256()
                var more = true
                while more {
                    if shouldCancel?() == true { throw ScanCancelled() }
                    try autoreleasepool {
                        if let chunk = try input.read(upToCount: 1 << 20), !chunk.isEmpty {
                            hasher.update(data: chunk)
                            try output.write(contentsOf: chunk)
                            written += Int64(chunk.count)
                            progress?(written, totalBytes)
                        } else { more = false }
                    }
                }
                if durable && written >= fullSyncThreshold { fullSync(fd: output.fileDescriptor) } else { try output.synchronize() }
                let got = hasher.finalize().map { String(format: "%02x", $0) }.joined()
                guard got == expectHash else { throw CopyError.sourceChanged }

                #if canImport(Darwin)
                _ = copyfile(src.path, tmp.path, nil, copyfile_flags_t(COPYFILE_SECURITY | COPYFILE_XATTR))
                #endif
                if let mtime { try fm.setAttributes([.modificationDate: mtime], ofItemAtPath: tmp.path) }
            } catch {
                try? fm.removeItem(at: tmp)
                throw error
            }
        }
        if shouldCancel?() == true {
            try? fm.removeItem(at: tmp)
            throw ScanCancelled()
        }
        guard rename(tmp.path, dst.path) == 0 else {
            let err = POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            try? fm.removeItem(at: tmp)
            throw err
        }
        if durable {
            if written >= fullSyncThreshold { syncDirectory(dst.deletingLastPathComponent()) }
            guard (try? sha256OnMedia(of: dst)) == expectHash else {
                try? fm.removeItem(at: dst)
                throw CopyError.verificationFailed
            }
        }
    }

    public static func statInfo(_ url: URL) -> (size: Int64, mtimeNs: Int64)? {
        guard let st = getStat(path: url.path) else { return nil }
        return (st.size, st.mtimeNs)
    }

    /// Mount-level identity of the volume holding `url`.
    public static func volumeUUID(of url: URL) -> String? {
        try? url.resourceValues(forKeys: [.volumeUUIDStringKey]).volumeUUIDString
    }
}
