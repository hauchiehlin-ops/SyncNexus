import Foundation

/// Why a file name cannot be stored on exFAT / FAT32 / Windows (the disk travels between Mac and Windows).
public enum NameProblem: Equatable, Sendable {
    case forbiddenCharacter(Character)
    case controlCharacter
    case reservedName(String)
    case trailingDotOrSpace
    case componentTooLong
    case pathTooLong
}

public enum PortableName {
    static let forbidden: Set<Character> = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]
    static let reserved: Set<String> = {
        var s: Set<String> = ["CON", "PRN", "AUX", "NUL"]
        for i in 1...9 { s.insert("COM\(i)"); s.insert("LPT\(i)") }
        return s
    }()

    /// Problems with a single path component (empty array = portable).
    public static func problems(inComponent name: String) -> [NameProblem] {
        var out: [NameProblem] = []
        for ch in name {
            if forbidden.contains(ch) {
                out.append(.forbiddenCharacter(ch))
            } else if ch.unicodeScalars.contains(where: { $0.value < 0x20 }) {
                out.append(.controlCharacter)
            }
        }
        let stem = name.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? name
        if reserved.contains(stem.uppercased()) { out.append(.reservedName(stem)) }
        if name.hasSuffix(".") || name.hasSuffix(" ") { out.append(.trailingDotOrSpace) }
        if name.utf16.count > 255 { out.append(.componentTooLong) }
        return out
    }

    /// Problems for a relative path such as `Project/a:b.txt`. `rootLength` is the length of the
    /// endpoint root path, since Windows' 260-character limit counts the full path.
    public static func problems(inRelativePath path: String, rootLength: Int = 0) -> [NameProblem] {
        var out = path.split(separator: "/").flatMap { problems(inComponent: String($0)) }
        if rootLength + path.utf16.count + 1 > 260 { out.append(.pathTooLong) }
        return out
    }

    /// Canonical form used for comparing names across endpoints (macOS may hand back NFD).
    public static func canonical(_ name: String) -> String {
        name.precomposedStringWithCanonicalMapping
    }
}
