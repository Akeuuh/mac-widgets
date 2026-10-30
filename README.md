# Mac Widgets

Des utilitaires macOS natifs, sous forme de Widgets (bureau et Centre de notifications).

## Pull requests GitHub

Voir d'un coup d'œil où en sont tes pull requests GitHub, et ouvrir une PR en un clic. Chaque Widget affiche les PR d'un **Périmètre** :

- **Mes PR** : celles dont tu es l'auteur.
- **Revues demandées** : celles où ta review est encore attendue, la plus ancienne demande en haut.
- **Mentionné ou assigné** : celles où l'on t'implique.
- **Dépôt** : toutes les PR ouvertes d'un dépôt choisi dans une liste.

Sur chaque ligne : l'**État CI** (pastille verte, rouge, jaune ou grise), la **Décision de review**, un indicateur de **Conflit**, les **Brouillons** atténués et, en grande taille, un aperçu du **Dernier message** (bots exclus). Les PR qui attendent quelque chose de toi (**Action requise**) remontent en haut. Le petit Widget affiche un compteur et une pastille rouge si une CI est en échec.

Les Widgets se rafraîchissent d'eux-mêmes (environ toutes les 15 minutes, selon macOS) ; le bouton ↻ force un rafraîchissement. Hors ligne, les dernières données restent affichées avec l'horodatage en orange.

Vocabulaire complet : [CONTEXT.md](CONTEXT.md).

## Installation

macOS 14 (Sonoma) ou plus récent.

```bash
brew install --cask akeuuh/tap/mac-widgets
```

Ou télécharge le DMG notarisé depuis les [Releases](https://github.com/Akeuuh/mac-widgets/releases).

Ensuite : ouvre **Mac Widgets**, enregistre ton token, puis clic droit sur le bureau → **Modifier les widgets** → **Mac Widgets**. Clic droit sur un Widget → **Modifier le widget** pour choisir son Périmètre.

## Le token GitHub

L'app utilise un token GitHub **classic** avec les scopes `repo` et `read:org` ([créer le token pré-rempli](https://github.com/settings/tokens/new?scopes=repo,read:org&description=Mac%20Widgets)).

- **Pourquoi `repo`** : c'est le seul scope classic qui donne accès aux PR des dépôts privés. Il donne aussi l'**écriture** sur ces dépôts ; GitHub n'a pas d'équivalent en lecture seule. L'app ne fait que lire, et le code est public pour que tu puisses le vérifier.
- **Pourquoi `read:org`** : pour lister les dépôts de tes organisations dans le Périmètre *Dépôt*.
- **Pourquoi un token classic** : un token fine-grained ne couvre qu'un seul propriétaire (ton compte *ou* une organisation), et une OAuth App doit être approuvée par chaque organisation. Voir [ADR 0002](docs/adr/0002-token-classic-plutot-que-fine-grained-ou-oauth.md).

Le token est rangé dans le **Trousseau** du Mac, partagé entre l'app et l'extension Widget, et n'est envoyé qu'à `api.github.com` (voir [`GitHubClient.swift`](Core/Sources/GitHubClient/GitHubClient.swift) et [`TokenStore.swift`](Core/Sources/GitHubClient/TokenStore.swift)).

### Organisations sous SSO SAML

Si une organisation impose le SSO, autorise le token pour elle : **Settings → Developer settings → Personal access tokens → Configure SSO → Authorize**. Sans ça, GitHub omet ses PR **sans erreur**.

## Développement

```bash
brew install xcodegen
```

```bash
xcodegen generate && open MacWidgets.xcodeproj
```

Les règles métier vivent dans le package [`Core`](Core) (module `PRCore`, sans WidgetKit ni réseau) et sont testées sur des fixtures JSON :

```bash
cd Core && swift test
```

Le partage du Trousseau entre l'app et l'extension exige une build signée avec une équipe de développement (`DEVELOPMENT_TEAM` dans [`project.yml`](project.yml)).

## Publier une version

```bash
scripts/release.sh 0.1.0
```

Le script archive, signe Developer ID, crée le DMG, le notarise et l'agrafe, puis affiche le SHA-256 pour le cask ([modèle](docs/homebrew/mac-widgets.rb)) à copier dans le tap `Akeuuh/homebrew-tap`.

## Licence

[MIT](LICENSE)
