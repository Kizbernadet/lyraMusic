# LyraMusic — Vue d'ensemble du projet

> Lecteur de musique locale pour Android, **offline first** : aucune connexion, aucun compte.
> Toutes les données (bibliothèque, favoris, playlists, paroles, thèmes, LyricsCards) restent sur le téléphone.

Documents liés : [C1_Cadrage.md](C1_Cadrage.md) (cadrage), [C2_MVP.md](C2_MVP.md) (périmètre MVP), [DAILY_REPORT.md](DAILY_REPORT.md) (journal de travail).

---

## 1. Objectif

Offrir aux passionnés de musique un lecteur moderne et fluide pour leurs fichiers audio (MP3, FLAC, M4A), avec des **paroles synchronisées** qu'ils peuvent eux-mêmes ajouter, synchroniser et partager sous forme d'images (**LyricsCards**), le tout sans Internet.

Appareil de référence : Tecno Pop 9 (Android 14 Go, peu de mémoire, arm64), environ 1 500 morceaux.

## 2. Fonctionnalités

| Domaine | Fonctionnalités |
|---|---|
| Bibliothèque | Scan MediaStore incrémental, **détection automatique des nouveaux fichiers**, onglets Suggestions / Titres / Artistes / Albums / Dossiers / Genres (balayage entre onglets), tris, recherche sans accents |
| Lecture | Lecture en arrière-plan, notification, file d'attente, aléatoire / répétition, vitesse, minuterie, égaliseur, saut des silences, reprise de la session |
| Lecteur | Écran configurable (options affichables), pochette ou vinyle, fermeture par glissement, mini-lecteur flottant (glisser = morceau suivant / précédent) |
| Paroles | Paroles du fichier ou fichier `.lrc`, **ligne en cours agrandie et colorée** (jaune par défaut), défilement automatique, toucher une ligne = aller à ce moment |
| Atelier | Ajouter des paroles, **synchroniser** (un toucher par ligne, ajustement fin), compléter les infos manquantes (tags), **créer une LyricsCard**, parcours explicatif animé |
| LyricsCard | Extrait de 113 caractères au plus, fond (pochette, galerie, fonds prédéfinis), police / taille / alignement / couleur, formats 4:5, 1:1, 9:16, export JPEG 1080 px, galerie et partage |
| Collections | Favoris, playlists, historique, les plus écoutés |
| Tags | Édition des tags et de la pochette dans le fichier (avec sauvegarde et vérification) |
| Apparence | Thèmes clair / sombre / système, couleur d'accent, galerie de thèmes, thème « Pochette » dynamique, **éditeur de thèmes personnalisés** |
| Système | Widgets d'écran d'accueil, lecteur sur l'écran verrouillé, retours haptiques, FR / EN / ES |

## 3. Stack technique

- **Flutter 3.44 / Dart 3.12**, Android uniquement (arm64).
- **État** : `provider` (ChangeNotifier).
- **Audio** : `just_audio` (+ égaliseur et amplificateur Android), `audio_service` (session média, notification), `audio_session`.
- **Données** : `sqflite` (base locale, schéma v2), `shared_preferences` (réglages, thèmes personnalisés).
- **Tags** : `audio_metadata_reader` pour la lecture ; écriture maison (`tag_writer`, `id3_preserve`, `mp4_skeleton`).
- **Images** : `image_picker` (fond de LyricsCard depuis la galerie).
- **Natif (Kotlin)** : MediaStore (requête, écriture autorisée, observateur de changements), volume, widgets, écran verrouillé, export des LyricsCards (JPEG, galerie, partage via FileProvider).
- **Polices embarquées** (licence OFL) : Nunito, Inter, et pour les LyricsCards Playfair Display, Bebas Neue, Caveat, Space Mono.

## 4. Architecture et structure

```
app/
├─ lib/
│  ├─ main.dart                 Initialisation : audio, base, contrôleurs, thème
│  ├─ audio/handler.dart        LyraAudioHandler : file, lecture, effets, session
│  ├─ data/                     Accès aux données (sans interface)
│  │  ├─ db.dart                SQLite : morceaux, favoris, playlists, historique, paroles utilisateur
│  │  ├─ media_store.dart       Pont natif MediaStore + flux de changements
│  │  ├─ scanner.dart           Lecture des tags dans un isolate
│  │  ├─ lyrics.dart            Analyse LRC / texte, conversion en LRC
│  │  ├─ tag_writer.dart …      Écriture sûre des tags
│  │  └─ card_export.dart       Export des LyricsCards (natif)
│  ├─ models/track.dart
│  ├─ state/                    Contrôleurs (ChangeNotifier)
│  │  ├─ library.dart           Bibliothèque, scan incrémental, vues triées en cache
│  │  ├─ library_sync.dart      Synchronisation automatique (MediaStore + premier plan)
│  │  ├─ lyrics_store.dart      Paroles ajoutées / synchronisées par l'utilisateur
│  │  ├─ collections.dart       Favoris, playlists, historique
│  │  ├─ settings.dart          Réglages, thèmes, options d'affichage
│  │  └─ dynamic_palette.dart   Couleur dominante de la pochette
│  ├─ ui/
│  │  ├─ shell.dart             Démarrage (Gate) et navigation à 4 onglets
│  │  ├─ theme.dart, theme_presets.dart
│  │  ├─ brand/                 Logo vectorisé (R-vinyle)
│  │  ├─ screens/               Écrans (accueil, lecteur, atelier, LyricsCard…)
│  │  └─ widgets/               Composants réutilisables (kit, tuiles, mini-lecteur, canevas de carte)
│  └─ l10n/                     Traductions FR / EN / ES (ARB)
├─ android/app/src/main/kotlin/com/lyramusic/lyra/
│  ├─ MainActivity.kt           Canal « lyra/media » + observateur MediaStore
│  ├─ SystemChannel.kt          Canal « lyra/system » : volume, widgets, écran verrouillé
│  ├─ CardExport.kt             JPEG, galerie, partage
│  └─ LyraWidgets.kt, LockScreenActivity.kt, NowPlaying.kt
└─ test/                        Tests logiques, écriture de tags, aperçus (images de référence)
```

**Principes**
- Les écrans lisent l'état via `context.watch<…>()` et n'accèdent jamais directement à la base.
- Les traitements lourds (lecture des tags, encodage) se font hors du fil de l'interface (isolates, threads natifs).
- Les contributions de l'utilisateur (paroles) sont stockées en base et **ne modifient pas les fichiers audio** ; elles ont priorité sur les paroles du fichier.

## 5. Flux principaux

### Lecture
1. `LibraryController.load()` affiche la bibliothèque en cache dès le démarrage.
2. Un toucher sur un morceau → `LyraAudioHandler.playTracks()` → `just_audio`.
3. La position, l'état et le morceau courant sont diffusés (`ValueNotifier`, flux) au mini-lecteur, au lecteur, aux widgets et à la notification.

### Détection de la musique
1. Au démarrage (autorisation accordée), `LibrarySync.start()` lance un scan incrémental.
2. Un `ContentObserver` natif surveille MediaStore ; les rafales sont regroupées (1,5 s) puis un événement est envoyé à Flutter.
3. Au retour au premier plan, un nouveau scan est lancé (au plus toutes les 10 s).
4. Le scan compare taille et date de chaque fichier : seuls les fichiers nouveaux ou modifiés sont relus. **S'il n'y a rien de neuf, l'interface n'est pas reconstruite.** Sinon une fine barre de progression s'affiche et les nouveaux morceaux apparaissent au fil de l'analyse.

### Paroles
`LyricsStore.lyricsFor(track)` renvoie les paroles de l'utilisateur, sinon celles du fichier (tag ou `.lrc`). Le panneau du lecteur n'est reconstruit que lorsque la ligne en cours change.

### Atelier
- **Ajouter** : éditeur de texte → `LyricsStore.save(synced: false)`.
- **Synchroniser** : un toucher par ligne pendant la lecture, puis vérification et ajustement ; enregistrement au format LRC (`synced: true`).
- **Infos manquantes** : éditeur de tags.
- **LyricsCard** : voir ci-dessous. Un parcours animé en 3 étapes explique l'Atelier (affiché automatiquement à la première visite).

### LyricsCard
1. Onglet **Texte** : choix parmi les chansons qui ont des paroles ; sélection d'une ou plusieurs lignes (toucher), ajustement au caractère près (appui long). Compteur sur 113 : vert, orange à partir de 91, rouge au-delà (bouton « Continuer » désactivé).
2. Onglet **Image** : pochette, galerie ou fond prédéfini ; assombrir, flou ; format.
3. Onglet **Police** : 6 polices embarquées, taille, alignement (gauche, centré, droite, justifié), couleur, titre et artiste.
4. **Export** : le canevas (le même widget que l'aperçu) est rendu à ×3 (1080 px de large) en PNG, puis encodé en JPEG qualité 95 côté Android → galerie (`Images/LyraMusic`) ou feuille de partage.

## 6. Dépendances importantes

| Paquet | Rôle | Remarque |
|---|---|---|
| just_audio 0.10.6 | Lecture | Version figée (effets Android) |
| audio_service 0.18.19 | Arrière-plan, notification | L'activité hérite d'`AudioServiceActivity` |
| sqflite 2.4.4 | Base locale | Migration v1 → v2 (paroles) |
| audio_metadata_reader 1.8.0 | Lecture des tags | Pur Dart, exécuté en isolate |
| permission_handler 13.0.2 | Autorisations | Audio ; stockage pour l'export sur Android ≤ 9 |
| image_picker 1.2.3 | Fond de LyricsCard | Sélecteur système, sans permission |
| androidx.core 1.13.1 | FileProvider | Partage des cartes |

## 7. Limitations connues

- Android uniquement ; testé surtout sur Android 14 Go.
- La détection automatique fonctionne tant que le processus est vivant (lecture en cours ou application ouverte) ; sinon les changements sont rattrapés au prochain lancement ou retour au premier plan.
- Les paroles ajoutées restent dans la base de l'application : elles ne sont pas écrites dans les fichiers audio et sont perdues si l'application est désinstallée (pas encore d'export / sauvegarde).
- Les fonds « prédéfinis » des LyricsCards sont dessinés (dégradés et motifs), pas des photos.
- Pas de recherche de paroles en ligne (choix du hors-ligne).
- Formats audio : MP3, FLAC, M4A.

## 8. Pistes d'évolution

- Sauvegarde / restauration locale (paroles, playlists, thèmes) dans un fichier, et écriture optionnelle des paroles dans les tags ou en `.lrc`.
- Animations pendant la lecture : visualiseur audio, pochette animée, transitions entre morceaux, effets au rythme (voir les propositions dans le rapport du jour).
- Paroles mot par mot (format LRC étendu, type karaoké).
- LyricsCards animées (courte vidéo) et modèles enregistrables.
- Statistiques d'écoute locales et récapitulatif annuel.
