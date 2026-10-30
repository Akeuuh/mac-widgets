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
        case .content(let content, let fetchedAt, let isStale) where family == .systemSmall:
            VStack(spacing: 0) {
                CounterView(content: content)
                Freshness(fetchedAt: fetchedAt, isStale: isStale)
            }
        case .content(let content, let fetchedAt, let isStale):
            VStack(alignment: .leading, spacing: 6) {
                if content.pullRequests.isEmpty {
                    Text("Rien en attente ✓")
                        .font(.headline)
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                ForEach(content.pullRequests.prefix(capacity), id: \.url) { pullRequest in
                    PullRequestRow(pullRequest: pullRequest, showsLastMessage: family != .systemMedium)
                }
                Spacer(minLength: 0)
                HStack {
                    let hidden = content.hiddenCount(showing: capacity)
                    if hidden > 0 {
                        Link("+\(hidden) autres", destination: content.searchURL)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Freshness(fetchedAt: fetchedAt, isStale: isStale)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .failure(.missingToken):
            Problem(message: "Ouvre Mac Widgets pour enregistrer ton token GitHub.")
        case .failure(.invalidToken):
            Problem(message: "Token invalide")
        case .failure(.unavailable):
            Problem(message: "GitHub injoignable")
        case .missingRepository:
            Problem(message: "Choisis un dépôt : clic droit → Modifier le widget.")
        }
    }
}

struct Freshness: View {
    let fetchedAt: Date
    let isStale: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text("il y a \(fetchedAt, style: .relative)")
                .foregroundStyle(isStale ? AnyShapeStyle(.orange) : AnyShapeStyle(.tertiary))
            Button(intent: RefreshIntent()) {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Rafraîchir")
        }
        .font(.caption2)
    }
}

struct Problem: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.callout)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CounterView: View {
    let content: WidgetContent

    var body: some View {
        Text("\(content.counter)")
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                if content.hasFailingCI {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .accessibilityLabel("CI en échec")
                }
            }
            .widgetURL(content.searchURL)
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

#Preview("Contenu", as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder, fetchedAt: .now.addingTimeInterval(-240), isStale: false))
}

#Preview("Grand", as: .systemLarge) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder, fetchedAt: .now, isStale: false))
}

#Preview("Très grand", as: .systemExtraLarge) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder, fetchedAt: .now, isStale: false))
}

#Preview("Compteur", as: .systemSmall) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder, fetchedAt: .now, isStale: false))
}

#Preview("Hors ligne", as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.placeholder, fetchedAt: .now.addingTimeInterval(-3600), isStale: true))
}

#Preview("Rien en attente", as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .content(.empty, fetchedAt: .now, isStale: false))
}

#Preview("Pas de token", as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .failure(.missingToken))
}

#Preview("Token invalide", as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .failure(.invalidToken))
}

#Preview("GitHub injoignable sans cache", as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .failure(.unavailable))
}

#Preview("Dépôt à choisir", as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, state: .missingRepository)
}
