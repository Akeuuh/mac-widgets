import Foundation
import PRCore

func fixture(_ name: String) throws -> WidgetContent {
    let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")!
    return try makeContent(from: Data(contentsOf: url), scope: .myPullRequests)
}

extension WidgetContent {
    func pullRequest(titled title: String) -> PullRequest {
        pullRequests.first { $0.title == title }!
    }
}
