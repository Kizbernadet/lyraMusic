import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'media_store.dart';

/// Export des LyricsCards (code natif : CardExport.kt). L'image est transmise en PNG
/// sans perte, puis encodée en JPEG qualité 95 côté Android.
class CardExport {
  static const _channel = MethodChannel('lyra/media');

  /// Enregistre l'image dans la galerie (Images/LyraMusic). Faux si l'accès est refusé.
  static Future<bool> save(Uint8List png, String name) async {
    // Android 9 et inférieur : il faut l'autorisation d'écrire dans le stockage.
    if (await MediaStoreBridge.sdkInt() < 29 && !(await Permission.storage.request()).isGranted) return false;
    await _channel.invokeMethod('saveImage', {'png': png, 'name': name});
    return true;
  }

  /// Ouvre la feuille de partage du système.
  static Future<void> share(Uint8List png, String name, {String? title}) =>
      _channel.invokeMethod('shareImage', {'png': png, 'name': name, 'title': title});
}
