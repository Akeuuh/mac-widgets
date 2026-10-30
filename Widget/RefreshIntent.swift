import AppIntents

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Rafraîchir"

    func perform() async throws -> some IntentResult {
        .result()
    }
}
