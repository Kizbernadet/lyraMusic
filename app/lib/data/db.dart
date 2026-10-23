import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/track.dart';

/// Base SQLite locale : morceaux (cache du scan), playlists, favoris, historique.
class LyraDb {
  final Database db;
  LyraDb._(this.db);

  static Future<LyraDb> open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'lyra.db'),
      version: 2,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onUpgrade: (db, from, to) async {
        if (from < 2) {
          await _v2(db);
          // Relire tous les fichiers au prochain scan pour détecter les paroles.
          await db.execute('UPDATE tracks SET date_modified = -1');
        }
      },
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE tracks (
            id INTEGER PRIMARY KEY,
            path TEXT NOT NULL,
            title TEXT NOT NULL,
            artist TEXT, album_artist TEXT, album TEXT, genre TEXT,
            year INTEGER, track_no INTEGER, disc_no INTEGER,
            duration_ms INTEGER NOT NULL,
            bitrate INTEGER, sample_rate INTEGER,
            size INTEGER NOT NULL, mime TEXT,
            date_added INTEGER NOT NULL, date_modified INTEGER NOT NULL,
            art TEXT
          )''');
        await db.execute('''
          CREATE TABLE playlists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created INTEGER NOT NULL,
            updated INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE playlist_tracks (
            playlist_id INTEGER NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
            track_id INTEGER NOT NULL,
            position INTEGER NOT NULL
          )''');
        await db.execute('CREATE INDEX idx_pt ON playlist_tracks(playlist_id, position)');
        await db.execute('''
          CREATE TABLE favorites (
            track_id INTEGER PRIMARY KEY,
            created INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE history (
            track_id INTEGER NOT NULL,
            played_at INTEGER NOT NULL
          )''');
        await db.execute('CREATE INDEX idx_history ON history(played_at)');
        await _v2(db);
      },
    );
    return LyraDb._(db);
  }

  /// Version 2 : état des paroles par morceau et paroles saisies par l'utilisateur.
  static Future<void> _v2(Database db) async {
    await db.execute('ALTER TABLE tracks ADD COLUMN lyrics INTEGER NOT NULL DEFAULT 0');
    await db.execute('''
      CREATE TABLE user_lyrics (
        track_id INTEGER PRIMARY KEY,
        text TEXT NOT NULL,
        synced INTEGER NOT NULL,
        updated INTEGER NOT NULL
      )''');
  }

  // ---- Paroles de l'utilisateur ----

  Future<List<Map<String, Object?>>> userLyrics() => db.query('user_lyrics');

  Future<void> saveLyrics(int trackId, String text, bool synced) => db.insert('user_lyrics', {
    'track_id': trackId,
    'text': text,
    'synced': synced ? 1 : 0,
    'updated': DateTime.now().millisecondsSinceEpoch,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> deleteLyrics(int trackId) => db.delete('user_lyrics', where: 'track_id = ?', whereArgs: [trackId]);

  // ---- Morceaux ----

  Future<List<Track>> allTracks() async => (await db.query('tracks')).map(Track.fromRow).toList();

  Future<void> upsertTracks(Iterable<Track> tracks) async {
    final batch = db.batch();
    for (final t in tracks) {
      batch.insert('tracks', t.toRow(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteTracks(Iterable<int> ids) async {
    final list = ids.toList();
    for (var i = 0; i < list.length; i += 500) {
      final chunk = list.sublist(i, i + 500 > list.length ? list.length : i + 500);
      await db.delete('tracks', where: 'id IN (${List.filled(chunk.length, '?').join(',')})', whereArgs: chunk);
    }
  }

  /// Après la suppression des fichiers : on oublie aussi favoris, playlists,
  /// historique et paroles de ces morceaux.
  Future<void> forgetTracks(List<int> ids) async {
    await deleteTracks(ids);
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      final where = 'track_id IN (${List.filled(chunk.length, '?').join(',')})';
      for (final table in ['playlist_tracks', 'favorites', 'history', 'user_lyrics']) {
        await db.delete(table, where: where, whereArgs: chunk);
      }
    }
  }

  // ---- Playlists ----

  Future<List<Playlist>> playlists() async {
    final rows = await db.query('playlists', orderBy: 'updated DESC');
    final items = await db.query('playlist_tracks', orderBy: 'playlist_id, position');
    final byId = <int, List<int>>{};
    for (final r in items) {
      byId.putIfAbsent(r['playlist_id'] as int, () => []).add(r['track_id'] as int);
    }
    return rows
        .map((r) => Playlist(r['id'] as int, r['name'] as String, byId[r['id']] ?? [], r['updated'] as int))
        .toList();
  }

  Future<int> createPlaylist(String name) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert('playlists', {'name': name, 'created': now, 'updated': now});
  }

  Future<void> renamePlaylist(int id, String name) => db.update(
    'playlists',
    {'name': name, 'updated': DateTime.now().millisecondsSinceEpoch},
    where: 'id = ?',
    whereArgs: [id],
  );

  Future<void> deletePlaylist(int id) => db.delete('playlists', where: 'id = ?', whereArgs: [id]);

  Future<void> setPlaylistTracks(int id, List<int> trackIds) async {
    await db.transaction((tx) async {
      await tx.delete('playlist_tracks', where: 'playlist_id = ?', whereArgs: [id]);
      final batch = tx.batch();
      for (var i = 0; i < trackIds.length; i++) {
        batch.insert('playlist_tracks', {'playlist_id': id, 'track_id': trackIds[i], 'position': i});
      }
      await batch.commit(noResult: true);
      await tx.update(
        'playlists',
        {'updated': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // ---- Favoris ----

  Future<List<int>> favorites() async =>
      (await db.query('favorites', orderBy: 'created DESC')).map((r) => r['track_id'] as int).toList();

  Future<void> setFavorite(int trackId, bool value) async {
    if (value) {
      await db.insert('favorites', {
        'track_id': trackId,
        'created': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete('favorites', where: 'track_id = ?', whereArgs: [trackId]);
    }
  }

  // ---- Historique ----

  Future<void> addHistory(int trackId) async {
    await db.insert('history', {'track_id': trackId, 'played_at': DateTime.now().millisecondsSinceEpoch});
    // On garde les 500 dernières écoutes.
    await db.execute(
      'DELETE FROM history WHERE rowid NOT IN '
      '(SELECT rowid FROM history ORDER BY played_at DESC LIMIT 500)',
    );
  }

  /// Écoutes récentes avec leur date (écran Historique).
  Future<List<(int, DateTime)>> history({int limit = 300}) async {
    final rows = await db.query('history', orderBy: 'played_at DESC', limit: limit);
    return [for (final r in rows) (r['track_id'] as int, DateTime.fromMillisecondsSinceEpoch(r['played_at'] as int))];
  }

  Future<void> clearHistory() => db.delete('history');

  /// Morceaux les plus écoutés (nombre d'écoutes décroissant).
  Future<List<int>> mostPlayed({int limit = 30}) async {
    final rows = await db.rawQuery(
      'SELECT track_id, COUNT(*) AS n FROM history GROUP BY track_id ORDER BY n DESC LIMIT ?',
      [limit],
    );
    return rows.map((r) => r['track_id'] as int).toList();
  }

  Future<List<int>> recentlyPlayed({int limit = 30}) async {
    final rows = await db.rawQuery(
      'SELECT track_id, MAX(played_at) AS last FROM history GROUP BY track_id ORDER BY last DESC LIMIT ?',
      [limit],
    );
    return rows.map((r) => r['track_id'] as int).toList();
  }
}
