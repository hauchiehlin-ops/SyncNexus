import Foundation

public enum ConflictNaming {
    /// `report.docx` -> `report (conflict Disk 2026-10-02 14-30).docx`. The name avoids `:` so it is valid on exFAT.
    public static func name(for original: String, endpoint: String, date: Date, timeZone: TimeZone = .current) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = timeZone
        f.dateFormat = "yyyy-MM-dd HH-mm"
        let stamp = f.string(from: date)
        let ns = original as NSString
        let ext = ns.pathExtension
        let stem = ext.isEmpty ? original : ns.deletingPathExtension
        let safeEndpoint = PortableName.problems(inComponent: endpoint).isEmpty
            ? endpoint
            : String(endpoint.map { PortableName.forbidden.contains($0) ? "_" : $0 })
        let suffix = " (conflict \(safeEndpoint) \(stamp))"
        return ext.isEmpty ? stem + suffix : "\(stem)\(suffix).\(ext)"
    }

    /// Conflict copies are kept only on the endpoint where the conflict happened: they are never synced,
    /// so they stay out of every scan until the user resolves them (or renames them back to a normal name).
    public static func isConflictName(_ name: String) -> Bool {
        name.range(of: #" \(conflict .+ \d{4}-\d{2}-\d{2} \d{2}-\d{2}\)(\.[^./]*)?$"#, options: .regularExpression) != nil
    }
}
