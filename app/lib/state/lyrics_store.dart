import 'package:flutter/foundation.dart';

import '../data/db.dart';
import '../data/lyrics.dart';
import '../models/track.dart';

/// Paroles ajoutées ou synchronisées par l'utilisateur.
class UserLyrics {
  final String text;
  final bool synced;
  final DateTime updated;
  const UserLyrics(this.text, this.synced, this.updated);
}

enum LyricsStatus { none, plain, synced }

/// Contributions de l'utilisateur, enregistrées dans la base du téléphone
/// (hors ligne). Elles ont priorité sur les paroles du fichier.
class LyricsStore extends ChangeNotifier {
  final LyraDb db;
  LyricsStore(this.db);

  Map<int, UserLyrics> _map = {};
  int version = 0;

  Future<void> load() async {
    final rows = await db.userLyrics();
    _map = {
      for (final r in rows)
        r['track_id'] as int: UserLyrics(
          r['text'] as String,
          (r['synced'] as int) == 1,
          DateTime.fromMillisecondsSinceEpoch(r['updated'] as int),
        ),
    };
    notifyListeners();
  }

  UserLyrics? of(int trackId) => _map[trackId];

  int get count => _map.length;

  /// État des paroles d'un morceau (contribution de l'utilisateur d'abord).
  LyricsStatus status(Track t) {
    final u = _map[t.id];
    final kind = u != null ? (u.synced ? 2 : 1) : t.lyricsKind;
    return switch (kind) {
      2 => LyricsStatus.synced,
      1 => LyricsStatus.plain,
      _ => LyricsStatus.none,
    };
  }

  Future<void> save(int trackId, String text, {required bool synced}) async {
    await db.saveLyrics(trackId, text, synced);
    _map = {..._map, trackId: UserLyrics(text, synced, DateTime.now())};
    version++;
    notifyListeners();
  }

  Future<void> remove(int trackId) async {
    await db.deleteLyrics(trackId);
    _map = {..._map}..remove(trackId);
    version++;
    notifyListeners();
  }

  /// Paroles à afficher : celles de l'utilisateur, sinon celles du fichier.
  Future<Lyrics?> lyricsFor(Track t) async {
    final u = _map[t.id];
    if (u != null && u.text.trim().isNotEmpty) return parseLyrics(u.text);
    return loadLyrics(t.path);
  }

  /// Texte brut (sans horodatage) pour l'éditeur.
  Future<String> plainTextFor(Track t) async {
    final l = await lyricsFor(t);
    if (l == null) return '';
    return l.lines.map((e) => e.text).join('\n').trim();
  }
}

/// Pour les aperçus et les tests.
@visibleForTesting
class EmptyLyricsStore extends LyricsStore {
  EmptyLyricsStore(super.db);

  @override
  Future<Lyrics?> lyricsFor(Track t) async => null;
}
