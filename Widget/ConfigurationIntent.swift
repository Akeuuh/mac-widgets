import AppIntents
import GitHubClient
import PRCore

enum ScopeOption: String, AppEnum {
    case myPullRequests
    case reviewRequested
    case involved
    case repository

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Périmètre"
    static var caseDisplayRepresentations: [ScopeOption: DisplayRepresentation] = [
        .myPullRequests: "Mes PR",
        .reviewRequested: "Revues demandées",
        .involved: "Mentionné ou assigné",
        .repository: "Dépôt",
    ]
}

struct RepositoryEntity: AppEntity {
    let id: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Dépôt"
    static var defaultQuery = RepositoryQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
}

struct RepositoryQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [RepositoryEntity] {
        identifiers.map(RepositoryEntity.init)
    }

    func entities(matching string: String) async throws -> [RepositoryEntity] {
        try await suggestedEntities().filter { $0.id.localizedCaseInsensitiveContains(string) }
    }

    func suggestedEntities() async throws -> [RepositoryEntity] {
        try await GitHubClient.fromKeychain().repositories().map(RepositoryEntity.init)
    }
}

struct ConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Périmètre"

    @Parameter(title: "Périmètre", default: .myPullRequests)
    var scope: ScopeOption

    @Parameter(title: "Dépôt")
    var repository: RepositoryEntity?

    static var parameterSummary: some ParameterSummary {
        When(\ConfigurationIntent.$scope, .equalTo, ScopeOption.repository) {
            Summary {
                \.$scope
                \.$repository
            }
        } otherwise: {
            Summary {
                \.$scope
            }
        }
    }

    /// `nil` while the Dépôt Périmètre has no repository chosen yet.
    var resolvedScope: Scope? {
        switch scope {
        case .myPullRequests: .myPullRequests
        case .reviewRequested: .reviewRequested
        case .involved: .involved
        case .repository: repository.map { .repository($0.id) }
        }
    }
}
