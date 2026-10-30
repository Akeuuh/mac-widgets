import Foundation

public enum Scope: Hashable, Sendable {
    case myPullRequests

    public var searchQuery: String {
        switch self {
        case .myPullRequests: "is:pr is:open author:@me"
        }
    }

    public var searchURL: URL {
        var components = URLComponents(string: "https://github.com/pulls")!
        components.queryItems = [URLQueryItem(name: "q", value: searchQuery)]
        return components.url!
    }
}
