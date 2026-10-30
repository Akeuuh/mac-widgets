# Token GitHub classic plutôt que fine-grained ou OAuth

L'utilisateur colle un token GitHub *classic* (scopes `repo` et `read:org`), stocké dans le Trousseau du Mac et envoyé uniquement à `api.github.com`. C'est le seul mode qui couvre avec un seul token les dépôts perso et ceux de plusieurs organisations, y compris sous SSO SAML, sans dépendre d'un administrateur d'organisation.

## Considered Options

- **Token fine-grained** : rejeté, il est limité à un seul propriétaire de ressources (le compte *ou* une organisation), il en faudrait un par organisation.
- **OAuth App (device flow)** : rejeté, chaque organisation qui restreint les apps tierces doit l'approuver, ce qui bloque l'usage au travail.

## Consequences

- `repo` donne lecture *et* écriture sur tous les dépôts privés ; il n'existe pas d'équivalent classic en lecture seule. C'est pour ça que le code est public et que l'app l'explique au moment de coller le token.
- Les PR d'une organisation sous SSO n'apparaissent que si l'utilisateur a autorisé le token pour elle ; GitHub les omet sans erreur, donc l'app le documente au lieu de le détecter.
