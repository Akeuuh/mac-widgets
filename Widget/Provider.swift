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
            return .success(try makeContent(from: response))
        } catch let error as GitHubError {
            return .failure(error)
        } catch {
            return .failure(.unavailable)
        }
    }
}

extension WidgetContent {
    static let placeholder = WidgetContent(login: "octocat", pullRequests: (1...3).map {
        PullRequest(
            repository: "octocat/hello-world",
            number: $0,
            title: "Pull request \($0)",
            url: URL(string: "https://github.com/octocat/hello-world/pull/\($0)")!,
            updatedAt: .now
        )
    })
}
