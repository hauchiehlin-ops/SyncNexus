import AppKit
import SyncCore

/// Gives each synced folder the icon of its sync group in Finder: the system folder with the group's symbol on it.
/// Groups that keep the plain "folder" icon leave their folders untouched. macOS stores the custom icon in a hidden
/// "Icon\r" file inside the folder, which SyncCore ignores, so it never travels to other endpoints.
@MainActor
enum FolderIcon {
    private static let enabledKey = "folder_icons_enabled"
    private static let appliedKey = "folder_icons_applied"   // [folder path: symbol] we put there, so we can take it away again

    static var isEnabled: Bool {
        get { UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    private static var applied: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: appliedKey) as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: appliedKey) }
    }

    /// The system folder icon with the group's SF Symbol in its body.
    static func render(symbol: String) -> NSImage? {
        guard let glyph = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) else { return nil }
        let size = NSSize(width: 512, height: 512)
        let base = NSWorkspace.shared.icon(for: .folder)
        let tint = NSColor.controlAccentColor.blended(withFraction: 0.25, of: .black) ?? .controlAccentColor
        let config = NSImage.SymbolConfiguration(pointSize: 190, weight: .semibold)
            .applying(NSImage.SymbolConfiguration(paletteColors: [tint.withAlphaComponent(0.9)]))
        guard let colored = glyph.withSymbolConfiguration(config) else { return nil }

        return NSImage(size: size, flipped: false) { rect in
            base.draw(in: rect)
            let g = colored.size
            let scale = min(210 / max(g.width, 1), 210 / max(g.height, 1), 1.6)
            let w = g.width * scale, h = g.height * scale
            // the folder body sits a little below the middle of the icon
            colored.draw(in: NSRect(x: rect.midX - w / 2, y: rect.midY - h / 2 - 28, width: w, height: h))
            return true
        }
    }

    @discardableResult
    static func apply(symbol: String, to path: String) -> Bool {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir), isDir.boolValue,
              let image = render(symbol: symbol) else { return false }
        return NSWorkspace.shared.setIcon(image, forFile: path, options: [])
    }

    static func remove(from path: String) {
        guard FileManager.default.fileExists(atPath: path) else { return }
        NSWorkspace.shared.setIcon(nil, forFile: path, options: [])
    }

    /// Brings Finder in line with `desired` (folder path → group symbol). Only touches what changed, and only
    /// removes icons that this app put there itself.
    static func sync(desired: [String: String]) {
        let wanted = isEnabled ? desired : [:]
        var now = applied
        guard wanted != now else { return }

        for (path, symbol) in wanted where now[path] != symbol {
            if apply(symbol: symbol, to: path) { now[path] = symbol }
        }
        for path in Array(now.keys) where wanted[path] == nil {
            remove(from: path)
            now.removeValue(forKey: path)
        }
        applied = now
    }
}
