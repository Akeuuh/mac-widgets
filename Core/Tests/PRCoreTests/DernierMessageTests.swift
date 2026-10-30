import Foundation
import Testing
import PRCore

struct DernierMessage {
    let content = try! fixture("dernier-message")

    @Test func messageHumainAvecAuteurExtraitEtDate() {
        let message = content.pullRequest(titled: "Message humain").lastMessage
        #expect(message?.author == "alice")
        #expect(message?.excerpt == "Tu peux regarder le cas des remises ?")
        #expect(message?.date == ISO8601DateFormatter().date(from: "2026-10-29T09:00:00Z"))
    }

    @Test func unMessageDeBotSeulNeDonnePasDeDernierMessage() {
        #expect(content.pullRequest(titled: "Message de bot seul").lastMessage == nil)
    }

    @Test func lesBotsSontIgnoresMemePlusRecents() {
        #expect(content.pullRequest(titled: "Bot plus récent qu'un humain").lastMessage?.author == "alice")
    }

    @Test func uneApprobationSansTexteNEstPasUnMessage() {
        #expect(content.pullRequest(titled: "Approbation sans texte").lastMessage == nil)
    }

    @Test func unCommentaireInlinePlusRecentLEmporteSurUnCommentaire() {
        let message = content.pullRequest(titled: "Commentaire inline plus récent").lastMessage
        #expect(message?.author == "bob")
        #expect(message?.excerpt == "Ce nom de variable prête à confusion")
    }

    @Test func uneReviewAvecTexteEstUnMessage() {
        #expect(content.pullRequest(titled: "Review avec texte").lastMessage?.excerpt == "Il manque les tests")
    }

    @Test func uneReviewEnCoursDeRedactionNEstPasUnMessage() {
        #expect(content.pullRequest(titled: "Review en attente de l'utilisateur").lastMessage?.author == "alice")
    }
}
