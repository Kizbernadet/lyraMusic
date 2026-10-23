import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
// ParserTag n'est pas exporté par le paquet, mais c'est le type commun des tags.
// ignore: implementation_imports
import 'package:audio_metadata_reader/src/metadata/base.dart' show ParserTag;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/track.dart';
import 'flac_tags.dart';
import 'id3_preserve.dart';
import 'media_store.dart';
import 'mp4_skeleton.dart';
import 'safe_metadata.dart';
import 'scanner.dart';

/// Modifications demandées par l'éditeur de tags.
class TagEdit {
  final String title;
  final String? artist;
  final String? albumArtist;
  final String? album;
  final String? genre;
  final int? year;
  final int? trackNumber;

  /// Nombre de pistes de l'album : null = inchangé.
  final int? trackTotal;

  /// true si la pochette a été remplacée ou supprimée.
  final bool artChanged;
  final Uint8List? artBytes; // null + artChanged = suppression
  final String artMime;

  const TagEdit({
    required this.title,
    this.artist,
    this.albumArtist,
    this.album,
    this.genre,
    this.year,
    this.trackNumber,
    this.trackTotal,
    this.artChanged = false,
    this.artBytes,
    this.artMime = 'image/jpeg',
  });
}

enum TagWriteError { denied, failed }

class TagWriteException implements Exception {
  final TagWriteError kind;
  final Object? cause;
  TagWriteException(this.kind, [this.cause]);
  @override
  String toString() => 'TagWriteException($kind, $cause)';
}

/// Écrit les tags dans le fichier audio, de façon sûre :
/// 1. demande l'autorisation à l'utilisateur (Android 11+) ;
/// 2. copie de sauvegarde + copie de travail dans le cache ;
/// 3. modification et vérification de la copie de travail ;
/// 4. remplacement du contenu du fichier d'origine ;
/// 5. vérification, et restauration de la sauvegarde en cas d'échec.
/// Le fichier d'origine n'est jamais laissé dans un état intermédiaire connu.
/// [askPermission] à false quand l'autorisation a déjà été demandée pour un
/// groupe de fichiers (album entier, voir [requestWriteAll]).
Future<Track> writeTags(Track track, TagEdit edit, {required String artDir, bool askPermission = true}) async {
  final sdk = await MediaStoreBridge.sdkInt();
  if (askPermission && sdk >= 30) {
    final granted = await MediaStoreBridge.requestWrite([track.id]);
    if (!granted) throw TagWriteException(TagWriteError.denied);
  }

  final tmp = await getTemporaryDirectory();
  final work = File(p.join(tmp.path, 'edit_${track.id}.${track.extension}'));
  final backup = File(p.join(tmp.path, 'backup_${track.id}.${track.extension}'));

  try {
    await File(track.path).copy(backup.path);
    await backup.copy(work.path);
    final workPath = work.path;
    await Isolate.run(() {
      applyEdit(workPath, edit);
      verify(workPath, edit.title);
    });
  } catch (e) {
    await _delete([work, backup]);
    throw TagWriteException(TagWriteError.failed, e);
  }

  try {
    await MediaStoreBridge.writeFromFile(track.id, work.path, path: track.path);
    final path = track.path;
    await Isolate.run(() => verify(path, edit.title));
  } catch (e) {
    // Restauration du fichier d'origine.
    try {
      await MediaStoreBridge.writeFromFile(track.id, backup.path, path: track.path);
    } catch (_) {
      // La sauvegarde reste dans le cache si la restauration échoue.
      await _delete([work]);
      throw TagWriteException(TagWriteError.failed, e);
    }
    await _delete([work, backup]);
    throw TagWriteException(TagWriteError.failed, e);
  }
  await _delete([work, backup]);

  final stat = await File(track.path).stat();
  var updated = track.copyWith(
    title: edit.title,
    artist: () => edit.artist,
    albumArtist: () => edit.albumArtist,
    album: () => edit.album,
    genre: () => edit.genre,
    year: () => edit.year,
    trackNumber: () => edit.trackNumber,
    size: stat.size,
    dateModified: stat.modified.millisecondsSinceEpoch ~/ 1000,
  );
  if (edit.artChanged) {
    final bytes = edit.artBytes;
    final key = updated.albumKey;
    final mime = edit.artMime;
    final art = bytes == null ? null : await Isolate.run(() => saveArt(bytes, mime, artDir, key));
    updated = updated.copyWith(art: () => art);
  }
  return updated;
}

/// Une seule demande d'autorisation pour plusieurs fichiers (Android 11+).
Future<void> requestWriteAll(List<Track> tracks) async {
  if (await MediaStoreBridge.sdkInt() < 30) return;
  final granted = await MediaStoreBridge.requestWrite([for (final t in tracks) t.id]);
  if (!granted) throw TagWriteException(TagWriteError.denied);
}

Future<void> _delete(List<File> files) async {
  for (final f in files) {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}

void applyEdit(String path, TagEdit e) {
  final file = File(path);
  if (p.extension(path).toLowerCase() == '.flac') {
    file.writeAsBytesSync(flacEdit(file.readAsBytesSync(), e), flush: true);
    return;
  }
  if (p.extension(path).toLowerCase() == '.m4a') {
    // Structure que la bibliothèque ne sait pas parcourir : on refuse proprement.
    ensureWritableLayout(path);
    // M4A sans bloc de tags : on crée la structure avant d'écrire.
    final patched = addIlstIfMissing(file.readAsBytesSync());
    if (patched != null) file.writeAsBytesSync(patched, flush: true);
  }
  final meta = readAllMetadata(file, getImage: true);

  void common(ParserTag m) {
    m.setTitle(e.title);
    m.setArtist(e.artist);
    m.setAlbum(e.album);
    m.setYear(e.year == null ? null : DateTime(e.year!));
    m.setGenres(e.genre == null ? [] : [e.genre!]);
    m.setTrackNumber(e.trackNumber);
    if (e.trackTotal != null) m.setTrackTotal(e.trackTotal);
    if (e.artChanged) {
      m.setPictures(e.artBytes == null ? [] : [Picture(e.artBytes!, e.artMime, PictureType.coverFront)]);
    }
  }

  switch (meta) {
    case Mp3Metadata m:
      common(m);
      m.contentType = e.genre;
      m.bandOrOrchestra = e.albumArtist;
      // Paroles, commentaires… que l'écrivain ne gère pas : recopiés ensuite.
      final keep = framesToPreserve(file.readAsBytesSync());
      // Écriture ID3v2.4 directe : fonctionne aussi pour un MP3 sans aucun tag.
      Id3v4Writer().write(file, m);
      final injected = injectFrames(file.readAsBytesSync(), keep);
      if (injected != null) file.writeAsBytesSync(injected, flush: true);
    default:
      common(meta);
      replaceMetadata(file, meta);
  }
}

/// FLAC : seuls les champs gérés par l'éditeur sont remplacés (voir flac_tags.dart).
Uint8List flacEdit(Uint8List data, TagEdit e) {
  List<String> one(Object? v) => v == null ? const [] : ['$v'];
  final existing = readFlacComments(data);
  final date = existing.where((c) => c.$1.toUpperCase() == 'DATE').map((c) => c.$2).firstOrNull;
  return rewriteFlacTags(data, {
    'TITLE': one(e.title),
    'ARTIST': one(e.artist),
    'ALBUMARTIST': one(e.albumArtist),
    'ALBUM': one(e.album),
    'GENRE': one(e.genre),
    // Une date complète de la même année (« 2019-05-03 ») est gardée telle quelle.
    'DATE': e.year != null && date != null && date.startsWith('${e.year}') ? [date] : one(e.year),
    'TRACKNUMBER': one(e.trackNumber),
    if (e.trackTotal != null) ...{'TRACKTOTAL': one(e.trackTotal), 'TOTALTRACKS': const <String>[]},
  }, pictures: !e.artChanged ? null : [if (e.artBytes != null) FlacPicture(e.artBytes!, e.artMime)]);
}

void verify(String path, String expectedTitle) {
  final meta = readMetadataSafe(File(path));
  if ((meta.title ?? '').trim() != expectedTitle.trim()) {
    throw StateError('Verification failed: "${meta.title}" != "$expectedTitle"');
  }
}

/// Le format permet-il d'écrire l'artiste de l'album ?
bool supportsAlbumArtist(Track t) => t.extension != 'm4a' && isSupported(t.path);
