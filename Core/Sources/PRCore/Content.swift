import Foundation

public func makeContent(from response: Data, scope: Scope) throws -> WidgetContent {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let payload = try decoder.decode(SearchResponse.self, from: response).data

    let login = payload.viewer.login
    let items = payload.search.nodes.map { node in
        var pullRequest = PullRequest(
            repository: node.repository.nameWithOwner,
            number: node.number,
            title: node.title,
            url: node.url,
            updatedAt: node.updatedAt,
            ciState: ciState(of: node.commits.nodes.last?.commit.statusCheckRollup?.contexts.nodes ?? []),
            reviewDecision: reviewDecision(node.reviewDecision),
            hasConflict: node.mergeable == "CONFLICTING",
            isDraft: node.isDraft,
            lastMessage: lastMessage(of: node)
        )
        pullRequest.actionRequired = isActionRequired(pullRequest, scope: scope, login: login)
        return (pullRequest: pullRequest, reviewRequestedAt: reviewRequestedAt(of: node, login: login))
    }
    let pullRequests = switch scope {
    case .reviewRequested:
        items.sorted(by: readyThenLongestWaiting).map(\.pullRequest)
    case .myPullRequests, .involved, .repository:
        items.map(\.pullRequest).sorted(by: actionRequiredThenRecentActivity)
    }
    return WidgetContent(
        login: login,
        pullRequests: pullRequests,
        totalCount: payload.search.issueCount,
        searchURL: scope.searchURL
    )
}

private func isActionRequired(_ pullRequest: PullRequest, scope: Scope, login: String) -> Bool {
    let lastMessageFromSomeoneElse = pullRequest.lastMessage.map { $0.author != login } ?? false
    switch scope {
    case .myPullRequests:
        return pullRequest.ciState == .failure
            || pullRequest.reviewDecision == .changesRequested
            || pullRequest.hasConflict
            || lastMessageFromSomeoneElse
    case .involved:
        return lastMessageFromSomeoneElse
    case .reviewRequested, .repository:
        return false
    }
}

private func readyThenLongestWaiting(
    _ lhs: (pullRequest: PullRequest, reviewRequestedAt: Date?),
    _ rhs: (pullRequest: PullRequest, reviewRequestedAt: Date?)
) -> Bool {
    let lhsReady = isReadyForReview(lhs.pullRequest)
    if lhsReady != isReadyForReview(rhs.pullRequest) { return lhsReady }
    return (lhs.reviewRequestedAt ?? .distantFuture) < (rhs.reviewRequestedAt ?? .distantFuture)
}

private func isReadyForReview(_ pullRequest: PullRequest) -> Bool {
    pullRequest.ciState != .failure && !pullRequest.hasConflict
}

/// The latest request addressed to the user, else the latest one (a team the user belongs to).
private func reviewRequestedAt(of node: SearchResponse.Node, login: String) -> Date? {
    let requests = node.timelineItems.nodes
    return (requests.last { $0.requestedReviewer?.login == login } ?? requests.last)?.createdAt
}

private func actionRequiredThenRecentActivity(_ lhs: PullRequest, _ rhs: PullRequest) -> Bool {
    if lhs.actionRequired != rhs.actionRequired { return lhs.actionRequired }
    return lhs.updatedAt > rhs.updatedAt
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

private func lastMessage(of node: SearchResponse.Node) -> Message? {
    let submittedReviews = node.reviews.nodes.filter { $0.state != "PENDING" }
    let comments = node.comments.nodes.map { ($0.author, $0.body, $0.createdAt) }
    let reviews = submittedReviews.compactMap { review in
        review.submittedAt.map { (review.author, review.body, $0) }
    }
    let inlineComments = submittedReviews.flatMap(\.comments.nodes).map { ($0.author, $0.body, $0.createdAt) }

    return (comments + reviews + inlineComments)
        .filter { author, body, _ in author?.__typename != "Bot" && !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .max { $0.2 < $1.2 }
        .map { author, body, date in
            Message(
                author: author?.login ?? "ghost",
                excerpt: body.split(whereSeparator: \.isNewline).joined(separator: " "),
                date: date
            )
        }
}
