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
            updatedAt: node.updatedAt
        )
    }
    return WidgetContent(
        login: payload.viewer.login,
        pullRequests: pullRequests.sorted { $0.updatedAt > $1.updatedAt }
    )
}
