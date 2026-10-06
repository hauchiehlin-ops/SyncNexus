import Foundation

/// Where SyncNexus keeps its own data (databases, version archive, logs).
///
/// Normally this is the user's `~/Library`. Setting `SYNCNEXUS_HOME` to a directory redirects
/// everything there instead, so the app and CLI can run against a throw-away environment
/// (screenshots, demos, tests) without ever reading or writing the real data.
public enum DataLocations {
    /// The override directory, or nil in normal operation.
    public static var overrideRoot: URL? {
        guard let p = ProcessInfo.processInfo.environment["SYNCNEXUS_HOME"], !p.isEmpty else { return nil }
        return URL(fileURLWithPath: (p as NSString).expandingTildeInPath, isDirectory: true)
    }

    /// Parent of the "SyncNexus" data folder.
    public static var applicationSupport: URL {
        if let o = overrideRoot { return o.appendingPathComponent("Application Support", isDirectory: true) }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    /// Parent of "Logs/SyncNexus".
    public static var library: URL {
        if let o = overrideRoot { return o.appendingPathComponent("Library-Override", isDirectory: true) }
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }

    /// Home directory used to abbreviate paths as "~" in the UI.
    public static var displayHome: String { overrideRoot?.path ?? NSHomeDirectory() }
}
