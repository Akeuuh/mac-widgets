import Foundation

public enum Scope: Hashable, Sendable {
    case myPullRequests
    case reviewRequested
    case involved
    case repository(String)

    public var searchQuery: String {
        switch self {
        case .myPullRequests: "is:pr is:open author:@me"
        case .reviewRequested: "is:pr is:open review-requested:@me"
        case .involved: "is:pr is:open involves:@me -author:@me"
        case .repository(let nameWithOwner): "is:pr is:open repo:\(nameWithOwner)"
        }
    }

    public var searchURL: URL {
        if case .repository(let nameWithOwner) = self {
            return URL(string: "https://github.com/\(nameWithOwner)/pulls")!
        }
        var components = URLComponents(string: "https://github.com/pulls")!
        components.queryItems = [URLQueryItem(name: "q", value: searchQuery)]
        return components.url!
    }
}
