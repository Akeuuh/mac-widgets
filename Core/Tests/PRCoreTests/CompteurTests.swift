import Testing
import PRCore

struct Compteur {
    @Test func mesPRCompteLesActionsRequises() throws {
        #expect(try fixture("action-requise", scope: .myPullRequests).counter == 4)
    }

    @Test func mentionneOuAssigneCompteLesActionsRequises() throws {
        #expect(try fixture("mentionne-ou-assigne", scope: .involved).counter == 2)
    }

    @Test func revuesDemandeesCompteToutesLesPR() throws {
        #expect(try fixture("revues-demandees", scope: .reviewRequested).counter == 7)
    }

    @Test func depotCompteToutesLesPR() throws {
        #expect(try fixture("depot", scope: .repository("acme/api")).counter == 4)
    }

    @Test func pastilleRougeSiAuMoinsUnePRALaCIEnEchec() throws {
        #expect(try fixture("action-requise").hasFailingCI)
        #expect(try !fixture("dernier-message").hasFailingCI)
    }
}
