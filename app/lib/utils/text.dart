/// Petits utilitaires texte : recherche sans accents, formatage des durées.
library;

const _accents = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ą': 'a',
  'æ': 'ae',
  'ç': 'c',
  'ć': 'c',
  'č': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ę': 'e',
  'ě': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ñ': 'n',
  'ń': 'n',
  'ň': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'œ': 'oe',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ů': 'u',
  'ý': 'y',
  'ÿ': 'y',
  'ß': 'ss',
  'ł': 'l',
  'ś': 's',
  'š': 's',
  'ź': 'z',
  'ż': 'z',
  'ž': 'z',
  'ř': 'r',
  'ď': 'd',
  'ť': 't',
};

/// Minuscules et sans accents : « Beyoncé » → « beyonce ».
String fold(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_accents[ch] ?? ch);
  }
  return buffer.toString();
}

/// Clé de tri : ignore « the », « le », « la », « les », « el » en tête.
String sortKey(String input) {
  var s = fold(input.trim());
  for (final prefix in const ['the ', 'le ', 'la ', 'les ', 'el ', 'los ', 'las ', "l'"]) {
    if (s.startsWith(prefix) && s.length > prefix.length) {
      s = s.substring(prefix.length);
      break;
    }
  }
  return s;
}

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

String formatBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// Hachage FNV-1a 32 bits, pour nommer les fichiers de pochette.
String fnv(String input) {
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
