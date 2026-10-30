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
        let isDraft: Bool
        let mergeable: String
        let reviewDecision: String?
        let repository: Repository
        let commits: Commits
    }

    struct Repository: Decodable {
        let nameWithOwner: String
    }

    struct Commits: Decodable {
        let nodes: [CommitNode]
    }

    struct CommitNode: Decodable {
        let commit: Commit
    }

    struct Commit: Decodable {
        let statusCheckRollup: Rollup?
    }

    struct Rollup: Decodable {
        let contexts: Contexts
    }

    struct Contexts: Decodable {
        let nodes: [Check]
    }

    /// A `CheckRun` has `status` and `conclusion`; a `StatusContext` has `state`.
    struct Check: Decodable {
        let status: String?
        let conclusion: String?
        let state: String?
    }
}
