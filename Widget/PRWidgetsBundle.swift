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
        AppIntentConfiguration(kind: "PullRequests", intent: ConfigurationIntent.self, provider: Provider()) { entry in
            PullRequestsView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pull requests")
        .description("Les PR ouvertes d'un Périmètre : Mes PR, Revues demandées ou Mentionné ou assigné.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}
