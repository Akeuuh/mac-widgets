import Testing
import PRCore

@Test func lesPRPersoEtOrganisationsApparaissentEnsemble() throws {
    let content = try content("mes-pr")

    #expect(content.login == "octocat")
    #expect(content.pullRequests.map(\.repository) == ["acme/billing", "octocat/hello-world"])
    #expect(content.pullRequests.first?.number == 481)
    #expect(content.pullRequests.first?.url.absoluteString == "https://github.com/acme/billing/pull/481")
}
