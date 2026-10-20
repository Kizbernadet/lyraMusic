import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'safe_metadata.dart';

class LyricLine {
  final Duration? time;
  final String text;
  const LyricLine(this.time, this.text);
}

class Lyrics {
  final List<LyricLine> lines;
  final bool synced;
  const Lyrics(this.lines, this.synced);

  /// Index de la ligne en cours pour une position de lecture.
  int indexAt(Duration position) {
    if (!synced) return -1;
    var lo = 0, hi = lines.length - 1, found = -1;
    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      if (lines[mid].time! <= position) {
        found = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return found;
  }
}

/// Paroles intégrées au fichier (USLT / LYRICS) ou fichier .lrc à côté.
Future<Lyrics?> loadLyrics(String audioPath) {
  final scratch = metadataScratchDir;
  return Isolate.run(() => _loadLyrics(audioPath, scratch));
}

Lyrics? _loadLyrics(String audioPath, String? scratch) {
  String? text;
  try {
    text = readMetadataSafe(File(audioPath), scratchDir: scratch).lyrics;
  } catch (_) {}
  if (text == null || text.trim().isEmpty) {
    try {
      final lrc = File(p.setExtension(audioPath, '.lrc'));
      if (lrc.existsSync()) text = lrc.readAsStringSync();
    } catch (_) {}
  }
  if (text == null || text.trim().isEmpty) return null;
  return parseLyrics(text);
}

final _stamp = RegExp(r'\[(\d{1,3}):(\d{1,2}(?:[.:]\d{1,3})?)\]');
final _meta = RegExp(r'^\[(ar|ti|al|by|offset|length|re|ve|au|#):', caseSensitive: false);

Lyrics parseLyrics(String text) {
  final timed = <LyricLine>[];
  final plain = <LyricLine>[];
  for (final raw in text.split(RegExp(r'\r?\n'))) {
    final line = raw.trimRight();
    if (_meta.hasMatch(line)) continue;
    final stamps = _stamp.allMatches(line).toList();
    if (stamps.isEmpty) {
      plain.add(LyricLine(null, line.trim()));
      continue;
    }
    final content = line.substring(stamps.last.end).trim();
    for (final m in stamps) {
      final min = int.parse(m.group(1)!);
      final sec = double.parse(m.group(2)!.replaceAll(':', '.'));
      timed.add(LyricLine(Duration(milliseconds: ((min * 60 + sec) * 1000).round()), content));
    }
  }
  if (timed.length >= 2) {
    timed.sort((a, b) => a.time!.compareTo(b.time!));
    return Lyrics(timed, true);
  }
  // On retire les lignes vides en début et fin.
  while (plain.isNotEmpty && plain.first.text.isEmpty) {
    plain.removeAt(0);
  }
  while (plain.isNotEmpty && plain.last.text.isEmpty) {
    plain.removeLast();
  }
  return Lyrics(plain, false);
}

/// 0 aucune parole, 1 texte simple, 2 paroles synchronisées (LRC).
int lyricsKindOf(String? text) {
  if (text == null || text.trim().isEmpty) return 0;
  return _stamp.allMatches(text).length >= 2 ? 2 : 1;
}

/// Paroles synchronisées → texte LRC.
String toLrc(List<LyricLine> lines) {
  String stamp(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inMilliseconds % 60000 / 1000).toStringAsFixed(2).padLeft(5, '0');
    return '[$m:$s]';
  }

  return lines.map((l) => '${l.time == null ? '' : stamp(l.time!)}${l.text}').join('\n');
}
