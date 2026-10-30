import Foundation

struct SearchResponse: Decodable {
    let data: Payload

    struct Payload: Decodable {
        let viewer: Viewer
        let search: Search
    }

    struct Viewer: Decodable {
        let login: String
    }

    struct Search: Decodable {
        let issueCount: Int
        let nodes: [Node]
    }

    struct Node: Decodable {
        let number: Int
        let title: String
        let url: URL
        let updatedAt: Date
        let repository: Repository
    }

    struct Repository: Decodable {
        let nameWithOwner: String
    }
}
