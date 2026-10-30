import GitHubClient
import PRCore
import WidgetKit

struct Entry: TimelineEntry {
    enum State {
        case content(WidgetContent)
        case failure(GitHubError)
        case missingRepository
    }

    let date: Date
    let state: State
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, state: .content(.placeholder))
    }

    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> Entry {
        placeholder(in: context)
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<Entry> {
        let state = if let scope = configuration.resolvedScope { await load(scope) } else { Entry.State.missingRepository }
        return Timeline(entries: [Entry(date: .now, state: state)], policy: .after(.now.addingTimeInterval(15 * 60)))
    }

    private func load(_ scope: Scope) async -> Entry.State {
        do {
            let response = try await GitHubClient.fromKeychain().search(scope)
            return .content(try makeContent(from: response, scope: scope))
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
        searchURL: Scope.myPullRequests.searchURL,
        counter: 3
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
