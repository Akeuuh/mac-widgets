import GitHubClient
import SwiftUI
import WidgetKit

struct TokenView: View {
    private static let newTokenURL = URL(string: "https://github.com/settings/tokens/new?scopes=repo,read:org&description=Mac%20Widgets")!

    @State private var token = ""
    @State private var hasStoredToken = TokenStore.read() != nil
    @State private var status: Status?

    private enum Status {
        case testing
        case success(login: String)
        case failure(String)
    }

    var body: some View {
        Form {
            Section {
                SecureField("Token GitHub classic", text: $token, prompt: Text(hasStoredToken ? "Token enregistré" : "ghp_…"))
                HStack {
                    Button("Enregistrer", action: save)
                        .disabled(token.isEmpty)
                    Button("Tester", action: test)
                        .disabled(!hasStoredToken)
                    Button("Supprimer", role: .destructive, action: delete)
                        .disabled(!hasStoredToken)
                }
                statusView
            }
            Section("Scopes requis") {
                Text("`repo` et `read:org`. `repo` est nécessaire pour lire les PR des dépôts privés, mais il donne aussi l'écriture : GitHub n'a pas d'équivalent en lecture seule pour les tokens classic. Le token est rangé dans le Trousseau et n'est envoyé qu'à api.github.com.")
                Link("Créer un token avec ces scopes", destination: Self.newTokenURL)
            }
            Section("Organisations sous SSO") {
                Text("Si une organisation impose le SSO SAML, autorise le token pour elle (Settings → Developer settings → Tokens → Configure SSO). Sinon GitHub omet ses PR sans erreur.")
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
    }

    @ViewBuilder private var statusView: some View {
        switch status {
        case .testing: ProgressView().controlSize(.small)
        case .success(let login): Label("Connecté en tant que \(login)", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
        case .failure(let message): Label(message, systemImage: "xmark.octagon.fill").foregroundStyle(.red)
        case nil: EmptyView()
        }
    }

    private func save() {
        guard TokenStore.save(token.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            status = .failure("Impossible d'écrire dans le Trousseau")
            return
        }
        token = ""
        hasStoredToken = true
        WidgetCenter.shared.reloadAllTimelines()
        test()
    }

    private func test() {
        status = .testing
        Task {
            do {
                status = .success(login: try await GitHubClient.fromKeychain().viewerLogin())
            } catch GitHubError.invalidToken {
                status = .failure("Token invalide")
            } catch {
                status = .failure("GitHub injoignable")
            }
        }
    }

    private func delete() {
        TokenStore.delete()
        hasStoredToken = false
        status = nil
        WidgetCenter.shared.reloadAllTimelines()
    }
}
