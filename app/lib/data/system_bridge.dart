import 'package:flutter/services.dart';

/// Pont vers Android (MainActivity.kt, canal « lyra/system ») :
/// volume média, widgets d'écran d'accueil, écran de verrouillage LyraMusic.
class SystemBridge {
  static const _channel = MethodChannel('lyra/system');

  static String? _lastSync;

  /// Envoie le morceau en cours aux widgets et à l'écran de verrouillage.
  static Future<void> updateNowPlaying({String? title, String? artist, String? art, required bool playing}) async {
    final key = '$title|$artist|$art|$playing';
    if (key == _lastSync) return;
    _lastSync = key;
    try {
      await _channel.invokeMethod('updateNowPlaying', {
        'title': title,
        'artist': artist,
        'art': art,
        'playing': playing,
      });
    } on MissingPluginException {
      // Moteur en arrière-plan sans activité : rien à mettre à jour.
    } catch (_) {}
  }

  // ---- Volume média (celui des touches du téléphone) ----

  static Future<(int, int)> volume() async {
    final m = await _channel.invokeMapMethod<String, int>('getVolume') ?? const {};
    return (m['current'] ?? 0, m['max'] ?? 15);
  }

  static Future<void> setVolume(int value) => _channel.invokeMethod('setVolume', {'value': value});

  // ---- Écran de verrouillage ----

  /// Le téléphone permet-il d'afficher le lecteur au-dessus de l'écran verrouillé ?
  static Future<bool> lockScreenAllowed() async => await _channel.invokeMethod<bool>('lockScreenAllowed') ?? false;

  /// Ouvre le réglage système qui donne cette autorisation.
  static Future<void> requestLockScreenPermission() => _channel.invokeMethod('requestLockScreenPermission');

  static Future<void> setLockScreenEnabled(bool enabled) =>
      _channel.invokeMethod('setLockScreenEnabled', {'enabled': enabled});

  // ---- Widgets ----

  /// Propose d'ajouter un widget sur l'écran d'accueil (si le lanceur le permet).
  static Future<bool> pinWidget(String kind) async =>
      await _channel.invokeMethod<bool>('pinWidget', {'kind': kind}) ?? false;
}
