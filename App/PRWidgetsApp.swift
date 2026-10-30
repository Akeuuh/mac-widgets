import SwiftUI

@main
struct PRWidgetsApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        Window("PR Widgets", id: "token") {
            TokenView()
                // macOS hands the URL of a clicked widget link to the containing app instead of the browser.
                .onOpenURL { url in
                    NSWorkspace.shared.open(url)
                    NSApp.terminate(nil)
                }
        }
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
