import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/theme.dart';
import '../ui/theme_presets.dart';

enum SongSort { title, artist, album, year, dateAdded, duration }

/// Tri des artistes, albums, dossiers et genres.
enum GroupSort { name, artist, year, count }

/// Forme de la pochette dans le lecteur.
enum ArtworkStyle { rounded, square, vinyl }

/// Fond du lecteur.
enum PlayerBackground { blur, gradient, plain }

/// Options d'affichage activables (lecteur, file d'attente, mini-lecteur).
/// La valeur par défaut est donnée par [defaultOn].
enum Toggle {
  // Lecteur plein écran
  playerVolume,
  playerRemaining,
  playerAlbumInfo,
  playerFormat,
  playerNextUp,
  playerFavorite,
  playerShuffleRepeat,
  playerSwipe,
  playerSeekButtons,
  actionQueue,
  actionLyrics,
  actionSleep,
  actionSpeed,
  actionEqualizer,
  actionPlaylist,
  actionDetails,
  // File d'attente
  queueArtwork,
  queueDuration,
  queueNowPlaying,
  queueSwipeRemove,
  // Mini-lecteur
  miniProgress,
  miniFavorite,
  miniNext,
  // Écran de verrouillage LyraMusic
  lockScreen,
  // Lecture
  skipSilence,
  // Interface
  haptics,
}

const _defaultOff = {
  Toggle.playerFormat,
  Toggle.playerNextUp,
  Toggle.playerSeekButtons,
  Toggle.actionDetails,
  Toggle.actionPlaylist,
  Toggle.miniFavorite,
  Toggle.lockScreen,
  Toggle.skipSilence,
};

bool defaultOn(Toggle t) => !_defaultOff.contains(t);

/// Réglages de l'utilisateur, conservés sur le téléphone.
class SettingsController extends ChangeNotifier {
  final SharedPreferences prefs;
  SettingsController(this.prefs);

  static const supportedLanguages = ['fr', 'en', 'es'];

  // ---- Langue ----

  /// null = langue du téléphone.
  Locale? get locale {
    final code = prefs.getString('locale');
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? value) async {
    if (value == null) {
      await prefs.remove('locale');
    } else {
      await prefs.setString('locale', value.languageCode);
    }
    notifyListeners();
  }

  // ---- Apparence ----

  AppearanceMode get appearance => AppearanceMode.values.firstWhere(
    (m) => m.name == prefs.getString('appearance'),
    orElse: () => AppearanceMode.system,
  );

  Future<void> setAppearance(AppearanceMode m) async {
    await prefs.setString('appearance', m.name);
    notifyListeners();
  }

  /// Thème choisi : 'classic' (mode + couleur), `preset:id`, `custom:id` ou 'dynamic'.
  String get themeChoice => prefs.getString('themeChoice') ?? 'classic';

  Future<void> setThemeChoice(String v) async {
    await prefs.setString('themeChoice', v);
    notifyListeners();
  }

  /// Thèmes créés par l'utilisateur (enregistrés sur le téléphone).
  List<ThemeSpec> get customThemes => ThemeSpec.decodeList(prefs.getString('customThemes'));

  Future<void> saveCustomTheme(ThemeSpec t) async {
    final list = customThemes;
    final i = list.indexWhere((x) => x.id == t.id);
    if (i >= 0) {
      list[i] = t;
    } else {
      list.add(t);
    }
    await prefs.setString('customThemes', ThemeSpec.encodeList(list));
    notifyListeners();
  }

  Future<void> deleteCustomTheme(String id) async {
    await prefs.setString('customThemes', ThemeSpec.encodeList(customThemes.where((t) => t.id != id).toList()));
    if (themeChoice == 'custom:$id') await prefs.setString('themeChoice', 'classic');
    notifyListeners();
  }

  /// Le thème choisi (hors « classique » et « dynamique »).
  ThemeSpec? get selectedSpec {
    final c = themeChoice;
    if (c.startsWith('preset:')) return presetThemes.where((t) => 'preset:${t.id}' == c).firstOrNull;
    if (c.startsWith('custom:')) return customThemes.where((t) => 'custom:${t.id}' == c).firstOrNull;
    return null;
  }

  AccentColor get accent =>
      AccentColor.values.firstWhere((a) => a.name == prefs.getString('accent'), orElse: () => AccentColor.classic);

  Future<void> setAccent(AccentColor a) async {
    await prefs.setString('accent', a.name);
    notifyListeners();
  }

  ArtworkStyle get artworkStyle => ArtworkStyle.values.firstWhere(
    (a) => a.name == prefs.getString('artworkStyle'),
    orElse: () => ArtworkStyle.rounded,
  );

  Future<void> setArtworkStyle(ArtworkStyle a) async {
    await prefs.setString('artworkStyle', a.name);
    notifyListeners();
  }

  PlayerBackground get playerBackground => PlayerBackground.values.firstWhere(
    (a) => a.name == prefs.getString('playerBackground'),
    orElse: () => PlayerBackground.plain,
  );

  Future<void> setPlayerBackground(PlayerBackground a) async {
    await prefs.setString('playerBackground', a.name);
    notifyListeners();
  }

  // ---- Options activables ----

  bool on(Toggle t) => prefs.getBool('t_${t.name}') ?? defaultOn(t);

  Future<void> set(Toggle t, bool value) async {
    await prefs.setBool('t_${t.name}', value);
    notifyListeners();
  }

  Future<void> resetPlayerLayout() async {
    for (final t in Toggle.values) {
      if (t != Toggle.lockScreen) await prefs.remove('t_${t.name}');
    }
    await prefs.remove('artworkStyle');
    await prefs.remove('playerBackground');
    notifyListeners();
  }

  // ---- Bibliothèque ----

  SongSort get songSort =>
      SongSort.values.firstWhere((s) => s.name == prefs.getString('songSort'), orElse: () => SongSort.title);

  Future<void> setSongSort(SongSort sort) async {
    await prefs.setString('songSort', sort.name);
    notifyListeners();
  }

  bool get songAscending => prefs.getBool('songAsc') ?? true;

  Future<void> setSongAscending(bool v) async {
    await prefs.setBool('songAsc', v);
    notifyListeners();
  }

  /// Tri d'une vue de groupes : 'artists', 'albums', 'folders', 'genres'.
  GroupSort groupSort(String view) =>
      GroupSort.values.firstWhere((s) => s.name == prefs.getString('sort_$view'), orElse: () => GroupSort.name);

  bool groupAscending(String view) => prefs.getBool('asc_$view') ?? true;

  Future<void> setGroupSort(String view, GroupSort s) async {
    await prefs.setString('sort_$view', s.name);
    notifyListeners();
  }

  Future<void> setGroupAscending(String view, bool v) async {
    await prefs.setBool('asc_$view', v);
    notifyListeners();
  }

  /// Présentation d'accueil (diapositives) déjà vue.
  bool get onboarded => prefs.getBool('onboarded') ?? false;

  Future<void> setOnboarded() => prefs.setBool('onboarded', true);

  /// Le parcours « Comment fonctionne l'Atelier ? » a déjà été montré.
  bool get workshopGuideSeen => prefs.getBool('workshopGuideSeen') ?? false;
  Future<void> setWorkshopGuideSeen() => prefs.setBool('workshopGuideSeen', true);

  List<String> get recentSearches => prefs.getStringList('recentSearches') ?? const [];

  Future<void> addRecentSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = [q, ...recentSearches.where((s) => s.toLowerCase() != q.toLowerCase())].take(8).toList();
    await prefs.setStringList('recentSearches', list);
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    await prefs.setStringList('recentSearches', recentSearches.where((s) => s != query).toList());
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    await prefs.remove('recentSearches');
    notifyListeners();
  }
}
