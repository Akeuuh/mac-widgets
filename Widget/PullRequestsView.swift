import GitHubClient
import PRCore
import SwiftUI
import WidgetKit

struct PullRequestsView: View {
    let entry: Entry

    var body: some View {
        switch entry.result {
        case .success(let content):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(content.pullRequests.prefix(3), id: \.url) { pullRequest in
                    PullRequestRow(pullRequest: pullRequest)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .failure(.missingToken):
            Text("Ouvre PR Widgets pour enregistrer ton token GitHub.")
        case .failure:
            Text("GitHub injoignable")
        }
    }
}

struct PullRequestRow: View {
    let pullRequest: PullRequest

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
    Entry(date: .now, result: .success(.placeholder))
}
