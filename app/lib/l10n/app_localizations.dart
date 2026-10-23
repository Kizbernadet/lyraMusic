import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'LyraMusic'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Music for everyone, everywhere.'**
  String get splashTagline;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your library…'**
  String get splashPreparing;

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Let LyraMusic find your songs'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In en, this message translates to:
  /// **'LyraMusic needs to read the audio files saved on this phone so your albums, artists and playlists can appear here. Nothing is uploaded anywhere.'**
  String get permBody;

  /// No description provided for @permPoint1.
  ///
  /// In en, this message translates to:
  /// **'Reads only audio files'**
  String get permPoint1;

  /// No description provided for @permPoint1Sub.
  ///
  /// In en, this message translates to:
  /// **'Photos, messages and documents are never opened.'**
  String get permPoint1Sub;

  /// No description provided for @permPoint2.
  ///
  /// In en, this message translates to:
  /// **'Works without internet'**
  String get permPoint2;

  /// No description provided for @permPoint2Sub.
  ///
  /// In en, this message translates to:
  /// **'Scanning and playback happen entirely on this phone.'**
  String get permPoint2Sub;

  /// No description provided for @permPoint3.
  ///
  /// In en, this message translates to:
  /// **'You stay in control'**
  String get permPoint3;

  /// No description provided for @permPoint3Sub.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw access at any time in the phone settings.'**
  String get permPoint3Sub;

  /// No description provided for @permAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow music access'**
  String get permAllow;

  /// No description provided for @permLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permLater;

  /// No description provided for @permFootnote.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in the phone settings.'**
  String get permFootnote;

  /// No description provided for @permDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Music access is turned off'**
  String get permDeniedTitle;

  /// No description provided for @permDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Without access to your audio files, your library stays empty.'**
  String get permDeniedBody;

  /// No description provided for @permOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open phone settings'**
  String get permOpenSettings;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning your music…'**
  String get scanning;

  /// No description provided for @scanProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} files'**
  String scanProgress(int done, int total);

  /// No description provided for @scanResult.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No songs found} =1{1 song in your library} other{{count} songs in your library}}'**
  String scanResult(int count);

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'The library could not be scanned.'**
  String get scanError;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @scanMusic.
  ///
  /// In en, this message translates to:
  /// **'Scan for music'**
  String get scanMusic;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No songs yet} =1{1 song, on your device} other{{count} songs, all on your device}}'**
  String homeHeadline(int count);

  /// No description provided for @resumePlayback.
  ///
  /// In en, this message translates to:
  /// **'Resume playback'**
  String get resumePlayback;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String timeLeft(String time);

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get recentlyAdded;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get recentlyPlayed;

  /// No description provided for @recentlyFavorited.
  ///
  /// In en, this message translates to:
  /// **'Recently favorited'**
  String get recentlyFavorited;

  /// No description provided for @yourPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Your playlists'**
  String get yourPlaylists;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @allFavorites.
  ///
  /// In en, this message translates to:
  /// **'All favorites'**
  String get allFavorites;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// No description provided for @badgeFix.
  ///
  /// In en, this message translates to:
  /// **'Fix info'**
  String get badgeFix;

  /// No description provided for @localLibraryFooter.
  ///
  /// In en, this message translates to:
  /// **'Local library · {songs}'**
  String localLibraryFooter(String songs);

  /// No description provided for @shuffleAll.
  ///
  /// In en, this message translates to:
  /// **'Shuffle all'**
  String get shuffleAll;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playAll.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get playAll;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @shuffleOn.
  ///
  /// In en, this message translates to:
  /// **'Shuffle on'**
  String get shuffleOn;

  /// No description provided for @shuffleOff.
  ///
  /// In en, this message translates to:
  /// **'Shuffle off'**
  String get shuffleOff;

  /// No description provided for @repeatOff.
  ///
  /// In en, this message translates to:
  /// **'Repeat off'**
  String get repeatOff;

  /// No description provided for @repeatAll.
  ///
  /// In en, this message translates to:
  /// **'Repeat all'**
  String get repeatAll;

  /// No description provided for @repeatOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat one'**
  String get repeatOne;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @tabSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get tabSongs;

  /// No description provided for @tabArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get tabArtists;

  /// No description provided for @tabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get tabAlbums;

  /// No description provided for @tabGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get tabGenres;

  /// No description provided for @tabFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get tabFolders;

  /// No description provided for @songsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String songsCount(int count);

  /// No description provided for @albumsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 album} other{{count} albums}}'**
  String albumsCount(int count);

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown album'**
  String get unknownAlbum;

  /// No description provided for @unknownGenre.
  ///
  /// In en, this message translates to:
  /// **'Unknown genre'**
  String get unknownGenre;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @sortArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get sortArtist;

  /// No description provided for @sortAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get sortAlbum;

  /// No description provided for @sortDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortDateAdded;

  /// No description provided for @incompleteBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file has incomplete information} other{{count} files have incomplete information}}'**
  String incompleteBannerTitle(int count);

  /// No description provided for @incompleteBannerText.
  ///
  /// In en, this message translates to:
  /// **'LyraMusic never invents missing tags. Review them whenever you like.'**
  String get incompleteBannerText;

  /// No description provided for @reviewFiles.
  ///
  /// In en, this message translates to:
  /// **'Review files'**
  String get reviewFiles;

  /// No description provided for @incompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Songs to complete'**
  String get incompleteTitle;

  /// No description provided for @foldersHint.
  ///
  /// In en, this message translates to:
  /// **'Only folders containing audio are listed.'**
  String get foldersHint;

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your device only'**
  String get searchSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Songs, artists, albums, playlists'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @browseBy.
  ///
  /// In en, this message translates to:
  /// **'Browse by'**
  String get browseBy;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String searchNoResults(String query);

  /// No description provided for @searchNoResultsText.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or rescan your library if the song was added recently.'**
  String get searchNoResultsText;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String resultsCount(int count);

  /// No description provided for @emptyLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'No music found'**
  String get emptyLibraryTitle;

  /// No description provided for @emptyLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Copy MP3, FLAC or M4A files to this phone, then rescan the library.'**
  String get emptyLibraryBody;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @localPlaylists.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No local playlists} =1{1 local playlist} other{{count} local playlists}}'**
  String localPlaylists(int count);

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @newPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get newPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @toggleView.
  ///
  /// In en, this message translates to:
  /// **'Change view'**
  String get toggleView;

  /// No description provided for @deletePlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this playlist?'**
  String get deletePlaylistTitle;

  /// No description provided for @deletePlaylistBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed. Your music files are not deleted.'**
  String deletePlaylistBody(String name);

  /// No description provided for @playlistCreated.
  ///
  /// In en, this message translates to:
  /// **'Playlist created'**
  String get playlistCreated;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToPlaylist(String name);

  /// No description provided for @playlistsLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlists live on this device'**
  String get playlistsLocalTitle;

  /// No description provided for @playlistsLocalText.
  ///
  /// In en, this message translates to:
  /// **'Nothing is synced or uploaded. A song can appear more than once in the same playlist.'**
  String get playlistsLocalText;

  /// No description provided for @emptyPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty'**
  String get emptyPlaylistTitle;

  /// No description provided for @emptyPlaylistBody.
  ///
  /// In en, this message translates to:
  /// **'Add songs to start listening.'**
  String get emptyPlaylistBody;

  /// No description provided for @noPlaylistsTitle.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get noPlaylistsTitle;

  /// No description provided for @noPlaylistsBody.
  ///
  /// In en, this message translates to:
  /// **'Create a playlist to group the songs you love.'**
  String get noPlaylistsBody;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a song to find it here.'**
  String get noFavoritesBody;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from Favorites'**
  String get removedFromFavorites;

  /// No description provided for @addSongs.
  ///
  /// In en, this message translates to:
  /// **'Add songs'**
  String get addSongs;

  /// No description provided for @searchSongs.
  ///
  /// In en, this message translates to:
  /// **'Search songs'**
  String get searchSongs;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No song selected} =1{1 song selected} other{{count} songs selected}}'**
  String selectedCount(int count);

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// No description provided for @historyThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get historyThisWeek;

  /// No description provided for @historyEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get historyEarlier;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear listening history?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Your songs, favorites and playlists are not affected.'**
  String get clearHistoryBody;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No listening history yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Songs you play will appear here.'**
  String get historyEmptyBody;

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @goToArtist.
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get goToArtist;

  /// No description provided for @goToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Go to album'**
  String get goToAlbum;

  /// No description provided for @songDetails.
  ///
  /// In en, this message translates to:
  /// **'Song details'**
  String get songDetails;

  /// No description provided for @editTags.
  ///
  /// In en, this message translates to:
  /// **'Edit information'**
  String get editTags;

  /// No description provided for @removeFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get removeFromPlaylist;

  /// No description provided for @willPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Will play next'**
  String get willPlayNext;

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get addedToQueue;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// No description provided for @fromAlbum.
  ///
  /// In en, this message translates to:
  /// **'from {album}'**
  String fromAlbum(String album);

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @playingQueue.
  ///
  /// In en, this message translates to:
  /// **'Playing queue'**
  String get playingQueue;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @nextUpCount.
  ///
  /// In en, this message translates to:
  /// **'Next up · {count}'**
  String nextUpCount(int count);

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @shuffleQueue.
  ///
  /// In en, this message translates to:
  /// **'Shuffle queue'**
  String get shuffleQueue;

  /// No description provided for @queueCleared.
  ///
  /// In en, this message translates to:
  /// **'Queue cleared'**
  String get queueCleared;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'The queue is empty'**
  String get queueEmpty;

  /// No description provided for @queueEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add songs from your library, an album or a playlist to keep the music going.'**
  String get queueEmptyBody;

  /// No description provided for @openLibrary.
  ///
  /// In en, this message translates to:
  /// **'Open library'**
  String get openLibrary;

  /// No description provided for @removeFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get removeFromQueue;

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @lyricsSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced lyrics'**
  String get lyricsSynced;

  /// No description provided for @lyricsUnsynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get lyricsUnsynced;

  /// No description provided for @lyricsStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'Stored on device · available offline'**
  String get lyricsStoredLocally;

  /// No description provided for @lyricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Lyrics unavailable'**
  String get lyricsUnavailable;

  /// No description provided for @lyricsNoneText.
  ///
  /// In en, this message translates to:
  /// **'No lyrics are stored in this file, and no .lrc file with the same name was found next to it.'**
  String get lyricsNoneText;

  /// No description provided for @detailsFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get detailsFile;

  /// No description provided for @detailsFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get detailsFormat;

  /// No description provided for @detailsBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get detailsBitrate;

  /// No description provided for @detailsSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get detailsSampleRate;

  /// No description provided for @detailsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get detailsDuration;

  /// No description provided for @detailsSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get detailsSize;

  /// No description provided for @detailsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get detailsLocation;

  /// No description provided for @detailsTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get detailsTags;

  /// No description provided for @badgeMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get badgeMissing;

  /// No description provided for @badgeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get badgeIncomplete;

  /// No description provided for @missingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Some information is missing'**
  String get missingInfoTitle;

  /// No description provided for @missingInfoText.
  ///
  /// In en, this message translates to:
  /// **'LyraMusic never invents tags. The file plays normally — you can complete it whenever you like.'**
  String get missingInfoText;

  /// No description provided for @chooseArtwork.
  ///
  /// In en, this message translates to:
  /// **'Choose artwork'**
  String get chooseArtwork;

  /// No description provided for @fileOfType.
  ///
  /// In en, this message translates to:
  /// **'{format} file'**
  String fileOfType(String format);

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get fieldArtist;

  /// No description provided for @fieldAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get fieldAlbum;

  /// No description provided for @fieldAlbumArtist.
  ///
  /// In en, this message translates to:
  /// **'Album artist'**
  String get fieldAlbumArtist;

  /// No description provided for @fieldGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get fieldGenre;

  /// No description provided for @fieldYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get fieldYear;

  /// No description provided for @fieldTrackNumber.
  ///
  /// In en, this message translates to:
  /// **'Track no.'**
  String get fieldTrackNumber;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'The title cannot be empty'**
  String get titleRequired;

  /// No description provided for @yearInvalid.
  ///
  /// In en, this message translates to:
  /// **'4 digits'**
  String get yearInvalid;

  /// No description provided for @numberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get numberInvalid;

  /// No description provided for @notSupportedForFormat.
  ///
  /// In en, this message translates to:
  /// **'Not supported for this format'**
  String get notSupportedForFormat;

  /// No description provided for @artwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get artwork;

  /// No description provided for @artworkEmbedded.
  ///
  /// In en, this message translates to:
  /// **'Embedded in the file'**
  String get artworkEmbedded;

  /// No description provided for @artworkNew.
  ///
  /// In en, this message translates to:
  /// **'New artwork, saved with the file'**
  String get artworkNew;

  /// No description provided for @artworkChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get artworkChoose;

  /// No description provided for @artworkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove artwork'**
  String get artworkRemove;

  /// No description provided for @artworkNone.
  ///
  /// In en, this message translates to:
  /// **'No artwork embedded in this file'**
  String get artworkNone;

  /// No description provided for @tagsWriteInfo.
  ///
  /// In en, this message translates to:
  /// **'Changes are written directly into the audio file. Android will ask for your permission.'**
  String get tagsWriteInfo;

  /// No description provided for @tagsSaved.
  ///
  /// In en, this message translates to:
  /// **'Tags written to file'**
  String get tagsSaved;

  /// No description provided for @tagsErrorDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission to modify this file was refused. Nothing was changed.'**
  String get tagsErrorDenied;

  /// No description provided for @tagsErrorWrite.
  ///
  /// In en, this message translates to:
  /// **'The file could not be modified. The original file is unchanged.'**
  String get tagsErrorWrite;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes have not been saved.'**
  String get discardBody;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @groupAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get groupAppearance;

  /// No description provided for @groupLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get groupLibrary;

  /// No description provided for @groupData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get groupData;

  /// No description provided for @groupSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get groupSystem;

  /// No description provided for @groupAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get groupAbout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languageSystem;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Music access granted'**
  String get permissionGranted;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyValue.
  ///
  /// In en, this message translates to:
  /// **'No account, no tracking, no cloud'**
  String get privacyValue;

  /// No description provided for @licences.
  ///
  /// In en, this message translates to:
  /// **'Open source licences'**
  String get licences;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'Your music never leaves this phone. No internet connection is needed.'**
  String get settingsFooter;

  /// No description provided for @cannotPlay.
  ///
  /// In en, this message translates to:
  /// **'This file cannot be played. It may have been moved or deleted.'**
  String get cannotPlay;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Main colour'**
  String get accentColor;

  /// No description provided for @accentHint.
  ///
  /// In en, this message translates to:
  /// **'Used for buttons, the current song and active controls.'**
  String get accentHint;

  /// No description provided for @accentClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get accentClassic;

  /// No description provided for @accentSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get accentSand;

  /// No description provided for @accentTaupe.
  ///
  /// In en, this message translates to:
  /// **'Taupe'**
  String get accentTaupe;

  /// No description provided for @accentSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get accentSage;

  /// No description provided for @accentTerracotta.
  ///
  /// In en, this message translates to:
  /// **'Terracotta'**
  String get accentTerracotta;

  /// No description provided for @accentOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get accentOcean;

  /// No description provided for @accentMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get accentMint;

  /// No description provided for @accentViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get accentViolet;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @listenNow.
  ///
  /// In en, this message translates to:
  /// **'Listen now'**
  String get listenNow;

  /// No description provided for @playerLayout.
  ///
  /// In en, this message translates to:
  /// **'Now playing screen'**
  String get playerLayout;

  /// No description provided for @playerLayoutSub.
  ///
  /// In en, this message translates to:
  /// **'Choose what is shown'**
  String get playerLayoutSub;

  /// No description provided for @playerLayoutHint.
  ///
  /// In en, this message translates to:
  /// **'Show or hide each element of the player, the queue and the mini-player.'**
  String get playerLayoutHint;

  /// No description provided for @artRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get artRounded;

  /// No description provided for @artSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get artSquare;

  /// No description provided for @artVinyl.
  ///
  /// In en, this message translates to:
  /// **'Vinyl'**
  String get artVinyl;

  /// No description provided for @bgBlur.
  ///
  /// In en, this message translates to:
  /// **'Blurred'**
  String get bgBlur;

  /// No description provided for @bgGradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get bgGradient;

  /// No description provided for @bgPlain.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get bgPlain;

  /// No description provided for @optSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe the artwork'**
  String get optSwipe;

  /// No description provided for @optSwipeSub.
  ///
  /// In en, this message translates to:
  /// **'Left: next song · right: previous'**
  String get optSwipeSub;

  /// No description provided for @groupInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get groupInfo;

  /// No description provided for @optAlbumInfo.
  ///
  /// In en, this message translates to:
  /// **'Album and year'**
  String get optAlbumInfo;

  /// No description provided for @optFormat.
  ///
  /// In en, this message translates to:
  /// **'Audio format'**
  String get optFormat;

  /// No description provided for @optRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get optRemaining;

  /// No description provided for @optRemainingSub.
  ///
  /// In en, this message translates to:
  /// **'Otherwise the total duration is shown'**
  String get optRemainingSub;

  /// No description provided for @optNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next song preview'**
  String get optNextUp;

  /// No description provided for @groupControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get groupControls;

  /// No description provided for @optVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get optVolume;

  /// No description provided for @optVolumeSub.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone\'s volume buttons'**
  String get optVolumeSub;

  /// No description provided for @optFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favourite button'**
  String get optFavorite;

  /// No description provided for @optShuffleRepeat.
  ///
  /// In en, this message translates to:
  /// **'Shuffle and repeat'**
  String get optShuffleRepeat;

  /// No description provided for @groupActionBar.
  ///
  /// In en, this message translates to:
  /// **'Action bar'**
  String get groupActionBar;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playbackSpeed;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @optQueueNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing card'**
  String get optQueueNowPlaying;

  /// No description provided for @optQueueArtwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get optQueueArtwork;

  /// No description provided for @optQueueDuration.
  ///
  /// In en, this message translates to:
  /// **'Durations'**
  String get optQueueDuration;

  /// No description provided for @optQueueSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe to remove'**
  String get optQueueSwipe;

  /// No description provided for @miniPlayer.
  ///
  /// In en, this message translates to:
  /// **'Mini-player'**
  String get miniPlayer;

  /// No description provided for @optMiniProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress bar'**
  String get optMiniProgress;

  /// No description provided for @optMiniNext.
  ///
  /// In en, this message translates to:
  /// **'Next button'**
  String get optMiniNext;

  /// No description provided for @resetLayout.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get resetLayout;

  /// No description provided for @resetLayoutDone.
  ///
  /// In en, this message translates to:
  /// **'Default layout restored'**
  String get resetLayoutDone;

  /// No description provided for @sleepTimerOff.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer off'**
  String get sleepTimerOff;

  /// No description provided for @sleepEndOfTrack.
  ///
  /// In en, this message translates to:
  /// **'At the end of the song'**
  String get sleepEndOfTrack;

  /// No description provided for @sleepIn.
  ///
  /// In en, this message translates to:
  /// **'Stops in {minutes} min'**
  String sleepIn(int minutes);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minutes(int count);

  /// No description provided for @speedHint.
  ///
  /// In en, this message translates to:
  /// **'The pitch is kept.'**
  String get speedHint;

  /// No description provided for @eqFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get eqFlat;

  /// No description provided for @eqBass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get eqBass;

  /// No description provided for @eqVocal.
  ///
  /// In en, this message translates to:
  /// **'Vocal'**
  String get eqVocal;

  /// No description provided for @eqElectronic.
  ///
  /// In en, this message translates to:
  /// **'Electronic'**
  String get eqElectronic;

  /// No description provided for @eqClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get eqClassical;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @eqUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Start playing a song to adjust the equalizer.'**
  String get eqUnavailable;

  /// No description provided for @bassBoost.
  ///
  /// In en, this message translates to:
  /// **'Volume boost'**
  String get bassBoost;

  /// No description provided for @eqHint.
  ///
  /// In en, this message translates to:
  /// **'Settings are kept and applied to every song.'**
  String get eqHint;

  /// No description provided for @groupPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get groupPlayback;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @skipSilence.
  ///
  /// In en, this message translates to:
  /// **'Skip silences'**
  String get skipSilence;

  /// No description provided for @skipSilenceSub.
  ///
  /// In en, this message translates to:
  /// **'Skips silent parts in songs'**
  String get skipSilenceSub;

  /// No description provided for @lockScreen.
  ///
  /// In en, this message translates to:
  /// **'Lock screen'**
  String get lockScreen;

  /// No description provided for @lockScreenOption.
  ///
  /// In en, this message translates to:
  /// **'LyraMusic on the lock screen'**
  String get lockScreenOption;

  /// No description provided for @lockScreenSub.
  ///
  /// In en, this message translates to:
  /// **'Shows the player when you lock the phone during playback'**
  String get lockScreenSub;

  /// No description provided for @lockPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'To show the player above the lock screen, Android needs your permission (full-screen notifications). The settings will open: turn on the option for LyraMusic, then come back.'**
  String get lockPermissionBody;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @lockPermissionMissing.
  ///
  /// In en, this message translates to:
  /// **'Permission needed'**
  String get lockPermissionMissing;

  /// No description provided for @lockPermissionMissingSub.
  ///
  /// In en, this message translates to:
  /// **'Tap to open the Android settings'**
  String get lockPermissionMissingSub;

  /// No description provided for @widgets.
  ///
  /// In en, this message translates to:
  /// **'Home screen widgets'**
  String get widgets;

  /// No description provided for @widgetSmall.
  ///
  /// In en, this message translates to:
  /// **'Compact widget (4 × 1)'**
  String get widgetSmall;

  /// No description provided for @widgetSmallSub.
  ///
  /// In en, this message translates to:
  /// **'Song and controls · tap to add'**
  String get widgetSmallSub;

  /// No description provided for @widgetLarge.
  ///
  /// In en, this message translates to:
  /// **'Player widget (4 × 2)'**
  String get widgetLarge;

  /// No description provided for @widgetLargeSub.
  ///
  /// In en, this message translates to:
  /// **'Large artwork · tap to add'**
  String get widgetLargeSub;

  /// No description provided for @widgetManual.
  ///
  /// In en, this message translates to:
  /// **'Long-press your home screen, then Widgets › LyraMusic.'**
  String get widgetManual;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @mostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get mostPlayed;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortSongCount.
  ///
  /// In en, this message translates to:
  /// **'Number of songs'**
  String get sortSongCount;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @artistsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 artist} other{{count} artists}}'**
  String artistsCount(int count);

  /// No description provided for @foldersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 folder} other{{count} folders}}'**
  String foldersCount(int count);

  /// No description provided for @genresCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 genre} other{{count} genres}}'**
  String genresCount(int count);

  /// No description provided for @newPlaylistSub.
  ///
  /// In en, this message translates to:
  /// **'Choose a name and songs'**
  String get newPlaylistSub;

  /// No description provided for @searchIntro.
  ///
  /// In en, this message translates to:
  /// **'Search your music'**
  String get searchIntro;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @back10.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds'**
  String get back10;

  /// No description provided for @forward10.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds'**
  String get forward10;

  /// No description provided for @optSeekButtons.
  ///
  /// In en, this message translates to:
  /// **'±10 s buttons'**
  String get optSeekButtons;

  /// No description provided for @optSeekButtonsSub.
  ///
  /// In en, this message translates to:
  /// **'Replace shuffle and repeat next to Play (they move to the row below)'**
  String get optSeekButtonsSub;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'All your music, on your phone'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Plays offline. No account, no streaming, no ads.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Clean tags, no computer needed'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Fix titles, artists and covers right inside your files.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Lyrics that follow the music'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Synced lyrics, home screen widgets and a lock screen player.'**
  String get onb3Body;

  /// No description provided for @onbLyrics.
  ///
  /// In en, this message translates to:
  /// **'Music brings us together|A soundtrack|for every story|Music for everyone,|everywhere'**
  String get onbLyrics;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @hapticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get hapticsLabel;

  /// No description provided for @hapticsSub.
  ///
  /// In en, this message translates to:
  /// **'Subtle feedback on gestures'**
  String get hapticsSub;

  /// No description provided for @themeDynamic.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get themeDynamic;

  /// No description provided for @themeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeClassic;

  /// No description provided for @themesGalleryHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a mood, or create your own.'**
  String get themesGalleryHint;

  /// No description provided for @themeDynamicHint.
  ///
  /// In en, this message translates to:
  /// **'Colors follow the artwork of the current song.'**
  String get themeDynamicHint;

  /// No description provided for @themeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a theme'**
  String get themeCreate;

  /// No description provided for @themeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit theme'**
  String get themeEdit;

  /// No description provided for @themeMine.
  ///
  /// In en, this message translates to:
  /// **'My theme'**
  String get themeMine;

  /// No description provided for @themeSaved.
  ///
  /// In en, this message translates to:
  /// **'Theme saved and applied'**
  String get themeSaved;

  /// No description provided for @themeSurprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get themeSurprise;

  /// No description provided for @themeName.
  ///
  /// In en, this message translates to:
  /// **'Theme name'**
  String get themeName;

  /// No description provided for @themeColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get themeColors;

  /// No description provided for @themeBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get themeBackground;

  /// No description provided for @themeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get themeText;

  /// No description provided for @themeContrastLow.
  ///
  /// In en, this message translates to:
  /// **'Low readability'**
  String get themeContrastLow;

  /// No description provided for @themeContrastOk.
  ///
  /// In en, this message translates to:
  /// **'Good readability'**
  String get themeContrastOk;

  /// No description provided for @themeContrastText.
  ///
  /// In en, this message translates to:
  /// **'Text contrast: {ratio}:1 (4.5 recommended)'**
  String themeContrastText(String ratio);

  /// No description provided for @themeTipDark.
  ///
  /// In en, this message translates to:
  /// **'Tip: a very dark background saves battery on OLED screens.'**
  String get themeTipDark;

  /// No description provided for @themeTipLight.
  ///
  /// In en, this message translates to:
  /// **'Tip: a cream background is easier on the eyes than pure white.'**
  String get themeTipLight;

  /// No description provided for @lyricsMenu.
  ///
  /// In en, this message translates to:
  /// **'Lyrics…'**
  String get lyricsMenu;

  /// No description provided for @lyricsSaved.
  ///
  /// In en, this message translates to:
  /// **'Lyrics saved on your device'**
  String get lyricsSaved;

  /// No description provided for @lyricsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyricsEditTitle;

  /// No description provided for @lyricsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete my lyrics'**
  String get lyricsDelete;

  /// No description provided for @lyricsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Lyrics deleted'**
  String get lyricsDeleted;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @lyricsHint2.
  ///
  /// In en, this message translates to:
  /// **'Paste or type the lyrics, one line per phrase.'**
  String get lyricsHint2;

  /// No description provided for @linesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lines} =1{1 line} other{{count} lines}}'**
  String linesCount(int count);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncNow;

  /// No description provided for @syncSaved.
  ///
  /// In en, this message translates to:
  /// **'Synced lyrics saved'**
  String get syncSaved;

  /// No description provided for @syncReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get syncReview;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync lyrics'**
  String get syncTitle;

  /// No description provided for @syncProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String syncProgress(int done, int total);

  /// No description provided for @syncReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a line to hear it and adjust its timing.'**
  String get syncReviewHint;

  /// No description provided for @syncHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button right when each line starts.'**
  String get syncHint;

  /// No description provided for @syncUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get syncUndo;

  /// No description provided for @syncRestart.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get syncRestart;

  /// No description provided for @syncTap.
  ///
  /// In en, this message translates to:
  /// **'Next line'**
  String get syncTap;

  /// No description provided for @syncShiftAll.
  ///
  /// In en, this message translates to:
  /// **'Shift all'**
  String get syncShiftAll;

  /// No description provided for @syncAdjustLine.
  ///
  /// In en, this message translates to:
  /// **'Adjust line {line}'**
  String syncAdjustLine(int line);

  /// No description provided for @syncPlayAll.
  ///
  /// In en, this message translates to:
  /// **'Play from the start'**
  String get syncPlayAll;

  /// No description provided for @syncListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get syncListen;

  /// No description provided for @workshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get workshop;

  /// No description provided for @workshopSub.
  ///
  /// In en, this message translates to:
  /// **'Lyrics and tags to complete'**
  String get workshopSub;

  /// No description provided for @wsNoLyrics.
  ///
  /// In en, this message translates to:
  /// **'No lyrics'**
  String get wsNoLyrics;

  /// No description provided for @wsToSync.
  ///
  /// In en, this message translates to:
  /// **'To sync'**
  String get wsToSync;

  /// No description provided for @wsSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get wsSynced;

  /// No description provided for @wsMissingInfo.
  ///
  /// In en, this message translates to:
  /// **'Missing info'**
  String get wsMissingInfo;

  /// No description provided for @wsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get wsAdd;

  /// No description provided for @wsSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get wsSync;

  /// No description provided for @wsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get wsEdit;

  /// No description provided for @wsComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get wsComplete;

  /// No description provided for @wsEmptyNone.
  ///
  /// In en, this message translates to:
  /// **'All your songs have lyrics.'**
  String get wsEmptyNone;

  /// No description provided for @wsEmptyPlain.
  ///
  /// In en, this message translates to:
  /// **'Nothing to sync for now.'**
  String get wsEmptyPlain;

  /// No description provided for @wsEmptySynced.
  ///
  /// In en, this message translates to:
  /// **'No synced lyrics yet.'**
  String get wsEmptySynced;

  /// No description provided for @wsEmptyInfo.
  ///
  /// In en, this message translates to:
  /// **'All tags are complete.'**
  String get wsEmptyInfo;

  /// No description provided for @wsProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Synced lyrics'**
  String get wsProgressTitle;

  /// No description provided for @wsProgressBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No contributions yet} =1{1 contribution saved on your device} other{{count} contributions saved on your device}}'**
  String wsProgressBody(int count);

  /// No description provided for @wsAllDone.
  ///
  /// In en, this message translates to:
  /// **'Library complete, well done!'**
  String get wsAllDone;

  /// No description provided for @wsCountNone.
  ///
  /// In en, this message translates to:
  /// **'{count} without lyrics'**
  String wsCountNone(int count);

  /// No description provided for @wsCountPlain.
  ///
  /// In en, this message translates to:
  /// **'{count} to sync'**
  String wsCountPlain(int count);

  /// No description provided for @wsCountInfo.
  ///
  /// In en, this message translates to:
  /// **'{count} to complete'**
  String wsCountInfo(int count);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @guideLink.
  ///
  /// In en, this message translates to:
  /// **'How does the Workshop work?'**
  String get guideLink;

  /// No description provided for @guideStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get guideStart;

  /// No description provided for @guide1Title.
  ///
  /// In en, this message translates to:
  /// **'Add lyrics'**
  String get guide1Title;

  /// No description provided for @guide1Body.
  ///
  /// In en, this message translates to:
  /// **'Paste or type a song\'s lyrics, one line per phrase. They\'re saved on your phone, without touching the file.'**
  String get guide1Body;

  /// No description provided for @guide2Title.
  ///
  /// In en, this message translates to:
  /// **'Sync to the beat'**
  String get guide2Title;

  /// No description provided for @guide2Body.
  ///
  /// In en, this message translates to:
  /// **'Play the song and tap the button as each line starts. Then fine-tune to a tenth of a second.'**
  String get guide2Body;

  /// No description provided for @guide3Title.
  ///
  /// In en, this message translates to:
  /// **'Create a LyricsCard'**
  String get guide3Title;

  /// No description provided for @guide3Body.
  ///
  /// In en, this message translates to:
  /// **'Pick an excerpt, a background and a font, then save the image to your gallery or share it.'**
  String get guide3Body;

  /// No description provided for @wsAddLyrics.
  ///
  /// In en, this message translates to:
  /// **'Add lyrics'**
  String get wsAddLyrics;

  /// No description provided for @wsSyncSongs.
  ///
  /// In en, this message translates to:
  /// **'Sync songs'**
  String get wsSyncSongs;

  /// No description provided for @lcCreateShort.
  ///
  /// In en, this message translates to:
  /// **'LyricsCard'**
  String get lcCreateShort;

  /// No description provided for @lcCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a LyricsCard'**
  String get lcCreate;

  /// No description provided for @lcTabText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get lcTabText;

  /// No description provided for @lcTabImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get lcTabImage;

  /// No description provided for @lcTabFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get lcTabFont;

  /// No description provided for @lcChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get lcChange;

  /// No description provided for @lcPickSong.
  ///
  /// In en, this message translates to:
  /// **'Songs with lyrics'**
  String get lcPickSong;

  /// No description provided for @lcNoSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs with lyrics'**
  String get lcNoSongs;

  /// No description provided for @lcNoSongsBody.
  ///
  /// In en, this message translates to:
  /// **'Add lyrics from the Workshop to create a card.'**
  String get lcNoSongsBody;

  /// No description provided for @lcSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a line, then another to extend. Long-press to adjust character by character.'**
  String get lcSelectHint;

  /// No description provided for @lcClear.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get lcClear;

  /// No description provided for @lcTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long: 113 characters max'**
  String get lcTooLong;

  /// No description provided for @lcPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Pick an excerpt from the lyrics'**
  String get lcPlaceholder;

  /// No description provided for @lcContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get lcContinue;

  /// No description provided for @lcArtwork.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get lcArtwork;

  /// No description provided for @lcGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get lcGallery;

  /// No description provided for @lcDim.
  ///
  /// In en, this message translates to:
  /// **'Darken'**
  String get lcDim;

  /// No description provided for @lcBlur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get lcBlur;

  /// No description provided for @lcFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get lcFormat;

  /// No description provided for @lcSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get lcSize;

  /// No description provided for @lcAlign.
  ///
  /// In en, this message translates to:
  /// **'Alignment'**
  String get lcAlign;

  /// No description provided for @lcColor.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get lcColor;

  /// No description provided for @lcShowInfo.
  ///
  /// In en, this message translates to:
  /// **'Title and artist'**
  String get lcShowInfo;

  /// No description provided for @lcExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get lcExport;

  /// No description provided for @lcSave.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get lcSave;

  /// No description provided for @lcShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get lcShare;

  /// No description provided for @lcSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved to your gallery'**
  String get lcSaved;

  /// No description provided for @lcSaveDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage access denied'**
  String get lcSaveDenied;

  /// No description provided for @lcError.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get lcError;

  /// No description provided for @deleteFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete from phone'**
  String get deleteFromDevice;

  /// No description provided for @deleteTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this song?'**
  String get deleteTrackTitle;

  /// No description provided for @deleteTrackBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently deleted from your phone.'**
  String deleteTrackBody(String name);

  /// No description provided for @deleteTracksTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 song?} other{Delete {count} songs?}}'**
  String deleteTracksTitle(int count);

  /// No description provided for @deleteTracksBody.
  ///
  /// In en, this message translates to:
  /// **'These files will be permanently deleted from your phone.'**
  String get deleteTracksBody;

  /// No description provided for @deleteAlbum.
  ///
  /// In en, this message translates to:
  /// **'Delete album'**
  String get deleteAlbum;

  /// No description provided for @deleteAlbumTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this album?'**
  String get deleteAlbumTitle;

  /// No description provided for @deleteAlbumBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{\"{name}\" and its song will be permanently deleted from your phone.} other{\"{name}\" and its {count} songs will be permanently deleted from your phone.}}'**
  String deleteAlbumBody(String name, int count);

  /// No description provided for @deletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song deleted} other{{count} songs deleted}}'**
  String deletedCount(int count);

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'The files could not be deleted.'**
  String get deleteError;

  /// No description provided for @editAlbum.
  ///
  /// In en, this message translates to:
  /// **'Edit album'**
  String get editAlbum;

  /// No description provided for @fieldTrackTotal.
  ///
  /// In en, this message translates to:
  /// **'Number of tracks'**
  String get fieldTrackTotal;

  /// No description provided for @multipleValues.
  ///
  /// In en, this message translates to:
  /// **'Multiple values'**
  String get multipleValues;

  /// No description provided for @albumEditInfo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Changes are written to the album\'s song.} other{Changes are written to the album\'s {count} songs.}} Fields you don\'t touch stay as they are.'**
  String albumEditInfo(int count);

  /// No description provided for @albumSaving.
  ///
  /// In en, this message translates to:
  /// **'Writing {done} / {total}…'**
  String albumSaving(int done, int total);

  /// No description provided for @albumSaved.
  ///
  /// In en, this message translates to:
  /// **'Album updated'**
  String get albumSaved;

  /// No description provided for @albumSavePartial.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song could not be changed} other{{count} songs could not be changed}}'**
  String albumSavePartial(int count);

  /// No description provided for @alreadyInPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Already in {name}'**
  String alreadyInPlaylist(String name);

  /// No description provided for @skippedDuplicates.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 duplicate skipped} other{{count} duplicates skipped}}'**
  String skippedDuplicates(int count);

  /// No description provided for @inPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Already in the playlist'**
  String get inPlaylist;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get clearSelection;

  /// No description provided for @back5.
  ///
  /// In en, this message translates to:
  /// **'Back 5 seconds'**
  String get back5;

  /// No description provided for @syncSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get syncSpeed;

  /// No description provided for @syncSpeedHint.
  ///
  /// In en, this message translates to:
  /// **'Slow down the song to tap more precisely: times stay exact.'**
  String get syncSpeedHint;

  /// No description provided for @syncLatency.
  ///
  /// In en, this message translates to:
  /// **'Reaction time'**
  String get syncLatency;

  /// No description provided for @syncLatencyHint.
  ///
  /// In en, this message translates to:
  /// **'Subtracted from each tap to make up for the delay between hearing and touching.'**
  String get syncLatencyHint;

  /// No description provided for @syncSetHere.
  ///
  /// In en, this message translates to:
  /// **'Set to now'**
  String get syncSetHere;

  /// No description provided for @syncSettings.
  ///
  /// In en, this message translates to:
  /// **'Sync settings'**
  String get syncSettings;

  /// No description provided for @movedToTrash.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song moved to the trash} other{{count} songs moved to the trash}}'**
  String movedToTrash(int count);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @restoredCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song restored} other{{count} songs restored}}'**
  String restoredCount(int count);

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @trashSub.
  ///
  /// In en, this message translates to:
  /// **'Deleted songs, restorable for 30 days'**
  String get trashSub;

  /// No description provided for @trashEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The trash is empty'**
  String get trashEmptyTitle;

  /// No description provided for @trashEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deleted songs stay here for 30 days before your phone erases them.'**
  String get trashEmptyBody;

  /// No description provided for @trashUnsupported.
  ///
  /// In en, this message translates to:
  /// **'The trash needs Android 11 or later. On this phone, deleting is permanent.'**
  String get trashUnsupported;

  /// No description provided for @trashExpires.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Erased today} =1{Erased in 1 day} other{Erased in {days} days}}'**
  String trashExpires(int days);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore all'**
  String get restoreAll;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get emptyTrash;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteForever;

  /// No description provided for @emptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty the trash?'**
  String get emptyTrashTitle;

  /// No description provided for @emptyTrashBody.
  ///
  /// In en, this message translates to:
  /// **'These songs will be permanently deleted. This can\'t be undone.'**
  String get emptyTrashBody;

  /// No description provided for @addAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get addAnyway;

  /// No description provided for @removedFromPlaylist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song removed} other{{count} songs removed}}'**
  String removedFromPlaylist(int count);

  /// No description provided for @syncBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get syncBreak;

  /// No description provided for @syncBreakLine.
  ///
  /// In en, this message translates to:
  /// **'Instrumental break'**
  String get syncBreakLine;

  /// No description provided for @syncBreakHint.
  ///
  /// In en, this message translates to:
  /// **'Mark the end of the line that just ended (instrumental passage)'**
  String get syncBreakHint;

  /// No description provided for @syncRemoveBreak.
  ///
  /// In en, this message translates to:
  /// **'Remove the break'**
  String get syncRemoveBreak;

  /// No description provided for @syncSnap.
  ///
  /// In en, this message translates to:
  /// **'Snap to voice'**
  String get syncSnap;

  /// No description provided for @syncSnapAll.
  ///
  /// In en, this message translates to:
  /// **'Snap all lines'**
  String get syncSnapAll;

  /// No description provided for @syncSnapped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No line moved} =1{1 line adjusted} other{{count} lines adjusted}}'**
  String syncSnapped(int count);

  /// No description provided for @syncWaveLoading.
  ///
  /// In en, this message translates to:
  /// **'Analysing the sound…'**
  String get syncWaveLoading;

  /// No description provided for @syncWaveHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the waveform to move the line. A voice starting shows up as a rise.'**
  String get syncWaveHint;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'fr':
      return L10nFr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
