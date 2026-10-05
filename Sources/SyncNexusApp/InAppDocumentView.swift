import SwiftUI
import AppKit

enum DocumentType: Identifiable {
    case manual
    case privacy
    case excludeGuide

    var id: String {
        switch self {
        case .manual: return "manual"
        case .privacy: return "privacy"
        case .excludeGuide: return "excludeGuide"
        }
    }
}

struct InAppDocumentView: View {
    let type: DocumentType
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedManualSection: MainSection = .overview

    init(type: DocumentType, initialManualSection: MainSection = .overview) {
        self.type = type
        self._selectedManualSection = State(initialValue: initialManualSection)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header: 標題、語系切換器、關閉按鈕
            HStack(alignment: .center, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: type == .manual ? "book.pages.fill" : (type == .privacy ? "hand.raised.shield.fill" : "shield.checkerboard"))
                        .font(.system(size: 22))
                        .foregroundStyle(Color.accentColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type == .manual ? loc("manual_inapp_title") : (type == .privacy ? loc("privacy_inapp_title") : loc("exclude_guide_inapp_title")))
                            .font(.system(size: 17, weight: .bold))
                        Text(type == .manual ? loc("manual_inapp_subtitle") : (type == .privacy ? loc("privacy_inapp_subtitle") : loc("exclude_guide_inapp_subtitle")))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()

                // 手冊內直接切換語系
                Picker("", selection: Binding(
                    get: { L10n.shared.currentLanguage },
                    set: { L10n.shared.currentLanguage = $0 }
                )) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 130)

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
            .padding(.vertical, 14)
            .background(Theme.sidebar)

            Divider()

            // Main Content Area
            if type == .manual {
                manualLayout
            } else if type == .privacy {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        privacyContent
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        excludeGuideContent
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
            .padding(.vertical, 12)
            .background(Theme.tile)
        }
        .frame(minWidth: 920, minHeight: 650)
        .background(Theme.card)
    }

    // MARK: - 7 大主題獨立頁面式操作手冊
    private var manualLayout: some View {
        HStack(spacing: 0) {
            // 左側主題導覽列 (100% 對齊主視窗 7 大主題順序)
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
            .frame(width: 190)
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
                badge: section.title,
                imageName: "01_overview",
                opsTitle: loc("manual_topic_overview_ops_title"),
                opsDesc: loc("manual_topic_overview_ops_desc"),
                safeTitle: loc("manual_topic_overview_safe_title"),
                safeDesc: loc("manual_topic_overview_safe_desc"),
                tipsTitle: loc("manual_topic_overview_tips_title"),
                tipsDesc: loc("manual_topic_overview_tips_desc")
            )
        case .diffPreview:
            renderTopic(
                title: loc("manual_topic_diff_title"),
                desc: loc("manual_topic_diff_desc"),
                badge: section.title,
                imageName: "02_diff_preview",
                opsTitle: loc("manual_topic_diff_ops_title"),
                opsDesc: loc("manual_topic_diff_ops_desc"),
                safeTitle: loc("manual_topic_diff_safe_title"),
                safeDesc: loc("manual_topic_diff_safe_desc"),
                tipsTitle: loc("manual_topic_diff_tips_title"),
                tipsDesc: loc("manual_topic_diff_tips_desc")
            )
        case .folders:
            renderTopic(
                title: loc("manual_topic_folders_title"),
                desc: loc("manual_topic_folders_desc"),
                badge: section.title,
                imageName: "03_folders",
                opsTitle: loc("manual_topic_folders_ops_title"),
                opsDesc: loc("manual_topic_folders_ops_desc"),
                safeTitle: loc("manual_topic_folders_safe_title"),
                safeDesc: loc("manual_topic_folders_safe_desc"),
                tipsTitle: loc("manual_topic_folders_tips_title"),
                tipsDesc: loc("manual_topic_folders_tips_desc")
            )
        case .activity:
            renderTopic(
                title: loc("manual_topic_activity_title"),
                desc: loc("manual_topic_activity_desc"),
                badge: section.title,
                imageName: "01_overview",
                opsTitle: loc("manual_topic_activity_ops_title"),
                opsDesc: loc("manual_topic_activity_ops_desc"),
                safeTitle: loc("manual_topic_activity_safe_title"),
                safeDesc: loc("manual_topic_activity_safe_desc"),
                tipsTitle: loc("manual_topic_activity_tips_title"),
                tipsDesc: loc("manual_topic_activity_tips_desc")
            )
        case .conflicts:
            renderTopic(
                title: loc("manual_topic_conflicts_title"),
                desc: loc("manual_topic_conflicts_desc"),
                badge: section.title,
                imageName: "04_conflicts",
                opsTitle: loc("manual_topic_conflicts_ops_title"),
                opsDesc: loc("manual_topic_conflicts_ops_desc"),
                safeTitle: loc("manual_topic_conflicts_safe_title"),
                safeDesc: loc("manual_topic_conflicts_safe_desc"),
                tipsTitle: loc("manual_topic_conflicts_tips_title"),
                tipsDesc: loc("manual_topic_conflicts_tips_desc")
            )
        case .versions:
            renderTopic(
                title: loc("manual_topic_versions_title"),
                desc: loc("manual_topic_versions_desc"),
                badge: section.title,
                imageName: "05_versions",
                opsTitle: loc("manual_topic_versions_ops_title"),
                opsDesc: loc("manual_topic_versions_ops_desc"),
                safeTitle: loc("manual_topic_versions_safe_title"),
                safeDesc: loc("manual_topic_versions_safe_desc"),
                tipsTitle: loc("manual_topic_versions_tips_title"),
                tipsDesc: loc("manual_topic_versions_tips_desc")
            )
        case .verification:
            renderTopic(
                title: loc("manual_topic_verification_title"),
                desc: loc("manual_topic_verification_desc"),
                badge: section.title,
                imageName: "06_verification",
                opsTitle: loc("manual_topic_verification_ops_title"),
                opsDesc: loc("manual_topic_verification_ops_desc"),
                safeTitle: loc("manual_topic_verification_safe_title"),
                safeDesc: loc("manual_topic_verification_safe_desc"),
                tipsTitle: loc("manual_topic_verification_tips_title"),
                tipsDesc: loc("manual_topic_verification_tips_desc")
            )
        case .settings:
            renderTopic(
                title: loc("manual_topic_settings_title"),
                desc: loc("manual_topic_settings_desc"),
                badge: section.title,
                imageName: "07_settings",
                opsTitle: loc("manual_topic_settings_ops_title"),
                opsDesc: loc("manual_topic_settings_ops_desc"),
                safeTitle: loc("manual_topic_settings_safe_title"),
                safeDesc: loc("manual_topic_settings_safe_desc"),
                tipsTitle: loc("manual_topic_settings_tips_title"),
                tipsDesc: loc("manual_topic_settings_tips_desc")
            )
        }
    }

    private func renderTopic(
        title: String,
        desc: String,
        badge: String,
        imageName: String,
        opsTitle: String,
        opsDesc: String,
        safeTitle: String,
        safeDesc: String,
        tipsTitle: String,
        tipsDesc: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            // 標題與簡介卡片
            DocCard(
                icon: "sparkles",
                title: title,
                desc: desc,
                badge: badge
            )

            // 真實 UI 截圖展示 (精確對應當前主題畫面)
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

            // 卡片 1：功能按鈕位置與操作方式說明
            DocCard(
                icon: "hand.tap.fill",
                title: opsTitle,
                desc: opsDesc,
                badge: loc("manual_badge_operations")
            )

            // 卡片 2：產出現象、反饋與防護機制
            DocCard(
                icon: "shield.checkerboard",
                title: safeTitle,
                desc: safeDesc,
                badge: loc("manual_badge_phenomena")
            )

            // 卡片 3：日常使用小撇步與秘訣
            DocCard(
                icon: "lightbulb.fill",
                title: tipsTitle,
                desc: tipsDesc,
                badge: loc("manual_badge_tips")
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

    // MARK: - 排除同步安全原則說明內容
    private var excludeGuideContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            DocCard(
                icon: "hammer.fill",
                title: loc("exclude_guide_sec1_title"),
                desc: loc("exclude_guide_sec1_desc"),
                badge: loc("exclude_guide_badge_safe")
            )

            DocCard(
                icon: "shield.lefthalf.filled",
                title: loc("exclude_guide_sec2_title"),
                desc: loc("exclude_guide_sec2_desc"),
                badge: loc("exclude_guide_badge_standard")
            )

            DocCard(
                icon: "exclamationmark.triangle.fill",
                title: loc("exclude_guide_sec3_title"),
                desc: loc("exclude_guide_sec3_desc"),
                badge: loc("exclude_guide_badge_hazard")
            )

            DocCard(
                icon: "arrow.triangle.2.circlepath.circle.fill",
                title: loc("exclude_guide_sec4_title"),
                desc: loc("exclude_guide_sec4_desc"),
                badge: loc("exclude_guide_badge_restore")
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
