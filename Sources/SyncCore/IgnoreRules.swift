import Foundation

/// Files that are never synced: OS litter, partial transfers and the engine's own temporaries.
/// The provider-specific patterns (iCloud / Google Drive) are provisional until confirmed by the Phase 0 probe.
public struct IgnoreRules: Sendable {
    public var exactNames: Set<String>
    public var prefixes: [String]
    public var suffixes: [String]

    public static let `default` = IgnoreRules(
        exactNames: [".DS_Store", ".Trashes", ".Spotlight-V100", ".fseventsd", ".TemporaryItems",
                     ".DocumentRevisions-V100", "Thumbs.db", "desktop.ini", "$RECYCLE.BIN",
                     "System Volume Information", ".syncnexus-endpoint", ".localized", ".syncnexus-history",
                     "Icon\r", ".syncnexus-icon.ico"],   // custom folder icons (macOS "Icon\r", Windows icon file): local decoration, never synced
        prefixes: ["._", "~$", ".~lock.", ".nexus-"],
        suffixes: [".nexus-part", ".tmp", ".crdownload", ".part", ".tmp.drivedownload", ".gdoc", ".gsheet", ".gslides", ".gscript", ".gform", ".gdraw", ".gsite", ".gmap", ".gjam", ".gtable"]
    )

    public var pathPrefixes: [String] = []
    public var exactPaths: Set<String> = []

    public init(exactNames: Set<String>, prefixes: [String], suffixes: [String], pathPrefixes: [String] = [], exactPaths: Set<String> = []) {
        self.exactNames = exactNames
        self.prefixes = prefixes
        self.suffixes = suffixes
        self.pathPrefixes = pathPrefixes
        self.exactPaths = exactPaths
    }

    /// OS litter and partial transfers: safe to discard together with a folder that is being removed.
    public func isLitter(component name: String) -> Bool {
        if exactNames.contains(name) { return true }
        if prefixes.contains(where: name.hasPrefix) { return true }
        // iCloud placeholder files for evicted items look like ".name.ext.icloud"
        if name.hasPrefix(".") && name.hasSuffix(".icloud") { return true }
        return suffixes.contains(where: name.hasSuffix)
    }

    /// Litter plus conflict copies (which stay on their endpoint until the user resolves them).
    public func isIgnored(component name: String) -> Bool {
        isLitter(component: name) || ConflictNaming.isConflictName(name)
    }

    public func isIgnored(relativePath path: String) -> Bool {
        let clean = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if exactPaths.contains(clean) { return true }
        if pathPrefixes.contains(where: { clean == $0 || clean.hasPrefix($0 + "/") }) { return true }
        return clean.split(separator: "/").contains { isIgnored(component: String($0)) }
    }
}

/// Unsafe live data that is always excluded and left untouched everywhere (never deleted).
public enum ExcludePreset: String, CaseIterable, Sendable, Identifiable {
    case nodeModules, git, databases, photosLibraries, buildCaches, pythonEnvironments
    public var id: String { rawValue }
    public static let defaults = Set(ExcludePreset.allCases)

    public var title: String {
        switch self {
        case .nodeModules: "node_modules（程式專案的套件資料夾）"
        case .git: ".git（版本控制資料夾）"
        case .databases: "資料庫暫存檔（-wal、-shm、-journal）"
        case .photosLibraries: "照片圖庫（.photoslibrary）"
        case .buildCaches: "專案編譯快取（.build、target、build、.gradle、DerivedData、Pods）"
        case .pythonEnvironments: "Python 虛擬環境與快取（venv、.venv、env、__pycache__、.pytest_cache、.mypy_cache、.tox）"
        }
    }

    public var why: String {
        switch self {
        case .nodeModules: "檔案又多又瑣碎，可以隨時重新安裝。"
        case .git: "同步到一半的 .git 可能損壞版本庫，請直接使用 Git 管理。"
        case .databases: "使用中的資料庫會得到不一致的複本。"
        case .photosLibraries: "照片圖庫是一個正在使用的資料庫，同步它會損壞圖庫。"
        case .buildCaches: "編譯產物瑣碎且可隨時重新產生，同步會產生大量衝突並耗損傳輸效能。"
        case .pythonEnvironments: "Python 虛擬環境包含數萬個硬編碼路徑的小檔案，無法跨機器共用，且能隨時重建。"
        }
    }
}

extension IgnoreRules {
    public func applying(_ presets: Set<ExcludePreset>) -> IgnoreRules {
        var r = self
        for p in presets {
            switch p {
            case .nodeModules: r.exactNames.insert("node_modules")
            case .git: r.exactNames.insert(".git")
            case .databases: r.suffixes += ["-wal", "-shm", "-journal", ".sqlite-wal", ".sqlite-shm"]
            case .photosLibraries: r.suffixes += [".photoslibrary", ".photolibrary"]
            case .buildCaches: r.exactNames.formUnion([".build", "build", "target", ".gradle", "DerivedData", "Pods"])
            case .pythonEnvironments: r.exactNames.formUnion(["venv", ".venv", "env", "__pycache__", ".pytest_cache", ".mypy_cache", ".tox"])
            }
        }
        return r
    }

    public func applying(customPatterns: [String]) -> IgnoreRules {
        var r = self
        for pat in customPatterns {
            let trimmed = pat.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            guard !trimmed.isEmpty else { continue }
            if trimmed.contains("/") {
                r.pathPrefixes.append(trimmed)
            } else {
                r.exactNames.insert(trimmed)
                r.exactPaths.insert(trimmed)
                r.pathPrefixes.append(trimmed)
            }
        }
        return r
    }

    public static func parsePresets(_ raw: String?) -> Set<ExcludePreset> {
        // Migrate every legacy selection (including an empty value) to mandatory protection.
        _ = raw
        return ExcludePreset.defaults
    }
}
