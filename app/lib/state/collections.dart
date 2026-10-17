import 'package:flutter/foundation.dart';

import '../data/db.dart';
import '../models/track.dart';

/// Playlists, favoris et historique d'écoute.
class CollectionsController extends ChangeNotifier {
  final LyraDb db;
  CollectionsController(this.db);

  List<Playlist> playlists = [];
  List<int> favoriteIds = [];
  Set<int> _favorites = {};
  List<int> recentIds = [];
  List<int> mostPlayedIds = [];

  /// Pour les aperçus et les tests.
  @visibleForTesting
  void debugSeed({
    List<Playlist> playlists = const [],
    List<int> favorites = const [],
    List<int> recent = const [],
    List<int> most = const [],
  }) {
    this.playlists = playlists;
    favoriteIds = favorites;
    _favorites = favorites.toSet();
    recentIds = recent;
    mostPlayedIds = most;
    notifyListeners();
  }

  Future<void> load() async {
    playlists = await db.playlists();
    favoriteIds = await db.favorites();
    _favorites = favoriteIds.toSet();
    recentIds = await db.recentlyPlayed();
    mostPlayedIds = await db.mostPlayed();
    notifyListeners();
  }

  // ---- Favoris ----

  bool isFavorite(int trackId) => _favorites.contains(trackId);

  /// Renvoie le nouvel état.
  Future<bool> toggleFavorite(int trackId) async {
    final value = !isFavorite(trackId);
    await db.setFavorite(trackId, value);
    if (value) {
      _favorites.add(trackId);
      favoriteIds = [trackId, ...favoriteIds];
    } else {
      _favorites.remove(trackId);
      favoriteIds = favoriteIds.where((id) => id != trackId).toList();
    }
    notifyListeners();
    return value;
  }

  // ---- Playlists ----

  Playlist? playlist(int id) {
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<int> create(String name, {List<int> trackIds = const []}) async {
    final id = await db.createPlaylist(name.trim());
    if (trackIds.isNotEmpty) await db.setPlaylistTracks(id, trackIds);
    await _reload();
    return id;
  }

  Future<void> rename(int id, String name) async {
    await db.renamePlaylist(id, name.trim());
    await _reload();
  }

  Future<void> delete(int id) async {
    await db.deletePlaylist(id);
    await _reload();
  }

  Future<void> addTracks(int id, List<int> trackIds) async {
    final p = playlist(id);
    if (p == null) return;
    await db.setPlaylistTracks(id, [...p.trackIds, ...trackIds]);
    await _reload();
  }

  Future<void> removeAt(int id, int index) async {
    final p = playlist(id);
    if (p == null) return;
    final ids = [...p.trackIds]..removeAt(index);
    await db.setPlaylistTracks(id, ids);
    await _reload();
  }

  Future<void> move(int id, int from, int to) async {
    final p = playlist(id);
    if (p == null) return;
    final ids = [...p.trackIds];
    final item = ids.removeAt(from);
    ids.insert(to, item);
    // Mise à jour immédiate de l'affichage, puis enregistrement.
    playlists = [for (final x in playlists) x.id == id ? Playlist(x.id, x.name, ids, x.updated) : x];
    notifyListeners();
    await db.setPlaylistTracks(id, ids);
  }

  Future<void> _reload() async {
    playlists = await db.playlists();
    notifyListeners();
  }

  // ---- Historique ----

  Future<List<(int, DateTime)>> history() => db.history();

  Future<void> clearHistory() async {
    await db.clearHistory();
    recentIds = [];
    mostPlayedIds = [];
    notifyListeners();
  }

  Future<void> recordPlay(int trackId) async {
    await db.addHistory(trackId);
    recentIds = [trackId, ...recentIds.where((id) => id != trackId)].take(30).toList();
    mostPlayedIds = await db.mostPlayed();
    notifyListeners();
  }
}
