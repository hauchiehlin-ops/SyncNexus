import AppKit
import ServiceManagement
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
    @Published var snap = SyncService.Snapshot.initial
    @Published var launchAtLogin = false
    @Published var loginNote: String?
    @Published var section: MainSection = .overview
    @Published var versionItems: [VersionItem] = []
    @Published var trialRunReport: SyncReport?
    @Published var isRunningTrialRun = false

    private var service: SyncService!
    private var lastNotifiedConfirmation: String?
    private var lastNotifiedConflicts = 0

    static let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("SyncNexus")
    static let logURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Logs/SyncNexus/syncnexus.log")

    @Published var nearbyPeers: [LocalPeer] = []

    init() {
        service = SyncService(dbPath: Self.appSupport.appendingPathComponent("state.db").path,
                              versionsDir: Self.appSupport.appendingPathComponent("Versions"),
                              logURL: Self.logURL) { [weak self] snapshot in
            Task { @MainActor in self?.apply(snapshot) }
        }
        if let i = CommandLine.arguments.firstIndex(of: "--section"), i + 1 < CommandLine.arguments.count,
           let sec = MainSection(rawValue: CommandLine.arguments[i + 1]) { section = sec }     // debugging aid
        service.start()
        refreshLoginState()
        setupLoginItemOnce()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        // After sleep the event stream can have gaps: re-check everything on wake.
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.service.syncNow()
        }

        // 啟動局域網點對點設備發現
        LocalPeerDiscovery.shared.onPeersChanged = { [weak self] peers in
            Task { @MainActor in self?.nearbyPeers = peers }
        }
        LocalPeerDiscovery.shared.start()
    }

    // MARK: state

    private func apply(_ s: SyncService.Snapshot) {
        snap = s
        if let c = s.confirmation, c.reason != lastNotifiedConfirmation {
            lastNotifiedConfirmation = c.reason
            notify("Sync-Nexus 需要你確認", c.reason)
        } else if s.confirmation == nil { lastNotifiedConfirmation = nil }
        if s.conflicts.count > lastNotifiedConflicts {
            let n = s.conflicts.count
            notify("有 \(n) 個同步衝突待處理", "同一個檔案在兩個地方被修改。原檔已與其他資料夾一致，另一份保留在發生衝突的資料夾，請到「設定端點」選擇要留哪一份。")
        }
        lastNotifiedConflicts = s.conflicts.count
    }

    var overall: Overall {
        if snap.phase == .paused { return .paused }
        if snap.error != nil || snap.confirmation != nil || !snap.conflicts.isEmpty || !snap.integrityIssues.isEmpty { return .attention }
        if snap.phase == .syncing { return .syncing }
        if snap.lastRun == nil { return .starting }
        if snap.endpoints.contains(where: { !$0.online }) { return .partial }
        return .ok
    }

    var overallTitle: String {
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

    var overallDetail: String {
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

    var iconName: String {
        if snap.error != nil || snap.confirmation != nil { return "exclamationmark.arrow.triangle.2.circlepath" }
        if snap.endpoints.contains(where: { !$0.online }) && snap.phase != .syncing { return "arrow.triangle.2.circlepath.circle" }
        switch snap.phase {
        case .paused: return "pause.circle"
        default: return "arrow.triangle.2.circlepath"
        }
    }

    var headline: String {
        if let e = snap.error { return "錯誤：\(e)" }
        if snap.confirmation != nil { return "⚠︎ 需要你確認" }
        switch snap.phase {
        case .paused: return "已暫停"
        case .syncing: return "同步中…"
        case .idle:
            guard let t = snap.lastRun else { return "啟動中…" }
            let f = RelativeDateTimeFormatter(); f.locale = Locale(identifier: "zh_TW"); f.unitsStyle = .short
            return "已同步 · \(f.localizedString(for: t, relativeTo: Date()))"
        }
    }

    // MARK: actions

    func syncNow() { service.syncNow() }
    func verifyNow() { service.verifyNow() }
    func togglePause() { snap.phase == .paused ? service.resume() : service.pause() }

    func reviewConfirmation() {
        guard let c = snap.confirmation else { return }
        let alert = NSAlert()
        alert.messageText = c.reason
        let lines = c.preview.prefix(25).joined(separator: "\n")
        alert.informativeText = lines + (c.preview.count > 25 ? "\n…另有 \(c.preview.count - 25) 項" : "")
        alert.addButton(withTitle: "確認執行")
        alert.addButton(withTitle: "取消")
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn { service.syncNow(confirmed: true) }
    }

    func openLog() {
        try? FileManager.default.createDirectory(at: Self.logURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: Self.logURL.path) { try? Data().write(to: Self.logURL) }
        NSWorkspace.shared.open(Self.logURL)
    }

    func revealVersions() {
        let dir = Self.appSupport.appendingPathComponent("Versions")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        NSWorkspace.shared.open(dir)
    }

    // MARK: endpoint settings

    @Published var settingsMessage: String?

    var existingConfigs: [EndpointConfig] {
        snap.endpoints.map { EndpointConfig(id: $0.id, root: $0.root, removable: $0.removable, portableNames: $0.portableNames) }
    }

    func validate(path: String, name: String, replacing: String? = nil, portable: Bool = false) -> [ValidationIssue] {
        EndpointValidator.validate(path: path, name: name, replacing: replacing, existing: existingConfigs, portableNames: portable)
    }

    func addEndpoint(name: String, path: String, removable: Bool, portable: Bool, archive: Bool = false, bookmarkData: Data? = nil) {
        let cfg = EndpointConfig(id: name.trimmingCharacters(in: .whitespaces), root: path, removable: removable, portableNames: portable, role: archive ? .archive : .mirror, bookmarkData: bookmarkData)
        service.addEndpoint(cfg) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "新增失敗：\($0)" } ?? "已新增「\(cfg.id)」。首次同步前會先顯示預覽，等你確認。" }
        }
    }

    func relink(id: String, to path: String, bookmarkData: Data? = nil) {
        service.relinkEndpoint(id: id, root: path, bookmarkData: bookmarkData) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "更換失敗：\($0)" } ?? "「\(id)」已改指向新資料夾，下次同步前會先顯示預覽。" }
        }
    }

    func remove(id: String) {
        service.removeEndpoint(id: id) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "移除失敗：\($0)" } ?? "已移除「\(id)」，資料夾內的檔案完全沒有被動到。" }
        }
    }

    // MARK: versions archive

    func purgeVersions(_ mode: SyncService.PurgeMode) {
        service.purgeVersions(mode) { [weak self] files, bytes in
            Task { @MainActor in
                self?.settingsMessage = "已清理 \(files) 個舊版本檔案，釋出 \(ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file))"
            }
        }
    }

    func setRetention(days: Int) {
        service.setVersionsRetention(days: days) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "設定失敗：\($0)" } ?? "舊版本保留期限已更新" }
        }
    }

    func setArchiveRetention(days: Int) {
        service.setArchiveRetention(days: days) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "設定失敗：\($0)" } ?? "備份歷史保留期限已更新" }
        }
    }

    func runTrialRun() {
        isRunningTrialRun = true
        service.trialRun { [weak self] report in
            Task { @MainActor in
                self?.isRunningTrialRun = false
                self?.trialRunReport = report
                self?.settingsMessage = report != nil ? "已完成模擬試跑比對" : "模擬試跑失敗"
            }
        }
    }

    func createAPFSSnapshot() {
        let res = APFSSnapshotManager.shared.createLocalSnapshot()
        settingsMessage = res.message
    }

    func repair(_ issue: IntegrityIssue, action: IntegrityAction) {
        service.resolveIntegrity(issue, action: action) { [weak self] err in
            Task { @MainActor in
                self?.settingsMessage = err.map { "處理失敗：\($0)" } ?? (action == .restoreFromOthers ? "已用其他資料夾的版本修復，損壞的內容保留在舊版本" : "已接受現在的內容，會同步到其他資料夾")
            }
        }
    }

    /// How many cloud files of this folder are still being read in the background (iCloud / Drive placeholders).
    func pendingCloud(_ id: String) -> Int { snap.skipped.filter { $0.hasPrefix("[\(id)]") && $0.contains("讀取雲端") }.count }

    func setExclude(_ preset: ExcludePreset, on: Bool) {
        var p = snap.excludePresets
        if on { p.insert(preset) } else { p.remove(preset) }
        service.setExcludePresets(p) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "設定失敗：\($0)" } ?? "排除項目已更新（已同步的檔案不會被刪除，只是不再同步）" }
        }
    }

    func refreshVersions() { service.refreshVersionsUsage() }

    func revealVersionsFolder() { revealVersions() }

    // MARK: conflicts

    func setPolicy(_ p: ConflictPolicy) {
        service.setConflictPolicy(p) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "設定失敗：\($0)" } ?? "衝突策略已更新" }
        }
    }

    func resolve(_ c: SyncService.ConflictItem, keep: ConflictChoice) {
        service.resolveConflict(id: c.id, keep: keep) { [weak self] err in
            Task { @MainActor in
                self?.settingsMessage = err.map { "處理失敗：\($0)" }
                    ?? (keep == .main ? "已保留原檔，另一份已移到垃圾桶" : "已改用衝突副本，舊版存入 Versions，正在傳到其他資料夾")
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
                self?.settingsMessage = err.map { "還原失敗：\($0)" } ?? "已還原「\((item.path as NSString).lastPathComponent)」，正在同步到其他資料夾"
                self?.loadVersions()
            }
        }
    }

    func quit() { service.stop(); NSApp.terminate(nil) }

    // MARK: launch at login

    func refreshLoginState() {
        let status = SMAppService.mainApp.status
        launchAtLogin = status == .enabled
        loginNote = status == .requiresApproval ? "需在「系統設定 > 一般 > 登入項目」允許" : nil
    }

    func setLaunchAtLogin(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        } catch {
            loginNote = "無法設定開機啟動：\(error.localizedDescription)"
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
