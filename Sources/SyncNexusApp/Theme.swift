import AppKit
import SwiftUI
import SyncCore

/// "Quiet": looks like part of macOS. System fonts and materials, one accent colour, green / amber only for meaning.
enum Theme {
    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let v = isDark ? dark : light
            return NSColor(srgbRed: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255, blue: CGFloat(v & 0xFF) / 255, alpha: 1)
        })
    }

    static let ok = dynamic(light: 0x1F7A45, dark: 0x52C97F)
    static let okFill = dynamic(light: 0xEAF6EE, dark: 0x16301F)
    static let warn = dynamic(light: 0x9A5200, dark: 0xFFB454)
    static let warnFill = dynamic(light: 0xFFF2DE, dark: 0x3A2A10)
    static let bad = dynamic(light: 0xB3261E, dark: 0xFF8A80)
    static let badFill = dynamic(light: 0xFDECEA, dark: 0x3A1613)
    static let card = Color(nsColor: .controlBackgroundColor)
    static let tile = Color.primary.opacity(0.05)
    static let line = Color.primary.opacity(0.10)
    static let sidebar = dynamic(light: 0xF1F1F5, dark: 0x252528)
}

struct Chip: View {
    enum Kind { case ok, warn, bad, neutral }
    let text: String
    var kind: Kind = .ok
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(fg)
            .padding(.horizontal, 9).padding(.vertical, 3)
            .background(bg, in: Capsule())
    }
    private var fg: Color { switch kind { case .ok: Theme.ok; case .warn: Theme.warn; case .bad: Theme.bad; case .neutral: .secondary } }
    private var bg: Color { switch kind { case .ok: Theme.okFill; case .warn: Theme.warnFill; case .bad: Theme.badFill; case .neutral: Theme.tile } }
}

struct Card<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
    }
}

struct StatTile: View {
    let label: String, value: String, sub: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.system(size: 12, weight: .semibold)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 26, weight: .bold)).tracking(-0.5).monospacedDigit()
            Text(sub).font(.system(size: 12)).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18).padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.tile, in: RoundedRectangle(cornerRadius: 14))
    }
}

struct QuietButton: ButtonStyle {
    enum Kind { case primary, secondary, plain, dark }
    var kind: Kind = .secondary
    var compact = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, kind == .plain ? 0 : (compact ? 13 : 16)).padding(.vertical, kind == .plain ? 0 : (compact ? 7 : 9))
            .foregroundStyle(fg)
            .background(bg, in: RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(kind == .secondary ? Theme.line : .clear, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Rectangle())
    }
    private var fg: Color { switch kind { case .primary, .dark: Color.white; case .secondary: Color.primary; case .plain: Color.accentColor } }
    private var bg: Color { switch kind { case .primary: Color.accentColor; case .dark: Color(nsColor: .labelColor).opacity(0.88); case .secondary: Theme.card; case .plain: .clear } }
}

extension EndpointKind {
    var symbol: String {
        switch self { case .local: "laptopcomputer"; case .icloud: "icloud"; case .googleDrive: "cloud"; case .external: "externaldrive" }
    }
    var label: String {
        switch self { case .local: "本機"; case .icloud: "iCloud 雲碟"; case .googleDrive: "Google Drive"; case .external: "外接磁碟" }
    }
}

func shortPath(_ p: String) -> String {
    p.replacingOccurrences(of: NSHomeDirectory(), with: "~")
        .replacingOccurrences(of: "/Library/Mobile Documents/com~apple~CloudDocs", with: "/iCloud Drive")
        .replacingOccurrences(of: #"/Library/CloudStorage/GoogleDrive-[^/]+"#, with: "/Google Drive", options: .regularExpression)
}

func friendlyOp(_ op: String) -> String {
    switch op {
    case "copy": "已更新"
    case "move": "已改名"
    case "trash": "已移到垃圾桶"
    case "mkdir": "已建立資料夾"
    case "restore": "已還原舊版本"
    case "conflict-rename": "衝突，已保留兩份"
    case "conflict-keep-main", "conflict-keep-copy": "衝突已處理"
    default: op
    }
}
