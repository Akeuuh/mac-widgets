import Testing
import PRCore

struct RevuesDemandees {
    let content = try! fixture("revues-demandees", scope: .reviewRequested)

    @Test func laPlusAncienneAttenteEnHautEtLesPRNonPretesEnDernier() {
        #expect(content.pullRequests.map(\.title) == [
            "Demandée il y a longtemps",
            "Demandée à une équipe",
            "Demandée hier",
            "Redemandée après une première review",
            "Demandée récemment",
            "Ancienne mais CI rouge",
            "Ancienne mais en conflit",
        ])
    }

    @Test func aucuneActionRequise() {
        #expect(content.pullRequests.allSatisfy { !$0.actionRequired })
    }

    @Test func plusNAutresOuvreLaRechercheDesRevuesDemandees() {
        #expect(content.searchURL.absoluteString == "https://github.com/pulls?q=is:pr%20is:open%20review-requested:@me")
    }
}

struct MentionneOuAssigne {
    let content = try! fixture("mentionne-ou-assigne", scope: .involved)

    @Test func actionRequiseQuandLeDernierMessageVientDeQuelquUnDAutre() {
        #expect(content.pullRequest(titled: "Question d'un collègue").actionRequired)
        #expect(content.pullRequest(titled: "Review d'un collègue").actionRequired)
        #expect(!content.pullRequest(titled: "J'ai répondu").actionRequired)
    }

    @Test func laCIEtLesChangementsDemandesNeRendentPasActionRequise() {
        #expect(!content.pullRequest(titled: "CI rouge sans message").actionRequired)
        #expect(!content.pullRequest(titled: "Changements demandés sans message").actionRequired)
    }

    @Test func actionRequiseDAbordPuisActiviteRecente() {
        #expect(content.pullRequests.map(\.title) == [
            "Question d'un collègue",
            "Review d'un collègue",
            "J'ai répondu",
            "CI rouge sans message",
            "Changements demandés sans message",
        ])
    }

    @Test func plusNAutresOuvreLaRechercheDuPerimetre() {
        #expect(content.searchURL.absoluteString == "https://github.com/pulls?q=is:pr%20is:open%20involves:@me%20-author:@me")
    }
}

struct Depot {
    let content = try! fixture("depot", scope: .repository("acme/api"))

    @Test func toutesLesPRParActiviteRecenteSansActionRequise() {
        #expect(content.pullRequests.map(\.number) == [303, 301, 302, 304])
        #expect(content.pullRequests.allSatisfy { !$0.actionRequired })
    }

    @Test func plusNAutresOuvreLesPRDuDepot() {
        #expect(content.searchURL.absoluteString == "https://github.com/acme/api/pulls")
    }
}
