import GitHubClient
import PRCore
import WidgetKit

struct Entry: TimelineEntry {
    let date: Date
    let result: Result<WidgetContent, GitHubError>
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        Entry(date: .now, result: .success(.placeholder))
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let entry = Entry(date: .now, result: await load())
            completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60))))
        }
    }

    private func load() async -> Result<WidgetContent, GitHubError> {
        do {
            let response = try await GitHubClient.fromKeychain().search(.myPullRequests)
            return .success(try makeContent(from: response, scope: .myPullRequests))
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
