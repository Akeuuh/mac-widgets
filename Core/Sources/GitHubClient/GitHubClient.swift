import Foundation
import PRCore

public enum GitHubError: Error, Equatable {
    case missingToken
    case invalidToken
    case unavailable
}

public struct GitHubClient: Sendable {
    private static let endpoint = URL(string: "https://api.github.com/graphql")!

    private let token: String

    public init(token: String) {
        self.token = token
    }

    public static func fromKeychain() throws -> GitHubClient {
        guard let token = TokenStore.read() else { throw GitHubError.missingToken }
        return GitHubClient(token: token)
    }

    public func viewerLogin() async throws -> String {
        struct Response: Decodable {
            struct Payload: Decodable { struct Viewer: Decodable { let login: String }; let viewer: Viewer }
            let data: Payload
        }
        let data = try await graphQL("query { viewer { login } }", variables: [:])
        return try JSONDecoder().decode(Response.self, from: data).data.viewer.login
    }

    /// Every repository the token can read, personal and from organizations, most recently pushed first.
    public func repositories() async throws -> [String] {
        struct Response: Decodable {
            struct Payload: Decodable { let viewer: Viewer }
            struct Viewer: Decodable { let repositories: Repositories }
            struct Repositories: Decodable { let nodes: [Repository]; let pageInfo: PageInfo }
            struct Repository: Decodable { let nameWithOwner: String }
            struct PageInfo: Decodable { let hasNextPage: Bool; let endCursor: String? }
            let data: Payload
        }
        var names: [String] = []
        var cursor: String?
        repeat {
            let data = try await graphQL(Self.repositoriesQuery, variables: ["after": cursor.map { $0 as Any } ?? NSNull()])
            let repositories = try JSONDecoder().decode(Response.self, from: data).data.viewer.repositories
            names += repositories.nodes.map(\.nameWithOwner)
            cursor = repositories.pageInfo.hasNextPage ? repositories.pageInfo.endCursor : nil
        } while cursor != nil
        return names
    }

    public func search(_ scope: Scope) async throws -> Data {
        try await graphQL(Self.searchQuery, variables: ["query": scope.searchQuery])
    }

    private func graphQL(_ query: String, variables: [String: Any]) async throws -> Data {
        var request = URLRequest(url: Self.endpoint)
        request.httpMethod = "POST"
        request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query, "variables": variables])

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GitHubError.unavailable
        }
        switch (response as? HTTPURLResponse)?.statusCode {
        case 200: return data
        case 401: throw GitHubError.invalidToken
        default: throw GitHubError.unavailable
        }
    }

    private static let repositoriesQuery = """
    query($after: String) {
      viewer {
        repositories(first: 100, after: $after, affiliations: [OWNER, COLLABORATOR, ORGANIZATION_MEMBER],
                     ownerAffiliations: [OWNER, COLLABORATOR, ORGANIZATION_MEMBER],
                     orderBy: {field: PUSHED_AT, direction: DESC}) {
          nodes { nameWithOwner }
          pageInfo { hasNextPage endCursor }
        }
      }
    }
    """

    private static let searchQuery = """
    query($query: String!) {
      viewer { login }
      search(query: $query, type: ISSUE, first: 50) {
        issueCount
        nodes {
          ... on PullRequest {
            number
            title
            url
            updatedAt
            isDraft
            mergeable
            reviewDecision
            repository { nameWithOwner }
            comments(last: 10) {
              nodes { author { __typename login } body createdAt }
            }
            reviews(last: 10) {
              nodes {
                author { __typename login }
                body
                state
                submittedAt
                comments(last: 10) {
                  nodes { author { __typename login } body createdAt }
                }
              }
            }
            timelineItems(itemTypes: [REVIEW_REQUESTED_EVENT], last: 20) {
              nodes {
                ... on ReviewRequestedEvent {
                  createdAt
                  requestedReviewer { ... on User { login } }
                }
              }
            }
            commits(last: 1) {
              nodes {
                commit {
                  statusCheckRollup {
                    contexts(first: 100) {
                      nodes {
                        ... on CheckRun { status conclusion }
                        ... on StatusContext { state }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """
}
