import SwiftUI

@main
struct PRWidgetsApp: App {
    var body: some Scene {
        Window("PR Widgets", id: "token") {
            TokenView()
                // macOS hands the URL of a clicked widget link to the containing app instead of the browser.
                .onOpenURL { url in
                    NSWorkspace.shared.open(url)
                    NSApp.hide(nil)
                }
        }
        .windowResizability(.contentSize)
    }
}
