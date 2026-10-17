import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

import '../models/track.dart';
import '../utils/text.dart';
import 'lyrics.dart';
import 'media_store.dart';

const supportedExtensions = {'mp3', 'flac', 'm4a'};

bool isSupported(String path) => supportedExtensions.contains(p.extension(path).replaceFirst('.', '').toLowerCase());

/// Lit les tags d'une série de fichiers dans un isolate séparé
/// (l'interface reste fluide pendant le scan).
Future<List<Track>> parseInIsolate({
  required List<MediaRow> rows,
  required String artDir,
  required Map<String, String> knownArt,
}) {
  return Isolate.run(() => parseRows(rows, artDir, knownArt));
}

List<Track> parseRows(List<MediaRow> rows, String artDir, Map<String, String> knownArt) {
  final out = <Track>[];
  for (final row in rows) {
    var track = parseFile(row);
    final key = track.albumKey;
    var art = knownArt[key];
    if (art == null || !File(art).existsSync()) {
      art = extractArt(track.path, artDir, key);
      if (art != null) knownArt[key] = art;
    }
    if (art != null) track = track.copyWith(art: () => art);
    out.add(track);
  }
  return out;
}

String? _clean(String? s) {
  if (s == null) return null;
  final t = s.replaceAll('\u0000', '').trim();
  if (t.isEmpty || t == '<unknown>') return null;
  return t;
}

/// Construit un [Track] à partir des tags du fichier.
/// Si les tags sont absents ou illisibles, on utilise le nom du fichier.
Track parseFile(MediaRow row) {
  AudioMetadata? meta;
  try {
    meta = readMetadata(File(row.path), getImage: false);
  } catch (_) {
    meta = null; // fichier sans tags lisibles : on se replie sur MediaStore
  }
  final fileTitle = p.basenameWithoutExtension(row.path);
  final durationMs = row.durationMs > 0 ? row.durationMs : (meta?.duration?.inMilliseconds ?? 0);
  return Track(
    id: row.id,
    path: row.path,
    title: _clean(meta?.title) ?? fileTitle,
    artist: _clean(meta?.artist) ?? (meta == null ? _clean(row.artist) : null),
    albumArtist: _clean(meta?.albumArtist),
    album: _clean(meta?.album) ?? (meta == null ? _albumFromStore(row) : null),
    genre: meta == null || meta.genres.isEmpty ? null : _clean(meta.genres.first),
    year: meta?.year?.year,
    trackNumber: meta?.trackNumber,
    discNumber: meta?.discNumber,
    durationMs: durationMs,
    bitrate: meta?.bitrate,
    sampleRate: meta?.sampleRate,
    size: row.size,
    mime: row.mime,
    dateAdded: row.dateAdded,
    dateModified: row.dateModified,
    lyricsKind: _lyricsKind(meta?.lyrics, row.path),
  );
}

String? _albumFromStore(MediaRow row) {
  final album = _clean(row.album);
  // MediaStore met le nom du dossier quand il n'y a pas d'album.
  if (album == null || album == p.basename(p.dirname(row.path))) return null;
  return album;
}

/// Extrait la pochette du fichier vers [artDir]. Renvoie le chemin ou null.
String? extractArt(String path, String artDir, String key) {
  try {
    final meta = readMetadata(File(path), getImage: true);
    if (meta.pictures.isEmpty) return null;
    final pic = meta.pictures.firstWhere(
      (x) => x.pictureType == PictureType.coverFront,
      orElse: () => meta.pictures.first,
    );
    if (pic.bytes.isEmpty) return null;
    return saveArt(pic.bytes, pic.mimetype, artDir, key);
  } catch (_) {
    return null;
  }
}

String saveArt(List<int> bytes, String mime, String artDir, String key) {
  final ext = mime.contains('png') ? 'png' : 'jpg';
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final file = File(p.join(artDir, '${fnv(key)}_$stamp.$ext'));
  file.writeAsBytesSync(bytes, flush: true);
  return file.path;
}

/// Paroles du fichier : 0 aucune, 1 texte, 2 synchronisées (ou fichier .lrc à côté).
int _lyricsKind(String? embedded, String path) {
  var text = embedded;
  if (text == null || text.trim().isEmpty) {
    try {
      final lrc = File(p.setExtension(path, '.lrc'));
      if (lrc.existsSync()) text = lrc.readAsStringSync();
    } catch (_) {}
  }
  return lyricsKindOf(text);
}
