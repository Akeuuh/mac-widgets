import GitHubClient
import PRCore
import WidgetKit

struct Entry: TimelineEntry {
    let date: Date
    let result: Result<WidgetContent, GitHubError>
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, result: .success(.placeholder))
    }

    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> Entry {
        placeholder(in: context)
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<Entry> {
        let entry = Entry(date: .now, result: await load(configuration.scope.scope))
        return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60)))
    }

    private func load(_ scope: Scope) async -> Result<WidgetContent, GitHubError> {
        do {
            let response = try await GitHubClient.fromKeychain().search(scope)
            return .success(try makeContent(from: response, scope: scope))
        } catch let error as GitHubError {
            return .failure(error)
        } catch {
            return .failure(.unavailable)
        }
    }
}

extension WidgetContent {
    static let placeholder = WidgetContent(
        login: "octocat",
        pullRequests: (1...10).map(placeholderPullRequest),
        totalCount: 12,
        searchURL: Scope.myPullRequests.searchURL
    )

    private static func placeholderPullRequest(_ number: Int) -> PullRequest {
        PullRequest(
            repository: "octocat/hello-world",
            number: number,
            title: "Pull request \(number)",
            url: URL(string: "https://github.com/octocat/hello-world/pull/\(number)")!,
            updatedAt: .now,
            ciState: [.success, .failure, .pending][number % 3],
            reviewDecision: [.approved, .changesRequested, .pending][number % 3],
            hasConflict: number == 2,
            isDraft: number == 3,
            lastMessage: Message(author: "alice", excerpt: "Tu peux regarder le cas des remises ?", date: .now.addingTimeInterval(-600))
        )
    }
}
