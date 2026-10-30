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
            VStack(alignment: .leading, spacing: 1) {
                Text("\(pullRequest.repository) #\(pullRequest.number)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(pullRequest.title)
                    .font(.callout)
                    .lineLimit(1)
            }
        }
    }
}

#Preview(as: .systemMedium) {
    PullRequestsWidget()
} timeline: {
    Entry(date: .now, result: .success(.placeholder))
}
