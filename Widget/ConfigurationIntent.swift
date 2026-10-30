import AppIntents
import PRCore

enum ScopeOption: String, AppEnum {
    case myPullRequests
    case reviewRequested
    case involved

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Périmètre"
    static var caseDisplayRepresentations: [ScopeOption: DisplayRepresentation] = [
        .myPullRequests: "Mes PR",
        .reviewRequested: "Revues demandées",
        .involved: "Mentionné ou assigné",
    ]

    var scope: Scope {
        switch self {
        case .myPullRequests: .myPullRequests
        case .reviewRequested: .reviewRequested
        case .involved: .involved
        }
    }
}

struct ConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Périmètre"

    @Parameter(title: "Périmètre", default: .myPullRequests)
    var scope: ScopeOption
}
