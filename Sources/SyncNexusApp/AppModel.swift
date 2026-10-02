import AppKit
import ServiceManagement
import SwiftUI
import SyncCore
import UserNotifications

@MainActor
final class AppModel: ObservableObject {
    @Published var snap = SyncService.Snapshot.initial
    @Published var launchAtLogin = false
    @Published var loginNote: String?

    private var service: SyncService!
    private var lastNotifiedConfirmation: String?
    private var lastNotifiedConflicts = 0

    static let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("SyncNexus")
    static let logURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Logs/SyncNexus/syncnexus.log")

    init() {
        service = SyncService(dbPath: Self.appSupport.appendingPathComponent("state.db").path,
                              versionsDir: Self.appSupport.appendingPathComponent("Versions"),
                              logURL: Self.logURL) { [weak self] snapshot in
            Task { @MainActor in self?.apply(snapshot) }
        }
        service.start()
        refreshLoginState()
        setupLoginItemOnce()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
        // After sleep the event stream can have gaps: re-check everything on wake.
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.service.syncNow()
        }
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

    func addEndpoint(name: String, path: String, removable: Bool, portable: Bool) {
        let cfg = EndpointConfig(id: name.trimmingCharacters(in: .whitespaces), root: path, removable: removable, portableNames: portable)
        service.addEndpoint(cfg) { [weak self] err in
            Task { @MainActor in self?.settingsMessage = err.map { "新增失敗：\($0)" } ?? "已新增「\(cfg.id)」。首次同步前會先顯示預覽，等你確認。" }
        }
    }

    func relink(id: String, to path: String) {
        service.relinkEndpoint(id: id, root: path) { [weak self] err in
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

    func reveal(_ path: String) { NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)]) }

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
