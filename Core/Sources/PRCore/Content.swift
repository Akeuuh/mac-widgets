import Foundation

public func makeContent(from response: Data) throws -> WidgetContent {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let payload = try decoder.decode(SearchResponse.self, from: response).data

    let pullRequests = payload.search.nodes.map { node in
        PullRequest(
            repository: node.repository.nameWithOwner,
            number: node.number,
            title: node.title,
            url: node.url,
            updatedAt: node.updatedAt,
            ciState: ciState(of: node.commits.nodes.last?.commit.statusCheckRollup?.contexts.nodes ?? []),
            reviewDecision: reviewDecision(node.reviewDecision),
            hasConflict: node.mergeable == "CONFLICTING",
            isDraft: node.isDraft
        )
    }
    return WidgetContent(
        login: payload.viewer.login,
        pullRequests: pullRequests.sorted { $0.updatedAt > $1.updatedAt }
    )
}

private func ciState(of checks: [SearchResponse.Check]) -> CIState {
    let states = checks.map(ciState)
    if states.isEmpty { return .none }
    if states.contains(.failure) { return .failure }
    if states.contains(.pending) { return .pending }
    return .success
}

private func ciState(of check: SearchResponse.Check) -> CIState {
    if let state = check.state {
        switch state {
        case "SUCCESS": return .success
        case "PENDING", "EXPECTED": return .pending
        default: return .failure
        }
    }
    guard check.status == "COMPLETED" else { return .pending }
    switch check.conclusion {
    case "SUCCESS", "NEUTRAL", "SKIPPED": return .success
    default: return .failure
    }
}

private func reviewDecision(_ value: String?) -> ReviewDecision {
    switch value {
    case "APPROVED": .approved
    case "CHANGES_REQUESTED": .changesRequested
    default: .pending
    }
}
