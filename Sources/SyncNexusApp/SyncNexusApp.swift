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
            PopoverView(model: model)
        } label: {
            MenuBarIcon(name: model.iconName)
        }
        .menuBarExtraStyle(.window)

        Window("歡迎使用 Sync-Nexus", id: "welcome") {
            OnboardingView(model: model)
        }
        .windowResizability(.contentSize)

        Window("彈出視窗預覽", id: "popover-preview") {
            PopoverView(model: model)
        }
        .windowResizability(.contentSize)

        Window("Sync-Nexus", id: "settings") {
            MainWindowView(model: model)
        }
        .windowResizability(.contentMinSize)
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
            if CommandLine.arguments.contains("--open-popover-preview") {
                openWindow(id: "popover-preview"); NSApp.activate(ignoringOtherApps: true)
            }
            if CommandLine.arguments.contains("--open-welcome") || !UserDefaults.standard.bool(forKey: "onboardingDone") {
                openWindow(id: "welcome"); NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

