import AppKit
import SwiftUI
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
        }
    }

    var localizedWhy: String {
        switch self {
        case .nodeModules: return loc("preset_node_modules_why")
        case .buildCaches: return loc("preset_build_caches_why")
        case .git: return loc("preset_git_why")
        case .databases: return loc("preset_databases_why")
        case .photosLibraries: return loc("preset_photos_why")
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
            } else if let live = model.primaryProgress {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        ProgressView().controlSize(.small)
                        Text(model.progressStage(live.progress))
                            .font(.system(size: 13, weight: .semibold))
                        if live.progress.stage == .scanning && live.progress.completed > 0 {
                            Text("（已發現 \(live.progress.completed.formatted()) 項）")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        if model.groups.count > 1 {
                            Text(live.groupName).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Text("\(Int((model.aggregateProgressFraction * 100).rounded()))%")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        Button(loc("progress_cancel")) { model.cancelAllCurrentRuns() }
                            .buttonStyle(QuietButton(kind: .secondary, compact: true))
                            .disabled(model.isCancellingRuns)
                    }
                    ProgressView(value: model.aggregateProgressFraction).progressViewStyle(.linear)
                    if let path = live.progress.currentPath, !path.isEmpty {
                        Text(path).font(.system(size: 11, design: .monospaced)).foregroundStyle(.secondary)
                            .lineLimit(1).truncationMode(.middle)
                    }
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
                Button { model.section = s } label: {
                    HStack(spacing: 10) {
                        Image(systemName: s.symbol).font(.system(size: 15)).frame(width: 20)
                        Text(s.title).font(.system(size: 14, weight: model.section == s ? .semibold : .medium))
                        Spacer(minLength: 0)
                        if s == .conflicts && !model.snap.conflicts.isEmpty {
                            Text("\(model.snap.conflicts.count)").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
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
        sectionHeader(model.overall == .ok ? loc("status_all_normal") : model.overallTitle, overviewSubtitle)

        if model.groups.count > 1 {
            HStack(spacing: 8) {
                Text(loc("group_selector_title") + ":")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(model.groups, id: \.id) { (group: SyncGroup) in
                            let isActive: Bool = (group.id == model.activeGroupId)
                            Button(action: { model.selectGroup(id: group.id) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: group.icon).font(.system(size: 11))
                                    Text(model.groupName(group)).font(.system(size: 12, weight: isActive ? .bold : .regular))
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
        let kind = EndpointValidator.describe(path: ep.root).kind
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
                     : ((ep.removable && !FileManager.default.fileExists(atPath: ep.root)) ? loc("endpoint_unplugged_sub") : ep.detail))
                    .font(.system(size: 13)).foregroundStyle(ep.online ? Color.primary : Theme.warn).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: conflicts

struct ConflictsSection: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    var body: some View {
        sectionHeader(loc("section_conflicts"), model.snap.conflicts.isEmpty ? nil : loc("conflicts_section_desc"))
        if model.snap.conflicts.isEmpty {
            Card(padding: 28) {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle").font(.system(size: 34)).foregroundStyle(Theme.ok)
                    Text(loc("conflicts_empty_title")).font(.system(size: 16, weight: .semibold))
                    Text(loc("conflicts_empty_desc")).font(.system(size: 13)).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        ForEach(model.snap.conflicts) { c in ConflictCard(model: model, c: c) }
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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text((c.path as NSString).lastPathComponent).font(.system(size: 22, weight: .bold)).tracking(-0.3)
                Text(loc("conflicts_happened_on", c.path, DisplayNames.endpoint(c.endpoint))).font(.system(size: 13)).foregroundStyle(.secondary)
            }
            HStack(alignment: .top, spacing: 16) {
                version(title: loc("conflicts_current_version"), note: loc("conflicts_consistent_note"), size: c.mainSize, modified: c.mainModified, newer: !extraNewer,
                        path: c.mainPath, keep: loc("conflicts_keep_this"), primary: true) { model.resolve(c, keep: .main) }
                version(title: loc("conflicts_version_on_endpoint", DisplayNames.endpoint(c.endpoint)), note: loc("conflicts_local_only_note"), size: c.extraSize, modified: c.extraModified, newer: extraNewer,
                        path: c.extraPath, keep: loc("conflicts_use_this"), primary: false) { model.resolve(c, keep: .conflict) }
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
                         keep: String, primary: Bool, action: @escaping () -> Void) -> some View {
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
                Text(loc("settings_exclude_title")).font(.system(size: 15, weight: .bold))
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
