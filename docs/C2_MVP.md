# C2 – Définition détaillée du MVP (version proposée, à valider)
Date : 14 octobre 2026
Référence : C1 – Cadrage du projet (12 octobre 2026)

## 1. Objectif du MVP
Livrer d'ici le 18 octobre 2026 un lecteur de musique locale **complet, fiable et hors ligne**, utilisable au quotidien sur le Tecno Pop 9. L'application doit aussi permettre de **corriger à la main les tags** d'un morceau. Le MVP n'utilise pas Internet du tout.

Le MVP est réussi si l'utilisateur peut remplacer son lecteur actuel pendant une journée complète sans revenir en arrière, et peut corriger un fichier mal tagué sans ordinateur.

## 2. Méthode de priorisation
- **P0 – Indispensable** : sans cette fonctionnalité, le MVP n'est pas livrable.
- **P1 – Important** : à faire si les P0 sont terminés et testés.
- **P2 – Bonus** : seulement s'il reste du temps, sinon repoussé en V1.1.
- **Hors MVP** : explicitement exclu, même si l'écran existe dans le prototype.

## 3. Périmètre fonctionnel

### 3.1 Accès à la musique et bibliothèque
| ID | Fonctionnalité | Priorité | Écran prototype |
|---|---|---|---|
| F01 | Demande d'autorisation d'accès aux fichiers audio, avec explication et gestion du refus | P0 | 02 Music Permission |
| F02 | Analyse (scan) des fichiers MP3, FLAC et M4A du téléphone et lecture de leurs tags | P0 | 03 Home |
| F03 | Bibliothèque par **Titres** | P0 | 04 Songs |
| F04 | Bibliothèque par **Artistes**, avec la liste de leurs albums et titres | P0 | 06 Artists |
| F05 | Bibliothèque par **Albums**, avec la pochette et les titres dans l'ordre des pistes | P0 | 05 Albums |
| F06 | Bibliothèque par **Genres** | P0 | 07 Genres |
| F07 | Recherche instantanée dans les titres, artistes et albums | P0 | 09 Search, 10 Results |
| F08 | Nouveau scan manuel de la bibliothèque | P1 | 03 Home (Rescan) |
| F09 | Tri des listes (A→Z, date d'ajout, artiste) | P1 | 04 Songs (Sort) |
| F10 | Accueil avec « Ajoutés récemment » et « Écoutés récemment » | P1 | 03 Home |
| F11 | Navigation par **Dossiers** | P2 | 08 Folders |

### 3.2 Lecture
| ID | Fonctionnalité | Priorité | Écran prototype |
|---|---|---|---|
| F20 | Lecture / pause | P0 | 11 Full Player |
| F21 | Morceau suivant / précédent (le bouton précédent revient au début du morceau après 3 s de lecture) | P0 | 11 |
| F22 | Barre de progression avec déplacement manuel (seek), temps écoulé et durée | P0 | 11 |
| F23 | Lecture aléatoire (activée / désactivée) | P0 | 11 |
| F24 | Répétition : désactivée → toute la file → un seul morceau | P0 | 11 |
| F25 | Mini-lecteur visible au-dessus de la navigation, qui ouvre le lecteur complet | P0 | 03 Home |
| F26 | Lecture en arrière-plan (application fermée ou écran éteint) | P0 | – |
| F27 | Contrôles dans la notification et sur l'écran de verrouillage (lecture/pause, suivant, précédent, pochette, titre) | P0 | – |
| F28 | Pause automatique quand le casque ou l'écouteur Bluetooth est débranché, et pendant un appel | P0 | – |
| F29 | Reprise de la dernière file d'attente et de la position au redémarrage de l'application | P1 | – |

### 3.3 File d'attente
| ID | Fonctionnalité | Priorité | Écran prototype |
|---|---|---|---|
| F30 | Afficher la file d'attente avec le morceau en cours | P0 | 12 Queue |
| F31 | « Lire ensuite » et « Ajouter à la file » depuis n'importe quel morceau | P0 | 30 Context Menu |
| F32 | Retirer un morceau de la file | P0 | 12 Queue |
| F33 | Réordonner la file par glisser-déposer | P1 | 12 Queue |
| F34 | Vider la file | P1 | 12 Queue |

### 3.4 Playlists et collections
| ID | Fonctionnalité | Priorité | Écran prototype |
|---|---|---|---|
| F40 | Créer une playlist (nom obligatoire) | P0 | 14 Create Playlist |
| F41 | Ajouter un ou plusieurs morceaux à une playlist | P0 | 30 Context Menu |
| F42 | Lire une playlist, retirer un morceau d'une playlist | P0 | 15 Playlist Detail |
| F43 | Renommer et supprimer une playlist (avec confirmation) | P0 | 13 Playlists |
| F44 | Réordonner les morceaux d'une playlist | P1 | 15 Playlist Detail |
| F45 | Favoris (cœur) et liste des favoris | P0 | 16 Favorites |
| F46 | Historique de lecture | P2 | 17 History |

### 3.5 Édition des tags
| ID | Fonctionnalité | Priorité | Écran prototype |
|---|---|---|---|
| F50 | Fiche d'un morceau : tags, format, débit, durée, taille, emplacement | P0 | 18 Song Details |
| F51 | Modifier **titre, artiste, album, genre, année** | P0 | 19 Metadata Editor |
| F52 | Remplacer ou supprimer la **pochette** à partir d'une image de la galerie | P0 | 21 Artwork Selection |
| F53 | Écrire les modifications **dans le fichier audio** (MP3, FLAC, M4A) et mettre la bibliothèque à jour | P0 | 19 |
| F54 | Modifier le numéro de piste et l'artiste de l'album | P1 | 19 |
| F55 | Annuler les modifications avant d'enregistrer, avec un avertissement si l'utilisateur quitte sans enregistrer | P1 | 19 |

### 3.6 Langues, apparence et réglages
| ID | Fonctionnalité | Priorité | Écran prototype |
|---|---|---|---|
| F60 | Interface en **français, anglais, espagnol**, qui suit la langue du téléphone | P0 | – |
| F61 | Choisir la langue dans les réglages | P0 | 25 Settings |
| F62 | Thème sombre « Lyra Night » (thème par défaut) | P0 | 26 Themes |
| F63 | Thème clair « Daylight » et mode automatique | P1 | 26 Themes |
| F64 | Thèmes supplémentaires : Graphite, Amber Room, Bloom | P2 | 26 Themes |
| F65 | États vides et messages d'erreur clairs | P0 | 28 Empty, 29 Errors |

### 3.7 Hors MVP (décision de périmètre)
| Élément | Présent dans le prototype | Reporté à |
|---|---|---|
| Enrichissement en ligne, tagging automatique | 20 Enrichment | V1.1 |
| Pochettes suggérées depuis Internet | 21 (partie « Suggested ») | V1.1 |
| Édition des tags en lot | – | V1.1 |
| Fiches artistes (photo, biographie) | – | V1.1 |
| Paroles | 22 Lyrics | V2 |
| Égaliseur | 23 Equalizer | Backlog (à positionner) |
| Réglages audio avancés, vitesse de lecture | 24 Audio Settings | Backlog |
| Navigation par compositeur et par année | 03 Home | Backlog |
| Écran « Hors ligne » | 27 Offline | Inutile au MVP (aucune fonction réseau) |

## 4. Critères d'acceptation (P0)
Format : **Étant donné** une situation, **quand** l'utilisateur fait une action, **alors** il observe un résultat.

### Accès et bibliothèque
- **CA-01 (F01)** Au premier lancement, quand l'utilisateur ouvre l'application, alors un écran explique pourquoi l'accès est nécessaire avant la demande système.
- **CA-02 (F01)** Quand l'utilisateur refuse l'accès, alors l'application affiche un écran avec un bouton « Ouvrir les réglages du téléphone » et ne plante pas.
- **CA-03 (F02)** Quand le scan se termine, alors tous les fichiers MP3, FLAC et M4A du téléphone apparaissent. Les sonneries, notifications et enregistrements vocaux n'apparaissent pas.
- **CA-04 (F02)** Étant donné un fichier sans tags, alors il apparaît avec le nom du fichier comme titre, « Artiste inconnu » et « Album inconnu ».
- **CA-05 (F02)** Étant donné un fichier corrompu ou illisible, alors il est ignoré sans bloquer le scan des autres fichiers.
- **CA-06 (F03–F06)** Dans chaque onglet, la liste défile de façon fluide, même avec 1 000 morceaux.
- **CA-07 (F05)** Quand l'utilisateur ouvre un album, alors les titres sont classés par numéro de piste, ou par nom si le numéro est absent.
- **CA-08 (F07)** Quand l'utilisateur tape au moins 1 caractère, alors les résultats s'affichent en moins de 300 ms, regroupés par Titres, Artistes et Albums. La recherche ignore les majuscules et les accents (« beyonce » trouve « Beyoncé »).

### Lecture
- **CA-10 (F20)** Quand l'utilisateur touche un morceau dans une liste, alors la lecture démarre en moins d'une seconde. La file d'attente contient la liste entière, à partir du morceau touché.
- **CA-11 (F21)** Quand l'utilisateur appuie sur « Précédent » après plus de 3 s de lecture, alors le morceau recommence. Avant 3 s, le morceau précédent démarre.
- **CA-12 (F22)** Quand l'utilisateur fait glisser la barre de progression, alors la lecture reprend à la position choisie.
- **CA-13 (F23)** Quand l'aléatoire est activé, alors le morceau en cours continue et les suivants sont mélangés sans doublon. Quand il est désactivé, alors l'ordre d'origine revient.
- **CA-14 (F24)** En mode « répéter un », quand le morceau se termine, alors il recommence. En mode « répéter tout », la file reprend au début. En mode désactivé, la lecture s'arrête après le dernier morceau.
- **CA-15 (F26)** Quand l'écran est éteint ou l'application est en arrière-plan, alors la lecture continue pendant au moins 1 heure sans interruption, y compris sur le Tecno Pop 9.
- **CA-16 (F27)** Pendant la lecture, la notification et l'écran de verrouillage affichent la pochette, le titre et l'artiste. Les boutons lecture/pause, suivant et précédent fonctionnent.
- **CA-17 (F28)** Quand le casque est débranché, alors la lecture se met en pause. Quand un appel arrive, alors elle se met en pause.

### File d'attente et playlists
- **CA-20 (F31)** Quand l'utilisateur choisit « Lire ensuite », alors le morceau est placé juste après le morceau en cours et un message de confirmation s'affiche.
- **CA-21 (F32)** Quand l'utilisateur retire un morceau de la file, alors il disparaît sans interrompre la lecture en cours.
- **CA-22 (F40)** Quand l'utilisateur crée une playlist sans nom, alors le bouton « Créer » reste désactivé.
- **CA-23 (F40–F43)** Les playlists sont conservées après la fermeture et le redémarrage de l'application.
- **CA-24 (F43)** Quand l'utilisateur supprime une playlist, alors une confirmation est demandée. Les fichiers audio ne sont jamais supprimés.

### Édition des tags
- **CA-30 (F51)** Quand l'utilisateur modifie un tag et enregistre, alors la nouvelle valeur apparaît immédiatement partout : listes, lecteur, notification.
- **CA-31 (F53)** Après l'enregistrement, le tag modifié est visible dans un autre lecteur ou sur un ordinateur (vérification avec Mp3tag), pour chacun des 3 formats.
- **CA-32 (F53)** Quand l'écriture échoue (fichier protégé, carte SD en lecture seule, permission refusée), alors un message clair s'affiche et **le fichier d'origine reste intact et lisible**.
- **CA-33 (F51)** Le champ année n'accepte que 4 chiffres. Les autres champs acceptent les accents et les caractères non latins.
- **CA-34 (F52)** Quand l'utilisateur choisit une image dans la galerie, alors elle est enregistrée comme pochette dans le fichier et s'affiche dans les listes et la notification.
- **CA-35 (F53)** Quand le morceau modifié est en cours de lecture, alors la lecture n'est pas interrompue, ou reprend au même endroit.

### Langues et interface
- **CA-40 (F60)** Étant donné un téléphone réglé en espagnol, alors l'application s'affiche en espagnol. Pour une langue non prise en charge, elle s'affiche en anglais.
- **CA-41 (F60)** Aucun texte de l'interface n'est écrit en dur dans le code : tous les textes passent par les fichiers de traduction, pour qu'on puisse ajouter une langue plus tard.
- **CA-42 (F61)** Quand l'utilisateur change de langue dans les réglages, alors l'interface change sans redémarrage et le choix est conservé.
- **CA-43 (F65)** Étant donné une bibliothèque vide, alors un message explique qu'aucune musique n'a été trouvée et propose un nouveau scan.

## 5. Exigences non fonctionnelles
| Domaine | Exigence (cible, à mesurer sur le Tecno Pop 9) |
|---|---|
| Démarrage | Écran utilisable en moins de 3 s (démarrage à froid, bibliothèque déjà analysée) |
| Scan | 1 000 morceaux analysés en moins de 60 s au premier lancement. Les lancements suivants utilisent les données en cache. |
| Fluidité | Défilement sans saccade visible dans les listes |
| Stabilité | Aucun plantage pendant le scénario de test complet (section 7) |
| Hors ligne | Aucune permission Internet utilisée. L'application fonctionne en mode avion. |
| Données | Playlists, favoris, réglages et cache de la bibliothèque stockés uniquement sur le téléphone |
| Sécurité des fichiers | L'application ne supprime ni ne déplace jamais un fichier audio |
| Accessibilité | Zones tactiles d'au moins 44 px. Un état n'est jamais indiqué par la couleur seule. |

## 6. Données à conserver localement
- **Morceau** : identifiant, chemin, titre, artiste, artiste de l'album, album, genre, année, numéro de piste, durée, format, débit, taille, présence d'une pochette, date d'ajout, date de modification du fichier.
- **Playlist** : identifiant, nom, liste ordonnée des identifiants de morceaux, dates de création et de modification.
- **Favori** (P1) : identifiant du morceau, date.
- **État de lecture** (P1) : file d'attente, index en cours, position, modes aléatoire et répétition.
- **Réglages** : langue, thème.

## 7. Scénario de recette (test manuel de fin de MVP)
1. Installer l'application sur le Tecno Pop 9, refuser l'accès, puis l'accorder depuis les réglages.
2. Vérifier que la bibliothèque contient des MP3, FLAC et M4A, dont un fichier sans tags.
3. Parcourir les 4 onglets, puis chercher un artiste avec un accent sans taper l'accent.
4. Lancer un album, tester suivant, précédent, la barre de progression, l'aléatoire et les 3 modes de répétition.
5. Verrouiller l'écran et piloter la lecture pendant 10 minutes depuis l'écran de verrouillage. Débrancher le casque.
6. Ajouter 3 morceaux avec « Lire ensuite » et « Ajouter à la file », puis en retirer un.
7. Créer une playlist, y ajouter 5 morceaux, la renommer, fermer l'application, la rouvrir et vérifier que la playlist est toujours là.
8. Corriger le fichier sans tags (titre, artiste, album, genre, année, pochette) pour chacun des 3 formats. Vérifier le résultat sur un ordinateur avec Mp3tag.
9. Passer le téléphone en espagnol, puis choisir le français dans l'application.
10. Activer le mode avion et refaire les étapes 3 et 4.

## 8. Planning indicatif (14 → 18 octobre 2026)
| Jour | Objectif |
|---|---|
| Mar. 14 | Valider C2, choisir les bibliothèques Flutter (C4), créer le projet, vérifier l'écriture des tags sur le Tecno Pop 9 (test technique prioritaire) |
| Mer. 15 | Permissions, scan, base de données locale, bibliothèque (F01–F07) |
| Jeu. 16 | Moteur de lecture, arrière-plan, notification, file d'attente (F20–F32) |
| Ven. 17 | Playlists, édition des tags, multilingue (F40–F43, F50–F53, F60–F61) |
| Sam. 18 | États vides et erreurs, recette complète (section 7), corrections, version de livraison |

Règle : on ne commence aucune fonctionnalité P1 tant qu'une fonctionnalité P0 échoue à un critère d'acceptation.

## 9. Points à vérifier en priorité (risques C1)
- **Écriture des tags sur Android** : depuis Android 11, modifier un fichier audio qu'une autre application a créé demande en général une confirmation de l'utilisateur pour chaque modification (API MediaStore). C'est à tester dès le premier jour sur le Tecno Pop 9, pour les 3 formats. Si ce n'est pas possible, il faudra revoir le périmètre de F53.
- **Version d'Android et restrictions de batterie** sur le Tecno Pop 9 : les surcouches de certains constructeurs arrêtent les applications en arrière-plan, ce qui menace CA-15.
- **Bibliothèque de tags Flutter** compatible avec MP3 (ID3v2), FLAC (Vorbis comments) et M4A (atoms MP4), en lecture **et** en écriture. C'est le choix le plus critique de C4.
- **iOS** : pas de test possible sans appareil Apple. Le MVP est donc validé sur Android uniquement. Sur iOS, l'accès aux fichiers locaux et l'écriture des tags fonctionnent très différemment.

## 10. Questions à valider
1. Le périmètre P0 ci-dessus te convient-il, notamment l'exclusion de l'égaliseur et des dossiers ?
2. Les favoris (F45) passent-ils en P0 ? Ils sont très visibles dans le prototype.
3. Faut-il prévoir une sauvegarde avant modification (copie du fichier d'origine) pour l'édition des tags, ou le critère CA-32 suffit-il ?
4. Les cibles de performance (section 5) sont-elles réalistes pour ta bibliothèque ? Combien de morceaux contient-elle environ ?

## 11. Prochaine étape
Validation de ce document, puis C4 – choix des bibliothèques Flutter et preuve de faisabilité technique (écriture des tags et lecture en arrière-plan sur le Tecno Pop 9).
