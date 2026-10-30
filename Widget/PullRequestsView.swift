import GitHubClient
import PRCore
import SwiftUI
import WidgetKit

struct PullRequestsView: View {
    let entry: Entry

    @Environment(\.widgetFamily) private var family

    private var capacity: Int {
        switch family {
        case .systemLarge: 5
        case .systemExtraLarge: 10
        default: 3
        }
    }

    var body: some View {
        switch entry.state {
        case .content(let content):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(content.pullRequests.prefix(capacity), id: \.url) { pullRequest in
                    PullRequestRow(pullRequest: pullRequest, showsLastMessage: family != .systemMedium)
                }
                Spacer(minLength: 0)
                let hidden = content.hiddenCount(showing: capacity)
                if hidden > 0 {
                    Link("+\(hidden) autres", destination: content.searchURL)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .failure(.missingToken):
            Text("Ouvre PR Widgets pour enregistrer ton token GitHub.")
        case .failure:
            Text("GitHub injoignable")
        case .missingRepository:
            Text("Choisis un dépôt : clic droit → Modifier le widget.")
        }
    }
}

struct PullRequestRow: View {
    let pullRequest: PullRequest
    let showsLastMessage: Bool

    var body: some View {
        Link(destination: pullRequest.url) {
            HStack(spacing: 8) {
                Circle()
                    .fill(ciColor)
                    .frame(width: 8, height: 8)
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(pullRequest.repository) #\(pullRequest.number)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(pullRequest.title)
                        .font(.callout)
                        .lineLimit(1)
                    if showsLastMessage, let message = pullRequest.lastMessage {
                        Text("\(Text(message.author).bold()) · \(message.excerpt) · \(message.date, format: .relative(presentation: .named))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
                if pullRequest.hasConflict {
                    Image(systemName: "arrow.triangle.merge")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("Conflit")
                }
                reviewDecisionIcon
            }
            .opacity(pullRequest.isDraft ? 0.5 : 1)
        }
    }

    private var ciColor: Color {
        switch pullRequest.ciState {
        case .success: .green
        case .failure: .red
        case .pending: .yellow
        case .none: .secondary.opacity(0.4)
        }
    }

    @ViewBuilder private var reviewDecisionIcon: some View {
        switch pullRequest.reviewDecision {
        case .approved:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .changesRequested:
            Image(systemName: "exclamationmark.bubble.fill").foregroundStyle(.red)
        case .pending:
            Image(systemName: "clock").foregroundStyle(.secondary)
        }
    }
}

#Preview(as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder))
}

#Preview(as: .systemLarge) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder))
}

#Preview(as: .systemExtraLarge) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder))
}
