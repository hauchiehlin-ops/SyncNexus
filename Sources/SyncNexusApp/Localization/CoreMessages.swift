import Foundation
import SyncCore

/// SyncCore produces its user-visible messages as fixed Chinese templates (its logic depends on them).
/// This maps each message to the selected UI language at the display boundary, so nothing stays untranslated.
enum CoreMessages {
    private struct Entry { let key: String; let regex: NSRegularExpression; let literalCount: Int; let zhStartsWithBracket: Bool }

    private static let entries: [Entry] = CoreMessageTemplates.all.compactMap { key, zh in
        let parts = zh.components(separatedBy: "%@")
        let pattern = "^" + parts.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "(.*?)") + "$"
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { return nil }
        return Entry(key: key, regex: re, literalCount: parts.reduce(0) { $0 + $1.count }, zhStartsWithBracket: zh.hasPrefix("[%@]"))
    }.sorted { $0.literalCount > $1.literalCount }   // most specific template first

    static func localize(_ text: String) -> String {
        let ns = text as NSString
        let full = NSRange(location: 0, length: ns.length)
        for e in entries {
            guard let m = e.regex.firstMatch(in: text, options: [], range: full) else { continue }
            var args: [CVarArg] = []
            for i in 1..<m.numberOfRanges {
                let arg = ns.substring(with: m.range(at: i))
                // the first argument of "[endpoint] ..." messages is an endpoint name
                args.append(i == 1 && e.zhStartsWithBracket ? DisplayNames.endpoint(arg) : localize(arg))   // arguments may themselves be core messages
            }
            return loc(e.key, arguments: args)
        }
        return text
    }

    static func localize(_ error: Error) -> String { localize(String(describing: error)) }
}

/// Names that the app itself generated in whatever language was active at the time (endpoint "本機", group "預設群組")
/// are shown in the current language. Names the user typed are never touched.
enum DisplayNames {
    private static func variants(_ key: String) -> Set<String> {
        Set(AppLanguage.allCases.compactMap { StringsTable[key]?[$0] })
    }

    static func endpoint(_ id: String) -> String {
        var base = id, suffix = ""
        if let last = id.last, let n = last.wholeNumberValue, (2...9).contains(n) { base = String(id.dropLast()); suffix = String(last) }
        if base == "Local" || variants("kind_local").contains(base) { return loc("kind_local") + suffix }
        return id
    }

    /// Groups the user never named have an empty name and are shown as "New Group", "New Group 2"… in the current language.
    static func group(_ g: SyncGroup, among all: [SyncGroup]) -> String {
        if g.id == "default", variants("group_default_name").contains(g.name) { return loc("group_default_name") }
        if g.name.isEmpty {
            let unnamed = all.filter { $0.name.isEmpty }
            let n = (unnamed.firstIndex { $0.id == g.id } ?? 0) + 1
            return loc("group_new_default_name") + (n > 1 ? " \(n)" : "")
        }
        return g.name
    }
}
