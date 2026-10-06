import AppKit
import SwiftUI
import UniformTypeIdentifiers
import SyncCore

func bytes(_ n: Int64) -> String { ByteCountFormatter.string(fromByteCount: n, countStyle: .file) }

extension ExcludePreset {
    var localizedTitle: String {
        switch self {
        case .nodeModules: return loc("preset_node_modules_title")
        case .buildCaches: return loc("preset_build_caches_title")
        case .git: return loc("preset_git_title")
        case .databases: return loc("preset_databases_title")
        case .photosLibraries: return loc("preset_photos_title")
        case .pythonEnvironments: return loc("preset_python_title")
        }
    }

    var localizedWhy: String {
        switch self {
        case .nodeModules: return loc("preset_node_modules_why")
        case .buildCaches: return loc("preset_build_caches_why")
        case .git: return loc("preset_git_why")
        case .databases: return loc("preset_databases_why")
        case .photosLibraries: return loc("preset_photos_why")
        case .pythonEnvironments: return loc("preset_python_why")
        }
    }
}

struct MainWindowView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State private var activeDocument: DocumentType?

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            VStack(spacing: 0) {
                // 首頁頁首 / 頂部導覽列：語系、操作說明手冊、隱私權政策
                HStack(alignment: .center, spacing: 10) {
                    Text(model.section.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    // 語系選單
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

                    // 操作說明手冊入口圖示按鈕 (原生應用內開展)
                    Button {
                        activeDocument = .manual
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "book.pages")
                            Text(loc("menu_user_manual"))
                        }
                    }
                    .buttonStyle(QuietButton(kind: .secondary, compact: true))
                    .help(loc("menu_user_manual"))

                    // 隱私權政策入口圖示按鈕 (原生應用內開展)
                    Button {
                        activeDocument = .privacy
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.raised.shield")
                            Text(loc("privacy_policy_title"))
                        }
                    }
                    .buttonStyle(QuietButton(kind: .secondary, compact: true))
                    .help(loc("privacy_policy_title"))
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 10)
                .background(Theme.sidebar.opacity(0.35))

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch model.section {
                        case .overview: OverviewSection(model: model)
                        case .diffPreview: DiffPreviewSection(model: model)
                        case .folders: FoldersSection(model: model)
                        case .activity: SyncActivitySection(model: model)
                        case .conflicts: ConflictsSection(model: model)
                        case .versions: VersionsSection(model: model)
                        case .verification: VerificationSection(model: model)
                        case .settings: SettingsSection(model: model)
                        }
                    }
                    .padding(.horizontal, 36).padding(.vertical, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(minWidth: 940, minHeight: 620)
        .id(l10n.currentLanguage)
        // 快顯提示 (Floating Toast HUD)
        .overlay(alignment: .top) {
            if model.isRestoringBackup {
                HStack(alignment: .center, spacing: 12) {
                    ProgressView().controlSize(.small)
                    Text(model.backupRestoreStatus ?? loc("backup_restore_stopping"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.primary)
                    Spacer(minLength: 8)
                    Button(loc("cancel")) { model.cancelBackupRestore() }
                        .buttonStyle(QuietButton(kind: .secondary, compact: true))
                        .disabled(!model.canCancelBackupRestore)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                .padding(.top, 16)
                .padding(.horizontal, 40)
                .frame(maxWidth: 680)
                .zIndex(1000)
            } else if let status = model.appOperationStatus {
                HStack(alignment: .center, spacing: 12) {
                    ProgressView().controlSize(.small)
                    Text(status).font(.system(size: 13, weight: .medium))
                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                .padding(.top, 16)
                .padding(.horizontal, 40)
                .frame(maxWidth: 680)
                .zIndex(1000)
            } else if model.section != .activity, let live = model.primaryProgress {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        ProgressView().controlSize(.small)
                        Text(model.progressStage(live.progress))
                            .font(.system(size: 13, weight: .semibold))
                        if live.progress.stage == .scanning && live.progress.completed > 0 {
                            Text("（已發現 \(live.progress.completed.formatted()) 項）")
                                .font(.system(size: 12).monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        if model.groups.count > 1 {
                            Text(live.groupName).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Text("\(Int((model.aggregateProgressFraction * 100).rounded()))%")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .frame(minWidth: 40, alignment: .trailing)
                        Button(loc("progress_cancel")) { model.cancelAllCurrentRuns() }
                            .buttonStyle(QuietButton(kind: .secondary, compact: true))
                            .disabled(model.isCancellingRuns)
                    }
                    ProgressView(value: model.aggregateProgressFraction).progressViewStyle(.linear)
                    // Always present (blank when idle) so the card keeps its height while the scan reports paths.
                    Text(live.progress.currentPath.flatMap { $0.isEmpty ? nil : $0 } ?? " ")
                        .font(.system(size: 11, design: .monospaced)).foregroundStyle(.secondary)
                        .lineLimit(1).truncationMode(.middle)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                .padding(.top, 16)
                .padding(.horizontal, 40)
                .frame(maxWidth: 680)
                .zIndex(1000)
            } else if let m = model.settingsMessage {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.accentColor)
                    Text(m)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.primary)
                        .lineLimit(4)
                    Spacer(minLength: 8)
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            model.settingsMessage = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 8)
                .padding(.top, 16)
                .padding(.horizontal, 40)
                .frame(maxWidth: 680)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .zIndex(999)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: model.settingsMessage)
        .task(id: model.settingsMessage) {
            guard model.settingsMessage != nil else { return }
            try? await Task.sleep(nanoseconds: 7_000_000_000)
            withAnimation(.easeOut(duration: 0.2)) {
                model.settingsMessage = nil
            }
        }
        .sheet(item: $activeDocument) { doc in
            InAppDocumentView(type: doc)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 10) {
                Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 30, height: 30)
                Text(loc("app_name")).font(.system(size: 15, weight: .bold))
            }
            .padding(.horizontal, 10).padding(.bottom, 18).padding(.top, 6)
            ForEach(MainSection.allCases) { s in
                Button {
                    model.section = s
                    if s == .conflicts && model.snap.conflicts.isEmpty {
                        if let g = model.groups.first(where: { !(model.snapshots[$0.id]?.conflicts.isEmpty ?? true) }) {
                            model.selectGroup(id: g.id)
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: s.symbol).font(.system(size: 15)).frame(width: 20)
                        Text(s.title).font(.system(size: 14, weight: model.section == s ? .semibold : .medium))
                        Spacer(minLength: 0)
                        if s == .conflicts && model.totalConflictCount > 0 {
                            Text("\(model.totalConflictCount)").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                                .padding(.horizontal, 6).frame(minWidth: 18, minHeight: 18)
                                .background(Theme.warn, in: Capsule())
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(model.section == s ? Color.primary.opacity(0.09) : .clear, in: RoundedRectangle(cornerRadius: 8))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Text(loc("app_version_build", Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?", Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"))
                .font(.system(size: 11)).foregroundStyle(.secondary).padding(.horizontal, 10)
        }
        .padding(.horizontal, 12).padding(.vertical, 16)
        .frame(width: 224)
        .background(Theme.sidebar)
    }
}

func sectionHeader(_ title: String, _ subtitle: String? = nil) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title).font(.system(size: 30, weight: .bold)).tracking(-0.5)
        if let subtitle { Text(subtitle).font(.system(size: 15)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true) }
    }
}

// MARK: overview

struct OverviewSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State private var editingGroup: SyncGroup? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            sectionHeader(model.overall == .ok ? loc("status_all_normal") : model.overallTitle, overviewSubtitle)
            Spacer()
            if let g = model.activeGroup {
                let isPaused = model.isGroupPaused(id: g.id)
                if isPaused {
                    Button(action: { model.resumeGroup(id: g.id) }) {
                        HStack(spacing: 5) {
                            Image(systemName: "play.fill").font(.system(size: 11))
                            Text(loc("popover_resume_sync"))
                        }
                    }
                    .buttonStyle(QuietButton(kind: .primary, compact: true))
                } else {
                    Button(action: { model.syncGroupNow(id: g.id) }) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.clockwise").font(.system(size: 11))
                            Text(loc("popover_sync_now"))
                        }
                    }
                    .buttonStyle(QuietButton(kind: .secondary, compact: true))
                }
            }
        }

        if model.groups.count > 1 {
            HStack(spacing: 8) {
                Text(loc("group_selector_title") + ":")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(model.groups, id: \.id) { (group: SyncGroup) in
                            let isActive: Bool = (group.id == model.activeGroupId)
                            let badge = model.groupStatusBadge(for: group.id)
                            Button(action: {
                                model.selectGroup(id: group.id)
                                if badge.kind == .bad || badge.kind == .warn {
                                    if !(model.snapshots[group.id]?.conflicts.isEmpty ?? true) {
                                        model.section = .conflicts
                                    }
                                }
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: group.icon).font(.system(size: 11))
                                    Text(model.groupName(group)).font(.system(size: 12, weight: isActive ? .bold : .regular))
                                    Text(badge.text)
                                        .font(.system(size: 9, weight: .semibold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1.5)
                                        .background(
                                            isActive ? Color.white.opacity(0.3) :
                                                (badge.kind == .bad ? Theme.badFill : (badge.kind == .warn ? Theme.warnFill : Theme.okFill)),
                                            in: Capsule()
                                        )
                                        .foregroundStyle(
                                            isActive ? Color.white :
                                                (badge.kind == .bad ? Theme.bad : (badge.kind == .warn ? Theme.warn : Theme.ok))
                                        )
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(isActive ? Theme.accent : Theme.tile, in: RoundedRectangle(cornerRadius: 6))
                                .foregroundStyle(isActive ? Color.white : Color.primary)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                let isPaused = model.isGroupPaused(id: group.id)
                                if isPaused {
                                    Button(loc("popover_resume_sync")) {
                                        model.resumeGroup(id: group.id)
                                    }
                                } else {
                                    Button(loc("popover_sync_now")) {
                                        model.syncGroupNow(id: group.id)
                                    }
                                    Button(loc("popover_pause_sync")) {
                                        model.pauseGroup(id: group.id)
                                    }
                                }
                                Divider()
                                Button(loc("group_edit_title")) {
                                    editingGroup = group
                                }
                                Button(role: .destructive) {
                                    model.confirmAndDeleteGroup(group)
                                } label: {
                                    Label(loc("group_delete_button"), systemImage: "trash")
                                }
                                .disabled(model.groups.count <= 1)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 4)
        }

        if model.snap.confirmation != nil {
            Card {
                HStack(spacing: 12) {
                    Image(systemName: "hand.raised").foregroundStyle(Theme.warn)
                    Text(model.snap.confirmation?.reason ?? "").font(.system(size: 13)).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Button(loc("btn_review_confirm")) { model.reviewConfirmation() }.buttonStyle(QuietButton(kind: .dark))
                }
            }
        }
        HStack(spacing: 14) {
            StatTile(label: loc("stat_tracked_files"), value: model.snap.trackedFiles.formatted(), sub: loc("stat_sub_sha256"))
            StatTile(label: loc("stat_last_deep_verify"), value: model.snap.lastDeepVerify?.formatted(date: .omitted, time: .shortened) ?? loc("never"), sub: model.snap.integrityIssues.isEmpty ? loc("no_anomalies") : loc("suspected_corrupted_count", model.snap.integrityIssues.count))
            StatTile(label: loc("stat_old_versions"), value: bytes(model.snap.versions.bytes), sub: model.snap.versionsRetentionDays == 0 ? loc("retention_permanent_sub") : loc("retention_days_sub", model.snap.versionsRetentionDays))
        }
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            ForEach(model.snap.endpoints, id: \.id) { ep in EndpointCard(model: model, ep: ep) }
        }

        // 同 Wi-Fi 局域網近端設備 (P2P 局域網直連)
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "wifi").foregroundStyle(Color.accentColor)
                    Text(loc("p2p_section_title")).font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text(model.nearbyPeers.isEmpty ? loc("p2p_searching") : loc("p2p_found", model.nearbyPeers.count))
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                }

                if model.nearbyPeers.isEmpty {
                    Text(loc("p2p_empty_hint"))
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                } else {
                    ForEach(model.nearbyPeers) { peer in
                        HStack(spacing: 10) {
                            Image(systemName: "laptopcomputer.and.iphone").font(.system(size: 16))
                            VStack(alignment: .leading) {
                                Text(peer.name).font(.system(size: 13, weight: .medium))
                                Text("P2P Direct").font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Chip(text: loc("online"), kind: .ok)
                        }
                        .padding(8)
                        .background(Theme.tile, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }

        if model.snap.endpoints.count < 2 {
            Card { HStack { Image(systemName: "folder.badge.plus").foregroundStyle(Color.accentColor)
                Text(loc("folders_minimum_warning")).font(.system(size: 14))
                Spacer(); Button(loc("folders_add_button")) { model.section = .folders }.buttonStyle(QuietButton(kind: .primary)) } }
        }
        Color.clear.frame(height: 0)
            .sheet(item: $editingGroup) { group in
                EditGroupSheet(model: model, group: group) { editingGroup = nil }
            }
    }

    private var overviewSubtitle: String {
        switch model.overall {
        case .ok: loc("overview_sub_ok", model.snap.endpoints.count)
        case .partial: loc("overview_sub_partial")
        default: model.overallDetail
        }
    }
}

struct EndpointCard: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    let ep: SyncService.EndpointStatus
    var body: some View {
        let kind = EndpointValidator.kind(path: ep.root, removable: ep.removable)
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: kind.symbol).font(.system(size: 17))
                    Text(DisplayNames.endpoint(ep.id)).font(.system(size: 15, weight: .bold))
                    Spacer()
                    Chip(text: ep.online ? loc("online") : loc("offline"), kind: ep.online ? .ok : .warn)
                }
                Text(shortPath(ep.root)).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(2).truncationMode(.middle)
                Text(ep.online ? (model.pendingCloud(ep.id) > 0 ? loc("endpoint_reading_cloud", model.pendingCloud(ep.id)) : kind.label + (ep.portableNames ? loc("endpoint_portable_suffix") : "") + (ep.role == .archive ? loc("endpoint_archive_suffix") : ""))
                     : ep.detail)
                    .font(.system(size: 13)).foregroundStyle(ep.online ? Color.primary : Theme.warn).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: sync activity

struct SyncActivitySection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State private var selectedGroupFilter: String = "ALL" // "ALL" or groupId
    @State private var query = ""
    @State private var autoScroll = true

    private var filteredLogs: [SyncLogItem] {
        let q = query.trimmingCharacters(in: .whitespaces)
        return model.syncLogs.filter { item in
            if selectedGroupFilter != "ALL" && item.groupId != selectedGroupFilter {
                return false
            }
            if !q.isEmpty {
                let match = item.path.localizedCaseInsensitiveContains(q)
                    || item.fileName.localizedCaseInsensitiveContains(q)
                    || item.op.localizedCaseInsensitiveContains(q)
                    || item.destinationEndpoint.localizedCaseInsensitiveContains(q)
                    || (item.sourceEndpoint?.localizedCaseInsensitiveContains(q) ?? false)
                    || item.groupName.localizedCaseInsensitiveContains(q)
                if !match { return false }
            }
            return true
        }
    }

    var body: some View {
        sectionHeader(loc("section_activity"), loc("section_activity_desc"))

        // 即時進度卡片（若正在同步）
        if let live = model.primaryProgress {
            Card {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        ProgressView().controlSize(.small)
                        Text(model.progressStage(live.progress))
                            .font(.system(size: 14, weight: .semibold))
                        if live.progress.stage == .scanning && live.progress.completed > 0 {
                            Text("（已發現 \(live.progress.completed.formatted()) 項）")
                                .font(.system(size: 12).monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        if model.groups.count > 1 {
                            Text("· \(live.groupName)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(Int((model.aggregateProgressFraction * 100).rounded()))%")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .frame(minWidth: 44, alignment: .trailing)
                        Button(loc("progress_cancel")) { model.cancelAllCurrentRuns() }
                            .buttonStyle(QuietButton(kind: .secondary, compact: true))
                            .disabled(model.isCancellingRuns)
                    }
                    ProgressView(value: model.aggregateProgressFraction).progressViewStyle(.linear)
                    Text(live.progress.currentPath.flatMap { $0.isEmpty ? nil : $0 } ?? " ")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }

        // 工具列：群組篩選器、搜尋、自動滾動開關、清除紀錄、匯出紀錄
        Card(padding: 12) {
            HStack(spacing: 12) {
                // 群組選擇器
                Picker("", selection: $selectedGroupFilter) {
                    Text(loc("activity_all_groups")).tag("ALL")
                    ForEach(model.groups) { g in
                        Text(model.groupName(g)).tag(g.id)
                    }
                }
                .frame(width: 150)

                // 搜尋框
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    TextField(loc("activity_search_placeholder"), text: $query)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                    if !query.isEmpty {
                        Button {
                            query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
                .frame(maxWidth: 240)

                Toggle(isOn: $autoScroll) {
                    Text(loc("activity_auto_scroll"))
                        .font(.system(size: 12))
                }
                .toggleStyle(.checkbox)

                Spacer(minLength: 8)

                Button {
                    model.clearSyncLogs()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text(loc("activity_clear_logs"))
                    }
                }
                .buttonStyle(QuietButton(kind: .secondary, compact: true))
                .disabled(model.syncLogs.isEmpty)

                Button {
                    exportLogs()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text(loc("activity_export_logs"))
                    }
                }
                .buttonStyle(QuietButton(kind: .secondary, compact: true))
                .disabled(model.syncLogs.isEmpty)
            }
        }

        // 動態事件串流表格
        if filteredLogs.isEmpty {
            Card(padding: 36) {
                VStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.accentColor.opacity(0.6))
                    Text(loc("activity_empty_hint"))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        } else {
            Card(padding: 0) {
                ScrollView(.horizontal, showsIndicators: true) {
                    VStack(spacing: 0) {
                        // 表格標頭
                        HStack(spacing: 8) {
                            Text(loc("activity_col_time"))
                                .frame(width: 72, alignment: .leading)
                            Text(loc("activity_col_group"))
                                .frame(width: 80, alignment: .leading)
                            Text(loc("activity_col_filename"))
                                .frame(width: 140, alignment: .leading)
                            Text(loc("activity_col_direction"))
                                .frame(width: 130, alignment: .leading)
                            Text(loc("activity_col_action"))
                                .frame(width: 75, alignment: .leading)
                            Text(loc("activity_col_size"))
                                .frame(width: 70, alignment: .trailing)
                            Text(loc("activity_col_speed"))
                                .frame(width: 80, alignment: .trailing)
                            Text(loc("activity_col_duration"))
                                .frame(width: 60, alignment: .trailing)
                            Text(loc("activity_col_path"))
                                .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.primary.opacity(0.04))

                        Divider()

                        // 事件清單（帶 ScrollViewReader 支援自動滾動到最頂端最新事件）
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(filteredLogs.enumerated()), id: \.element.id) { index, item in
                                        if index > 0 {
                                            Divider()
                                        }
                                        HStack(spacing: 8) {
                                            // 時間
                                            Text(item.timestamp.formatted(date: .omitted, time: .standard))
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundStyle(.secondary)
                                                .frame(width: 72, alignment: .leading)

                                            // 群組
                                            Text(item.groupName)
                                                .font(.system(size: 11, weight: .medium))
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .frame(width: 80, alignment: .leading)

                                            // 傳輸檔名 (新增欄位)
                                            HStack(spacing: 4) {
                                                Image(systemName: fileIcon(for: item.fileName))
                                                    .font(.system(size: 10))
                                                    .foregroundStyle(.secondary)
                                                Text(item.fileName)
                                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                                    .lineLimit(1)
                                                    .truncationMode(.middle)
                                            }
                                            .frame(width: 140, alignment: .leading)
                                            .help(item.path)

                                            // 同步方向
                                            Text(item.directionText)
                                                .font(.system(size: 11))
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                                .frame(width: 130, alignment: .leading)

                                            // 動作 / 狀態
                                            HStack(spacing: 4) {
                                                chipForOp(item.op, status: item.status)
                                            }
                                            .frame(width: 75, alignment: .leading)

                                            // 大小
                                            Text(item.sizeText)
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundStyle(.secondary)
                                                .frame(width: 70, alignment: .trailing)

                                            // 速度
                                            Text(item.speedText)
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundStyle(item.speedBytesPerSec > 0 ? Color.accentColor : Color.secondary)
                                                .frame(width: 80, alignment: .trailing)

                                            // 耗時
                                            Text(item.durationText)
                                                .font(.system(size: 11, design: .monospaced))
                                                .foregroundStyle(.secondary)
                                                .frame(width: 60, alignment: .trailing)

                                            // 檔案路徑
                                            Text(item.path)
                                                .font(.system(size: 11, design: .monospaced))
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                                .foregroundStyle(.secondary)
                                                .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(index % 2 == 1 ? Color.primary.opacity(0.015) : Color.clear)
                                        .id(item.id)
                                    }
                                }
                            }
                            .frame(minHeight: 280, maxHeight: 480)
                            .onChange(of: filteredLogs.first?.id) { newestId in
                                if autoScroll, let id = newestId {
                                    withAnimation {
                                        proxy.scrollTo(id, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                    .frame(minWidth: 920)
                }
            }
        }
    }

    private func fileIcon(for filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "swift", "kt", "ts", "js", "py", "rs", "go", "c", "cpp", "h", "java", "json", "yaml", "yml", "xml", "html", "css", "md", "txt":
            return "doc.text"
        case "png", "jpg", "jpeg", "gif", "webp", "heic", "svg", "icns":
            return "photo"
        case "mp4", "mov", "mkv", "avi":
            return "film"
        case "mp3", "wav", "m4a", "flac":
            return "waveform"
        case "pdf":
            return "doc.richtext"
        case "zip", "tar", "gz", "7z", "dmg", "pkg":
            return "archivebox"
        case "db", "sqlite", "sqlite3":
            return "cylinder"
        default:
            return "doc"
        }
    }

    private func chipForOp(_ op: String, status: String) -> some View {
        let (label, kind): (String, Chip.Kind) = {
            if status == "failed" {
                return (op.uppercased(), .bad)
            }
            switch op {
            case "copy":
                return (loc("op_copy"), .ok)
            case "move":
                return (loc("op_rename"), .ok)
            case "mkdir":
                return (loc("op_mkdir"), .neutral)
            case "trash":
                return (loc("op_trash"), .warn)
            case "verify":
                return (loc("section_verification"), .neutral)
            default:
                return (op, .neutral)
            }
        }()
        return Chip(text: label, kind: kind)
    }

    private func exportLogs() {
        let savePanel = NSSavePanel()
        let mdType = UTType(filenameExtension: "md") ?? .plainText
        savePanel.allowedContentTypes = [mdType, .plainText, .commaSeparatedText]
        let dateStr = Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")
        savePanel.nameFieldStringValue = "SyncNexus-Activity-\(dateStr).md"
        NSApp.activate(ignoringOtherApps: true)
        if savePanel.runModal() == .OK, let url = savePanel.url {
            let ext = url.pathExtension.lowercased()
            let content: String
            switch ext {
            case "txt", "text":
                content = generateTextExport(filteredLogs)
            case "csv":
                content = generateCSVExport(filteredLogs)
            case "md", "markdown":
                fallthrough
            default:
                content = generateMarkdownExport(filteredLogs)
            }
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func generateMarkdownExport(_ logs: [SyncLogItem]) -> String {
        let groupTitle = selectedGroupFilter == "ALL" ? loc("activity_all_groups") : (model.groups.first { $0.id == selectedGroupFilter }.map(model.groupName) ?? selectedGroupFilter)
        let nowStr = Date().formatted(date: .numeric, time: .standard)
        let totalSize = logs.reduce(Int64(0)) { $0 + $1.size }
        let successCount = logs.filter { $0.status == "done" }.count
        let failedCount = logs.filter { $0.status != "done" }.count

        var md = """
        # SyncNexus 同步動態記錄報告

        > **匯出時間**：`\(nowStr)`  
        > **檢視群組**：`\(groupTitle)`  
        > **總記錄筆數**：\(logs.count) 筆  
        > **傳輸總大小**：\(bytes(totalSize))  
        > **狀態統計**：成功 \(successCount) 筆 / 失敗或例外 \(failedCount) 筆  

        ---

        ## 傳輸活動清單

        | 時間 | 群組 | 傳輸檔名 | 同步方向 | 動作 / 狀態 | 大小 | 傳輸速度 | 耗時 | 相對路徑 |
        | :--- | :--- | :--- | :--- | :--- | ---: | ---: | ---: | :--- |

        """

        for log in logs {
            let timeStr = log.timestamp.formatted(date: .numeric, time: .standard)
            let safeFileName = log.fileName.replacingOccurrences(of: "|", with: "\\|")
            let safeGroup = log.groupName.replacingOccurrences(of: "|", with: "\\|")
            let safeDir = log.directionText.replacingOccurrences(of: "|", with: "\\|")
            let safeOp = "\(log.op) (\(log.status))"
            let safePath = log.path.replacingOccurrences(of: "|", with: "\\|")
            let row = "| \(timeStr) | \(safeGroup) | `\(safeFileName)` | \(safeDir) | \(safeOp) | \(log.sizeText) | \(log.speedText) | \(log.durationText) | `\(safePath)` |\n"
            md.append(row)
        }

        md.append("\n---\n*本報告由 SyncNexus 自動匯出產出*\n")
        return md
    }

    private func generateTextExport(_ logs: [SyncLogItem]) -> String {
        let groupTitle = selectedGroupFilter == "ALL" ? loc("activity_all_groups") : (model.groups.first { $0.id == selectedGroupFilter }.map(model.groupName) ?? selectedGroupFilter)
        let totalSize = logs.reduce(Int64(0)) { $0 + $1.size }
        let nowStr = Date().formatted(date: .numeric, time: .standard)

        var txt = """
        ========================================================================================================================
        SyncNexus 同步動態日誌報告 (Activity Report)
        ========================================================================================================================
        匯出時間：\(nowStr)
        群組篩選：\(groupTitle)
        記錄筆數：\(logs.count) 筆
        傳輸總量：\(bytes(totalSize))
        ------------------------------------------------------------------------------------------------------------------------
        時間                 群組        檔名                     同步方向          動作     大小      速度        耗時    路徑
        ------------------------------------------------------------------------------------------------------------------------

        """

        for log in logs {
            let timeStr = log.timestamp.formatted(date: .numeric, time: .standard)
            let line = String(format: "%-19@  %-10@  %-22@  %-16@  %-7@  %8@  %10@  %7@  %@\n",
                             timeStr as NSString,
                             log.groupName as NSString,
                             log.fileName as NSString,
                             log.directionText as NSString,
                             log.op as NSString,
                             log.sizeText as NSString,
                             log.speedText as NSString,
                             log.durationText as NSString,
                             log.path as NSString)
            txt.append(line)
        }

        txt.append("========================================================================================================================\n")
        return txt
    }

    private func generateCSVExport(_ logs: [SyncLogItem]) -> String {
        var csv = "Time,Group,FileName,Direction,Action,Size(Bytes),SizeFormatted,Speed(Bytes/s),SpeedFormatted,Duration(s),DurationFormatted,Path,Status,Error\n"
        for log in logs {
            let timeStr = log.timestamp.formatted(date: .numeric, time: .standard)
            let row = "\"\(timeStr)\",\"\(log.groupName)\",\"\(log.fileName)\",\"\(log.directionText)\",\"\(log.op)\",\(log.size),\"\(log.sizeText)\",\(Int(log.speedBytesPerSec)),\"\(log.speedText)\",\(log.duration),\"\(log.durationText)\",\"\(log.path)\",\"\(log.status)\",\"\(log.error ?? "")\"\n"
            csv.append(row)
        }
        return csv
    }
}

// MARK: conflicts

struct ConflictsSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State private var filterMultiEndpointOnly: Bool = false

    var body: some View {
        sectionHeader(loc("section_conflicts"), model.snap.conflicts.isEmpty ? nil : loc("conflicts_section_desc"))

        if model.groups.count > 1 {
            HStack(spacing: 8) {
                Text(loc("group_selector_title") + ":")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(model.groups, id: \.id) { (group: SyncGroup) in
                            let isActive: Bool = (group.id == model.activeGroupId)
                            let badge = model.groupStatusBadge(for: group.id)
                            Button(action: { model.selectGroup(id: group.id) }) {
                                HStack(spacing: 5) {
                                    Image(systemName: group.icon).font(.system(size: 11))
                                    Text(model.groupName(group)).font(.system(size: 12, weight: isActive ? .bold : .regular))
                                    Text(badge.text)
                                        .font(.system(size: 9, weight: .semibold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1.5)
                                        .background(
                                            isActive ? Color.white.opacity(0.3) :
                                                (badge.kind == .bad ? Theme.badFill : (badge.kind == .warn ? Theme.warnFill : Theme.okFill)),
                                            in: Capsule()
                                        )
                                        .foregroundStyle(
                                            isActive ? Color.white :
                                                (badge.kind == .bad ? Theme.bad : (badge.kind == .warn ? Theme.warn : Theme.ok))
                                        )
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(isActive ? Theme.accent : Theme.tile, in: RoundedRectangle(cornerRadius: 6))
                                .foregroundStyle(isActive ? Color.white : Color.primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }

        if model.snap.conflicts.isEmpty {
            if let otherGroup = model.groups.first(where: { !(model.snapshots[$0.id]?.conflicts.isEmpty ?? true) }) {
                Card(padding: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 24)).foregroundStyle(Theme.warn)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(loc("conflicts_in_other_group_title", model.groupName(otherGroup)))
                                .font(.system(size: 14, weight: .bold))
                            Text(loc("conflicts_in_other_group_desc"))
                                .font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(loc("conflicts_switch_to_group_action", model.groupName(otherGroup))) {
                            model.selectGroup(id: otherGroup.id)
                        }
                        .buttonStyle(QuietButton(kind: .primary, compact: true))
                    }
                }
            }
            Card(padding: 28) {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle").font(.system(size: 34)).foregroundStyle(Theme.ok)
                    Text(loc("conflicts_empty_title")).font(.system(size: 16, weight: .semibold))
                    Text(loc("conflicts_empty_desc")).font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        } else {
            // 全域一鍵批次處理工具卡片
            if model.snap.conflicts.count > 1 {
                Card(padding: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "bolt.shield.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Theme.accent)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    Text(loc("conflicts_batch_title"))
                                        .font(.system(size: 15, weight: .bold))
                                    Chip(text: loc("badge_recommended"), kind: .ok)
                                }
                                Text(loc("conflicts_batch_desc", model.snap.conflicts.count))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }

                        HStack(spacing: 10) {
                            Button {
                                model.resolveAllNewer()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                    Text(loc("conflicts_batch_all_newer"))
                                }
                            }
                            .buttonStyle(QuietButton(kind: .primary))
                            .disabled(!model.resolvingConflictIds.isEmpty)

                            Button {
                                model.resolveAllCurrent()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.fill")
                                    Text(loc("conflicts_batch_all_current"))
                                }
                            }
                            .buttonStyle(QuietButton(kind: .secondary))
                            .disabled(!model.resolvingConflictIds.isEmpty)

                            Button {
                                model.resolveAllEndpoint()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "externaldrive.fill")
                                    Text(loc("conflicts_batch_all_endpoint"))
                                }
                            }
                            .buttonStyle(QuietButton(kind: .secondary))
                            .disabled(!model.resolvingConflictIds.isEmpty)
                        }

                        // 快速篩選標籤：如果有同名多端點衝突
                        let multiEndpointCount = Set(
                            Dictionary(grouping: model.snap.conflicts, by: { $0.path })
                                .filter { $0.value.count > 1 }
                                .values.flatMap { $0.map(\.id) }
                        ).count

                        if multiEndpointCount > 0 {
                            Divider().padding(.vertical, 2)
                            HStack(spacing: 8) {
                                Button {
                                    filterMultiEndpointOnly = false
                                } label: {
                                    Text(loc("conflicts_filter_all", model.snap.conflicts.count))
                                        .font(.system(size: 12, weight: !filterMultiEndpointOnly ? .semibold : .regular))
                                }
                                .buttonStyle(QuietButton(kind: !filterMultiEndpointOnly ? .primary : .plain, compact: true))

                                Button {
                                    filterMultiEndpointOnly = true
                                } label: {
                                    Text(loc("conflicts_filter_multi_endpoint", multiEndpointCount))
                                        .font(.system(size: 12, weight: filterMultiEndpointOnly ? .semibold : .regular))
                                }
                                .buttonStyle(QuietButton(kind: filterMultiEndpointOnly ? .primary : .plain, compact: true))
                            }
                        }
                    }
                }
            }

            let displayedConflicts: [SyncService.ConflictItem] = {
                if filterMultiEndpointOnly {
                    let grouped = Dictionary(grouping: model.snap.conflicts, by: { $0.path })
                    return model.snap.conflicts.filter { (grouped[$0.path]?.count ?? 0) > 1 }
                }
                return model.snap.conflicts
            }()

            ForEach(displayedConflicts) { c in
                ConflictCard(model: model, c: c)
            }
        }

        if !model.snap.duplicateHints.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(loc("conflicts_duplicate_hints_title")).font(.system(size: 16, weight: .bold))
                Text(loc("conflicts_duplicate_hints_desc"))
                    .font(.system(size: 13)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                Card(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(model.snap.duplicateHints.prefix(30).enumerated()), id: \.element.id) { i, h in
                            if i > 0 { Divider() }
                            HStack {
                                Image(systemName: "doc.on.doc").foregroundStyle(.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text((h.path as NSString).lastPathComponent).font(.system(size: 14, weight: .semibold))
                                    Text(loc("conflicts_duplicate_differs_from", (h.basePath as NSString).lastPathComponent, DisplayNames.endpoint(h.endpoint))).font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(loc("btn_reveal_in_finder")) { model.revealInEndpoint(h.endpoint, h.path) }.buttonStyle(QuietButton(kind: .plain))
                            }
                            .padding(.horizontal, 16).padding(.vertical, 10)
                        }
                    }
                }
            }
        }
    }
}

struct ConflictCard: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    let c: SyncService.ConflictItem
    private func date(_ d: Date?) -> String { d?.formatted(date: .abbreviated, time: .shortened) ?? "—" }
    private var extraNewer: Bool { (c.extraModified ?? .distantPast) > (c.mainModified ?? .distantPast) }
    private var isResolving: Bool { model.resolvingConflictIds.contains(c.id) }

    private var samePathConflicts: [SyncService.ConflictItem] {
        model.snap.conflicts.filter { $0.path == c.path }
    }

    private var fileExtension: String {
        (c.path as NSString).pathExtension.lowercased()
    }

    private var sameExtConflicts: [SyncService.ConflictItem] {
        guard !fileExtension.isEmpty else { return [] }
        return model.snap.conflicts.filter { ($0.path as NSString).pathExtension.lowercased() == fileExtension }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text((c.path as NSString).lastPathComponent).font(.system(size: 22, weight: .bold)).tracking(-0.3)
                Text(loc("conflicts_happened_on", c.path, DisplayNames.endpoint(c.endpoint))).font(.system(size: 13)).foregroundStyle(.secondary)
            }

            // 同檔案多端點衝突提示橫幅與一鍵解決
            if samePathConflicts.count > 1 {
                HStack(spacing: 10) {
                    Image(systemName: "square.3.layers.3d.down.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.accent)
                    Text(loc("conflicts_batch_same_file_banner", samePathConflicts.count))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.accent)
                    Spacer()
                    Button {
                        model.resolveAllSamePathNewer(path: c.path)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                            Text(loc("conflicts_batch_apply_same_file_newer", samePathConflicts.count))
                        }
                    }
                    .buttonStyle(QuietButton(kind: .primary, compact: true))
                    .disabled(isResolving)

                    Button {
                        model.resolveAllSamePath(path: c.path, keep: .main)
                    } label: {
                        Text(loc("conflicts_batch_apply_same_file_main", samePathConflicts.count))
                    }
                    .buttonStyle(QuietButton(kind: .secondary, compact: true))
                    .disabled(isResolving)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
            }

            HStack(alignment: .top, spacing: 16) {
                version(title: loc("conflicts_current_version"), note: loc("conflicts_consistent_note"), size: c.mainSize, modified: c.mainModified, newer: !extraNewer,
                        path: c.mainPath, keep: loc("conflicts_keep_this"), primary: true, choice: .main) { model.resolve(c, keep: .main) }
                version(title: loc("conflicts_version_on_endpoint", DisplayNames.endpoint(c.endpoint)), note: loc("conflicts_local_only_note"), size: c.extraSize, modified: c.extraModified, newer: extraNewer,
                        path: c.extraPath, keep: loc("conflicts_use_this"), primary: false, choice: .conflict) { model.resolve(c, keep: .conflict) }
            }
            if isResolving {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text(loc("conflicts_sync_in_progress_queued"))
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.accent)
                }
                .padding(.vertical, 2)
            }
            if !c.endpointOnline {
                Label(loc("conflicts_endpoint_offline", DisplayNames.endpoint(c.endpoint)), systemImage: "externaldrive.badge.xmark").font(.system(size: 13)).foregroundStyle(Theme.warn)
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.line, lineWidth: 1))
        .opacity(isResolving ? 0.75 : 1.0)
    }

    private func version(title: String, note: String, size: Int64?, modified: Date?, newer: Bool, path: String,
                         keep: String, primary: Bool, choice: ConflictChoice, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(title).font(.system(size: 14, weight: .bold))
                if newer { Chip(text: loc("conflicts_newer_badge"), kind: .ok) }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("\(size.map(bytes) ?? "—")　· \(date(modified))").font(.system(size: 13)).monospacedDigit()
                Text(note).font(.system(size: 12)).foregroundStyle(.secondary)
            }
            HStack {
                Button(action: action) {
                    HStack(spacing: 6) {
                        if isResolving {
                            ProgressView().controlSize(.mini)
                        }
                        Text(keep)
                    }
                }
                .buttonStyle(QuietButton(kind: primary ? .primary : .secondary))
                .disabled(!c.endpointOnline || isResolving)

                // 針對同副檔名的批次套用快速選單 (如果有多個同副檔名衝突)
                if sameExtConflicts.count > 1 {
                    Menu {
                        Button {
                            model.resolveAllSameExtension(ext: fileExtension, keep: choice)
                        } label: {
                            Text(loc("conflicts_batch_apply_same_ext", fileExtension, sameExtConflicts.count))
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 13))
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 24, height: 24)
                    .disabled(isResolving)
                    .help(loc("conflicts_batch_apply_same_ext", fileExtension, sameExtConflicts.count))
                }

                Button(loc("btn_reveal_in_finder")) { model.reveal(path) }
                    .buttonStyle(QuietButton(kind: .plain))
                    .disabled(isResolving)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.tile, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: versions

struct VersionsSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @State private var query = ""
    @State private var confirmClear = false

    private var filtered: [VersionItem] {
        let q = query.trimmingCharacters(in: .whitespaces)
        return q.isEmpty ? model.versionItems : model.versionItems.filter { $0.path.localizedCaseInsensitiveContains(q) || $0.endpoint.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        sectionHeader(loc("section_versions"), loc("versions_header_desc"))
        let u = model.snap.versions
        HStack(spacing: 14) {
            StatTile(label: loc("versions_stat_retained"), value: "\(u.files)", sub: loc("versions_stat_files_sub"))
            StatTile(label: loc("versions_stat_storage"), value: bytes(u.bytes), sub: u.oldest.map { loc("versions_stat_oldest_from", $0.formatted(date: .abbreviated, time: .omitted)) } ?? loc("versions_stat_none"))
        }
        Card {
            HStack(spacing: 14) {
                Text(loc("versions_auto_clean_label")).font(.system(size: 14))
                Picker("", selection: Binding(get: { model.snap.versionsRetentionDays }, set: { model.setRetention(days: $0) })) {
                    Text(loc("days_count", 7)).tag(7)
                    Text(loc("days_count", 30)).tag(30)
                    Text(loc("days_count", 90)).tag(90)
                    Text(loc("permanent")).tag(0)
                }
                .labelsHidden().frame(width: 100)
                Text(loc("versions_auto_clean_desc")).font(.system(size: 12)).foregroundStyle(.secondary)
                Spacer()
                Button(loc("versions_btn_clean_expired")) { model.purgeVersions(.expired); model.loadVersions() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                Button(loc("versions_btn_clear_all")) { confirmClear = true }.buttonStyle(QuietButton(kind: .secondary, compact: true)).disabled(u.files == 0)
            }
        }
        if model.snap.endpoints.contains(where: { $0.role == .archive }) {
            Card {
                HStack(spacing: 14) {
                    Text(loc("archive_retention_label")).font(.system(size: 14))
                    Picker("", selection: Binding(get: { model.snap.archiveRetentionDays }, set: { model.setArchiveRetention(days: $0) })) {
                        Text(loc("days_count", 90)).tag(90)
                        Text(loc("years_count", 1)).tag(365)
                        Text(loc("years_count", 3)).tag(1095)
                        Text(loc("permanent")).tag(0)
                    }
                    .labelsHidden().frame(width: 100)
                    Text(loc("archive_retention_desc")).font(.system(size: 12)).foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        HStack {
            Text(loc("versions_restorable_title")).font(.system(size: 16, weight: .bold))
            Spacer()
            TextField(loc("versions_search_placeholder"), text: $query).textFieldStyle(.roundedBorder).frame(width: 220)
            Button(loc("btn_reveal_in_finder")) { model.revealVersionsFolder() }.buttonStyle(QuietButton(kind: .plain))
        }
        if filtered.isEmpty {
            Card(padding: 24) { Text(model.versionItems.isEmpty ? loc("versions_empty") : loc("versions_no_matches")).font(.system(size: 13)).foregroundStyle(.secondary).frame(maxWidth: .infinity) }
        } else {
            Card(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(filtered.prefix(100).enumerated()), id: \.element.id) { i, item in
                        if i > 0 { Divider() }
                        HStack(spacing: 12) {
                            Image(systemName: "doc").frame(width: 24).foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text((item.path as NSString).lastPathComponent).font(.system(size: 14, weight: .semibold)).lineLimit(1)
                                Text("\(DisplayNames.endpoint(item.endpoint))　· \(item.path)").font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1).truncationMode(.middle)
                            }
                            Spacer()
                            Text("\(bytes(item.size))　\(item.stamp.formatted(date: .abbreviated, time: .shortened))").font(.system(size: 12)).foregroundStyle(.secondary).monospacedDigit()
                            Button(loc("versions_btn_restore")) { model.restore(item) }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }
                }
            }
            if filtered.count > 100 { Text(loc("versions_showing_100_hint")).font(.system(size: 12)).foregroundStyle(.secondary) }
        }
        Color.clear.frame(height: 0)
            .onAppear { model.loadVersions(); model.refreshVersions() }
            .alert(loc("versions_alert_clear_title"), isPresented: $confirmClear) {
                Button(loc("versions_alert_clear_confirm"), role: .destructive) { model.purgeVersions(.all); model.loadVersions() }
                Button(loc("cancel"), role: .cancel) {}
            } message: { Text(loc("versions_alert_clear_message")) }
    }
}

// MARK: verification

struct VerificationSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    var body: some View {
        sectionHeader(loc("section_verification"), loc("verification_header_desc"))
        HStack(spacing: 14) {
            StatTile(label: loc("verification_stat_clean_sync"), value: model.snap.lastCleanSync?.formatted(date: .omitted, time: .shortened) ?? loc("never"), sub: model.snap.lastCleanSync?.formatted(date: .abbreviated, time: .omitted) ?? loc("verification_stat_clean_sub_none"))
            StatTile(label: loc("stat_last_deep_verify"), value: model.snap.lastDeepVerify?.formatted(date: .omitted, time: .shortened) ?? loc("never"), sub: model.snap.lastDeepVerify?.formatted(date: .abbreviated, time: .omitted) ?? loc("verification_stat_verify_sub"))
            StatTile(label: loc("verification_stat_issues"), value: "\(model.snap.integrityIssues.count)", sub: model.snap.integrityIssues.isEmpty ? loc("no_anomalies") : loc("verification_stat_quarantined"))
        }
        if !model.snap.integrityIssues.isEmpty {
            Card {
                VStack(alignment: .leading, spacing: 8) {
                    Label(loc("verification_issue_title"), systemImage: "exclamationmark.triangle").font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.warn)
                    ForEach(model.snap.integrityIssues) { issue in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(loc("verification_issue_location", issue.path, DisplayNames.endpoint(issue.endpoint))).font(.system(size: 13, weight: .semibold)).textSelection(.enabled)
                            HStack {
                                Button(loc("verification_btn_repair_others")) { model.repair(issue, action: .restoreFromOthers) }.buttonStyle(QuietButton(kind: .primary, compact: true))
                                Button(loc("verification_btn_accept_current")) { model.repair(issue, action: .acceptCurrent) }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                            }
                        }
                        .padding(12).frame(maxWidth: .infinity, alignment: .leading).background(Theme.tile, in: RoundedRectangle(cornerRadius: 10))
                    }
                    Text(loc("verification_issue_desc")).font(.system(size: 12)).foregroundStyle(.secondary)
                }
            }
        }
        Card {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(loc("verification_verify_now_title")).font(.system(size: 14, weight: .bold))
                    Text(loc("verification_verify_now_desc")).font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                Button(loc("verification_btn_start")) { model.verifyNow() }.buttonStyle(QuietButton(kind: .primary))
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Text(loc("verification_safeguards_title")).font(.system(size: 14, weight: .bold))
                ForEach([loc("safeguard_1"), loc("safeguard_2"), loc("safeguard_3"), loc("safeguard_4")], id: \.self) { t in
                    Label { Text(t).font(.system(size: 13)) } icon: { Image(systemName: "checkmark").foregroundStyle(Theme.ok) }
                }
            }
        }
    }
}

// MARK: settings

struct SettingsSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.openWindow) private var openWindow
    @State private var fullDisk = Permissions.hasFullDiskAccess()
    @State private var showingAddGroup = false
    @State private var editingGroup: SyncGroup? = nil
    @State private var showingExcludeGuide = false

    var body: some View {
        sectionHeader(loc("section_settings"))
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(loc("group_selector_title")).font(.system(size: 15, weight: .bold))
                    Spacer()
                    Button(action: { showingAddGroup = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text(loc("group_add_button"))
                        }
                        .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(QuietButton(kind: .secondary, compact: true))
                    .disabled(model.isRestoringBackup)
                }

                ForEach(model.groups) { group in
                    let isActive = group.id == model.activeGroupId
                    let epCount = model.endpointCount(for: group.id)
                    HStack(spacing: 10) {
                        Image(systemName: group.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(model.groupName(group))
                                    .font(.system(size: 13, weight: isActive ? .bold : .medium))
                                if isActive {
                                    Chip(text: loc("active_current"), kind: .ok)
                                }
                            }
                            Text(loc("group_endpoints_count", epCount))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if !isActive {
                            Button(loc("switch_to_group")) {
                                model.selectGroup(id: group.id)
                            }
                            .buttonStyle(QuietButton(kind: .secondary, compact: true))
                            .disabled(model.isRestoringBackup)
                            .help(loc("switch_to_group_help"))
                        }
                        Button(loc("group_edit_title")) {
                            editingGroup = group
                        }
                        .buttonStyle(QuietButton(kind: .secondary, compact: true))
                        .disabled(model.isRestoringBackup)
                        Button(action: { model.confirmAndDeleteGroup(group) }) {
                            HStack(spacing: 2) {
                                Image(systemName: "trash")
                                Text(loc("group_delete_button"))
                            }
                            .font(.system(size: 11))
                            .foregroundStyle(model.groups.count > 1 ? Theme.bad : Color.secondary)
                        }
                        .buttonStyle(QuietButton(kind: .plain, compact: true))
                        .disabled(model.isRestoringBackup || model.groups.count <= 1)
                        .help(model.groups.count <= 1 ? loc("group_cannot_delete_last") : loc("group_delete_button"))
                    }
                    .padding(.vertical, 4)
                    if group.id != model.groups.last?.id {
                        Divider()
                    }
                }
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(loc("settings_conflict_title")).font(.system(size: 15, weight: .bold))
                Picker("", selection: Binding(get: { model.snap.conflictPolicy }, set: { model.setPolicy($0) })) {
                    Text(loc("settings_conflict_keep_both")).tag(ConflictPolicy.keepBoth)
                    Text(loc("settings_conflict_newer_wins")).tag(ConflictPolicy.newerWins)
                }
                .pickerStyle(.radioGroup).labelsHidden()
                Text(model.snap.conflictPolicy == .keepBoth
                     ? loc("settings_conflict_desc_keep_both")
                     : loc("settings_conflict_desc_newer_wins"))
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    Text(loc("settings_exclude_title")).font(.system(size: 15, weight: .bold))
                    Spacer()
                    Button {
                        showingExcludeGuide = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle.fill")
                            Text(loc("settings_exclude_guide_btn"))
                        }
                        .font(.system(size: 12, weight: .medium))
                    }
                    .buttonStyle(QuietButton(kind: .secondary, compact: true))
                    .help(loc("settings_exclude_guide_help"))
                }
                Text(loc("settings_exclude_desc")).font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                ForEach(ExcludePreset.allCases) { p in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(Theme.ok)
                            .frame(width: 18)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.localizedTitle).font(.system(size: 13, weight: .semibold))
                            Text(p.localizedWhy).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                    }
                }
                Text(loc("settings_exclude_footer")).font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(loc("cloud_space_saving_title"), isOn: Binding(
                    get: { model.snap.cloudSpaceSaving },
                    set: { model.setCloudSpaceSaving($0) }
                ))
                .toggleStyle(.switch)
                Text(loc("cloud_space_saving_desc"))
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                Label(loc("cloud_space_saving_safety"), systemImage: "checkmark.shield")
                    .font(.system(size: 12)).foregroundStyle(Theme.ok)
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(loc("settings_auto_exclude_nested"), isOn: Binding(
                    get: { model.autoExcludeNestedGroups },
                    set: { model.setAutoExcludeNestedGroups($0) }
                ))
                .toggleStyle(.switch)
                Text(loc("settings_nested_groups_desc"))
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
        Card {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(loc("settings_language")).font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Picker("", selection: Binding(
                        get: { L10n.shared.currentLanguage },
                        set: { L10n.shared.currentLanguage = $0 }
                    )) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .frame(width: 160)
                }
                Divider()
                Toggle(loc("settings_launch_at_login"), isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) })).toggleStyle(.switch)
                if let n = model.loginNote { Text(n).font(.system(size: 12)).foregroundStyle(Theme.warn) }
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Toggle(loc("folder_icons_title"), isOn: Binding(get: { model.folderIconsEnabled }, set: { model.setFolderIcons($0) })).toggleStyle(.switch)
                    Text(loc("folder_icons_desc")).font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                }
                Divider()
                HStack {
                    Image(systemName: fullDisk ? "checkmark.circle.fill" : "exclamationmark.circle.fill").foregroundStyle(fullDisk ? Theme.ok : Theme.warn)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Permissions.isSandboxed ? loc("permissions_sandbox_title") : loc("permissions_full_disk_title")).font(.system(size: 14, weight: .semibold))
                        Text(Permissions.isSandboxed ? loc("permissions_sandbox_desc") : (fullDisk ? loc("permissions_authorized") : loc("permissions_unauthorized_desc"))).font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !fullDisk {
                        Button(loc("permissions_btn_open_settings")) { Permissions.openFullDiskAccessSettings() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                        Button(loc("permissions_btn_relaunch")) { Permissions.relaunch() }.buttonStyle(QuietButton(kind: .secondary, compact: true))
                    }
                }
            }
        }
        Card {
            HStack(spacing: 18) {
                Button(loc("settings_btn_open_log")) { model.openLog() }.buttonStyle(QuietButton(kind: .plain))
                Button(loc("settings_btn_instructions")) { openWindow(id: "welcome"); NSApp.activate(ignoringOtherApps: true) }.buttonStyle(QuietButton(kind: .plain))
                Spacer()
                Text("Sync-Nexus　© B&B Co.　Apache-2.0").font(.system(size: 12)).foregroundStyle(.secondary)
            }
        }
        Color.clear.frame(height: 0)
            .onAppear { fullDisk = Permissions.hasFullDiskAccess() }
            .sheet(isPresented: $showingAddGroup) {
                AddGroupSheet(model: model) { showingAddGroup = false }
            }
            .sheet(item: $editingGroup) { group in
                EditGroupSheet(model: model, group: group) { editingGroup = nil }
            }
            .sheet(isPresented: $showingExcludeGuide) {
                InAppDocumentView(type: .excludeGuide)
            }
    }
}

struct DiffPreviewSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared

    var body: some View {
        sectionHeader(loc("diff_preview_title"), loc("diff_preview_desc"))

        Card {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Button(model.isRunningTrialRun ? loc("btn_running_trial") : loc("btn_run_trial")) {
                        model.runTrialRun()
                    }
                    .buttonStyle(QuietButton(kind: .primary))
                    .disabled(model.isRunningTrialRun || model.snap.endpoints.count < 2)

                    Button(loc("settings_apfs_snapshot")) {
                        model.createAPFSSnapshot()
                    }
                    .buttonStyle(QuietButton(kind: .secondary))

                    Spacer()

                    if let _ = model.trialRunReport {
                        Text("\(Date().formatted(date: .omitted, time: .standard))")
                            .font(.system(size: 12)).foregroundStyle(.secondary)
                    }
                }

                if let report = model.trialRunReport {
                    Divider()
                    if report.preview.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.ok)
                            Text(loc("diff_no_changes")).font(.system(size: 14))
                        }
                        .padding(.vertical, 8)
                    } else {
                        let total = report.previewTotalCount > 0 ? report.previewTotalCount : report.preview.count
                        Text(loc("diff_items_count", total))
                            .font(.system(size: 14, weight: .semibold))

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(report.preview.prefix(100).enumerated()), id: \.offset) { _, line in
                                HStack(alignment: .top, spacing: 8) {
                                    diffIcon(for: line)
                                    Text(CoreMessages.localize(line)).font(.system(size: 13, design: .monospaced))
                                }
                            }
                            if total > 100 {
                                Text(loc("model_and_more_items", total - 100))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))

                        HStack {
                            Spacer()
                            Button(loc("status_ok")) {
                                model.syncNow()
                            }
                            .buttonStyle(QuietButton(kind: .primary))
                        }
                    }
                }
            }
        }

        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "wifi").foregroundStyle(Color.accentColor)
                    Text(loc("p2p_section_title")).font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Text(model.nearbyPeers.isEmpty ? loc("p2p_searching") : loc("p2p_found", model.nearbyPeers.count))
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                }

                if model.nearbyPeers.isEmpty {
                    Text(loc("p2p_empty_hint"))
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                } else {
                    ForEach(model.nearbyPeers) { peer in
                        HStack(spacing: 10) {
                            Image(systemName: "laptopcomputer.and.iphone").font(.system(size: 16))
                            VStack(alignment: .leading) {
                                Text(peer.name).font(.system(size: 13, weight: .medium))
                                Text("P2P Direct").font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Chip(text: loc("online"), kind: .ok)
                        }
                        .padding(8)
                        .background(Theme.tile, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func diffIcon(for line: String) -> some View {
        if line.contains("刪除") || line.contains("垃圾桶") || line.contains("Trash") || line.contains("delete") {
            Image(systemName: "minus.circle.fill").foregroundStyle(Theme.bad)
        } else if line.contains("重新命名") || line.contains("rename") || line.contains("move") {
            Image(systemName: "arrow.right.circle.fill").foregroundStyle(Color.accentColor)
        } else if line.contains("衝突") || line.contains("conflict") {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Theme.warn)
        } else {
            Image(systemName: "plus.circle.fill").foregroundStyle(Theme.ok)
        }
    }
}
