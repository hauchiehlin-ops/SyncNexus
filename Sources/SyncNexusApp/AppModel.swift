import AppKit
import ServiceManagement
import Combine
import SwiftUI
import SyncCore
import UserNotifications
import Darwin

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
    @Published var isQuitting = false
    @Published var isCancellingRuns = false
    @Published var isRestoringBackup = false
    @Published var canCancelBackupRestore = false
    @Published var backupRestoreStatus: String?
    @Published var appOperationStatus: String?
    private var backupRestoreTask: Task<Void, Never>?

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

    // MARK: Finder folder icons

    /// Folder path → symbol of its group, for every online folder of every group whose icon is not the plain folder.
    private func desiredFolderIcons() -> [String: String] {
        var out: [String: String] = [:]
        for g in groups where g.icon != "folder" {
            for ep in snapshots[g.id]?.endpoints ?? [] where ep.online { out[ep.root] = g.icon }
        }
        return out
    }

    func refreshFolderIcons() { FolderIcon.sync(desired: desiredFolderIcons()) }

    var folderIconsEnabled: Bool { FolderIcon.isEnabled }
    func setFolderIcons(_ on: Bool) {
        FolderIcon.isEnabled = on
        objectWillChange.send()
        refreshFolderIcons()
    }

    // MARK: state

    static func localized(_ s: SyncService.Snapshot) -> SyncService.Snapshot {
        var o = s
        o.error = s.error.map(CoreMessages.localize)
        o.skipped = s.skipped.map(CoreMessages.localize)
        if let c = s.confirmation {
            o.confirmation?.reason = CoreMessages.localize(c.reason)
            let previewLimit = min(c.preview.count, 50)
            o.confirmation?.preview = Array(c.preview.prefix(previewLimit).map(CoreMessages.localize))
            o.confirmation?.totalCount = c.totalCount
        }
        o.endpoints = s.endpoints.map { var e = $0; e.detail = CoreMessages.localize($0.detail); return e }
        return o
    }

    /// The untranslated detail SyncCore reported for an endpoint (for logic that looks for keywords).
    func rawDetail(_ endpointId: String) -> String {
        snapshots[activeGroupId]?.endpoints.first { $0.id == endpointId }?.detail ?? ""
    }

    private func apply(groupId: String, snapshot s: SyncService.Snapshot) {
        snapshots[groupId] = s
        if isCancellingRuns && snapshots.values.allSatisfy({ $0.progress == nil }) { isCancellingRuns = false }
        objectWillChange.send()   // the menu bar shows every group, not only the active one
        refreshFolderIcons()      // diff-based: does nothing unless a folder or a group icon changed
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
        if let live = primaryProgress { return progressDetail(live.progress) }
        guard let w = worstGroup else { return overallDetail }
        let text = Self.detail(of: w.snap, popoverOverall == .paused ? .paused : w.overall)
        // with several groups, say which one the message is about
        if groups.count > 1, w.overall == .attention, !text.isEmpty { return "\(groupName(w.group))：\(text)" }
        return text
    }

    var primaryProgress: (groupName: String, progress: SyncProgress)? {
        let active = groups.first { $0.id == activeGroupId }
        if let active, let progress = snapshots[active.id]?.progress {
            return (groupName(active), progress)
        }
        for group in groups {
            if let progress = snapshots[group.id]?.progress { return (groupName(group), progress) }
        }
        return nil
    }

    var activeProgressCount: Int { snapshots.values.filter { $0.progress != nil }.count }

    var aggregateProgressFraction: Double {
        let values = snapshots.values.compactMap { $0.progress?.fraction }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    func progressStage(_ progress: SyncProgress) -> String {
        if isCancellingRuns { return loc("progress_cancelling") }
        return loc("progress_\(progress.stage.rawValue)")
    }

    func progressDetail(_ progress: SyncProgress) -> String {
        let stage = progressStage(progress)
        let percent = Int((progress.fraction * 100).rounded())
        if let path = progress.currentPath, !path.isEmpty {
            return "\(stage) \(percent)% · \(path)"
        }
        return "\(stage) \(percent)%"
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

    func cancelAllCurrentRuns() {
        isCancellingRuns = true
        services.values.forEach { $0.cancelCurrentRun() }
    }

    func reviewConfirmation(group: String? = nil) {
        if let group { selectGroup(id: group) }   // the confirmation belongs to that group's service
        guard let c = snap.confirmation else { return }
        let alert = NSAlert()
        alert.messageText = c.reason   // already localized (snap)
        let lines = c.preview.prefix(25).joined(separator: "\n")
        let total = max(c.totalCount, c.preview.count)
        alert.informativeText = lines + (total > 25 ? loc("model_and_more_items", total - 25) : "")
        alert.addButton(withTitle: loc("model_btn_confirm_exec"))
        alert.addButton(withTitle: loc("cancel"))
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            snap.confirmation = nil
            if let gid = activeGroup?.id {
                snapshots[gid]?.confirmation = nil
            }
            lastNotifiedConfirmation = nil
            objectWillChange.send()
            service.syncNow(confirmed: true)
        }
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
            refreshFolderIcons()   // a new group icon applies to its folders right away
            settingsMessage = loc("group_updated_toast", trimmed.isEmpty ? (groups.first { $0.id == id }.map(groupName) ?? "") : trimmed)
        }
    }

    func deleteGroup(id: String) {
        guard appOperationStatus == nil else { return }
        guard groups.count > 1 else {
            settingsMessage = loc("group_cannot_delete_last")
            return
        }
        guard let group = registry.group(id: id) else { return }
        let stopping = services[id]
        services.removeValue(forKey: id)
        appOperationStatus = loc("operation_stopping_group")

        Task { [weak self] in
            if let stopping { await stopping.stopAndWait() }
            guard let self else { return }
            self.snapshots.removeValue(forKey: id)

            if id != "default" {
                let groupDir = Self.appSupport.appendingPathComponent("Groups/\(id)")
                await withCheckedContinuation { continuation in
                    DispatchQueue.global(qos: .utility).async {
                        try? FileManager.default.removeItem(at: groupDir)
                        continuation.resume()
                    }
                }
            }

            if self.registry.removeGroup(id: id) {
                self.groups = self.registry.allGroups()
                self.refreshFolderIcons()
                if self.activeGroupId == id { self.selectGroup(id: self.groups.first?.id ?? "default") }
                self.settingsMessage = loc("group_deleted_toast", self.groupName(group))
            }
            self.appOperationStatus = nil
        }
    }

    /// Lets the user pick an old (e.g. non-sandboxed) SyncNexus settings folder and merges it in.
    /// Sandbox-safe: access to the folder is granted by the user via the open panel.
    func importLegacySettings() {
        guard appOperationStatus == nil else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true; panel.canChooseFiles = false; panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        panel.message = loc("import_legacy_prompt"); panel.prompt = loc("choose")
        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let scoped = url.startAccessingSecurityScopedResource()
        let stopping = Array(services.values)
        appOperationStatus = loc("operation_stopping_services")

        Task { [weak self] in
            await withTaskGroup(of: Void.self) { group in
                for service in stopping { group.addTask { await service.stopAndWait() } }
            }
            guard let self else {
                if scoped { url.stopAccessingSecurityScopedResource() }
                return
            }
            self.services.removeAll()
            self.snapshots.removeAll()
            self.appOperationStatus = loc("operation_importing_settings")

            let registry = self.registry
            let result: Result<SyncGroupRegistry.LegacyImportResult, Error> = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    continuation.resume(returning: Result { try registry.importLegacySettings(from: url) })
                }
            }
            if scoped { url.stopAccessingSecurityScopedResource() }

            let message: String
            switch result {
            case .success(let imported):
                message = imported.imported.isEmpty ? loc("import_legacy_nothing_new")
                    : loc("import_legacy_ok", imported.imported.count, imported.endpointCount)
            case .failure(SyncGroupRegistry.LegacyImportError.nothingFound):
                message = loc("import_legacy_not_found")
            case .failure(let error):
                message = loc("import_legacy_failed", "\(error)")
            }

            self.groups = registry.allGroups()
            for group in self.groups { self.startService(for: group) }
            if !self.groups.contains(where: { $0.id == self.activeGroupId }) { self.activeGroupId = self.groups.first?.id ?? "default" }
            self.snap = Self.localized(self.snapshots[self.activeGroupId] ?? .initial)
            self.settingsMessage = message
            self.appOperationStatus = nil
        }
    }

    func restoreBackup(_ backup: SyncGroupRegistry.BackupInfo) {
        guard !isRestoringBackup else { return }
        // A SwiftUI Menu is still finishing AppKit event tracking when its action runs. Presenting
        // a modal alert in that same stack can strand the menu and alert event loops together.
        DispatchQueue.main.async { [weak self] in self?.confirmRestoreBackup(backup) }
    }

    private func confirmRestoreBackup(_ backup: SyncGroupRegistry.BackupInfo) {
        guard !isRestoringBackup else { return }
        let alert = NSAlert()
        alert.messageText = loc("backup_restore_confirm_title", backup.date.formatted(date: .abbreviated, time: .shortened))
        alert.informativeText = loc("backup_restore_confirm_desc")
        alert.addButton(withTitle: loc("backup_restore_button"))
        alert.addButton(withTitle: loc("cancel"))
        NSApp.activate(ignoringOtherApps: true)
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        beginBackupRestore(backup)
    }

    private func beginBackupRestore(_ backup: SyncGroupRegistry.BackupInfo) {
        isRestoringBackup = true
        canCancelBackupRestore = true
        backupRestoreStatus = loc("backup_restore_stopping")
        let stopping = Array(services.values)

        backupRestoreTask = Task { [weak self] in
            await withTaskGroup(of: Void.self) { group in
                for service in stopping {
                    group.addTask { await service.stopAndWait() }
                }
            }

            guard let self else { return }
            self.services.removeAll()
            self.snapshots.removeAll()

            guard !Task.isCancelled else {
                self.finishBackupRestore(message: loc("backup_restore_cancelled"))
                return
            }

            self.backupRestoreStatus = loc("backup_restore_applying")
            self.canCancelBackupRestore = false
            let registry = self.registry
            let result: Result<Void, Error> = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    continuation.resume(returning: Result { try registry.restore(backup) })
                }
            }

            let message: String
            switch result {
            case .success:
                message = loc("backup_restore_ok", backup.groupNames.count, backup.endpointCount)
            case .failure(let error):
                message = loc("backup_restore_failed", "\(error)")
            }
            self.finishBackupRestore(message: message)
        }
    }

    func cancelBackupRestore() {
        guard isRestoringBackup else { return }
        backupRestoreStatus = loc("backup_restore_cancelling")
        backupRestoreTask?.cancel()
    }

    private func finishBackupRestore(message: String) {
        groups = registry.allGroups()
        for g in groups { startService(for: g) }
        if !groups.contains(where: { $0.id == activeGroupId }) { activeGroupId = groups.first?.id ?? "default" }
        snap = Self.localized(snapshots[activeGroupId] ?? .initial)
        isRestoringBackup = false
        canCancelBackupRestore = false
        backupRestoreStatus = nil
        backupRestoreTask = nil
        settingsMessage = message
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
        guard appOperationStatus == nil else { return }
        appOperationStatus = loc("operation_creating_snapshot")
        Task { [weak self] in
            let result = await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    continuation.resume(returning: APFSSnapshotManager.shared.createLocalSnapshot())
                }
            }
            guard let self else { return }
            self.appOperationStatus = nil
            if result.isSandbox {
                self.settingsMessage = loc("msg_apfs_sandbox_active")
            } else if result.success {
                self.settingsMessage = loc("msg_apfs_success")
            } else {
                self.settingsMessage = loc("msg_apfs_failed_fallback")
            }
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

    func setCloudSpaceSaving(_ enabled: Bool) {
        service.setCloudSpaceSaving(enabled) { [weak self] error in
            Task { @MainActor in
                self?.settingsMessage = error.map { loc("msg_add_failed", CoreMessages.localize($0)) }
                    ?? loc(enabled ? "cloud_space_saving_enabled" : "cloud_space_saving_disabled")
            }
        }
    }

    func refreshVersions() { service.refreshVersionsUsage() }

    func revealVersionsFolder() { revealVersions() }

    // MARK: conflicts

    func setPolicy(_ p: ConflictPolicy) {
        snap.conflictPolicy = p
        if snapshots[activeGroupId] != nil {
            snapshots[activeGroupId]?.conflictPolicy = p
        }
        service.setConflictPolicy(p) { [weak self] err in
            Task { @MainActor in
                if let err {
                    self?.settingsMessage = loc("msg_add_failed", CoreMessages.localize(err))
                    if let cur = self?.snapshots[self?.activeGroupId ?? ""]?.conflictPolicy {
                        self?.snap.conflictPolicy = cur
                    }
                } else {
                    self?.settingsMessage = loc("msg_conflict_policy_updated")
                }
            }
        }
    }

    @Published var resolvingConflictIds: Set<Int64> = []

    func resolve(_ c: SyncService.ConflictItem, keep: ConflictChoice) {
        resolvingConflictIds.insert(c.id)
        service.resolveConflict(id: c.id, keep: keep) { [weak self] err in
            Task { @MainActor in
                self?.resolvingConflictIds.remove(c.id)
                if let err {
                    self?.settingsMessage = loc("msg_add_failed", CoreMessages.localize(err))
                } else {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self?.snap.conflicts.removeAll { $0.id == c.id }
                        if let gid = self?.activeGroupId {
                            self?.snapshots[gid]?.conflicts.removeAll { $0.id == c.id }
                        }
                    }
                    self?.settingsMessage = keep == .main ? loc("msg_conflict_kept_main") : loc("msg_conflict_used_extra")
                }
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
        guard !isQuitting else { return }
        isQuitting = true
        let stopping = Array(services.values)

        Task { [weak self] in
            await withTaskGroup(of: Void.self) { group in
                for service in stopping { group.addTask { await service.stopAndWait() } }
            }
            guard self != nil else { return }
            NSApp.terminate(nil)
        }

        // Copies use verified temp files and atomic renames; the journal recovers interrupted
        // operations. A menu-bar-only process must never remain trapped by a cloud provider.
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            guard self?.isQuitting == true else { return }
            Darwin.exit(0)
        }
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
