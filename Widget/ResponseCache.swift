import Foundation
import PRCore

enum ResponseCache {
    private struct Cached: Codable {
        let response: Data
        let date: Date
    }

    static func save(_ response: Data, for scope: Scope) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(Cached(response: response, date: .now)), forKey: key(scope))
    }

    static func load(for scope: Scope) -> (response: Data, date: Date)? {
        guard let data = UserDefaults.standard.data(forKey: key(scope)),
              let cached = try? PropertyListDecoder().decode(Cached.self, from: data) else { return nil }
        return (cached.response, cached.date)
    }

    private static func key(_ scope: Scope) -> String {
        "response:\(scope.searchQuery)"
    }
}
