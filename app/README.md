# LyraMusic — application Flutter (MVP)

Lecteur de musique locale, offline first. Voir `docs/C1_Cadrage.md` et `docs/C2_MVP.md`.

## Lancer

```bash
flutter pub get
flutter run                                   # téléphone branché en USB (débogage USB activé)
flutter build apk --release --target-platform android-arm64   # APK pour le Tecno Pop 9
flutter test                                  # tests (tags MP3/FLAC/M4A, recherche, paroles…)
```

## Organisation du code (`lib/`)

| Dossier | Rôle |
|---|---|
| `main.dart` | Démarrage : base locale, moteur audio, fournisseurs d'état |
| `models/track.dart` | Morceau, album, groupe (artiste/genre), playlist |
| `data/media_store.dart` | Pont vers Android (`MainActivity.kt`) : liste des fichiers audio, autorisation d'écriture |
| `data/scanner.dart` | Lecture des tags et des pochettes, dans un isolate (interface fluide) |
| `data/tag_writer.dart` | Écriture sûre des tags : copie de travail, vérification, sauvegarde et restauration |
| `data/mp4_skeleton.dart` | Crée le bloc de tags d'un M4A qui n'en a pas (avec correction des positions audio) |
| `data/lyrics.dart` | Paroles intégrées ou fichier `.lrc`, synchronisées ou non |
| `data/db.dart` | SQLite : cache de la bibliothèque, playlists, favoris, historique |
| `audio/handler.dart` | File d'attente, aléatoire, répétition, notification / écran verrouillé, reprise |
| `state/` | Bibliothèque, collections (playlists, favoris), réglages |
| `ui/` | Thème (design system du prototype), écrans, composants |
| `l10n/` | Traductions FR / EN / ES (`app_*.arb`) |

## Choix techniques

- **Scan** : MediaStore (Android) via un petit canal natif, puis lecture des tags en Dart pur
  (`audio_metadata_reader`). Scan incrémental : seuls les fichiers nouveaux ou modifiés sont relus.
- **Écriture des tags** sur Android 11+ : le fichier est modifié dans une copie, Android demande
  l'autorisation à l'utilisateur, puis le contenu est remplacé. En cas d'échec, la sauvegarde est
  restaurée (CA-32).
- **Lecture** : `just_audio` + `audio_service` (arrière-plan, notification) + `audio_session`
  (casque débranché, appels).
- **Aucune permission Internet** dans l'APK.

## Identité visuelle

Charte graphique, logos et icône : `assets/brand/` (voir `assets/brand/README.md`).
Polices embarquées : Plus Jakarta Sans, Inter, JetBrains Mono (`assets/fonts/`, licence OFL).

## Limites connues

- L'« artiste de l'album » n'est pas modifiable pour les M4A (non géré par la bibliothèque de tags).
- Lors de la modification d'un MP3, les cadres ID3 rares non gérés par la bibliothèque de tags
  peuvent être perdus (les champs courants, la pochette et les paroles sont conservés).
- iOS : non testé (pas d'appareil Apple) ; le scan repose sur MediaStore (Android uniquement).
