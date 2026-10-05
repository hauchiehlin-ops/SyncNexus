import AppKit
import SwiftUI

/// Gives SwiftUI-managed windows a stable AppKit identifier and reliably raises them
/// when an action originates from a MenuBarExtra window.
@MainActor
enum AppWindowPresenter {
    static let settingsID = NSUserInterfaceItemIdentifier("syncnexus.settings")

    static func presentSettings(using openWindow: OpenWindowAction) {
        openWindow(id: "settings")
        NSApp.activate(ignoringOtherApps: true)

        // `openWindow` is asynchronous when it has to create the scene. The first
        // attempt handles an existing window; the deferred attempts handle a newly
        // created one after SwiftUI has attached its NSWindow.
        bringToFront(identifier: settingsID)
        DispatchQueue.main.async {
            bringToFront(identifier: settingsID)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            bringToFront(identifier: settingsID)
        }
    }

    private static func bringToFront(identifier: NSUserInterfaceItemIdentifier) {
        guard let window = NSApp.windows.first(where: { $0.identifier == identifier }) else { return }
        if window.isMiniaturized { window.deminiaturize(nil) }
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
}

/// SwiftUI's `Window(id:)` does not expose the resulting NSWindow. This small
/// representable tags it once attached so AppWindowPresenter can find it later.
struct AppWindowIdentifierView: NSViewRepresentable {
    let identifier: NSUserInterfaceItemIdentifier

    func makeNSView(context: Context) -> IdentifierView {
        IdentifierView(identifier: identifier)
    }

    func updateNSView(_ nsView: IdentifierView, context: Context) {
        nsView.windowIdentifier = identifier
        nsView.applyIdentifier()
    }

    final class IdentifierView: NSView {
        var windowIdentifier: NSUserInterfaceItemIdentifier

        init(identifier: NSUserInterfaceItemIdentifier) {
            windowIdentifier = identifier
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            applyIdentifier()
        }

        func applyIdentifier() {
            window?.identifier = windowIdentifier
        }
    }
}
