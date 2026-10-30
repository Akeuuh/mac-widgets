import SwiftUI
import WidgetKit

@main
struct PRWidgetsBundle: WidgetBundle {
    var body: some Widget {
        PullRequestsWidget()
    }
}

struct PullRequestsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PullRequests", provider: Provider()) { entry in
            PullRequestsView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pull requests")
        .description("Les PR ouvertes dont tu es l'auteur.")
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}
