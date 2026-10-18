import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/media_store.dart';
import 'library.dart';

/// Garde la bibliothèque à jour sans action de l'utilisateur :
/// - au démarrage (scan incrémental) ;
/// - quand MediaStore signale un changement (fichier copié, téléchargé, supprimé) ;
/// - au retour de l'application au premier plan (changements faits pendant la pause).
/// Le scan manuel reste disponible dans l'Accueil et les réglages.
class LibrarySync with WidgetsBindingObserver {
  final LibraryController library;
  LibrarySync(this.library);

  StreamSubscription<void>? _changes;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  bool _started = false;

  void start() {
    if (_started) {
      _scan();
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _changes = MediaStoreBridge.changes().listen((_) => _scan(), onError: (_) {});
    _scan();
  }

  void _scan() {
    _last = DateTime.now();
    library.scan();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pas plus d'un scan toutes les 10 s pour les allers-retours rapides.
    if (state == AppLifecycleState.resumed && DateTime.now().difference(_last).inSeconds >= 10) _scan();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _changes?.cancel();
  }
}
