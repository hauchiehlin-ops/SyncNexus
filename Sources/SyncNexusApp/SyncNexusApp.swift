import AppKit
import SwiftUI
import ServiceManagement
import SyncCore

@main
struct SyncNexusApp: App {
    @StateObject private var model: AppModel

    init() {
        if CommandLine.arguments.contains("--login-enable") {
            do { try SMAppService.mainApp.register(); print("registered") } catch { print("register failed: \(error)") }
        }
        if CommandLine.arguments.contains("--login-status") || CommandLine.arguments.contains("--login-enable") {
            print("login item status: \(SMAppService.mainApp.status.rawValue) (0 notRegistered, 1 enabled, 2 requiresApproval, 3 notFound)")
            exit(0)
        }
        // Only one instance may run: two engines on one database would fight each other.
        let me = Bundle.main.bundleIdentifier ?? "com.syncnexus.app"
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: me).filter { $0 != .current }
        if !others.isEmpty { exit(0) }
        _model = StateObject(wrappedValue: AppModel())
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContent(model: model)
        } label: {
            MenuBarIcon(name: model.iconName)
        }
        .menuBarExtraStyle(.menu)

        Window("歡迎使用 Sync-Nexus", id: "welcome") {
            OnboardingView(model: model)
        }
        .windowResizability(.contentSize)

        Window("Sync-Nexus 設定", id: "settings") {
            SettingsView(model: model)
        }
        .windowResizability(.contentSize)
    }
}

/// The menu bar icon. `--open-settings` (a debugging aid) also opens the settings window at launch.
struct MenuBarIcon: View {
    let name: String
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Image(systemName: name).onAppear {
            if CommandLine.arguments.contains("--open-settings") {
                openWindow(id: "settings"); NSApp.activate(ignoringOtherApps: true)
            }
            if CommandLine.arguments.contains("--open-welcome") || !UserDefaults.standard.bool(forKey: "onboardingDone") {
                openWindow(id: "welcome"); NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct MenuContent: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text(model.headline)
        if model.snap.trackedFiles > 0 { Text("追蹤中 \(model.snap.trackedFiles) 個檔案") }
        if !model.snap.conflicts.isEmpty {
            Button("⚠︎ \(model.snap.conflicts.count) 個衝突待處理…") { openWindow(id: "settings"); NSApp.activate(ignoringOtherApps: true) }
        }
        if model.snap.confirmation != nil {
            Button("查看預覽並確認…") { model.reviewConfirmation() }
        }
        Divider()

        ForEach(model.snap.endpoints, id: \.id) { ep in
            Text("\(ep.online ? "●" : "○") \(ep.id)\(ep.online ? "" : "　\(ep.detail)")")
        }
        if model.snap.endpoints.count < 2 { Text("需要至少兩個端點才會開始同步") }

        if !model.snap.skipped.isEmpty {
            Menu("略過 \(model.snap.skipped.count) 項") {
                ForEach(model.snap.skipped.prefix(12), id: \.self) { Text($0) }
            }
        }
        Menu("最近活動") {
            if model.snap.recent.isEmpty { Text("尚無") }
            ForEach(model.snap.recent, id: \.self) { Text($0) }
        }
        Divider()

        Button("設定端點…") { openWindow(id: "settings"); NSApp.activate(ignoringOtherApps: true) }.keyboardShortcut(",")
        Button("立即同步") { model.syncNow() }.keyboardShortcut("r")
        Button(model.snap.phase == .paused ? "繼續同步" : "暫停同步") { model.togglePause() }
        Divider()

        Toggle("開機自動啟動", isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) }))
        if let note = model.loginNote { Text(note) }
        Button("使用說明與授權檢查…") { openWindow(id: "welcome"); NSApp.activate(ignoringOtherApps: true) }
        Button("開啟紀錄檔") { model.openLog() }
        Button("開啟舊版本資料夾") { model.revealVersions() }
        Divider()
        Text("版本 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")（build \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")）")
        Button("結束 Sync-Nexus") { model.quit() }.keyboardShortcut("q")
    }
}
