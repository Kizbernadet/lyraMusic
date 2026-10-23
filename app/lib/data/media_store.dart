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

/// Morceau dans la corbeille du téléphone.
class TrashedRow {
  final int id;
  final String path;
  final String? title;
  final String? artist;
  final int durationMs;

  /// Date de suppression définitive par le système.
  final DateTime expires;

  TrashedRow.fromMap(Map m)
    : id = m['id'] as int,
      path = m['path'] as String? ?? '',
      title = m['title'] as String?,
      artist = m['artist'] as String?,
      durationMs = m['duration'] as int? ?? 0,
      expires = DateTime.fromMillisecondsSinceEpoch((m['expires'] as int? ?? 0) * 1000);
}

/// Pont vers le code natif (MainActivity.kt, canal "lyra/media").
class MediaStoreBridge {
  static const _channel = MethodChannel('lyra/media');
  static const _changes = EventChannel('lyra/media/changes');

  /// Un événement chaque fois que la musique du téléphone change (déjà regroupé côté natif).
  static Stream<void> changes() => _changes.receiveBroadcastStream().map((_) {});

  static int? _sdk;

  static Future<int> sdkInt() async => _sdk ??= await _channel.invokeMethod<int>('sdkInt') ?? 0;

  static Future<List<MediaRow>> queryAudio() async {
    final rows = await _channel.invokeListMethod<Map>('queryAudio') ?? const [];
    return rows.where((m) => m['path'] != null).map(MediaRow.fromMap).toList();
  }

  /// Affiche la demande système « Autoriser LyraMusic à modifier ce fichier ? ».
  static Future<bool> requestWrite(List<int> ids) async =>
      await _channel.invokeMethod<bool>('requestWrite', {'ids': ids}) ?? false;

  /// Supprime les fichiers (demande système sur Android 11+). Avec [trash], ils vont
  /// dans la corbeille du téléphone (Android 11+ uniquement, sinon suppression définitive).
  /// Renvoie false si l'utilisateur refuse.
  static Future<bool> deleteAudio(List<int> ids, List<String> paths, {bool trash = false}) async =>
      await _channel.invokeMethod<bool>('deleteAudio', {'ids': ids, 'paths': paths, 'trash': trash}) ?? false;

  /// La corbeille du téléphone existe à partir d'Android 11.
  static Future<bool> hasTrash() async => await sdkInt() >= 30;

  /// Sort des fichiers de la corbeille (demande système).
  static Future<bool> restoreAudio(List<int> ids) async =>
      await _channel.invokeMethod<bool>('restoreAudio', {'ids': ids}) ?? false;

  static Future<List<TrashedRow>> queryTrash() async {
    final rows = await _channel.invokeListMethod<Map>('queryTrash') ?? const [];
    return rows.map(TrashedRow.fromMap).toList();
  }

  /// Volume du morceau toutes les 10 ms (0 à 255), pour la forme d'onde.
  static Future<Uint8List> audioEnvelope(String path) async =>
      await _channel.invokeMethod<Uint8List>('audioEnvelope', {'path': path}) ?? Uint8List(0);

  /// Remplace le contenu du fichier [id] par celui du fichier [source].
  static Future<void> writeFromFile(int id, String source, {String? path}) =>
      _channel.invokeMethod('writeFromFile', {'id': id, 'source': source, 'path': path});
}
