import Foundation

public struct VersionsUsage: Sendable, Equatable {
    public var bytes: Int64 = 0
    public var files = 0
    public var oldest: Date?
}

/// The archive of replaced file versions: `<UTC stamp>/<endpoint>/<path>`. Retention is by age and by total size.
public enum Versions {
    static let stampFormat: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd'T'HH-mm-ss'Z'"
        return f
    }()

    private static func stamps(_ dir: URL) -> [(url: URL, date: Date)] {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? []
        return names.compactMap { n in stampFormat.date(from: n).map { (dir.appendingPathComponent(n), $0) } }
            .sorted { $0.date < $1.date }
    }

    private static func size(of dir: URL) -> (bytes: Int64, files: Int) {
        var bytes: Int64 = 0, files = 0
        if let e = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey]) {
            for case let u as URL in e {
                let v = try? u.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
                if v?.isRegularFile == true { bytes += Int64(v?.fileSize ?? 0); files += 1 }
            }
        }
        return (bytes, files)
    }

    public static func usage(_ dir: URL) -> VersionsUsage {
        var u = VersionsUsage()
        for s in stamps(dir) {
            let sz = size(of: s.url)
            u.bytes += sz.bytes; u.files += sz.files
            if u.oldest == nil { u.oldest = s.date }
        }
        return u
    }

    /// Removes snapshots older than `days` and then the oldest ones until the total fits `maxBytes`.
    /// Pass nil / 0 to disable a rule. Returns what was freed.
    @discardableResult
    public static func purge(_ dir: URL, olderThanDays days: Int?, maxBytes: Int64?, now: Date = Date()) -> (files: Int, bytes: Int64) {
        var removedFiles = 0, freed: Int64 = 0
        func remove(_ s: (url: URL, date: Date)) {
            let sz = size(of: s.url)
            if (try? FileManager.default.removeItem(at: s.url)) != nil { removedFiles += sz.files; freed += sz.bytes }
        }
        var all = stamps(dir)
        if let days, days > 0 {
            let cutoff = now.addingTimeInterval(-Double(days) * 86400)
            for s in all where s.date < cutoff { remove(s) }
            all = all.filter { $0.date >= cutoff }
        }
        if let maxBytes, maxBytes > 0 {
            var total = all.reduce(Int64(0)) { $0 + size(of: $1.url).bytes }
            for s in all where total > maxBytes {
                total -= size(of: s.url).bytes
                remove(s)
            }
        }
        return (removedFiles, freed)
    }

    @discardableResult
    public static func purgeAll(_ dir: URL) -> (files: Int, bytes: Int64) {
        var f = 0, b: Int64 = 0
        for s in stamps(dir) {
            let sz = size(of: s.url)
            if (try? FileManager.default.removeItem(at: s.url)) != nil { f += sz.files; b += sz.bytes }
        }
        return (f, b)
    }
}
