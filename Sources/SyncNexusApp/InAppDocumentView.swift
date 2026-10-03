import SwiftUI
import AppKit

public enum DocumentType: Identifiable {
    case manual
    case privacy

    public var id: String {
        switch self {
        case .manual: return "manual"
        case .privacy: return "privacy"
        }
    }
}

public struct InAppDocumentView: View {
    let type: DocumentType
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.dismiss) private var dismiss

    public init(type: DocumentType) {
        self.type = type
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    Image(systemName: type == .manual ? "book.pages.fill" : "hand.raised.shield.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.accentColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type == .manual ? loc("manual_inapp_title") : loc("privacy_inapp_title"))
                            .font(.system(size: 18, weight: .bold))
                        Text(loc("manual_inapp_subtitle"))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text(loc("btn_close"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                }
                .buttonStyle(QuietButton(kind: .secondary, compact: true))
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Theme.sidebar)

            Divider()

            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if type == .manual {
                        manualContent
                    } else {
                        privacyContent
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            // Footer
            HStack {
                Text(loc("manual_inapp_footer_note"))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(loc("btn_close")) {
                    dismiss()
                }
                .buttonStyle(QuietButton(kind: .primary, compact: true))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Theme.tile)
        }
        .frame(minWidth: 640, minHeight: 520)
        .background(Theme.card)
    }

    // MARK: - 接地氣操作手冊內容
    private var manualContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            DocCard(
                icon: "folder.badge.plus",
                title: loc("manual_step1_title"),
                desc: loc("manual_step1_desc"),
                badge: loc("manual_badge_quickstart")
            )

            DocCard(
                icon: "internaldrive",
                title: loc("manual_local_title"),
                desc: loc("manual_local_desc"),
                badge: "Mac"
            )

            DocCard(
                icon: "icloud",
                title: loc("manual_icloud_title"),
                desc: loc("manual_icloud_desc"),
                badge: "iCloud"
            )

            DocCard(
                icon: "externaldrive.connected.to.line.below",
                title: loc("manual_gdrive_title"),
                desc: loc("manual_gdrive_desc"),
                badge: "Google Drive"
            )

            DocCard(
                icon: "externaldrive",
                title: loc("manual_usb_title"),
                desc: loc("manual_usb_desc"),
                badge: "USB / ExFAT"
            )

            DocCard(
                icon: "arrow.triangle.2.circlepath",
                title: loc("manual_sync_title"),
                desc: loc("manual_sync_desc"),
                badge: loc("manual_badge_smart")
            )

            DocCard(
                icon: "shield.lefthalf.filled",
                title: loc("manual_protection_title"),
                desc: loc("manual_protection_desc"),
                badge: loc("manual_badge_safety")
            )
        }
    }

    // MARK: - 隱私權保護政策內容
    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            DocCard(
                icon: "hand.raised.fill",
                title: loc("privacy_sec1_title"),
                desc: loc("privacy_sec1_desc"),
                badge: loc("privacy_badge_local")
            )

            DocCard(
                icon: "lock.shield",
                title: loc("privacy_sec2_title"),
                desc: loc("privacy_sec2_desc"),
                badge: loc("privacy_badge_sandbox")
            )

            DocCard(
                icon: "wifi.slash",
                title: loc("privacy_sec3_title"),
                desc: loc("privacy_sec3_desc"),
                badge: loc("privacy_badge_no_cloud")
            )

            DocCard(
                icon: "trash.circle",
                title: loc("privacy_sec4_title"),
                desc: loc("privacy_sec4_desc"),
                badge: loc("privacy_badge_trash")
            )
        }
    }
}

private struct DocCard: View {
    let icon: String
    let title: String
    let desc: String
    let badge: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Text(badge)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.12), in: Capsule())
                    .foregroundStyle(Color.accentColor)
            }
            Text(desc)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Theme.line, lineWidth: 1)
        )
    }
}
