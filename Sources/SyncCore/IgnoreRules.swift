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

    public init(exactNames: Set<String>, prefixes: [String], suffixes: [String]) {
        self.exactNames = exactNames
        self.prefixes = prefixes
        self.suffixes = suffixes
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
        path.split(separator: "/").contains { isIgnored(component: String($0)) }
    }
}

/// Things people rarely want synced. Chosen in the settings; excluded paths are simply left alone everywhere (never deleted).
public enum ExcludePreset: String, CaseIterable, Sendable, Identifiable {
    case nodeModules, git, databases, photosLibraries
    public var id: String { rawValue }
    public static let defaults: Set<ExcludePreset> = [.nodeModules, .databases, .photosLibraries]

    public var title: String {
        switch self {
        case .nodeModules: "node_modules（程式專案的套件資料夾）"
        case .git: ".git（版本控制資料夾）"
        case .databases: "資料庫暫存檔（-wal、-shm、-journal）"
        case .photosLibraries: "照片圖庫（.photoslibrary）"
        }
    }

    public var why: String {
        switch self {
        case .nodeModules: "檔案又多又瑣碎，可以隨時重新安裝。"
        case .git: "同步到一半的 .git 會損壞版本庫；預設不排除，請自行決定。"
        case .databases: "使用中的資料庫會得到不一致的複本。"
        case .photosLibraries: "照片圖庫是一個正在使用的資料庫，同步它會損壞圖庫。"
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
            }
        }
        return r
    }

    public static func parsePresets(_ raw: String?) -> Set<ExcludePreset> {
        guard let raw else { return ExcludePreset.defaults }
        return Set(raw.split(separator: ",").compactMap { ExcludePreset(rawValue: String($0)) })
    }
}
