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
                     "System Volume Information", ".syncnexus-endpoint", ".localized"],
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
