import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/db.dart';
import '../data/media_store.dart';
import '../data/scanner.dart';
import '../models/track.dart';
import '../utils/text.dart';
import 'settings.dart';

class SearchResults {
  final List<Track> songs;
  final List<Group> artists;
  final List<Album> albums;
  const SearchResults(this.songs, this.artists, this.albums);
  bool get isEmpty => songs.isEmpty && artists.isEmpty && albums.isEmpty;
}

/// Bibliothèque musicale : chargée depuis la base locale, mise à jour par le scan.
class LibraryController extends ChangeNotifier {
  final LyraDb db;
  final String artDir;
  LibraryController(this.db, this.artDir);

  List<Track> _tracks = [];
  Map<int, Track> _byId = {};
  bool loaded = false;
  bool scanning = false;
  int scanDone = 0;
  int scanTotal = 0;
  Object? scanError;

  List<Track> get tracks => _tracks;
  Track? byId(int id) => _byId[id];
  List<Track> resolve(Iterable<int> ids) => [for (final id in ids) ?_byId[id]];

  /// Pour les aperçus et les tests : remplace la bibliothèque.
  @visibleForTesting
  void debugSetTracks(List<Track> list) {
    _setTracks(list);
    loaded = true;
    notifyListeners();
  }

  Future<void> load() async {
    _setTracks(await db.allTracks());
    loaded = true;
    notifyListeners();
  }

  void _setTracks(List<Track> list) {
    _tracks = list;
    _byId = {for (final t in list) t.id: t};
    _sorted.clear();
    _albums = null;
    _artists = null;
    _genres = null;
    _folders = null;
  }

  bool _again = false;

  /// Scan incrémental : seuls les fichiers nouveaux ou modifiés sont relus.
  /// Silencieux quand rien n'a changé (aucune reconstruction de l'interface) ;
  /// sinon une fine barre de progression s'affiche et les nouveaux morceaux
  /// apparaissent au fil de l'analyse. Un scan demandé pendant un autre est
  /// mis en file et relancé à la fin. Renvoie le nombre de morceaux.
  Future<int> scan() async {
    if (_busy) {
      _again = true;
      return _tracks.length;
    }
    _busy = true;
    try {
      do {
        _again = false;
        await _scanOnce();
      } while (_again);
    } finally {
      _busy = false;
    }
    return _tracks.length;
  }

  bool _busy = false;

  Future<void> _scanOnce() async {
    scanError = null;
    try {
      final rows = (await MediaStoreBridge.queryAudio()).where((r) => isSupported(r.path)).toList();
      // Pochettes présentes sur le disque, lues une seule fois et hors du fil de l'interface.
      final arts = await _existingArt();
      final before = _byId;
      final keep = <Track>[];
      final toParse = <MediaRow>[];
      for (final row in rows) {
        final old = _byId[row.id];
        if (old != null &&
            old.path == row.path &&
            old.size == row.size &&
            old.dateModified == row.dateModified &&
            (old.art == null || arts.contains(old.art))) {
          keep.add(old);
        } else {
          toParse.add(row);
        }
      }
      final present = rows.map((r) => r.id).toSet();
      final removed = _tracks.where((t) => !present.contains(t.id)).map((t) => t.id).toList();
      if (toParse.isEmpty && removed.isEmpty) return; // rien de neuf

      final knownArt = <String, String>{
        for (final t in keep)
          if (t.art != null) t.albumKey: t.art!,
      };
      scanning = true;
      scanDone = 0;
      scanTotal = toParse.length;
      notifyListeners();

      List<Track> withAlbumArt(Iterable<Track> list) => list.map((t) {
        final art = knownArt[t.albumKey];
        return t.art == null && art != null ? t.copyWith(art: () => art) : t;
      }).toList();

      final parsed = <Track>[];
      final clock = Stopwatch()..start();
      const chunk = 60;
      for (var i = 0; i < toParse.length; i += chunk) {
        final part = toParse.sublist(i, i + chunk > toParse.length ? toParse.length : i + chunk);
        final result = await parseInIsolate(rows: part, artDir: artDir, knownArt: knownArt);
        for (final t in result) {
          if (t.art != null) knownArt.putIfAbsent(t.albumKey, () => t.art!);
        }
        parsed.addAll(result);
        scanDone = parsed.length;
        // Les nouveaux morceaux apparaissent au fur et à mesure (au plus une fois par seconde).
        if (clock.elapsedMilliseconds > 1000 && i + chunk < toParse.length) {
          clock.reset();
          final pending = [for (final r in toParse.skip(i + chunk)) ?before[r.id]];
          _setTracks(withAlbumArt([...keep, ...parsed, ...pending]));
        }
        notifyListeners();
      }

      // Les morceaux d'un album sans pochette prennent celle de l'album.
      final all = withAlbumArt([...keep, ...parsed]);
      if (removed.isNotEmpty) await db.deleteTracks(removed);
      await db.upsertTracks(all.where((t) => !identical(t, before[t.id])));
      _setTracks(all);
    } catch (e) {
      scanError = e;
    } finally {
      scanning = false;
      notifyListeners();
    }
  }

  Future<Set<String>> _existingArt() async {
    try {
      return await Directory(artDir).list().map((e) => e.path).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Après une modification des tags.
  Future<void> replaceTrack(Track updated, {String? previousArt}) async {
    final changed = <Track>[updated];
    final list = _tracks.map((t) {
      if (t.id == updated.id) return updated;
      // La nouvelle pochette s'applique à tout l'album.
      if (updated.art != previousArt && t.albumKey == updated.albumKey && t.art == previousArt) {
        final c = t.copyWith(art: () => updated.art);
        changed.add(c);
        return c;
      }
      return t;
    }).toList();
    await db.upsertTracks(changed);
    _setTracks(list);
    notifyListeners();
  }

  // ---- Vues dérivées ----

  final Map<String, List<Track>> _sorted = {};

  /// Morceaux triés. Le résultat est mis en cache par critère et par ordre.
  List<Track> sorted(SongSort sort, {bool ascending = true}) {
    final base = _sortedAsc(sort);
    if (ascending) return base;
    return _sorted.putIfAbsent('${sort.name}-false', () => base.reversed.toList());
  }

  List<Track> _sortedAsc(SongSort sort) => _sorted.putIfAbsent('${sort.name}-true', () {
    final keyed = [for (final t in _tracks) (t, sortKey(t.title))];
    int byTitle((Track, String) a, (Track, String) b) => a.$2.compareTo(b.$2);
    switch (sort) {
      case SongSort.title:
        keyed.sort(byTitle);
      case SongSort.artist:
        keyed.sort((a, b) {
          final c = _nullLast(a.$1.artist, b.$1.artist);
          return c != 0 ? c : byTitle(a, b);
        });
      case SongSort.album:
        keyed.sort((a, b) {
          final c = _nullLast(a.$1.album, b.$1.album);
          return c != 0 ? c : compareAlbumOrder(a.$1, b.$1);
        });
      case SongSort.year:
        keyed.sort((a, b) {
          final c = (a.$1.year ?? 9999).compareTo(b.$1.year ?? 9999);
          return c != 0 ? c : byTitle(a, b);
        });
      case SongSort.dateAdded:
        keyed.sort((a, b) => a.$1.dateAdded.compareTo(b.$1.dateAdded));
      case SongSort.duration:
        keyed.sort((a, b) => a.$1.durationMs.compareTo(b.$1.durationMs));
    }
    return [for (final k in keyed) k.$1];
  });

  List<Album>? _albums;
  List<Album> get albums => _albums ??= () {
    final map = <String, List<Track>>{};
    for (final t in _tracks) {
      map.putIfAbsent(t.albumKey, () => []).add(t);
    }
    final list = map.entries.map((e) {
      final tracks = e.value..sort(compareAlbumOrder);
      final first = tracks.first;
      return Album(e.key, first.album, first.albumArtist ?? _mainArtist(tracks), tracks);
    }).toList();
    list.sort((a, b) => _nullLast(a.name, b.name));
    return list;
  }();

  List<Group>? _artists;
  List<Group> get artists => _artists ??= _group((t) => t.artist);

  List<Group>? _genres;
  List<Group> get genres => _genres ??= _group((t) => t.genre);

  List<Group> _group(String? Function(Track) key) {
    final map = <String, (String?, List<Track>)>{};
    for (final t in _tracks) {
      final name = key(t);
      map.putIfAbsent(fold(name ?? ''), () => (name, [])).$2.add(t);
    }
    final list = map.values.map((v) => Group(v.$1, v.$2..sort(compareAlbumOrder))).toList();
    list.sort((a, b) => _nullLast(a.name, b.name));
    return list;
  }

  /// Dossiers contenant de l'audio (chemin, morceaux), triés par chemin.
  List<Group>? _folders;
  List<Group> get folders => _folders ??= () {
    final map = <String, List<Track>>{};
    for (final t in _tracks) {
      map.putIfAbsent(t.folder, () => []).add(t);
    }
    final list = map.entries.map((e) => Group(e.key, e.value..sort(compareAlbumOrder))).toList()
      ..sort((a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    return list;
  }();

  List<Track> get incomplete => sorted(SongSort.title).where((t) => t.isIncomplete).toList();

  Album? albumOf(Track t) {
    for (final a in albums) {
      if (a.key == t.albumKey) return a;
    }
    return null;
  }

  Group? artistOf(Track t) {
    final key = fold(t.artist ?? '');
    for (final g in artists) {
      if (fold(g.name ?? '') == key) return g;
    }
    return null;
  }

  List<Album> albumsOfArtist(Group artist) {
    final keys = artist.tracks.map((t) => t.albumKey).toSet();
    return albums.where((a) => keys.contains(a.key)).toList()..sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));
  }

  List<Track> recentlyAdded({int limit = 20}) => sorted(SongSort.dateAdded, ascending: false).take(limit).toList();

  List<Album> albumsSorted(GroupSort s, bool ascending) {
    final list = List.of(albums);
    int cmp(Album a, Album b) => switch (s) {
      GroupSort.name => _nullLast(a.name, b.name),
      GroupSort.artist => _nullLast(a.artist, b.artist),
      GroupSort.year => (a.year ?? 9999).compareTo(b.year ?? 9999),
      GroupSort.count => b.tracks.length.compareTo(a.tracks.length),
    };
    list.sort(cmp);
    return ascending ? list : list.reversed.toList();
  }

  List<Group> groupsSorted(List<Group> groups, GroupSort s, bool ascending) {
    final list = List.of(groups);
    if (s == GroupSort.count) list.sort((a, b) => b.tracks.length.compareTo(a.tracks.length));
    return ascending ? list : list.reversed.toList();
  }

  SearchResults search(String query) {
    final q = fold(query.trim());
    if (q.isEmpty) return const SearchResults([], [], []);
    final words = q.split(RegExp(r'\s+'));
    bool match(String text) => words.every(text.contains);
    final songs = sorted(SongSort.title).where((t) => match(t.searchText)).take(100).toList();
    final artists = this.artists.where((g) => g.name != null && match(fold(g.name!))).take(20).toList();
    final albums = this.albums
        .where((a) => a.name != null && match(fold('${a.name} ${a.artist ?? ''}')))
        .take(20)
        .toList();
    return SearchResults(songs, artists, albums);
  }
}

/// Ordre dans un album : disque, numéro de piste, puis titre (CA-07).
int compareAlbumOrder(Track a, Track b) {
  final d = (a.discNumber ?? 1).compareTo(b.discNumber ?? 1);
  if (d != 0) return d;
  final an = a.trackNumber, bn = b.trackNumber;
  if (an != null && bn != null && an != bn) return an.compareTo(bn);
  if (an != null && bn == null) return -1;
  if (an == null && bn != null) return 1;
  return sortKey(a.title).compareTo(sortKey(b.title));
}

/// Les valeurs inconnues (null) sont placées en fin de liste.
int _nullLast(String? a, String? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return sortKey(a).compareTo(sortKey(b));
}

String? _mainArtist(List<Track> tracks) {
  final counts = <String, int>{};
  for (final t in tracks) {
    if (t.artist != null) counts[t.artist!] = (counts[t.artist!] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
