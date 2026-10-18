# LyraMusic — Rapport quotidien

Une entrée par session de travail, la plus récente en haut. Mis à jour à la fin de chaque session.

---

## 2026-10-18

### Ce qui a été fait
1. **Analyse et corrections** du projet (voir « Bugs corrigés »), analyse statique propre (`flutter analyze` : 0 problème), 34 tests au vert, APK release arm64 compilé et installé sur le Tecno Pop 9.
2. **Fin du chantier fluidité** :
   - balayage horizontal entre les onglets de l'Accueil ;
   - mini-lecteur flottant (glisser à gauche / droite pour changer de morceau) ;
   - capsule animée sous l'onglet actif de la barre du bas ;
   - réglage « Vibrations ».
3. **Synchronisation automatique de la bibliothèque** :
   - observateur MediaStore natif ;
   - scan au retour au premier plan ;
   - scan silencieux quand rien n'a changé, mis en file s'il est demandé pendant un autre ;
   - nouveaux morceaux affichés progressivement ;
   - plus d'accès disque bloquant sur le fil de l'interface.
4. **Focus sur la ligne de paroles en cours** :
   - taille de police animée (20 → 27) et couleur distincte (jaune par défaut, couleur du thème si elle n'est pas blanche) avec un léger halo ;
   - lignes voisines atténuées selon leur distance ;
   - défilement doux, suspendu 3,5 s quand l'utilisateur fait défiler lui-même.
5. **Atelier** :
   - trois actions en tête (Ajouter des paroles, Synchroniser, LyricsCard) qui apparaissent en cascade ;
   - lien « Comment fonctionne l'Atelier ? » vers un **parcours animé en 3 étapes**, avec parallaxe 3D entre les pages, texte en cascade et une scène animée par étape :
     - texte tapé ligne par ligne ;
     - touchers qui posent les horodatages ;
     - carte qui se compose, pivote, brille puis s'envole ;
   - le parcours s'ouvre automatiquement à la première visite.
6. **Nouvelle fonctionnalité LyricsCard** :
   - écran Texte / Image / Police avec aperçu en direct ;
   - compteur 113 caractères vert / orange / rouge ;
   - 6 polices embarquées, 8 fonds dessinés, plus la pochette ou une image de la galerie ;
   - export JPEG 1080 px vers la galerie ou le partage système ;
   - raccourci depuis le panneau Paroles du lecteur.
7. **Documentation** : création de `PROJECT_OVERVIEW.md` et de ce rapport.

### Fichiers modifiés
- **Créés**
  - `lib/state/library_sync.dart`
  - `lib/data/card_export.dart`
  - `lib/ui/widgets/lyrics_card_canvas.dart`
  - `lib/ui/screens/lyrics_card_screen.dart`
  - `lib/ui/screens/workshop_guide.dart`
  - `android/.../CardExport.kt`
  - `android/.../res/xml/card_paths.xml`
  - 4 polices + licences dans `assets/fonts/`
  - `docs/PROJECT_OVERVIEW.md`, `docs/DAILY_REPORT.md`
- **Modifiés**
  - `lib/state/library.dart` (scan)
  - `lib/data/media_store.dart`, `MainActivity.kt` (observateur, export)
  - `AndroidManifest.xml` (FileProvider), `android/app/build.gradle*` (androidx.core)
  - `lib/ui/shell.dart` (synchronisation, capsule)
  - `lib/ui/widgets/mini_player.dart`
  - `lib/ui/screens/home_screen.dart` (PageView)
  - `lib/ui/screens/player_screen.dart` (panneau de paroles renommé `LyricsPanel`, raccourci LyricsCard)
  - `lib/ui/screens/workshop_screen.dart`, `settings_screen.dart`
  - `lib/state/settings.dart`, `lib/state/dynamic_palette.dart`
  - `lib/data/lyrics.dart`, `lib/main.dart`
  - `pubspec.yaml`
  - traductions FR / EN / ES
  - `test/previews_test.dart`, `test/tag_writer_test.dart`

### Bugs corrigés

| Fichier | Cause | Solution |
|---|---|---|
| `lib/data/lyrics.dart` | Saut de ligne littéral dans deux chaînes `join('…')` : le projet ne compilait plus | Remplacé par `'\n'` |
| `mini_player.dart`, `player_screen.dart` | `late final AnimationController` créé pour la première fois dans `dispose()` → exception « deactivated widget's ancestor » à la fermeture | Contrôleurs créés dans `initState` |
| `lib/ui/shell.dart` | Même risque pour le nouvel objet de synchronisation | Créé dans `initState` |
| `lib/state/dynamic_palette.dart` | `notifyListeners()` possible après `dispose` (calcul de couleur asynchrone) | Garde `_disposed` |
| `lib/state/library.dart` | 1 500 vérifications `existsSync()` sur le fil de l'interface à chaque scan (saccades) | Liste du dossier des pochettes lue une fois, en asynchrone |
| `lib/state/library.dart` | Chaque scan reconstruisait tout l'écran même sans changement | Scan silencieux s'il n'y a rien de neuf |
| `lib/state/library.dart` | Un scan demandé pendant un autre était ignoré (nouveaux fichiers manqués) | Mise en file et relance |
| `player_screen.dart` (paroles) | Le panneau entier était reconstruit à chaque tic de position (environ 5 par seconde) | Flux d'index de ligne `distinct()` : reconstruction seulement au changement de ligne |
| `player_screen.dart` (paroles) | Aucune ligne active à l'ouverture tant que la position n'avait pas changé | Valeur initiale calculée depuis la position courante |
| `test/previews_test.dart` | Fournisseurs `LyricsStore` / `DynamicPalette` absents : 10 aperçus en échec | Ajoutés, images de référence régénérées |
| `test/tag_writer_test.dart` | Échec aléatoire sous Windows : dossier temporaire verrouillé au nettoyage | Nettoyage tolérant (5 essais) |
| `lib/state/settings.dart`, `lyrics_sync_screen.dart` | Avertissements d'analyse (commentaire HTML, `if` sans accolades) | Corrigés |
| `lib/data/lyrics.dart` | Code mort : `plainLyrics` (doublon de `LyricsStore.plainTextFor`) | Supprimé |

### Décisions prises
- **Couleur de la ligne active** : la couleur du thème est jugée « blanche » si sa luminosité est très élevée ou si elle est très peu saturée et claire. C'est le cas du crème de la charte : le jaune s'applique alors. Sur fond clair, un jaune plus profond (#B98500) est utilisé pour rester lisible.
- **Sélection du texte d'une LyricsCard** : toucher = ligne entière ; toucher une autre ligne = étendre ; appui long et poignées = au caractère près. Le compteur passe à l'orange au-delà de 80 % (91 caractères).
- **Polices** : 4 polices OFL ajoutées (Playfair Display, Bebas Neue, Caveat, Space Mono) en plus de Nunito et Inter, embarquées pour rester hors ligne (+ environ 0,9 Mo).
- **Images prédéfinies** : fonds dessinés (dégradés de la charte, sillons de vinyle, vagues, grain) plutôt que des photos : aucun poids, rendu net à toutes les tailles.
- **Export** : rendu Flutter ×3 en PNG, puis JPEG qualité 95 encodé nativement. Aucune permission sur Android 10+ (MediaStore) ; permission de stockage demandée seulement sur Android 9 et inférieur.
- **Synchronisation automatique** : pas de service en arrière-plan permanent (économie de batterie sur Android Go) : observateur actif tant que l'application vit, plus un scan au retour au premier plan.
- Le panneau de paroles du lecteur s'appelle désormais `LyricsPanel`, pour éviter la confusion avec la fonctionnalité LyricsCard.

### Tâches restantes
- Vérifier sur le téléphone (il était verrouillé pendant la session) :
  - détection d'un fichier copié pendant que l'application est ouverte ;
  - export vers la galerie et partage ;
  - fluidité du panneau de paroles.
- Sauvegarde / export des paroles de l'utilisateur (fichier `.lrc` ou tags).
- Choisir parmi les propositions d'animations pendant la lecture (voir le message de fin de session).
- Envisager de réduire l'en-tête de l'Atelier sur les petits écrans (la liste commence assez bas).
