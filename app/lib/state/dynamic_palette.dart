import 'package:flutter/material.dart';

import '../audio/handler.dart';
import '../ui/widgets/artwork.dart';

/// Couleur dominante de la pochette en cours, pour le thème « Pochette ».
/// Se met à jour à chaque changement de morceau.
class DynamicPalette extends ChangeNotifier {
  final LyraAudioHandler audio;
  Color? seed;
  String? _art;

  DynamicPalette(this.audio) {
    audio.index.addListener(_update);
    audio.tracks.addListener(_update);
    _update();
  }

  Future<void> _update() async {
    final art = audio.current?.art;
    if (art == _art) return;
    _art = art;
    final color = art == null ? null : await dominantColor(art);
    if (art != _art) return; // un autre morceau a démarré entre-temps
    seed = color;
    notifyListeners();
  }

  @override
  void dispose() {
    audio.index.removeListener(_update);
    audio.tracks.removeListener(_update);
    super.dispose();
  }
}
