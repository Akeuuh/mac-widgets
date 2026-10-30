# WidgetKit plutôt qu'une app de barre de menus

On veut voir d'un coup d'œil l'état de ses PR, posé sur le bureau, et ouvrir une PR sur GitHub en un clic. On a choisi des widgets WidgetKit natifs plutôt qu'un popover de barre de menus ou des widgets HTML tiers (Übersicht), parce qu'ils sont natifs, toujours visibles et sans process permanent.

## Consequences

- Pas de lecture des fils de discussion : un Widget ne scrolle pas, il ne montre qu'un aperçu du Dernier message ; la lecture se fait sur GitHub.
- Pas de temps réel : le système décide des rafraîchissements (~15 min au mieux). On compense par un bouton ↻ et un horodatage, pas par une app de fond qui interrogerait GitHub en continu.
- Si un jour le besoin de lire ou d'agir sur les PR depuis le Mac devient central, c'est cette décision qu'il faut rouvrir, pas contourner.
