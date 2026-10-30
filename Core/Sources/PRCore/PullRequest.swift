import Foundation

public struct PullRequest: Equatable, Sendable {
    public let repository: String
    public let number: Int
    public let title: String
    public let url: URL
    public let updatedAt: Date

    public init(repository: String, number: Int, title: String, url: URL, updatedAt: Date) {
        self.repository = repository
        self.number = number
        self.title = title
        self.url = url
        self.updatedAt = updatedAt
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
