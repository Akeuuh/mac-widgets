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

    public func search(_ scope: Scope) async throws -> Data {
        try await graphQL(Self.searchQuery, variables: ["query": scope.searchQuery])
    }

    private func graphQL(_ query: String, variables: [String: String]) async throws -> Data {
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
            repository { nameWithOwner }
          }
        }
      }
    }
    """
}
