// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'LyraMusic';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navSettings => 'Settings';

  @override
  String get splashTagline => 'Music for everyone, everywhere.';

  @override
  String get splashPreparing => 'Preparing your library…';

  @override
  String get permTitle => 'Let LyraMusic find your songs';

  @override
  String get permBody =>
      'LyraMusic needs to read the audio files saved on this phone so your albums, artists and playlists can appear here. Nothing is uploaded anywhere.';

  @override
  String get permPoint1 => 'Reads only audio files';

  @override
  String get permPoint1Sub =>
      'Photos, messages and documents are never opened.';

  @override
  String get permPoint2 => 'Works without internet';

  @override
  String get permPoint2Sub =>
      'Scanning and playback happen entirely on this phone.';

  @override
  String get permPoint3 => 'You stay in control';

  @override
  String get permPoint3Sub =>
      'You can withdraw access at any time in the phone settings.';

  @override
  String get permAllow => 'Allow music access';

  @override
  String get permLater => 'Not now';

  @override
  String get permFootnote => 'You can change this later in the phone settings.';

  @override
  String get permDeniedTitle => 'Music access is turned off';

  @override
  String get permDeniedBody =>
      'Without access to your audio files, your library stays empty.';

  @override
  String get permOpenSettings => 'Open phone settings';

  @override
  String get scanning => 'Scanning your music…';

  @override
  String scanProgress(int done, int total) {
    return '$done of $total files';
  }

  @override
  String scanResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs in your library',
      one: '1 song in your library',
      zero: 'No songs found',
    );
    return '$_temp0';
  }

  @override
  String get scanError => 'The library could not be scanned.';

  @override
  String get rescan => 'Rescan';

  @override
  String get scanMusic => 'Scan for music';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String homeHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs, all on your device',
      one: '1 song, on your device',
      zero: 'No songs yet',
    );
    return '$_temp0';
  }

  @override
  String get resumePlayback => 'Resume playback';

  @override
  String timeLeft(String time) {
    return '$time left';
  }

  @override
  String get recentlyAdded => 'Recently added';

  @override
  String get recentlyPlayed => 'Recently played';

  @override
  String get recentlyFavorited => 'Recently favorited';

  @override
  String get yourPlaylists => 'Your playlists';

  @override
  String get manage => 'Manage';

  @override
  String get allFavorites => 'All favorites';

  @override
  String get seeAll => 'See all';

  @override
  String get badgeNew => 'New';

  @override
  String get badgeFix => 'Fix info';

  @override
  String localLibraryFooter(String songs) {
    return 'Local library · $songs';
  }

  @override
  String get shuffleAll => 'Shuffle all';

  @override
  String get play => 'Play';

  @override
  String get playAll => 'Play all';

  @override
  String get pause => 'Pause';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get shuffleOn => 'Shuffle on';

  @override
  String get shuffleOff => 'Shuffle off';

  @override
  String get repeatOff => 'Repeat off';

  @override
  String get repeatAll => 'Repeat all';

  @override
  String get repeatOne => 'Repeat one';

  @override
  String get library => 'Library';

  @override
  String get tabSongs => 'Songs';

  @override
  String get tabArtists => 'Artists';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabGenres => 'Genres';

  @override
  String get tabFolders => 'Folders';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
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
    );
    return '$_temp0';
  }

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get unknownAlbum => 'Unknown album';

  @override
  String get unknownGenre => 'Unknown genre';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortArtist => 'Artist';

  @override
  String get sortAlbum => 'Album';

  @override
  String get sortDateAdded => 'Recently added';

  @override
  String incompleteBannerTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files have incomplete information',
      one: '1 file has incomplete information',
    );
    return '$_temp0';
  }

  @override
  String get incompleteBannerText =>
      'LyraMusic never invents missing tags. Review them whenever you like.';

  @override
  String get reviewFiles => 'Review files';

  @override
  String get incompleteTitle => 'Songs to complete';

  @override
  String get foldersHint => 'Only folders containing audio are listed.';

  @override
  String get searchSubtitle => 'Your device only';

  @override
  String get searchHint => 'Songs, artists, albums, playlists';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get browseBy => 'Browse by';

  @override
  String get clear => 'Clear';

  @override
  String get clearSearch => 'Clear search';

  @override
  String searchNoResults(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get searchNoResultsText =>
      'Check the spelling, or rescan your library if the song was added recently.';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get emptyLibraryTitle => 'No music found';

  @override
  String get emptyLibraryBody =>
      'Copy MP3, FLAC or M4A files to this phone, then rescan the library.';

  @override
  String get playlists => 'Playlists';

  @override
  String localPlaylists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count local playlists',
      one: '1 local playlist',
      zero: 'No local playlists',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get history => 'History';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get playlistName => 'Playlist name';

  @override
  String get create => 'Create';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get change => 'Change';

  @override
  String get toggleView => 'Change view';

  @override
  String get deletePlaylistTitle => 'Delete this playlist?';

  @override
  String deletePlaylistBody(String name) {
    return '“$name” will be removed. Your music files are not deleted.';
  }

  @override
  String get playlistCreated => 'Playlist created';

  @override
  String addedToPlaylist(String name) {
    return 'Added to $name';
  }

  @override
  String get playlistsLocalTitle => 'Playlists live on this device';

  @override
  String get playlistsLocalText =>
      'Nothing is synced or uploaded. A song can appear more than once in the same playlist.';

  @override
  String get emptyPlaylistTitle => 'This playlist is empty';

  @override
  String get emptyPlaylistBody => 'Add songs to start listening.';

  @override
  String get noPlaylistsTitle => 'No playlists yet';

  @override
  String get noPlaylistsBody =>
      'Create a playlist to group the songs you love.';

  @override
  String get noFavoritesTitle => 'No favorites yet';

  @override
  String get noFavoritesBody => 'Tap the heart on a song to find it here.';

  @override
  String get addedToFavorites => 'Added to Favorites';

  @override
  String get removedFromFavorites => 'Removed from Favorites';

  @override
  String get addSongs => 'Add songs';

  @override
  String get searchSongs => 'Search songs';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs selected',
      one: '1 song selected',
      zero: 'No song selected',
    );
    return '$_temp0';
  }

  @override
  String get historyToday => 'Today';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get historyThisWeek => 'This week';

  @override
  String get historyEarlier => 'Earlier';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryTitle => 'Clear listening history?';

  @override
  String get clearHistoryBody =>
      'Your songs, favorites and playlists are not affected.';

  @override
  String get historyEmptyTitle => 'No listening history yet';

  @override
  String get historyEmptyBody => 'Songs you play will appear here.';

  @override
  String get playNext => 'Play next';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get goToArtist => 'Go to artist';

  @override
  String get goToAlbum => 'Go to album';

  @override
  String get songDetails => 'Song details';

  @override
  String get editTags => 'Edit information';

  @override
  String get removeFromPlaylist => 'Remove from playlist';

  @override
  String get willPlayNext => 'Will play next';

  @override
  String get addedToQueue => 'Added to queue';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String fromAlbum(String album) {
    return 'from $album';
  }

  @override
  String get queue => 'Queue';

  @override
  String get playingQueue => 'Playing queue';

  @override
  String get upNext => 'Up next';

  @override
  String nextUpCount(int count) {
    return 'Next up · $count';
  }

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get shuffleQueue => 'Shuffle queue';

  @override
  String get queueCleared => 'Queue cleared';

  @override
  String get queueEmpty => 'The queue is empty';

  @override
  String get queueEmptyBody =>
      'Add songs from your library, an album or a playlist to keep the music going.';

  @override
  String get openLibrary => 'Open library';

  @override
  String get removeFromQueue => 'Remove from queue';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get lyricsSynced => 'Synced lyrics';

  @override
  String get lyricsUnsynced => 'Not synced';

  @override
  String get lyricsStoredLocally => 'Stored on device · available offline';

  @override
  String get lyricsUnavailable => 'Lyrics unavailable';

  @override
  String get lyricsNoneText =>
      'No lyrics are stored in this file, and no .lrc file with the same name was found next to it.';

  @override
  String get detailsFile => 'File';

  @override
  String get detailsFormat => 'Format';

  @override
  String get detailsBitrate => 'Bitrate';

  @override
  String get detailsSampleRate => 'Sample rate';

  @override
  String get detailsDuration => 'Duration';

  @override
  String get detailsSize => 'File size';

  @override
  String get detailsLocation => 'Location';

  @override
  String get detailsTags => 'Tags';

  @override
  String get badgeMissing => 'Missing';

  @override
  String get badgeIncomplete => 'Incomplete';

  @override
  String get missingInfoTitle => 'Some information is missing';

  @override
  String get missingInfoText =>
      'LyraMusic never invents tags. The file plays normally — you can complete it whenever you like.';

  @override
  String get chooseArtwork => 'Choose artwork';

  @override
  String fileOfType(String format) {
    return '$format file';
  }

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldArtist => 'Artist';

  @override
  String get fieldAlbum => 'Album';

  @override
  String get fieldAlbumArtist => 'Album artist';

  @override
  String get fieldGenre => 'Genre';

  @override
  String get fieldYear => 'Year';

  @override
  String get fieldTrackNumber => 'Track no.';

  @override
  String get titleRequired => 'The title cannot be empty';

  @override
  String get yearInvalid => '4 digits';

  @override
  String get numberInvalid => 'Enter a number';

  @override
  String get notSupportedForFormat => 'Not supported for this format';

  @override
  String get artwork => 'Artwork';

  @override
  String get artworkEmbedded => 'Embedded in the file';

  @override
  String get artworkNew => 'New artwork, saved with the file';

  @override
  String get artworkChoose => 'Choose from gallery';

  @override
  String get artworkRemove => 'Remove artwork';

  @override
  String get artworkNone => 'No artwork embedded in this file';

  @override
  String get tagsWriteInfo =>
      'Changes are written directly into the audio file. Android will ask for your permission.';

  @override
  String get tagsSaved => 'Tags written to file';

  @override
  String get tagsErrorDenied =>
      'Permission to modify this file was refused. Nothing was changed.';

  @override
  String get tagsErrorWrite =>
      'The file could not be modified. The original file is unchanged.';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardBody => 'Your changes have not been saved.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get settings => 'Settings';

  @override
  String get groupAppearance => 'Appearance';

  @override
  String get groupLibrary => 'Library';

  @override
  String get groupData => 'Data';

  @override
  String get groupSystem => 'System';

  @override
  String get groupAbout => 'About';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get permissions => 'Permissions';

  @override
  String get permissionGranted => 'Music access granted';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyValue => 'No account, no tracking, no cloud';

  @override
  String get licences => 'Open source licences';

  @override
  String get version => 'Version';

  @override
  String get settingsFooter =>
      'Your music never leaves this phone. No internet connection is needed.';

  @override
  String get cannotPlay =>
      'This file cannot be played. It may have been moved or deleted.';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get appearance => 'Appearance';

  @override
  String get accentColor => 'Main colour';

  @override
  String get accentHint =>
      'Used for buttons, the current song and active controls.';

  @override
  String get accentClassic => 'Classic';

  @override
  String get accentSand => 'Sand';

  @override
  String get accentTaupe => 'Taupe';

  @override
  String get accentSage => 'Sage';

  @override
  String get accentTerracotta => 'Terracotta';

  @override
  String get accentOcean => 'Ocean';

  @override
  String get accentMint => 'Mint';

  @override
  String get accentViolet => 'Violet';

  @override
  String get preview => 'Preview';

  @override
  String get listenNow => 'Listen now';

  @override
  String get playerLayout => 'Now playing screen';

  @override
  String get playerLayoutSub => 'Choose what is shown';

  @override
  String get playerLayoutHint =>
      'Show or hide each element of the player, the queue and the mini-player.';

  @override
  String get artRounded => 'Rounded';

  @override
  String get artSquare => 'Square';

  @override
  String get artVinyl => 'Vinyl';

  @override
  String get bgBlur => 'Blurred';

  @override
  String get bgGradient => 'Gradient';

  @override
  String get bgPlain => 'Plain';

  @override
  String get optSwipe => 'Swipe the artwork';

  @override
  String get optSwipeSub => 'Left: next song · right: previous';

  @override
  String get groupInfo => 'Information';

  @override
  String get optAlbumInfo => 'Album and year';

  @override
  String get optFormat => 'Audio format';

  @override
  String get optRemaining => 'Remaining time';

  @override
  String get optRemainingSub => 'Otherwise the total duration is shown';

  @override
  String get optNextUp => 'Next song preview';

  @override
  String get groupControls => 'Controls';

  @override
  String get optVolume => 'Volume';

  @override
  String get optVolumeSub => 'Same as the phone\'s volume buttons';

  @override
  String get optFavorite => 'Favourite button';

  @override
  String get optShuffleRepeat => 'Shuffle and repeat';

  @override
  String get groupActionBar => 'Action bar';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get optQueueNowPlaying => 'Now playing card';

  @override
  String get optQueueArtwork => 'Artwork';

  @override
  String get optQueueDuration => 'Durations';

  @override
  String get optQueueSwipe => 'Swipe to remove';

  @override
  String get miniPlayer => 'Mini-player';

  @override
  String get optMiniProgress => 'Progress bar';

  @override
  String get optMiniNext => 'Next button';

  @override
  String get resetLayout => 'Restore defaults';

  @override
  String get resetLayoutDone => 'Default layout restored';

  @override
  String get sleepTimerOff => 'Sleep timer off';

  @override
  String get sleepEndOfTrack => 'At the end of the song';

  @override
  String sleepIn(int minutes) {
    return 'Stops in $minutes min';
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
  String get speedHint => 'The pitch is kept.';

  @override
  String get eqFlat => 'Flat';

  @override
  String get eqBass => 'Bass';

  @override
  String get eqVocal => 'Vocal';

  @override
  String get eqElectronic => 'Electronic';

  @override
  String get eqClassical => 'Classical';

  @override
  String get audio => 'Audio';

  @override
  String get eqUnavailable => 'Start playing a song to adjust the equalizer.';

  @override
  String get bassBoost => 'Volume boost';

  @override
  String get eqHint => 'Settings are kept and applied to every song.';

  @override
  String get groupPlayback => 'Playback';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get skipSilence => 'Skip silences';

  @override
  String get skipSilenceSub => 'Skips silent parts in songs';

  @override
  String get lockScreen => 'Lock screen';

  @override
  String get lockScreenOption => 'LyraMusic on the lock screen';

  @override
  String get lockScreenSub =>
      'Shows the player when you lock the phone during playback';

  @override
  String get lockPermissionBody =>
      'To show the player above the lock screen, Android needs your permission (full-screen notifications). The settings will open: turn on the option for LyraMusic, then come back.';

  @override
  String get allow => 'Allow';

  @override
  String get lockPermissionMissing => 'Permission needed';

  @override
  String get lockPermissionMissingSub => 'Tap to open the Android settings';

  @override
  String get widgets => 'Home screen widgets';

  @override
  String get widgetSmall => 'Compact widget (4 × 1)';

  @override
  String get widgetSmallSub => 'Song and controls · tap to add';

  @override
  String get widgetLarge => 'Player widget (4 × 2)';

  @override
  String get widgetLargeSub => 'Large artwork · tap to add';

  @override
  String get widgetManual =>
      'Long-press your home screen, then Widgets › LyraMusic.';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get mostPlayed => 'Most played';

  @override
  String get sortName => 'Name';

  @override
  String get sortSongCount => 'Number of songs';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String artistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artists',
      one: '1 artist',
    );
    return '$_temp0';
  }

  @override
  String foldersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders',
      one: '1 folder',
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
    );
    return '$_temp0';
  }

  @override
  String get newPlaylistSub => 'Choose a name and songs';

  @override
  String get searchIntro => 'Search your music';

  @override
  String get clearAll => 'Clear all';

  @override
  String get back10 => 'Back 10 seconds';

  @override
  String get forward10 => 'Forward 10 seconds';

  @override
  String get optSeekButtons => '±10 s buttons';

  @override
  String get optSeekButtonsSub =>
      'Replace shuffle and repeat next to Play (they move to the row below)';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get started';

  @override
  String get onb1Title => 'All your music, on your phone';

  @override
  String get onb1Body => 'Plays offline. No account, no streaming, no ads.';

  @override
  String get onb2Title => 'Clean tags, no computer needed';

  @override
  String get onb2Body =>
      'Fix titles, artists and covers right inside your files.';

  @override
  String get onb3Title => 'Lyrics that follow the music';

  @override
  String get onb3Body =>
      'Synced lyrics, home screen widgets and a lock screen player.';

  @override
  String get onbLyrics =>
      'Music brings us together|A soundtrack|for every story|Music for everyone,|everywhere';

  @override
  String get auto => 'Auto';

  @override
  String get edit => 'Edit';

  @override
  String get hapticsLabel => 'Haptics';

  @override
  String get hapticsSub => 'Subtle feedback on gestures';

  @override
  String get themeDynamic => 'Artwork';

  @override
  String get themeClassic => 'Classic';

  @override
  String get themesGalleryHint => 'Pick a mood, or create your own.';

  @override
  String get themeDynamicHint =>
      'Colors follow the artwork of the current song.';

  @override
  String get themeCreate => 'Create a theme';

  @override
  String get themeEdit => 'Edit theme';

  @override
  String get themeMine => 'My theme';

  @override
  String get themeSaved => 'Theme saved and applied';

  @override
  String get themeSurprise => 'Surprise me';

  @override
  String get themeName => 'Theme name';

  @override
  String get themeColors => 'Colors';

  @override
  String get themeBackground => 'Background';

  @override
  String get themeText => 'Text';

  @override
  String get themeContrastLow => 'Low readability';

  @override
  String get themeContrastOk => 'Good readability';

  @override
  String themeContrastText(String ratio) {
    return 'Text contrast: $ratio:1 (4.5 recommended)';
  }

  @override
  String get themeTipDark =>
      'Tip: a very dark background saves battery on OLED screens.';

  @override
  String get themeTipLight =>
      'Tip: a cream background is easier on the eyes than pure white.';

  @override
  String get lyricsMenu => 'Lyrics…';

  @override
  String get lyricsSaved => 'Lyrics saved on your device';

  @override
  String get lyricsEditTitle => 'Lyrics';

  @override
  String get lyricsDelete => 'Delete my lyrics';

  @override
  String get lyricsDeleted => 'Lyrics deleted';

  @override
  String get paste => 'Paste';

  @override
  String get lyricsHint2 => 'Paste or type the lyrics, one line per phrase.';

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
      zero: 'No lines',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sync';

  @override
  String get syncSaved => 'Synced lyrics saved';

  @override
  String get syncReview => 'Review';

  @override
  String get syncTitle => 'Sync lyrics';

  @override
  String syncProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get syncReviewHint => 'Tap a line to hear it and adjust its timing.';

  @override
  String get syncHint => 'Tap the button right when each line starts.';

  @override
  String get syncUndo => 'Undo';

  @override
  String get syncRestart => 'Start over';

  @override
  String get syncTap => 'Next line';

  @override
  String get syncShiftAll => 'Shift all';

  @override
  String syncAdjustLine(int line) {
    return 'Adjust line $line';
  }

  @override
  String get syncPlayAll => 'Play from the start';

  @override
  String get syncListen => 'Listen';

  @override
  String get workshop => 'Workshop';

  @override
  String get workshopSub => 'Lyrics and tags to complete';

  @override
  String get wsNoLyrics => 'No lyrics';

  @override
  String get wsToSync => 'To sync';

  @override
  String get wsSynced => 'Synced';

  @override
  String get wsMissingInfo => 'Missing info';

  @override
  String get wsAdd => 'Add';

  @override
  String get wsSync => 'Sync';

  @override
  String get wsEdit => 'Edit';

  @override
  String get wsComplete => 'Complete';

  @override
  String get wsEmptyNone => 'All your songs have lyrics.';

  @override
  String get wsEmptyPlain => 'Nothing to sync for now.';

  @override
  String get wsEmptySynced => 'No synced lyrics yet.';

  @override
  String get wsEmptyInfo => 'All tags are complete.';

  @override
  String get wsProgressTitle => 'Synced lyrics';

  @override
  String wsProgressBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions saved on your device',
      one: '1 contribution saved on your device',
      zero: 'No contributions yet',
    );
    return '$_temp0';
  }

  @override
  String get wsAllDone => 'Library complete, well done!';

  @override
  String wsCountNone(int count) {
    return '$count without lyrics';
  }

  @override
  String wsCountPlain(int count) {
    return '$count to sync';
  }

  @override
  String wsCountInfo(int count) {
    return '$count to complete';
  }

  @override
  String get close => 'Close';

  @override
  String get guideLink => 'How does the Workshop work?';

  @override
  String get guideStart => 'Let\'s go';

  @override
  String get guide1Title => 'Add lyrics';

  @override
  String get guide1Body =>
      'Paste or type a song\'s lyrics, one line per phrase. They\'re saved on your phone, without touching the file.';

  @override
  String get guide2Title => 'Sync to the beat';

  @override
  String get guide2Body =>
      'Play the song and tap the button as each line starts. Then fine-tune to a tenth of a second.';

  @override
  String get guide3Title => 'Create a LyricsCard';

  @override
  String get guide3Body =>
      'Pick an excerpt, a background and a font, then save the image to your gallery or share it.';

  @override
  String get wsAddLyrics => 'Add lyrics';

  @override
  String get wsSyncSongs => 'Sync songs';

  @override
  String get lcCreateShort => 'LyricsCard';

  @override
  String get lcCreate => 'Create a LyricsCard';

  @override
  String get lcTabText => 'Text';

  @override
  String get lcTabImage => 'Image';

  @override
  String get lcTabFont => 'Font';

  @override
  String get lcChange => 'Change';

  @override
  String get lcPickSong => 'Songs with lyrics';

  @override
  String get lcNoSongs => 'No songs with lyrics';

  @override
  String get lcNoSongsBody => 'Add lyrics from the Workshop to create a card.';

  @override
  String get lcSelectHint =>
      'Tap a line, then another to extend. Long-press to adjust character by character.';

  @override
  String get lcClear => 'Clear selection';

  @override
  String get lcTooLong => 'Too long: 113 characters max';

  @override
  String get lcPlaceholder => 'Pick an excerpt from the lyrics';

  @override
  String get lcContinue => 'Continue';

  @override
  String get lcArtwork => 'Artwork';

  @override
  String get lcGallery => 'Gallery';

  @override
  String get lcDim => 'Darken';

  @override
  String get lcBlur => 'Blur';

  @override
  String get lcFormat => 'Format';

  @override
  String get lcSize => 'Size';

  @override
  String get lcAlign => 'Alignment';

  @override
  String get lcColor => 'Text color';

  @override
  String get lcShowInfo => 'Title and artist';

  @override
  String get lcExport => 'Export';

  @override
  String get lcSave => 'Save to gallery';

  @override
  String get lcShare => 'Share';

  @override
  String get lcSaved => 'Card saved to your gallery';

  @override
  String get lcSaveDenied => 'Storage access denied';

  @override
  String get lcError => 'Export failed';
}
