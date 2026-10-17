import 'package:flutter/services.dart';

/// Ligne renvoyée par MediaStore (Android).
class MediaRow {
  final int id;
  final String path;
  final int size;
  final int dateAdded;
  final int dateModified;
  final int durationMs;
  final String? mime;
  final String? title;
  final String? artist;
  final String? album;

  MediaRow.fromMap(Map m)
    : id = m['id'] as int,
      path = m['path'] as String,
      size = m['size'] as int,
      dateAdded = m['dateAdded'] as int,
      dateModified = m['dateModified'] as int,
      durationMs = m['duration'] as int,
      mime = m['mime'] as String?,
      title = m['title'] as String?,
      artist = m['artist'] as String?,
      album = m['album'] as String?;
}

/// Pont vers le code natif (MainActivity.kt, canal "lyra/media").
class MediaStoreBridge {
  static const _channel = MethodChannel('lyra/media');

  static int? _sdk;

  static Future<int> sdkInt() async => _sdk ??= await _channel.invokeMethod<int>('sdkInt') ?? 0;

  static Future<List<MediaRow>> queryAudio() async {
    final rows = await _channel.invokeListMethod<Map>('queryAudio') ?? const [];
    return rows.where((m) => m['path'] != null).map(MediaRow.fromMap).toList();
  }

  /// Affiche la demande système « Autoriser LyraMusic à modifier ce fichier ? ».
  static Future<bool> requestWrite(List<int> ids) async =>
      await _channel.invokeMethod<bool>('requestWrite', {'ids': ids}) ?? false;

  /// Remplace le contenu du fichier [id] par celui du fichier [source].
  static Future<void> writeFromFile(int id, String source, {String? path}) =>
      _channel.invokeMethod('writeFromFile', {'id': id, 'source': source, 'path': path});
}
