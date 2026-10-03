import AppKit
import ServiceManagement
import Combine
import SwiftUI
import SyncCore
import UserNotifications

enum MainSection: String, CaseIterable, Identifiable {
    case overview, diffPreview, folders, conflicts, versions, verification, settings
    var id: String { rawValue }
    var title: String {
        switch self {
        case .overview: loc("section_overview")
        case .diffPreview: loc("section_diff_preview")
        case .folders: loc("section_folders")
        case .conflicts: loc("section_conflicts")
        case .versions: loc("section_versions")
        case .verification: loc("section_verification")
        case .settings: loc("section_settings")
        }
    }
    var symbol: String {
        switch self {
        case .overview: "house"
        case .diffPreview: "arrow.left.arrow.right"
        case .folders: "folder"
        case .conflicts: "exclamationmark.triangle"
        case .versions: "clock.arrow.circlepath"
        case .verification: "checkmark.shield"
        case .settings: "gearshape"
        }
    }
}

/// The one-line truth shown at the top of the popover and the overview.
enum Overall { case starting, ok, partial, attention, syncing, paused }

@MainActor
final class AppModel: ObservableObject {
    /// What the views show: SyncCore's messages translated into the selected language. `snapshots` keeps the raw ones for logic.
    @Published var snap = SyncService.Snapshot.initial
    private var languageObserver: AnyCancellable?
    @Published var launchAtLogin = false
    @Published var loginNote: String?
    @Published var section: MainSection = .overview
    @Published var versionItems: [VersionItem] = []
    @Published var trialRunReport: SyncReport?
    @Published var isRunningTrialRun = false

    public let registry: SyncGroupRegistry
    @Published var groups: [SyncGroup] = []
    @Published var activeGroupId: String = "default"

    private var services: [String: SyncService] = [:]
    private var snapshots: [String: SyncService.Snapshot] = [:]

    var activeGroup: SyncGroup? {
        groups.first { $0.id == activeGroupId }
    }

    var service: SyncService {
        if let s = services[activeGroupId] { return s }
        if let first = services.values.first { return first }
        fatalError("No sync service available")
    }

    private var lastNotifiedConfirmation: String?
    private var lastNotifiedConflicts = 0

    static let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("SyncNexus")
    static let logURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Logs/SyncNexus/syncnexus.log")

    @Published var nearbyPeers: [LocalPeer] = []

    init() {
        registry = SyncGroupRegistry(baseAppSupportURL: Self.appSupport)
        groups = registry.allGroups()
        languageObserver = L10n.shared.$currentLanguage.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] _ in
            guard let self else { return }
            self.snap = Self.localized(self.snapshots[self.activeGroupId] ?? .initial)
        }
        let initialGroup = groups.first?.id ?? "default"
        activeGroupId = initialGroup

        for group in groups {
            startService(for: group)
        }

        if let i = CommandLine.arguments.firstIndex(of: "--section"), i + 1 < CommandLine.arguments.count,
           let sec = MainSection(rawValue: CommandLine.arguments[i + 1]) { section = sec }     // debugging aid

        refreshLoginState()
        setupLoginItemOnce()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        // After sleep the event stream can have gaps: re-check everything on wake.
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                for s in self.services.values { s.syncNow() }
            }
        }

        // 啟動局域網點對點設備發現
        LocalPeerDiscovery.shared.onPeersChanged = { [weak self] peers in
            Task { @MainActor in self?.nearbyPeers = peers }
        }
        LocalPeerDiscovery.shared.start()
    }

    private func startService(for group: SyncGroup) {
        let dbPath = registry.dbPath(for: group.id)
        let versionsDir = registry.versionsURL(for: group.id)
        let logURL = registry.logURL(for: group.id)
        let gid = group.id

        let svc = SyncService(dbPath: dbPath, versionsDir: versionsDir, logURL: logURL) { [weak self] snapshot in
            Task { @MainActor in self?.apply(groupId: gid, snapshot: snapshot) }
        }
        services[gid] = svc
        svc.start()
    }

    // MARK: state

    static func localized(_ s: SyncService.Snapshot) -> SyncService.Snapshot {
        var o = s
        o.error = s.error.map(CoreMessages.localize)
        o.skipped = s.skipped.map(CoreMessages.localize)
        if let c = s.confirmation { o.confirmation?.reason = CoreMessages.localize(c.reason); o.confirmation?.preview = c.preview.map(CoreMessages.localize) }
        o.endpoints = s.endpoints.map { var e = $0; e.detail = CoreMessages.localize($0.detail); return e }
        return o
    }

    /// The untranslated detail SyncCore reported for an endpoint (for logic that looks for keywords).
    func rawDetail(_ endpointId: String) -> String {
        snapshots[activeGroupId]?.endpoints.first { $0.id == endpointId }?.detail ?? ""
    }

    private func apply(groupId: String, snapshot s: SyncService.Snapshot) {
        snapshots[groupId] = s
        objectWillChange.send()   // the menu bar shows every group, not only the active one
        if groupId == activeGroupId {
            snap = Self.localized(s)
            if let c = s.confirmation, c.reason != lastNotifiedConfirmation {
                lastNotifiedConfirmation = c.reason
                notify(loc("status_need_confirm"), CoreMessages.localize(c.reason))
            } else if s.confirmation == nil { lastNotifiedConfirmation = nil }
            if s.conflicts.count > lastNotifiedConflicts {
                let n = s.conflicts.count
                notify(loc("status_conflicts_pending", n), loc("conflicts_section_desc"))
            }
            lastNotifiedConflicts = s.conflicts.count
        }
    }

    static func overall(of snap: SyncService.Snapshot) -> Overall {
        if snap.phase == .paused { return .paused }
        if snap.error != nil || snap.confirmation != nil || !snap.conflicts.isEmpty || !snap.integrityIssues.isEmpty { return .attention }
        if snap.phase == .syncing { return .syncing }
        if snap.lastRun == nil { return .starting }
        if snap.endpoints.contains(where: { !$0.online }) { return .partial }
        return .ok
    }

    static func title(of snap: SyncService.Snapshot, _ overall: Overall) -> String {
        switch overall {
        case .starting: return loc("status_starting")
        case .ok: return loc("status_ok")
        case .partial: return loc("status_partial")
        case .attention:
            if snap.error != nil { return loc("status_error") }
            if snap.confirmation != nil { return loc("status_need_confirm") }
            if !snap.conflicts.isEmpty { return loc("status_conflicts_pending", snap.conflicts.count) }
            return loc("status_need_check")
        case .syncing: return loc("status_syncing")
        case .paused: return loc("status_paused")
        }
    }

    static func detail(of snap: SyncService.Snapshot, _ overall: Overall) -> String {
        switch overall {
        case .ok, .partial:
            if let t = snap.lastDeepVerify { return "\(loc("section_verification"))　\(t.formatted(date: .omitted, time: .shortened))" }
            if let t = snap.lastRun { return "\(loc("status_ok"))　\(t.formatted(date: .omitted, time: .shortened))" }
            return ""
        case .attention:
            if let e = snap.error { return e }
            if let c = snap.confirmation { return c.reason }
            if !snap.integrityIssues.isEmpty { return "\(snap.integrityIssues.count) items quarantined" }
            return snap.conflicts.first.map { "\($0.path)" } ?? ""
        case .syncing: return loc("status_detail_syncing")
        case .paused: return loc("status_detail_paused")
        case .starting: return ""
        }
    }

    var overall: Overall { Self.overall(of: snap) }
    var overallTitle: String { Self.title(of: snap, overall) }
    var overallDetail: String { Self.detail(of: snap, overall) }

    // MARK: all groups at a glance (menu bar)

    /// Every group with its own (translated) snapshot and state, in the order of the group bar.
    var groupStates: [(group: SyncGroup, snap: SyncService.Snapshot, overall: Overall)] {
        groups.map { g in
            let raw = snapshots[g.id] ?? .initial
            let local = Self.localized(raw)
            return (g, local, Self.overall(of: raw))
        }
    }

    private static func severity(_ o: Overall) -> Int {
        switch o {
        case .attention: 5
        case .partial: 4
        case .syncing: 3
        case .starting: 2
        case .ok: 1
        case .paused: 0
        }
    }

    /// The group that needs the most attention (the first one when all are fine).
    private var worstGroup: (group: SyncGroup, snap: SyncService.Snapshot, overall: Overall)? {
        let states = groupStates
        return states.max { Self.severity($0.overall) < Self.severity($1.overall) }
    }

    /// One state for the whole app: the worst across groups; paused only when every group is paused.
    var popoverOverall: Overall {
        let states = groupStates
        if !states.isEmpty && states.allSatisfy({ $0.overall == .paused }) { return .paused }
        return worstGroup?.overall ?? overall
    }
    var popoverTitle: String {
        guard let w = worstGroup else { return overallTitle }
        return Self.title(of: w.snap, popoverOverall == .paused ? .paused : w.overall)
    }
    var popoverDetail: String {
        guard let w = worstGroup else { return overallDetail }
        let text = Self.detail(of: w.snap, popoverOverall == .paused ? .paused : w.overall)
        // with several groups, say which one the message is about
        if groups.count > 1, w.overall == .attention, !text.isEmpty { return "\(groupName(w.group))：\(text)" }
        return text
    }

    var allPaused: Bool { !groupStates.isEmpty && groupStates.allSatisfy { $0.overall == .paused } }

    var iconName: String {
        let s = worstGroup?.snap ?? snap
        if s.error != nil || s.confirmation != nil { return "exclamationmark.arrow.triangle.2.circlepath" }
        if s.endpoints.contains(where: { !$0.online }) && s.phase != .syncing { return "arrow.triangle.2.circlepath.circle" }
        if allPaused { return "pause.circle" }
        return "arrow.triangle.2.circlepath"
    }

    var headline: String {
        if let e = snap.error { return loc("model_error_prefix", e) }
        if snap.confirmation != nil { return "⚠︎ " + loc("status_need_confirm") }
        switch snap.phase {
        case .paused: return loc("status_paused")
        case .syncing: return loc("status_syncing")
        case .idle:
            guard let t = snap.lastRun else { return loc("status_starting") }
            let f = RelativeDateTimeFormatter()
            f.locale = Locale(identifier: L10n.shared.currentLanguage.rawValue)
            f.unitsStyle = .short
            return loc("model_synced_relative", f.localizedString(for: t, relativeTo: Date()))
        }
    }

    // MARK: actions

    func syncNow() { service.syncNow() }
    func verifyNow() { service.verifyNow() }
    /// Pausing is app-wide: every group pauses (or resumes) together.
    func togglePause() {
        let all = Array(services.values)
        if allPaused { all.forEach { $0.resume() } } else { all.forEach { $0.pause() } }
    }

    func syncAllNow() { services.values.forEach { $0.syncNow() } }

    func reviewConfirmation(group: String? = nil) {
        if let group { selectGroup(id: group) }   // the confirmation belongs to that group's service
        guard let c = snap.confirmation else { return }
        let alert = NSAlert()
        alert.messageText = c.reason   // already localized (snap)
        let lines = c.preview.prefix(25).joined(separator: "\n")
        alert.informativeText = lines + (c.preview.count > 25 ? loc("model_and_more_items", c.preview.count - 25) : "")
        alert.addButton(withTitle: loc("model_btn_confirm_exec"))
        alert.addButton(withTitle: loc("cancel"))
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn { service.syncNow(confirmed: true) }
    }

    // MARK: sync groups management

    func selectGroup(id: String) {
        guard activeGroupId != id, groups.contains(where: { $0.id == id }) else { return }
        activeGroupId = id
        snap = Self.localized(snapshots[id] ?? .initial)
        lastNotifiedConfirmation = snap.confirmation?.reason
        lastNotifiedConflicts = snap.conflicts.count
        loadVersions()
    }

    func createGroup(name: String, icon: String = "folder") {
        // An unnamed group stores no text; its name is chosen per language when shown.
        let newGroup = registry.addGroup(name: name.trimmingCharacters(in: .whitespaces), icon: icon)
        groups = registry.allGroups()
        startService(for: newGroup)
        selectGroup(id: newGroup.id)
        settingsMessage = loc("group_created_toast", groupName(newGroup))
    }

    func updateGroup(id: String, name: String, icon: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty || groups.first(where: { $0.id == id })?.name.isEmpty == true else { return }
        if registry.updateGroup(id: id, name: trimmed, icon: icon) {
            groups = registry.allGroups()
            settingsMessage = loc("group_updated_toast", trimmed.isEmpty ? (groups.first { $0.id == id }.map(groupName) ?? "") : trimmed)
        }
    }

    func deleteGroup(id: String) {
        guard groups.count > 1 else {
            settingsMessage = loc("group_cannot_delete_last")
            return
        }
        guard let group = registry.group(id: id) else { return }
        services[id]?.stop()
        services.removeValue(forKey: id)
        snapshots.removeValue(forKey: id)

        if id != "default" {
            let groupDir = Self.appSupport.appendingPathComponent("Groups/\(id)")
            try? FileManager.default.removeItem(at: groupDir)
        }

        if registry.removeGroup(id: id) {
            groups = registry.allGroups()
            if activeGroupId == id {
                selectGroup(id: groups.first?.id ?? "default")
            }
            settingsMessage = loc("group_deleted_toast", groupName(group))
        }
    }

    /// Lets the user pick an old (e.g. non-sandboxed) SyncNexus settings folder and merges it in.
    /// Sandbox-safe: access to the folder is granted by the user via the open panel.
    func importLegacySettings() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true; panel.canChooseFiles = false; panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        panel.message = loc("import_legacy_prompt"); panel.prompt = loc("choose")
        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }

        // Release databases before they may be replaced.
        for s in services.values { s.stop() }
        services.removeAll()
        snapshots.removeAll()

        var message: String
        do {
            let r = try registry.importLegacySettings(from: url)
            message = r.imported.isEmpty ? loc("import_legacy_nothing_new")
                                         : loc("import_legacy_ok", r.imported.count, r.endpointCount)
        } catch SyncGroupRegistry.LegacyImportError.nothingFound {
            message = loc("import_legacy_not_found")
        } catch {
            message = loc("import_legacy_failed", "\(error)")
        }

        groups = registry.allGroups()
        for g in groups { startService(for: g) }
        if !groups.contains(where: { $0.id == activeGroupId }) { activeGroupId = groups.first?.id ?? "default" }
        snap = Self.localized(snapshots[activeGroupId] ?? .initial)
        settingsMessage = message
    }

    func restoreBackup(_ backup: SyncGroupRegistry.BackupInfo) {
        let alert = NSAlert()
        alert.messageText = loc("backup_restore_confirm_title", backup.date.formatted(date: .abbreviated, time: .shortened))
        alert.informativeText = loc("backup_restore_confirm_desc")
        alert.addButton(withTitle: loc("backup_restore_button"))
        alert.addButton(withTitle: loc("cancel"))
        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        for s in services.values { s.stop() }
        services.removeAll(); snapshots.removeAll()
        do {
            try registry.restore(backup)
            settingsMessage = loc("backup_restore_ok", backup.groupNames.count, backup.endpointCount)
        } catch {
            settingsMessage = loc("import_legacy_failed", "\(error)")
        }
        groups = registry.allGroups()
        for g in groups { startService(for: g) }
        if !groups.contains(where: { $0.id == activeGroupId }) { activeGroupId = groups.first?.id ?? "default" }
        snap = Self.localized(snapshots[activeGroupId] ?? .initial)
    }

    func confirmAndDeleteGroup(_ group: SyncGroup) {
        let alert = NSAlert()
        alert.messageText = loc("group_delete_confirm_title", groupName(group))
        alert.informativeText = loc("group_delete_confirm_desc")
        alert.addButton(withTitle: loc("group_delete_button"))
        alert.addButton(withTitle: loc("cancel"))
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn { deleteGroup(id: group.id) }
    }

    func groupName(_ g: SyncGroup) -> String { DisplayNames.group(g, among: groups) }

    func endpointCount(for groupId: String) -> Int {
        snapshots[groupId]?.endpoints.count ?? 0
    }

    func openLog() {
        let logURL = registry.logURL(for: activeGroupId)
        try? FileManager.default.createDirectory(at: logURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: logURL.path) { try? Data().write(to: logURL) }
        NSWorkspace.shared.open(logURL)
    }

    func revealVersions() {
        let dir = registry.versionsURL(for: activeGroupId)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        NSWorkspace.shared.open(dir)
    }

    // MARK: endpoint settings

    @Published var settingsMessage: String?

    var existingConfigs: [EndpointConfig] {
        snap.endpoints.map { EndpointConfig(id: $0.id, root: $0.root, removable: $0.removable, portableNames: $0.portableNames) }
    }

    func validate(path: String, name: String, replacing: String? = nil, portable: Bool = false) -> [ValidationIssue] {
        var issues = EndpointValidator.validate(path: path, name: name, replacing: replacing, existing: existingConfigs, portableNames: portable)
            .map { ValidationIssue(isError: $0.isError, message: CoreMessages.localize($0.message)) }
        let resPath = EndpointValidator.resolved(path)
        for (gid, s) in snapshots where gid != activeGroupId {
            if let ep = s.endpoints.first(where: { EndpointValidator.resolved($0.root) == resPath }) {
                let gName = groups.first(where: { $0.id == gid }).map(groupName) ?? gid
                issues.append(ValidationIssue(isError: true, message: loc("folders_used_in_other_group", gName, DisplayNames.endpoint(ep.id))))
            }
        }
        return issues
    }

    func addEndpoint(name: String, path: String, removable: Bool, portable: Bool, archive: Bool = false, bookmarkData: Data? = nil) {
        let cfg = EndpointConfig(id: name.trimmingCharacters(in: .whitespaces), root: path, removable: removable, portableNames: portable, role: archive ? .archive : .mirror, bookmarkData: bookmarkData)
        service.addEndpoint(cfg) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { loc("msg_add_failed", CoreMessages.localize($0)) } ?? loc("msg_endpoint_added", cfg.id) }
        }
    }

    func relink(id: String, to path: String, bookmarkData: Data? = nil) {
        service.relinkEndpoint(id: id, root: path, bookmarkData: bookmarkData) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { loc("msg_relink_failed", CoreMessages.localize($0)) } ?? loc("msg_relinked", id) }
        }
    }

    func remove(id: String) {
        service.removeEndpoint(id: id) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { loc("msg_remove_failed", CoreMessages.localize($0)) } ?? loc("msg_removed", id) }
        }
    }

    // MARK: versions archive

    func purgeVersions(_ mode: SyncService.PurgeMode) {
        service.purgeVersions(mode) { [weak self] files, bytes in
            Task { @MainActor in
                self?.settingsMessage = loc("msg_versions_purged", files, ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file))
            }
        }
    }

    func setRetention(days: Int) {
        service.setVersionsRetention(days: days) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { loc("msg_add_failed", CoreMessages.localize($0)) } ?? loc("msg_retention_updated") }
        }
    }

    func setArchiveRetention(days: Int) {
        service.setArchiveRetention(days: days) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { loc("msg_add_failed", CoreMessages.localize($0)) } ?? loc("msg_archive_retention_updated") }
        }
    }

    func runTrialRun() {
        isRunningTrialRun = true
        service.trialRun { [weak self] report in
            Task { @MainActor in
                self?.isRunningTrialRun = false
                self?.trialRunReport = report
                self?.settingsMessage = report != nil ? loc("msg_trial_run_completed") : loc("msg_trial_run_failed")
            }
        }
    }

    func createAPFSSnapshot() {
        let res = APFSSnapshotManager.shared.createLocalSnapshot()
        if res.isSandbox {
            settingsMessage = loc("msg_apfs_sandbox_active")
        } else if res.success {
            settingsMessage = loc("msg_apfs_success")
        } else {
            settingsMessage = loc("msg_apfs_failed_fallback")
        }
    }

    func repair(_ issue: IntegrityIssue, action: IntegrityAction) {
        service.resolveIntegrity(issue, action: action) { [weak self] err in
            Task { @MainActor in
                self?.settingsMessage = err.map { loc("msg_add_failed", CoreMessages.localize($0)) } ?? (action == .restoreFromOthers ? loc("msg_repaired_from_others") : loc("msg_accepted_current"))
            }
        }
    }

    /// How many cloud files of this folder are still being read in the background (iCloud / Drive placeholders).
    func pendingCloud(_ id: String, group: String? = nil) -> Int { (snapshots[group ?? activeGroupId]?.skipped ?? []).filter { $0.hasPrefix("[\(id)]") && $0.contains("讀取雲端") }.count }

    func setExclude(_ preset: ExcludePreset, on: Bool) {
        var p = snap.excludePresets
        if on { p.insert(preset) } else { p.remove(preset) }
        service.setExcludePresets(p) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { loc("msg_add_failed", CoreMessages.localize($0)) } ?? loc("msg_excludes_updated") }
        }
    }

    func refreshVersions() { service.refreshVersionsUsage() }

    func revealVersionsFolder() { revealVersions() }

    // MARK: conflicts

    func setPolicy(_ p: ConflictPolicy) {
        service.setConflictPolicy(p) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { loc("msg_add_failed", CoreMessages.localize($0)) } ?? loc("msg_conflict_policy_updated") }
        }
    }

    func resolve(_ c: SyncService.ConflictItem, keep: ConflictChoice) {
        service.resolveConflict(id: c.id, keep: keep) { [weak self] err in
            Task { @MainActor in
                self?.settingsMessage = err.map { loc("msg_add_failed", CoreMessages.localize($0)) }
                    ?? (keep == .main ? loc("msg_conflict_kept_main") : loc("msg_conflict_used_extra"))
            }
        }
    }

    func revealInEndpoint(_ endpoint: String, _ rel: String) {
        if let ep = snap.endpoints.first(where: { $0.id == endpoint }) { reveal(ep.root + "/" + rel) }
    }

    func reveal(_ path: String) { NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)]) }

    // MARK: versions

    func loadVersions() {
        service.listVersions { [weak self] items in Task { @MainActor in self?.versionItems = items } }
    }

    func restore(_ item: VersionItem) {
        service.restoreVersion(item) { [weak self] err in
            Task { @MainActor in
                self?.settingsMessage = err.map { loc("msg_restore_failed", CoreMessages.localize($0)) } ?? loc("msg_version_restored", (item.path as NSString).lastPathComponent)
                self?.loadVersions()
            }
        }
    }

    func quit() {
        for s in services.values { s.stop() }
        NSApp.terminate(nil)
    }

    // MARK: launch at login

    func refreshLoginState() {
        let status = SMAppService.mainApp.status
        launchAtLogin = status == .enabled
        loginNote = status == .requiresApproval ? loc("msg_login_approval_required") : nil
    }

    func setLaunchAtLogin(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        } catch {
            loginNote = loc("msg_login_config_failed", error.localizedDescription)
        }
        refreshLoginState()
        if SMAppService.mainApp.status == .requiresApproval { SMAppService.openSystemSettingsLoginItems() }
    }

    /// The user asked for start-at-login, so it is switched on the first time the app runs. The menu toggle turns it off.
    private func setupLoginItemOnce() {
        let key = "didSetupLoginItem"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        if SMAppService.mainApp.status == .notRegistered { setLaunchAtLogin(true) }
    }

    private func notify(_ title: String, _ body: String) {
        let c = UNMutableNotificationContent()
        c.title = title; c.body = body
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: c, trigger: nil))
    }
}
