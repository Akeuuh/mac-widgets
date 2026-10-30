import Foundation

public enum Scope: Hashable, Sendable {
    case myPullRequests

    public var searchQuery: String {
        switch self {
        case .myPullRequests: "is:pr is:open author:@me"
        }
    }
}
