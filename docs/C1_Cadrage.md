# C1 – Cadrage du projet (version validée)
Date : 12 octobre 2026

## 1. Vision
Application mobile cross-platform (iOS et Android) de lecture de musique locale, offline first, permettant de lire, tagger (à la Mp3tag), enrichir et organiser sa bibliothèque.

## 2. Problème
Les passionnés de musique jonglent entre un lecteur, un éditeur de tags sur ordinateur et des sites d'informations sur les artistes, et ont des bibliothèques mal étiquetées.

## 3. Cible
Tous les utilisateurs de musique locale, avec un focus sur les passionnés qui soignent leur bibliothèque.

## 4. Proposition de valeur
Lecteur offline complet + édition de tags efficace (unitaire et en lot) + tagging automatique + fiches artistes (description, photo) issues de sources fiables.

## 5. Périmètre par versions
| Version | Contenu |
|---|---|
| MVP (cette semaine) | Toutes les fonctionnalités indispensables d'un lecteur de musique (lecture/pause, suivant/précédent, barre de progression, aléatoire, répétition, file d'attente, playlists, bibliothèque par titres/artistes/albums/genres, recherche, lecture en arrière-plan, contrôles notification/écran verrouillé), édition manuelle des tags (titre, artiste, album, genre, année, pochette), multilingue FR/EN/ES |
| V1.1 | Tagging automatique, descriptions et photos d'artistes via sources fiables (candidates, à vérifier : MusicBrainz, Cover Art Archive, Wikipedia/Wikimedia Commons, licences à contrôler), édition en lot |
| V2 (backlog) | Paroles synchronisées (façon Musixmatch), annotations (façon Genius) |

## 6. Décisions validées
- Musique locale, offline first ; le réseau sert uniquement à l'enrichissement.
- Formats audio : MP3, FLAC, M4A.
- Langues : français, anglais, espagnol (architecture multilingue extensible).
- Stack : Flutter / Dart (confirmation des bibliothèques en C4).
- Appareil de test : Android Tecno Pop 9 (entrée de gamme : performances et version Android à vérifier).
- Livraison en 2 temps : MVP cette semaine (échéance autour du 18 octobre 2026), enrichissement ensuite.
- Budget : facultatif pour l'instant. Pas de compte utilisateur ni de cloud dans le MVP.

## 7. Profil et organisation
Le porteur du projet est organisateur et valide par tests manuels ; niveau Flutter/Dart débutant, comprend les workflows et algorithmes. La génération du code est assistée.

## 8. Risques
- Délai très serré (élevé).
- Accès aux fichiers, permissions et écriture des tags audio sur Android (à vérifier en C4).
- Performances sur appareil d'entrée de gamme (Tecno Pop 9) (à vérifier).
- Test iOS impossible sans appareil Apple (à vérifier).
- Droits et licences des photos et descriptions d'artistes (à vérifier).
- Fiabilité et quotas des API d'enrichissement (à vérifier).

## 9. Prochaine étape
C2 – Définition détaillée du MVP (fonctionnalités, priorités, critères d'acceptation).
