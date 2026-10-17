// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'LyraMusic';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navSettings => 'Réglages';

  @override
  String get splashTagline => 'Musique pour tous, partout.';

  @override
  String get splashPreparing => 'Préparation de la bibliothèque…';

  @override
  String get permTitle => 'Laissez LyraMusic trouver vos morceaux';

  @override
  String get permBody =>
      'LyraMusic doit lire les fichiers audio de ce téléphone pour afficher vos albums, artistes et playlists. Rien n\'est envoyé nulle part.';

  @override
  String get permPoint1 => 'Lit uniquement les fichiers audio';

  @override
  String get permPoint1Sub =>
      'Photos, messages et documents ne sont jamais ouverts.';

  @override
  String get permPoint2 => 'Fonctionne sans Internet';

  @override
  String get permPoint2Sub =>
      'L\'analyse et la lecture se font entièrement sur le téléphone.';

  @override
  String get permPoint3 => 'Vous gardez le contrôle';

  @override
  String get permPoint3Sub =>
      'Vous pouvez retirer l\'accès à tout moment dans les réglages du téléphone.';

  @override
  String get permAllow => 'Autoriser l\'accès à la musique';

  @override
  String get permLater => 'Plus tard';

  @override
  String get permFootnote =>
      'Vous pourrez changer cela plus tard dans les réglages du téléphone.';

  @override
  String get permDeniedTitle => 'L\'accès à la musique est désactivé';

  @override
  String get permDeniedBody =>
      'Sans accès à vos fichiers audio, votre bibliothèque reste vide.';

  @override
  String get permOpenSettings => 'Ouvrir les réglages du téléphone';

  @override
  String get scanning => 'Analyse de votre musique…';

  @override
  String scanProgress(int done, int total) {
    return '$done fichiers sur $total';
  }

  @override
  String scanResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux dans votre bibliothèque',
      one: '1 morceau dans votre bibliothèque',
      zero: 'Aucun morceau trouvé',
    );
    return '$_temp0';
  }

  @override
  String get scanError => 'La bibliothèque n\'a pas pu être analysée.';

  @override
  String get rescan => 'Analyser';

  @override
  String get scanMusic => 'Analyser la musique';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String homeHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux, tous sur votre téléphone',
      one: '1 morceau, sur votre téléphone',
      zero: 'Pas encore de morceaux',
    );
    return '$_temp0';
  }

  @override
  String get resumePlayback => 'Reprendre la lecture';

  @override
  String timeLeft(String time) {
    return '$time restantes';
  }

  @override
  String get recentlyAdded => 'Ajoutés récemment';

  @override
  String get recentlyPlayed => 'Écoutés récemment';

  @override
  String get recentlyFavorited => 'Favoris récents';

  @override
  String get yourPlaylists => 'Vos playlists';

  @override
  String get manage => 'Gérer';

  @override
  String get allFavorites => 'Tous les favoris';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get badgeNew => 'Nouveau';

  @override
  String get badgeFix => 'À compléter';

  @override
  String localLibraryFooter(String songs) {
    return 'Bibliothèque locale · $songs';
  }

  @override
  String get shuffleAll => 'Tout en aléatoire';

  @override
  String get play => 'Lecture';

  @override
  String get playAll => 'Tout lire';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get shuffle => 'Aléatoire';

  @override
  String get shuffleOn => 'Aléatoire activé';

  @override
  String get shuffleOff => 'Aléatoire désactivé';

  @override
  String get repeatOff => 'Répétition désactivée';

  @override
  String get repeatAll => 'Répéter tout';

  @override
  String get repeatOne => 'Répéter le morceau';

  @override
  String get library => 'Bibliothèque';

  @override
  String get tabSongs => 'Titres';

  @override
  String get tabArtists => 'Artistes';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabGenres => 'Genres';

  @override
  String get tabFolders => 'Dossiers';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux',
      one: '1 morceau',
      zero: '0 morceau',
    );
    return '$_temp0';
  }

  @override
  String albumsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count albums',
      one: '1 album',
      zero: '0 album',
    );
    return '$_temp0';
  }

  @override
  String get unknownArtist => 'Artiste inconnu';

  @override
  String get unknownAlbum => 'Album inconnu';

  @override
  String get unknownGenre => 'Genre inconnu';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortTitle => 'Titre';

  @override
  String get sortArtist => 'Artiste';

  @override
  String get sortAlbum => 'Album';

  @override
  String get sortDateAdded => 'Ajout récent';

  @override
  String incompleteBannerTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers ont des informations incomplètes',
      one: '1 fichier a des informations incomplètes',
    );
    return '$_temp0';
  }

  @override
  String get incompleteBannerText =>
      'LyraMusic n\'invente jamais les tags manquants. Vérifiez-les quand vous voulez.';

  @override
  String get reviewFiles => 'Vérifier les fichiers';

  @override
  String get incompleteTitle => 'Morceaux à compléter';

  @override
  String get foldersHint =>
      'Seuls les dossiers contenant de l\'audio sont affichés.';

  @override
  String get searchSubtitle => 'Sur votre téléphone uniquement';

  @override
  String get searchHint => 'Titres, artistes, albums, playlists';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String get browseBy => 'Parcourir par';

  @override
  String get clear => 'Effacer';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchNoResultsText =>
      'Vérifiez l\'orthographe, ou relancez l\'analyse si le morceau a été ajouté récemment.';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
    );
    return '$_temp0';
  }

  @override
  String get emptyLibraryTitle => 'Aucune musique trouvée';

  @override
  String get emptyLibraryBody =>
      'Copiez des fichiers MP3, FLAC ou M4A sur ce téléphone, puis relancez l\'analyse.';

  @override
  String get playlists => 'Playlists';

  @override
  String localPlaylists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count playlists locales',
      one: '1 playlist locale',
      zero: 'Aucune playlist locale',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoris';

  @override
  String get history => 'Historique';

  @override
  String get newPlaylist => 'Nouvelle playlist';

  @override
  String get playlistName => 'Nom de la playlist';

  @override
  String get create => 'Créer';

  @override
  String get rename => 'Renommer';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get change => 'Changer';

  @override
  String get toggleView => 'Changer d\'affichage';

  @override
  String get deletePlaylistTitle => 'Supprimer cette playlist ?';

  @override
  String deletePlaylistBody(String name) {
    return '« $name » sera supprimée. Vos fichiers audio ne sont pas supprimés.';
  }

  @override
  String get playlistCreated => 'Playlist créée';

  @override
  String addedToPlaylist(String name) {
    return 'Ajouté à $name';
  }

  @override
  String get playlistsLocalTitle => 'Les playlists restent sur ce téléphone';

  @override
  String get playlistsLocalText =>
      'Rien n\'est synchronisé ni envoyé. Un morceau peut apparaître plusieurs fois dans une même playlist.';

  @override
  String get emptyPlaylistTitle => 'Cette playlist est vide';

  @override
  String get emptyPlaylistBody =>
      'Ajoutez des morceaux pour commencer l\'écoute.';

  @override
  String get noPlaylistsTitle => 'Pas encore de playlist';

  @override
  String get noPlaylistsBody =>
      'Créez une playlist pour regrouper les morceaux que vous aimez.';

  @override
  String get noFavoritesTitle => 'Pas encore de favoris';

  @override
  String get noFavoritesBody =>
      'Touchez le cœur d\'un morceau pour le retrouver ici.';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get addSongs => 'Ajouter des morceaux';

  @override
  String get searchSongs => 'Rechercher des morceaux';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count morceaux sélectionnés',
      one: '1 morceau sélectionné',
      zero: 'Aucun morceau sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get historyToday => 'Aujourd\'hui';

  @override
  String get historyYesterday => 'Hier';

  @override
  String get historyThisWeek => 'Cette semaine';

  @override
  String get historyEarlier => 'Plus tôt';

  @override
  String get clearHistory => 'Effacer l\'historique';

  @override
  String get clearHistoryTitle => 'Effacer l\'historique d\'écoute ?';

  @override
  String get clearHistoryBody =>
      'Vos morceaux, favoris et playlists ne sont pas touchés.';

  @override
  String get historyEmptyTitle => 'Pas encore d\'historique';

  @override
  String get historyEmptyBody =>
      'Les morceaux que vous écoutez apparaîtront ici.';

  @override
  String get playNext => 'Lire ensuite';

  @override
  String get addToQueue => 'Ajouter à la file';

  @override
  String get addToPlaylist => 'Ajouter à une playlist';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get goToArtist => 'Voir l\'artiste';

  @override
  String get goToAlbum => 'Voir l\'album';

  @override
  String get songDetails => 'Détails du morceau';

  @override
  String get editTags => 'Modifier les informations';

  @override
  String get removeFromPlaylist => 'Retirer de la playlist';

  @override
  String get willPlayNext => 'Sera lu ensuite';

  @override
  String get addedToQueue => 'Ajouté à la file';

  @override
  String get nowPlaying => 'Lecture en cours';

  @override
  String fromAlbum(String album) {
    return 'de $album';
  }

  @override
  String get queue => 'File d\'attente';

  @override
  String get playingQueue => 'File de lecture';

  @override
  String get upNext => 'À suivre';

  @override
  String nextUpCount(int count) {
    return 'À suivre · $count';
  }

  @override
  String get dragToReorder => 'Glisser pour réordonner';

  @override
  String get shuffleQueue => 'Mélanger la file';

  @override
  String get queueCleared => 'File vidée';

  @override
  String get queueEmpty => 'La file est vide';

  @override
  String get queueEmptyBody =>
      'Ajoutez des morceaux depuis la bibliothèque, un album ou une playlist pour continuer l\'écoute.';

  @override
  String get openLibrary => 'Ouvrir la bibliothèque';

  @override
  String get removeFromQueue => 'Retirer de la file';

  @override
  String get lyrics => 'Paroles';

  @override
  String get lyricsSynced => 'Paroles synchronisées';

  @override
  String get lyricsUnsynced => 'Non synchronisées';

  @override
  String get lyricsStoredLocally =>
      'Stockées sur le téléphone · disponibles hors ligne';

  @override
  String get lyricsUnavailable => 'Paroles indisponibles';

  @override
  String get lyricsNoneText =>
      'Aucune parole n\'est enregistrée dans ce fichier, et aucun fichier .lrc du même nom n\'a été trouvé à côté.';

  @override
  String get detailsFile => 'Fichier';

  @override
  String get detailsFormat => 'Format';

  @override
  String get detailsBitrate => 'Débit';

  @override
  String get detailsSampleRate => 'Échantillonnage';

  @override
  String get detailsDuration => 'Durée';

  @override
  String get detailsSize => 'Taille du fichier';

  @override
  String get detailsLocation => 'Emplacement';

  @override
  String get detailsTags => 'Tags';

  @override
  String get badgeMissing => 'Manquant';

  @override
  String get badgeIncomplete => 'Incomplet';

  @override
  String get missingInfoTitle => 'Des informations manquent';

  @override
  String get missingInfoText =>
      'LyraMusic n\'invente jamais de tags. Le fichier se lit normalement — vous pouvez le compléter quand vous voulez.';

  @override
  String get chooseArtwork => 'Choisir une pochette';

  @override
  String fileOfType(String format) {
    return 'Fichier $format';
  }

  @override
  String get fieldTitle => 'Titre';

  @override
  String get fieldArtist => 'Artiste';

  @override
  String get fieldAlbum => 'Album';

  @override
  String get fieldAlbumArtist => 'Artiste de l\'album';

  @override
  String get fieldGenre => 'Genre';

  @override
  String get fieldYear => 'Année';

  @override
  String get fieldTrackNumber => 'N° de piste';

  @override
  String get titleRequired => 'Le titre ne peut pas être vide';

  @override
  String get yearInvalid => '4 chiffres';

  @override
  String get numberInvalid => 'Saisissez un nombre';

  @override
  String get notSupportedForFormat => 'Non pris en charge pour ce format';

  @override
  String get artwork => 'Pochette';

  @override
  String get artworkEmbedded => 'Intégrée au fichier';

  @override
  String get artworkNew => 'Nouvelle pochette, enregistrée avec le fichier';

  @override
  String get artworkChoose => 'Choisir dans la galerie';

  @override
  String get artworkRemove => 'Supprimer la pochette';

  @override
  String get artworkNone => 'Aucune pochette dans ce fichier';

  @override
  String get tagsWriteInfo =>
      'Les modifications sont écrites directement dans le fichier audio. Android vous demandera l\'autorisation.';

  @override
  String get tagsSaved => 'Tags écrits dans le fichier';

  @override
  String get tagsErrorDenied =>
      'L\'autorisation de modifier ce fichier a été refusée. Rien n\'a été modifié.';

  @override
  String get tagsErrorWrite =>
      'Le fichier n\'a pas pu être modifié. Le fichier d\'origine est intact.';

  @override
  String get discardTitle => 'Abandonner les modifications ?';

  @override
  String get discardBody => 'Vos modifications n\'ont pas été enregistrées.';

  @override
  String get discard => 'Abandonner';

  @override
  String get keepEditing => 'Continuer';

  @override
  String get settings => 'Réglages';

  @override
  String get groupAppearance => 'Apparence';

  @override
  String get groupLibrary => 'Bibliothèque';

  @override
  String get groupData => 'Données';

  @override
  String get groupSystem => 'Système';

  @override
  String get groupAbout => 'À propos';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get permissions => 'Autorisations';

  @override
  String get permissionGranted => 'Accès à la musique accordé';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get privacyValue => 'Pas de compte, pas de suivi, pas de cloud';

  @override
  String get licences => 'Licences open source';

  @override
  String get version => 'Version';

  @override
  String get settingsFooter =>
      'Votre musique ne quitte jamais ce téléphone. Aucune connexion Internet n\'est nécessaire.';

  @override
  String get cannotPlay =>
      'Ce fichier ne peut pas être lu. Il a peut-être été déplacé ou supprimé.';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get appearance => 'Apparence';

  @override
  String get accentColor => 'Couleur principale';

  @override
  String get accentHint =>
      'Utilisée pour les boutons, le morceau en cours et les commandes actives.';

  @override
  String get accentClassic => 'Classique';

  @override
  String get accentSand => 'Sable';

  @override
  String get accentTaupe => 'Taupe';

  @override
  String get accentSage => 'Sauge';

  @override
  String get accentTerracotta => 'Terracotta';

  @override
  String get accentOcean => 'Océan';

  @override
  String get accentMint => 'Menthe';

  @override
  String get accentViolet => 'Violet';

  @override
  String get preview => 'Aperçu';

  @override
  String get listenNow => 'Écouter maintenant';

  @override
  String get playerLayout => 'Écran de lecture';

  @override
  String get playerLayoutSub => 'Choisir ce qui s\'affiche';

  @override
  String get playerLayoutHint =>
      'Affichez ou masquez chaque élément du lecteur, de la file d\'attente et du mini-lecteur.';

  @override
  String get artRounded => 'Arrondie';

  @override
  String get artSquare => 'Carrée';

  @override
  String get artVinyl => 'Vinyle';

  @override
  String get bgBlur => 'Floutée';

  @override
  String get bgGradient => 'Dégradé';

  @override
  String get bgPlain => 'Uni';

  @override
  String get optSwipe => 'Glisser sur la pochette';

  @override
  String get optSwipeSub => 'Gauche : suivant · droite : précédent';

  @override
  String get groupInfo => 'Informations';

  @override
  String get optAlbumInfo => 'Album et année';

  @override
  String get optFormat => 'Format audio';

  @override
  String get optRemaining => 'Temps restant';

  @override
  String get optRemainingSub => 'Sinon, la durée totale est affichée';

  @override
  String get optNextUp => 'Aperçu du morceau suivant';

  @override
  String get groupControls => 'Commandes';

  @override
  String get optVolume => 'Volume';

  @override
  String get optVolumeSub => 'Le même que les touches du téléphone';

  @override
  String get optFavorite => 'Bouton favori';

  @override
  String get optShuffleRepeat => 'Aléatoire et répétition';

  @override
  String get groupActionBar => 'Barre d\'actions';

  @override
  String get sleepTimer => 'Minuterie de veille';

  @override
  String get playbackSpeed => 'Vitesse de lecture';

  @override
  String get equalizer => 'Égaliseur';

  @override
  String get optQueueNowPlaying => 'Carte « Lecture en cours »';

  @override
  String get optQueueArtwork => 'Pochettes';

  @override
  String get optQueueDuration => 'Durées';

  @override
  String get optQueueSwipe => 'Glisser pour retirer';

  @override
  String get miniPlayer => 'Mini-lecteur';

  @override
  String get optMiniProgress => 'Barre de progression';

  @override
  String get optMiniNext => 'Bouton suivant';

  @override
  String get resetLayout => 'Rétablir par défaut';

  @override
  String get resetLayoutDone => 'Disposition par défaut rétablie';

  @override
  String get sleepTimerOff => 'Minuterie désactivée';

  @override
  String get sleepEndOfTrack => 'À la fin du morceau';

  @override
  String sleepIn(int minutes) {
    return 'Arrêt dans $minutes min';
  }

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get speedHint => 'La hauteur du son est conservée.';

  @override
  String get eqFlat => 'Neutre';

  @override
  String get eqBass => 'Basses';

  @override
  String get eqVocal => 'Voix';

  @override
  String get eqElectronic => 'Électro';

  @override
  String get eqClassical => 'Classique';

  @override
  String get audio => 'Audio';

  @override
  String get eqUnavailable => 'Lancez un morceau pour régler l\'égaliseur.';

  @override
  String get bassBoost => 'Amplification';

  @override
  String get eqHint =>
      'Les réglages sont conservés et appliqués à tous les morceaux.';

  @override
  String get groupPlayback => 'Lecture';

  @override
  String get on => 'Activé';

  @override
  String get off => 'Désactivé';

  @override
  String get skipSilence => 'Ignorer les silences';

  @override
  String get skipSilenceSub => 'Saute les passages silencieux';

  @override
  String get lockScreen => 'Écran de verrouillage';

  @override
  String get lockScreenOption => 'LyraMusic sur l\'écran verrouillé';

  @override
  String get lockScreenSub =>
      'Affiche le lecteur quand vous verrouillez le téléphone pendant la lecture';

  @override
  String get lockPermissionBody =>
      'Pour afficher le lecteur au-dessus de l\'écran verrouillé, Android demande votre autorisation (notifications plein écran). Les réglages vont s\'ouvrir : activez l\'option pour LyraMusic, puis revenez.';

  @override
  String get allow => 'Autoriser';

  @override
  String get lockPermissionMissing => 'Autorisation nécessaire';

  @override
  String get lockPermissionMissingSub =>
      'Touchez pour ouvrir les réglages Android';

  @override
  String get widgets => 'Widgets d\'écran d\'accueil';

  @override
  String get widgetSmall => 'Widget compact (4 × 1)';

  @override
  String get widgetSmallSub => 'Morceau et commandes · touchez pour ajouter';

  @override
  String get widgetLarge => 'Widget lecteur (4 × 2)';

  @override
  String get widgetLargeSub => 'Grande pochette · touchez pour ajouter';

  @override
  String get widgetManual =>
      'Appui long sur l\'écran d\'accueil, puis Widgets › LyraMusic.';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get mostPlayed => 'Les plus écoutés';

  @override
  String get sortName => 'Nom';

  @override
  String get sortSongCount => 'Nombre de titres';

  @override
  String get ascending => 'Croissant';

  @override
  String get descending => 'Décroissant';

  @override
  String artistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artistes',
      one: '1 artiste',
      zero: '0 artiste',
    );
    return '$_temp0';
  }

  @override
  String foldersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers',
      one: '1 dossier',
      zero: '0 dossier',
    );
    return '$_temp0';
  }

  @override
  String genresCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genres',
      one: '1 genre',
      zero: '0 genre',
    );
    return '$_temp0';
  }

  @override
  String get newPlaylistSub => 'Choisir un nom et des morceaux';

  @override
  String get searchIntro => 'Rechercher dans votre musique';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get back10 => 'Reculer de 10 secondes';

  @override
  String get forward10 => 'Avancer de 10 secondes';

  @override
  String get optSeekButtons => 'Boutons ±10 s';

  @override
  String get optSeekButtonsSub =>
      'Remplacent aléatoire et répétition autour de Lecture (déplacés dans la rangée du dessous)';

  @override
  String get skip => 'Passer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get onb1Title => 'Toute votre musique, sur votre téléphone';

  @override
  String get onb1Body =>
      'Lecture hors ligne. Pas de compte, pas de streaming, pas de publicité.';

  @override
  String get onb2Title => 'Des tags propres, sans ordinateur';

  @override
  String get onb2Body =>
      'Corrigez titres, artistes et pochettes directement dans vos fichiers.';

  @override
  String get onb3Title => 'Des paroles qui suivent la musique';

  @override
  String get onb3Body =>
      'Paroles synchronisées, widgets et lecteur sur l\'écran verrouillé.';

  @override
  String get onbLyrics =>
      'La musique nous relie|Une bande-son|pour chaque histoire|Musique pour tous,|partout';

  @override
  String get auto => 'Auto';

  @override
  String get edit => 'Modifier';

  @override
  String get hapticsLabel => 'Vibrations';

  @override
  String get hapticsSub => 'Petits retours tactiles sur les gestes';

  @override
  String get themeDynamic => 'Pochette';

  @override
  String get themeClassic => 'Classique';

  @override
  String get themesGalleryHint => 'Choisissez une ambiance, ou créez la vôtre.';

  @override
  String get themeDynamicHint =>
      'Les couleurs suivent la pochette du morceau en cours.';

  @override
  String get themeCreate => 'Créer un thème';

  @override
  String get themeEdit => 'Modifier le thème';

  @override
  String get themeMine => 'Mon thème';

  @override
  String get themeSaved => 'Thème enregistré et appliqué';

  @override
  String get themeSurprise => 'Surprends-moi';

  @override
  String get themeName => 'Nom du thème';

  @override
  String get themeColors => 'Couleurs';

  @override
  String get themeBackground => 'Fond';

  @override
  String get themeText => 'Texte';

  @override
  String get themeContrastLow => 'Lisibilité faible';

  @override
  String get themeContrastOk => 'Bonne lisibilité';

  @override
  String themeContrastText(String ratio) {
    return 'Contraste du texte : $ratio:1 (4,5 conseillé)';
  }

  @override
  String get themeTipDark =>
      'Astuce : un fond très sombre économise la batterie sur les écrans OLED.';

  @override
  String get themeTipLight =>
      'Astuce : un fond crème est plus doux pour les yeux que le blanc pur.';

  @override
  String get lyricsMenu => 'Paroles…';

  @override
  String get lyricsSaved => 'Paroles enregistrées sur le téléphone';

  @override
  String get lyricsEditTitle => 'Paroles';

  @override
  String get lyricsDelete => 'Supprimer mes paroles';

  @override
  String get lyricsDeleted => 'Paroles supprimées';

  @override
  String get paste => 'Coller';

  @override
  String get lyricsHint2 =>
      'Collez ou tapez les paroles, une ligne par phrase.';

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes',
      one: '1 ligne',
      zero: 'Aucune ligne',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get syncSaved => 'Paroles synchronisées enregistrées';

  @override
  String get syncReview => 'Vérifier';

  @override
  String get syncTitle => 'Synchroniser';

  @override
  String syncProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get syncReviewHint =>
      'Touchez une ligne pour l\'écouter et ajuster son moment.';

  @override
  String get syncHint =>
      'Touchez le bouton au moment où chaque ligne commence.';

  @override
  String get syncUndo => 'Annuler';

  @override
  String get syncRestart => 'Recommencer';

  @override
  String get syncTap => 'Ligne suivante';

  @override
  String get syncShiftAll => 'Tout décaler';

  @override
  String syncAdjustLine(int line) {
    return 'Ajuster la ligne $line';
  }

  @override
  String get syncPlayAll => 'Écouter depuis le début';

  @override
  String get syncListen => 'Écouter';

  @override
  String get workshop => 'Atelier';

  @override
  String get workshopSub => 'Paroles et infos à compléter';

  @override
  String get wsNoLyrics => 'Sans paroles';

  @override
  String get wsToSync => 'À synchroniser';

  @override
  String get wsSynced => 'Synchronisées';

  @override
  String get wsMissingInfo => 'Infos manquantes';

  @override
  String get wsAdd => 'Ajouter';

  @override
  String get wsSync => 'Synchro';

  @override
  String get wsEdit => 'Modifier';

  @override
  String get wsComplete => 'Compléter';

  @override
  String get wsEmptyNone => 'Tous vos morceaux ont des paroles.';

  @override
  String get wsEmptyPlain => 'Rien à synchroniser pour l\'instant.';

  @override
  String get wsEmptySynced => 'Aucune parole synchronisée pour l\'instant.';

  @override
  String get wsEmptyInfo => 'Toutes les infos sont complètes.';

  @override
  String get wsProgressTitle => 'Paroles synchronisées';

  @override
  String wsProgressBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions enregistrées sur le téléphone',
      one: '1 contribution enregistrée sur le téléphone',
      zero: 'Aucune contribution pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get wsAllDone => 'Bibliothèque au complet, bravo !';

  @override
  String wsCountNone(int count) {
    return '$count sans paroles';
  }

  @override
  String wsCountPlain(int count) {
    return '$count à synchroniser';
  }

  @override
  String wsCountInfo(int count) {
    return '$count à compléter';
  }
}
