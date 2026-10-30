import Testing
import PRCore

struct IndicateursDeLigne {
    let content = try! fixture("indicateurs")

    @Test func etatCIEnSuccesQuandToutesLesVerificationsSontPassees() {
        #expect(content.pullRequest(titled: "CI verte").ciState == .success)
    }

    @Test func etatCIEnEchecQuandUneVerificationAEchoue() {
        #expect(content.pullRequest(titled: "CI rouge").ciState == .failure)
        #expect(content.pullRequest(titled: "Statut rouge").ciState == .failure)
    }

    @Test func etatCIEnCoursQuandUneVerificationTourneSansEchec() {
        #expect(content.pullRequest(titled: "CI en cours").ciState == .pending)
    }

    @Test func unEchecLEmporteSurUneVerificationEnCours() {
        #expect(content.pullRequest(titled: "CI en cours avec un échec").ciState == .failure)
    }

    @Test func etatCIAucuneSansVerification() {
        #expect(content.pullRequest(titled: "Sans CI").ciState == .none)
    }

    @Test func decisionDeReview() {
        #expect(content.pullRequest(titled: "Approuvée").reviewDecision == .approved)
        #expect(content.pullRequest(titled: "Changements demandés").reviewDecision == .changesRequested)
        #expect(content.pullRequest(titled: "CI verte").reviewDecision == .pending)
        #expect(content.pullRequest(titled: "Sans review requise").reviewDecision == .pending)
    }

    @Test func conflitSeulementQuandGitHubRepondEnConflit() {
        #expect(content.pullRequest(titled: "Conflit").hasConflict)
        #expect(!content.pullRequest(titled: "Fusionnabilité inconnue").hasConflict)
        #expect(!content.pullRequest(titled: "CI verte").hasConflict)
    }

    @Test func brouillonAffichePasMasque() {
        #expect(content.pullRequest(titled: "Brouillon").isDraft)
        #expect(content.pullRequests.count == 12)
    }
}
