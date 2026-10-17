import 'package:audio_service/audio_service.dart';
import 'package:path/path.dart' as p;

import '../utils/text.dart';

/// Un morceau de la bibliothèque. L'identifiant est celui de MediaStore.
class Track {
  final int id;
  final String path;
  final String title;
  final String? artist;
  final String? albumArtist;
  final String? album;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int? discNumber;
  final int durationMs;
  final int? bitrate;
  final int? sampleRate;
  final int size;
  final String? mime;
  final int dateAdded; // secondes
  final int dateModified; // secondes
  final String? art; // chemin du fichier image en cache

  Track({
    required this.id,
    required this.path,
    required this.title,
    this.artist,
    this.albumArtist,
    this.album,
    this.genre,
    this.year,
    this.trackNumber,
    this.discNumber,
    required this.durationMs,
    this.bitrate,
    this.sampleRate,
    required this.size,
    this.mime,
    required this.dateAdded,
    required this.dateModified,
    this.art,
    this.lyricsKind = 0,
  });

  /// Paroles trouvées dans le fichier (ou un .lrc à côté) : 0 aucune, 1 texte, 2 synchronisées.
  final int lyricsKind;

  Duration get duration => Duration(milliseconds: durationMs);

  /// Tags essentiels manquants (artiste ou album) : à compléter.
  bool get isIncomplete => artist == null || album == null;
  String get extension => p.extension(path).replaceFirst('.', '').toLowerCase();
  String get folder => p.dirname(path);
  String get fileName => p.basename(path);

  /// Artiste utilisé pour regrouper : vide si inconnu.
  String get artistKey => artist ?? '';

  /// Identifie un album : artiste de l'album s'il existe, sinon le dossier.
  String get albumKey {
    final name = fold(album ?? '');
    if (albumArtist != null && albumArtist!.isNotEmpty) {
      return 'aa:${fold(albumArtist!)}|$name';
    }
    return 'dir:$folder|$name';
  }

  late final String searchText = fold([title, artist ?? '', album ?? '', albumArtist ?? ''].join(' '));

  Track copyWith({
    String? title,
    String? Function()? artist,
    String? Function()? albumArtist,
    String? Function()? album,
    String? Function()? genre,
    int? Function()? year,
    int? Function()? trackNumber,
    int? size,
    int? dateModified,
    String? Function()? art,
  }) => Track(
    id: id,
    path: path,
    title: title ?? this.title,
    artist: artist != null ? artist() : this.artist,
    albumArtist: albumArtist != null ? albumArtist() : this.albumArtist,
    album: album != null ? album() : this.album,
    genre: genre != null ? genre() : this.genre,
    year: year != null ? year() : this.year,
    trackNumber: trackNumber != null ? trackNumber() : this.trackNumber,
    discNumber: discNumber,
    durationMs: durationMs,
    bitrate: bitrate,
    sampleRate: sampleRate,
    size: size ?? this.size,
    mime: mime,
    dateAdded: dateAdded,
    dateModified: dateModified ?? this.dateModified,
    art: art != null ? art() : this.art,
    lyricsKind: lyricsKind,
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'path': path,
    'title': title,
    'artist': artist,
    'album_artist': albumArtist,
    'album': album,
    'genre': genre,
    'year': year,
    'track_no': trackNumber,
    'disc_no': discNumber,
    'duration_ms': durationMs,
    'bitrate': bitrate,
    'sample_rate': sampleRate,
    'size': size,
    'mime': mime,
    'date_added': dateAdded,
    'date_modified': dateModified,
    'art': art,
    'lyrics': lyricsKind,
  };

  factory Track.fromRow(Map<String, Object?> r) => Track(
    id: r['id'] as int,
    path: r['path'] as String,
    title: r['title'] as String,
    artist: r['artist'] as String?,
    albumArtist: r['album_artist'] as String?,
    album: r['album'] as String?,
    genre: r['genre'] as String?,
    year: r['year'] as int?,
    trackNumber: r['track_no'] as int?,
    discNumber: r['disc_no'] as int?,
    durationMs: r['duration_ms'] as int,
    bitrate: r['bitrate'] as int?,
    sampleRate: r['sample_rate'] as int?,
    size: r['size'] as int,
    mime: r['mime'] as String?,
    dateAdded: r['date_added'] as int,
    dateModified: r['date_modified'] as int,
    art: r['art'] as String?,
    lyricsKind: r['lyrics'] as int? ?? 0,
  );

  /// Élément affiché par la notification et l'écran verrouillé.
  MediaItem toMediaItem({required String unknownArtist, required String unknownAlbum}) => MediaItem(
    id: id.toString(),
    title: title,
    artist: artist ?? unknownArtist,
    album: album ?? unknownAlbum,
    duration: duration,
    artUri: art != null ? Uri.file(art!) : null,
  );

  @override
  bool operator ==(Object other) => other is Track && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Album dérivé de la liste des morceaux.
class Album {
  final String key;
  final String? name;
  final String? artist;
  final List<Track> tracks;
  Album(this.key, this.name, this.artist, this.tracks);

  String? get art => tracks.map((t) => t.art).firstWhere((a) => a != null, orElse: () => null);
  int? get year => tracks.map((t) => t.year).firstWhere((y) => y != null, orElse: () => null);
}

/// Groupe nommé (artiste ou genre).
class Group {
  final String? name; // null = inconnu
  final List<Track> tracks;
  Group(this.name, this.tracks);

  String? get art => tracks.map((t) => t.art).firstWhere((a) => a != null, orElse: () => null);
}

class Playlist {
  final int id;
  final String name;
  final List<int> trackIds;
  final int updated;
  const Playlist(this.id, this.name, this.trackIds, this.updated);
}
