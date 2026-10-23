import 'dart:typed_data';

/// Durée d'une valeur de l'enveloppe sonore (voir AudioEnvelope.kt).
const envelopeFrameMs = 10;

/// Cherche une attaque (montée nette du volume, typiquement le début d'une
/// ligne chantée) près de [at] : entre [before] ms avant et [after] ms après.
/// Les appuis sont en général un peu en retard, d'où une fenêtre plus large
/// vers l'arrière. Renvoie null si rien de net n'est trouvé : la ligne garde
/// alors son temps.
Duration? snapToOnset(Uint8List envelope, Duration at, {int before = 350, int after = 200}) {
  const pre = 6, post = 4; // 60 ms avant, 40 ms après chaque point
  if (envelope.length < pre + post + 1) return null;
  final center = at.inMilliseconds ~/ envelopeFrameMs;
  final from = (center - before ~/ envelopeFrameMs).clamp(pre, envelope.length - post - 1);
  final to = (center + after ~/ envelopeFrameMs).clamp(pre, envelope.length - post - 1);

  double avg(int start, int count) {
    var sum = 0;
    for (var i = start; i < start + count; i++) {
      sum += envelope[i];
    }
    return sum / count;
  }

  int? best;
  var bestScore = 0.0;
  for (var i = from; i <= to; i++) {
    final rise = avg(i, post) - avg(i - pre, pre);
    if (rise < 14) continue; // trop faible pour être une attaque
    // À montée égale, on préfère le point le plus proche de l'appui.
    final score = rise - (i - center).abs() * 0.04;
    if (score > bestScore) {
      bestScore = score;
      best = i;
    }
  }
  return best == null ? null : Duration(milliseconds: best * envelopeFrameMs);
}
