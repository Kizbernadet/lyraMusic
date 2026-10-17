import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../utils/text.dart';

// Dégradés de remplacement du prototype (pochette absente).
const _placeholderPalettes = [
  // Tons de la charte : charbon, taupe, sauge, sable, brun.
  [Color(0xFF3A3A3A), Color(0xFF1C1C1C)],
  [Color(0xFF6B5E4A), Color(0xFF29231B)],
  [Color(0xFF5C6B52), Color(0xFF1F261B)],
  [Color(0xFF8A7656), Color(0xFF2E271C)],
  [Color(0xFF5A4A42), Color(0xFF1E1916)],
];

List<Color> placeholderColors(String seed) =>
    _placeholderPalettes[int.parse(fnv(seed).substring(0, 6), radix: 16) % _placeholderPalettes.length];

/// Pochette (fichier en cache) ou dégradé de remplacement.
class Artwork extends StatelessWidget {
  final String? path;
  final double size;
  final double radius;
  final String seed;
  final IconData icon;
  final bool glow;

  const Artwork({
    super.key,
    required this.path,
    required this.size,
    this.radius = 12,
    this.seed = '',
    this.icon = Icons.music_note_rounded,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final placeholder = _Placeholder(size: size, seed: seed, icon: icon);
    final child = path == null
        ? placeholder
        : Image.file(
            File(path!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            // Décodage à la taille affichée : indispensable sur un téléphone d'entrée de gamme.
            cacheWidth: (size * dpr).round(),
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => placeholder,
          );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: glow
            ? const [BoxShadow(color: Color(0x40000000), blurRadius: 36, offset: Offset(0, 14), spreadRadius: -6)]
            : null,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0x10FFFFFF)),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius), child: child),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double size;
  final String seed;
  final IconData icon;
  const _Placeholder({required this.size, required this.seed, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = placeholderColors(seed);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: const Alignment(-0.8, -1), end: const Alignment(0.8, 1), colors: colors),
      ),
      child: Center(
        child: Icon(icon, size: (size * 0.38).clamp(14, 44), color: Colors.white.withValues(alpha: 0.45)),
      ),
    );
  }
}

final Map<String?, Future<Color?>> _dominantCache = {};

/// Couleur dominante d'une pochette (moyenne pondérée par la saturation).
/// Le même Future est renvoyé pour un même fichier (pas de clignotement).
Future<Color?> dominantColor(String? path) => _dominantCache.putIfAbsent(path, () => _dominant(path));

Future<Color?> _dominant(String? path) async {
  if (path == null) return null;
  try {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 16, targetHeight: 16);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    frame.image.dispose();
    if (data == null) return null;
    double r = 0, g = 0, b = 0, w = 0;
    for (var i = 0; i < data.lengthInBytes; i += 4) {
      final pr = data.getUint8(i), pg = data.getUint8(i + 1), pb = data.getUint8(i + 2);
      final hsl = HSLColor.fromColor(Color.fromARGB(255, pr, pg, pb));
      final weight = 0.15 + hsl.saturation * (1 - (hsl.lightness - 0.5).abs() * 2);
      r += pr * weight;
      g += pg * weight;
      b += pb * weight;
      w += weight;
    }
    final color = Color.fromARGB(255, (r / w).round(), (g / w).round(), (b / w).round());
    // On garde une couleur assez saturée et pas trop claire pour un fond sombre.
    final hsl = HSLColor.fromColor(color);
    final tuned = hsl
        .withSaturation((hsl.saturation * 1.25).clamp(0.0, 0.85))
        .withLightness(hsl.lightness.clamp(0.22, 0.42))
        .toColor();
    return tuned;
  } catch (_) {
    return null;
  }
}
