# Mac Widgets

Widgets natifs macOS pour suivre son activité GitHub d'un coup d'œil, et ouvrir l'élément concerné sur GitHub en un clic.

## Language

**Widget**:
Une vue posée sur le bureau ou dans le Centre de notifications, en lecture seule, configurée avec exactement un Périmètre ; cliquer une ligne ouvre l'élément sur GitHub.
_Avoid_: App, panneau, dashboard

**Compte**:
L'unique compte GitHub.com de l'utilisateur, qui couvre aussi bien ses dépôts perso que ceux de ses organisations de travail.
_Avoid_: Profil, utilisateur

**Pull Request (PR)**:
Une pull request GitHub ouverte, visible par le Compte.

**État CI**:
Le verdict agrégé de toutes les vérifications du dernier commit d'une PR : *Succès*, *Échec* (au moins une vérification échouée), *En cours*, ou *Aucune*.
_Avoid_: Build, status, checks

**Décision de review**:
Le verdict des relecteurs sur une PR : *Approuvée*, *Changements demandés*, ou *En attente*.

**Conflit**:
Une PR qui ne peut pas être fusionnée en l'état parce que sa branche est en conflit avec la branche cible.

**Dernier message**:
Le commentaire, la review ou le commentaire inline le plus récent sur une PR, écrit par un humain (les bots sont exclus).
_Avoid_: Notification, activité

**Action requise**:
Une PR qui attend quelque chose de l'utilisateur ; elle est affichée avant les autres. Pour *Mes PR* : État CI en Échec, Changements demandés, Conflit, ou Dernier message écrit par quelqu'un d'autre (une approbation sans texte ne compte pas). Pour *Mentionné ou assigné* : Dernier message écrit par quelqu'un d'autre. Sans objet pour *Revues demandées* (tout y attend l'utilisateur) et *Dépôt*.
_Avoid_: Urgent, prioritaire, à traiter

**Brouillon**:
Une PR marquée *draft* ; elle est affichée, mais atténuée.

**Périmètre**:
Une règle de sélection des PR à afficher : *Mes PR* (auteur), *Revues demandées* (l'utilisateur figure encore parmi les relecteurs demandés), *Mentionné ou assigné*, ou *Dépôt* (toutes les PR d'un dépôt donné).
_Avoid_: Filtre, liste, query
