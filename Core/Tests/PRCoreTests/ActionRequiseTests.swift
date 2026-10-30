import Foundation
import Testing
import PRCore

struct ActionRequiseMesPR {
    let content = try! fixture("action-requise")

    @Test(arguments: ["CI en échec", "Changements demandés", "Conflit", "Message d'un relecteur"])
    func declencheursDActionRequise(title: String) {
        #expect(content.pullRequest(titled: title).actionRequired)
    }

    @Test func uneApprobationSansTexteNeRendPasLaPRActionRequise() {
        #expect(!content.pullRequest(titled: "Approbation sans texte").actionRequired)
    }

    @Test func unDernierMessageEcritParLUtilisateurNeRendPasLaPRActionRequise() {
        #expect(!content.pullRequest(titled: "Mon propre message").actionRequired)
        #expect(!content.pullRequest(titled: "Rien à faire").actionRequired)
    }

    @Test func actionRequiseDAbordPuisActiviteRecente() {
        #expect(content.pullRequests.map(\.title) == [
            "Message d'un relecteur",
            "Conflit",
            "Changements demandés",
            "CI en échec",
            "Approbation sans texte",
            "Mon propre message",
            "Rien à faire",
            "Ancienne PR calme",
        ])
    }

    @Test func plusNAutresCompteLesPRNonAffichees() {
        #expect(content.hiddenCount(showing: 3) == 5)
        #expect(content.hiddenCount(showing: 10) == 0)
    }

    @Test func plusNAutresOuvreLaRechercheGitHubDuPerimetre() {
        #expect(content.searchURL.absoluteString == "https://github.com/pulls?q=is:pr%20is:open%20author:@me")
    }
}
