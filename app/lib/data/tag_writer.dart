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
import 'id3_preserve.dart';
import 'media_store.dart';
import 'mp4_skeleton.dart';
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
Future<Track> writeTags(Track track, TagEdit edit, {required String artDir}) async {
  final sdk = await MediaStoreBridge.sdkInt();
  if (sdk >= 30) {
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

Future<void> _delete(List<File> files) async {
  for (final f in files) {
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}

void applyEdit(String path, TagEdit e) {
  final file = File(path);
  if (p.extension(path).toLowerCase() == '.m4a') {
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
    case VorbisMetadata m:
      common(m);
      // setArtist(null) ne vide pas le champ pour Vorbis : on l'affecte directement.
      m.artist = e.artist == null ? [] : [e.artist!];
      m.albumArtist = e.albumArtist == null ? [] : [e.albumArtist!];
      replaceMetadata(file, m);
    default:
      common(meta);
      replaceMetadata(file, meta);
  }
}

void verify(String path, String expectedTitle) {
  final meta = readMetadata(File(path), getImage: false);
  if ((meta.title ?? '').trim() != expectedTitle.trim()) {
    throw StateError('Verification failed: "${meta.title}" != "$expectedTitle"');
  }
}

/// Le format permet-il d'écrire l'artiste de l'album ?
bool supportsAlbumArtist(Track t) => t.extension != 'm4a' && isSupported(t.path);
