import SwiftUI

@main
struct PRWidgetsApp: App {
    var body: some Scene {
        Window("PR Widgets", id: "token") {
            TokenView()
        }
        .windowResizability(.contentSize)
    }
}
