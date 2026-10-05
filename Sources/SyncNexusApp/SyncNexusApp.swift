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
            MenuBarIcon(model: model)
        }
        .menuBarExtraStyle(.window)

        Window(loc("window_welcome_title"), id: "welcome") {
            OnboardingView(model: model)
        }
        .windowResizability(.contentSize)

        Window(loc("window_popover_preview"), id: "popover-preview") {
            PopoverView(model: model)
        }
        .windowResizability(.contentSize)

        Window("Sync-Nexus", id: "settings") {
            MainWindowView(model: model)
        }
        .windowResizability(.contentMinSize)
    }
}

/// The menu bar icon with dynamic signals and colors based on sync status.
/// - Syncing: Blue spinning icon (`arrow.triangle.2.circlepath` with continuous rotation)
/// - Attention/Warning: Red warning triangle (`exclamationmark.triangle.fill`)
/// - OK/Completed: Green checkmark (`checkmark.circle.fill`)
/// - Paused: Orange pause circle (`pause.circle.fill`)
/// `--open-settings` (a debugging aid) also opens the settings window at launch.
struct MenuBarIcon: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            switch model.popoverOverall {
            case .syncing:
                if #available(macOS 15.0, *) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(Color.blue)
                        .symbolEffect(.rotate, isActive: true)
                } else if #available(macOS 14.0, *) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(Color.blue)
                        .symbolEffect(.pulse, isActive: true)
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(Color.blue)
                }
            case .attention:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.red)
            case .ok:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.green)
            case .paused:
                Image(systemName: "pause.circle.fill")
                    .foregroundStyle(Color.orange)
            case .partial:
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .foregroundStyle(Color.orange)
            case .starting:
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Color.secondary)
            }
        }
        .onAppear {
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
