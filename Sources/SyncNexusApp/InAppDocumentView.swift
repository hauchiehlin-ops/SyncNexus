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
    @State private var selectedManualSection: MainSection = .overview

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

            // Main Content Area
            if type == .manual {
                manualLayout
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        privacyContent
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
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
        .frame(minWidth: 860, minHeight: 620)
        .background(Theme.card)
    }

    // MARK: - 7 大主題獨立頁面式操作手冊
    private var manualLayout: some View {
        HStack(spacing: 0) {
            // 左側主題導覽列 (對齊側邊欄 7 大項目)
            VStack(alignment: .leading, spacing: 4) {
                Text(loc("menu_user_manual"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 6)

                ForEach(MainSection.allCases) { sec in
                    Button {
                        selectedManualSection = sec
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: sec.symbol)
                                .font(.system(size: 14))
                                .frame(width: 18)
                            Text(sec.title)
                                .font(.system(size: 13, weight: selectedManualSection == sec ? .semibold : .regular))
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedManualSection == sec ? Color.accentColor.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(selectedManualSection == sec ? Color.accentColor : Color.primary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(10)
            .frame(width: 180)
            .background(Theme.sidebar.opacity(0.5))

            Divider()

            // 右側主題詳細頁面
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    topicPage(for: selectedManualSection)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func topicPage(for section: MainSection) -> some View {
        switch section {
        case .overview:
            renderTopic(
                title: loc("manual_topic_overview_title"),
                desc: loc("manual_topic_overview_desc"),
                badge: loc("section_overview"),
                imageName: "01_overview",
                f1Title: loc("manual_topic_overview_f1_title"),
                f1Desc: loc("manual_topic_overview_f1_desc"),
                f2Title: loc("stat_tracked_files"),
                f2Desc: loc("manual_topic_overview_f2_desc")
            )
        case .diffPreview:
            renderTopic(
                title: loc("manual_topic_diff_title"),
                desc: loc("manual_topic_diff_desc"),
                badge: loc("section_diff_preview"),
                imageName: "02_diff_preview",
                f1Title: loc("manual_topic_diff_f1_title"),
                f1Desc: loc("manual_topic_diff_f1_desc"),
                f2Title: loc("manual_topic_diff_f2_title"),
                f2Desc: loc("manual_topic_diff_f2_desc")
            )
        case .folders:
            renderTopic(
                title: loc("manual_topic_folders_title"),
                desc: loc("manual_topic_folders_desc"),
                badge: loc("section_folders"),
                imageName: "03_folders_endpoints",
                f1Title: loc("manual_topic_folders_f1_title"),
                f1Desc: loc("manual_topic_folders_f1_desc"),
                f2Title: loc("manual_topic_folders_f2_title"),
                f2Desc: loc("manual_topic_folders_f2_desc")
            )
        case .conflicts:
            renderTopic(
                title: loc("manual_topic_conflicts_title"),
                desc: loc("manual_topic_conflicts_desc"),
                badge: loc("section_conflicts"),
                imageName: "04_conflicts",
                f1Title: loc("manual_topic_conflicts_f1_title"),
                f1Desc: loc("manual_topic_conflicts_f1_desc"),
                f2Title: loc("conflicts_empty_title"),
                f2Desc: loc("conflicts_empty_desc")
            )
        case .versions:
            renderTopic(
                title: loc("manual_topic_versions_title"),
                desc: loc("manual_topic_versions_desc"),
                badge: loc("section_versions"),
                imageName: "05_versions",
                f1Title: loc("manual_topic_versions_f1_title"),
                f1Desc: loc("manual_topic_versions_f1_desc"),
                f2Title: loc("manual_topic_versions_f2_title"),
                f2Desc: loc("manual_topic_versions_f2_desc")
            )
        case .verification:
            renderTopic(
                title: loc("manual_topic_verification_title"),
                desc: loc("manual_topic_verification_desc"),
                badge: loc("section_verification"),
                imageName: "06_verification",
                f1Title: loc("manual_topic_verification_f1_title"),
                f1Desc: loc("manual_topic_verification_f1_desc"),
                f2Title: loc("verification_safeguards_title"),
                f2Desc: "\(loc("safeguard_1"))\n\(loc("safeguard_2"))\n\(loc("safeguard_3"))\n\(loc("safeguard_4"))"
            )
        case .settings:
            renderTopic(
                title: loc("manual_topic_settings_title"),
                desc: loc("manual_topic_settings_desc"),
                badge: loc("section_settings"),
                imageName: "07_settings",
                f1Title: loc("manual_topic_settings_f1_title"),
                f1Desc: loc("manual_topic_settings_f1_desc"),
                f2Title: loc("manual_topic_settings_f2_title"),
                f2Desc: loc("manual_topic_settings_f2_desc")
            )
        }
    }

    private func renderTopic(
        title: String,
        desc: String,
        badge: String,
        imageName: String,
        f1Title: String,
        f1Desc: String,
        f2Title: String,
        f2Desc: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            // 標題與簡介卡片
            DocCard(
                icon: "sparkles",
                title: title,
                desc: desc,
                badge: badge
            )

            // 實際 UI 截圖展示
            if let img = loadManualImage(named: imageName) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "macwindow")
                            .foregroundStyle(Color.accentColor)
                        Text(loc("menu_user_manual") + " — " + badge)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }

                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Theme.line, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                }
                .padding(14)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.line, lineWidth: 1))
            }

            // 功能按鈕位置與操作方式說明
            DocCard(
                icon: "hand.tap.fill",
                title: f1Title,
                desc: f1Desc,
                badge: loc("status_ok")
            )

            // 預期現象、反饋與防護機制
            DocCard(
                icon: "shield.checkerboard",
                title: f2Title,
                desc: f2Desc,
                badge: loc("manual_badge_safety")
            )
        }
    }

    private func loadManualImage(named: String) -> NSImage? {
        if let url = Bundle.main.url(forResource: named, withExtension: "png", subdirectory: "ManualAssets"),
           let img = NSImage(contentsOf: url) {
            return img
        }
        let appSupportPath = "Resources/ManualAssets/\(named).png"
        if FileManager.default.fileExists(atPath: appSupportPath), let img = NSImage(contentsOfFile: appSupportPath) {
            return img
        }
        let docsPath = "docs/manual/assets/\(named).png"
        if FileManager.default.fileExists(atPath: docsPath), let img = NSImage(contentsOfFile: docsPath) {
            return img
        }
        return nil
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
