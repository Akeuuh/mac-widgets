import Foundation

public enum CIState: Sendable {
    case success, failure, pending, none
}

public enum ReviewDecision: Sendable {
    case approved, changesRequested, pending
}

public struct Message: Equatable, Sendable {
    public let author: String
    public let excerpt: String
    public let date: Date

    public init(author: String, excerpt: String, date: Date) {
        self.author = author
        self.excerpt = excerpt
        self.date = date
    }
}

public struct PullRequest: Equatable, Sendable {
    public let repository: String
    public let number: Int
    public let title: String
    public let url: URL
    public let updatedAt: Date
    public let ciState: CIState
    public let reviewDecision: ReviewDecision
    public let hasConflict: Bool
    public let isDraft: Bool
    public let lastMessage: Message?

    public init(
        repository: String,
        number: Int,
        title: String,
        url: URL,
        updatedAt: Date,
        ciState: CIState,
        reviewDecision: ReviewDecision,
        hasConflict: Bool,
        isDraft: Bool,
        lastMessage: Message?
    ) {
        self.repository = repository
        self.number = number
        self.title = title
        self.url = url
        self.updatedAt = updatedAt
        self.ciState = ciState
        self.reviewDecision = reviewDecision
        self.hasConflict = hasConflict
        self.isDraft = isDraft
        self.lastMessage = lastMessage
    }
}

public struct WidgetContent: Equatable, Sendable {
    public let login: String
    public let pullRequests: [PullRequest]

    public init(login: String, pullRequests: [PullRequest]) {
        self.login = login
        self.pullRequests = pullRequests
    }
}
