import Foundation

public enum Scope: Hashable, Sendable {
    case myPullRequests
    case reviewRequested
    case involved

    public var searchQuery: String {
        switch self {
        case .myPullRequests: "is:pr is:open author:@me"
        case .reviewRequested: "is:pr is:open review-requested:@me"
        case .involved: "is:pr is:open involves:@me -author:@me"
        }
    }

    public var searchURL: URL {
        var components = URLComponents(string: "https://github.com/pulls")!
        components.queryItems = [URLQueryItem(name: "q", value: searchQuery)]
        return components.url!
    }
}
