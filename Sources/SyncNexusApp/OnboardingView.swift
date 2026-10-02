import AppKit
import ServiceManagement
import SwiftUI
import SyncCore
import UserNotifications

enum Permissions {
    /// Whether the app is currently running inside Apple App Sandbox.
    static var isSandboxed: Bool {
        ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
    }

    /// Full Disk Access status. In an App Store Sandbox environment, standard FDA is replaced
    /// by user-selected Security-Scoped Bookmarks, which are always active and authorized.
    static func hasFullDiskAccess() -> Bool {
        if isSandboxed {
            // App Store sandboxed builds rely on security-scoped bookmarks granted via OpenPanel.
            return true
        }
        let home = NSHomeDirectory()
        for dir in ["/Library/Safari", "/Library/Mail", "/Library/Messages"] {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: home + dir, isDirectory: &isDir), isDir.boolValue {
                return (try? FileManager.default.contentsOfDirectory(atPath: home + dir)) != nil
            }
        }
        return false
    }

    static func openFullDiskAccessSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
    }

    static func relaunch() {
        let path = Bundle.main.bundlePath
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/sh")
        p.arguments = ["-c", "sleep 1; /usr/bin/open -n \"\(path)\""]
        try? p.run()
        NSApp.terminate(nil)
    }
}

struct OnboardingView: View {
    @ObservedObject var model: AppModel
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var fullDisk = Permissions.hasFullDiskAccess()
    @State private var notifications: UNAuthorizationStatus = .notDetermined
    private let last = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                ForEach(0...last, id: \.self) { i in
                    Capsule().fill(i <= step ? Color.accentColor : Color.secondary.opacity(0.25)).frame(height: 4)
                }
            }
            Group {
                switch step {
                case 0: welcome
                case 1: permissions
                case 2: folders
                default: done
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
            HStack {
                if step > 0 { Button(loc("back")) { step -= 1 } }
                Spacer()
                if step < last { Button(step == 0 ? loc("start_setup") : loc("next")) { step += 1 }.keyboardShortcut(.defaultAction) }
                else { Button(loc("done")) { finish() }.keyboardShortcut(.defaultAction) }
            }
        }
        .padding(24)
        .frame(width: 560, height: 470)
        .id(l10n.currentLanguage)
        .onAppear { refresh() }
        .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in refresh() }
    }

    private func refresh() {
        fullDisk = Permissions.hasFullDiskAccess()
        UNUserNotificationCenter.current().getNotificationSettings { s in
            DispatchQueue.main.async { notifications = s.authorizationStatus }
        }
        model.refreshLoginState()
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "onboardingDone")
        dismiss()
    }

    // MARK: pages

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage).resizable().frame(width: 72, height: 72)
            Text(loc("welcome_title")).font(.title.bold())
            Text(loc("welcome_subtitle"))
            VStack(alignment: .leading, spacing: 8) {
                bullet("arrow.left.arrow.right", loc("welcome_bullet_1"))
                bullet("externaldrive", loc("welcome_bullet_2"))
                bullet("trash", loc("welcome_bullet_3"))
                bullet("exclamationmark.triangle", loc("welcome_bullet_4"))
            }
            .font(.callout)
        }
    }

    private var permissions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc("onboarding_perm_title")).font(.title2.bold())
            Text(loc("onboarding_perm_desc"))
                .font(.callout).foregroundStyle(.secondary)
            permissionRow(
                ok: fullDisk,
                title: Permissions.isSandboxed ? loc("permissions_sandbox_title") : loc("permissions_full_disk_title"),
                detail: Permissions.isSandboxed ? loc("permissions_sandbox_desc") : (fullDisk ? loc("permissions_authorized") : loc("permissions_unauthorized_desc"))
            ) {
                if !Permissions.isSandboxed {
                    HStack {
                        Button(loc("permissions_btn_open_settings")) { Permissions.openFullDiskAccessSettings() }
                        if !fullDisk { Button(loc("permissions_btn_relaunch")) { Permissions.relaunch() } }
                    }
                }
            }
            permissionRow(ok: notifications == .authorized, title: loc("onboarding_perm_notifications"), detail: loc("onboarding_perm_notifications_desc")) {
                if notifications == .denied { Button(loc("onboarding_perm_btn_notifications")) { NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension")!) } }
            }
            permissionRow(ok: model.launchAtLogin, title: loc("settings_launch_at_login"), detail: loc("onboarding_perm_launch_desc")) {
                Toggle("", isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) })).labelsHidden()
            }
            if !Permissions.isSandboxed {
                Text(loc("onboarding_perm_fda_hint"))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var folders: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc("onboarding_folders_title")).font(.title2.bold())
            Text(loc("onboarding_folders_desc"))
            VStack(alignment: .leading, spacing: 6) {
                bullet("laptopcomputer", loc("onboarding_folder_local"))
                bullet("icloud", loc("onboarding_folder_icloud"))
                bullet("externaldrive.badge.icloud", loc("onboarding_folder_gdrive"))
                bullet("externaldrive", loc("onboarding_folder_external"))
            }
            .font(.callout)
            Text(loc("onboarding_folders_min_hint"))
                .font(.callout).foregroundStyle(.secondary)
            HStack {
                Button(loc("folders_add_button")) { openWindow(id: "settings"); NSApp.activate(ignoringOtherApps: true) }
                Text(loc("onboarding_folders_current_count", model.snap.endpoints.count)).foregroundStyle(.secondary)
            }
            Text(loc("onboarding_folders_test_tip")).font(.callout).foregroundStyle(.orange)
        }
    }

    private var done: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc("onboarding_done_title")).font(.title2.bold())
            Text(loc("onboarding_done_desc"))
            VStack(alignment: .leading, spacing: 6) {
                bullet("arrow.triangle.2.circlepath", loc("onboarding_icon_ok"))
                bullet("pause.circle", loc("onboarding_icon_paused"))
                bullet("exclamationmark.arrow.triangle.2.circlepath", loc("onboarding_icon_attention"))
                bullet("arrow.triangle.2.circlepath.circle", loc("onboarding_icon_partial"))
            }
            .font(.callout)
            Text(loc("onboarding_done_footer"))
                .font(.callout).foregroundStyle(.secondary)
        }
    }

    private func bullet(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol).frame(width: 20).foregroundStyle(Color.accentColor)
            Text(text).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func permissionRow<Trailing: View>(ok: Bool, title: String, detail: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: ok ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(ok ? Color.green : Color.orange).font(.title3)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                trailing()
            }
            Spacer()
        }
        .padding(10)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
    }
}
