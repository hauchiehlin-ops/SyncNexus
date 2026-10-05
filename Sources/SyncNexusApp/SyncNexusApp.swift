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
/// - Syncing: Blue icon (`arrow.triangle.2.circlepath`)
/// - Attention/Warning: Red warning triangle (`exclamationmark.triangle.fill`)
/// - OK/Completed: Green checkmark (`checkmark.circle.fill`)
/// - Paused: Orange pause circle (`pause.circle.fill`)
/// - Partial / Offline: Orange indicator
/// Uses non-template colored NSImage so macOS MenuBarExtra renders true colors instead of mono-chrome mask.
struct MenuBarIcon: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow

    private var statusImage: NSImage {
        let (symbol, color): (String, NSColor) = {
            switch model.popoverOverall {
            case .syncing:
                return ("arrow.triangle.2.circlepath", .systemBlue)
            case .attention:
                return ("exclamationmark.triangle.fill", .systemRed)
            case .ok:
                return ("checkmark.circle.fill", .systemGreen)
            case .paused:
                return ("pause.circle.fill", .systemOrange)
            case .partial:
                return ("arrow.triangle.2.circlepath.circle", .systemOrange)
            case .starting:
                return ("arrow.triangle.2.circlepath", .secondaryLabelColor)
            }
        }()

        guard let base = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) else {
            return NSImage(size: NSSize(width: 18, height: 18))
        }
        let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let configured = base.withSymbolConfiguration(config) ?? base
        let tinted = NSImage(size: configured.size)
        tinted.lockFocus()
        color.set()
        let rect = NSRect(origin: .zero, size: tinted.size)
        configured.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
        color.set()
        rect.fill(using: .sourceAtop)
        tinted.unlockFocus()
        tinted.isTemplate = false // Crucial: prevents macOS MenuBar from stripping color!
        return tinted
    }

    var body: some View {
        Image(nsImage: statusImage)
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
