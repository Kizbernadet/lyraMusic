import 'dart:typed_data';

/// Cadres ID3 réécrits par la bibliothèque de tags (Id3v4Writer).
/// Tous les autres (paroles USLT/SYLT, commentaires COMM, TXXX, POPM…) seraient
/// perdus : on les recopie après l'écriture.
const _handledByWriter = {
  'TALB', 'TBPM', 'TCOM', 'TCOP', 'TDAT', 'TDLY', 'TENC', 'TEXT', 'TFLT', 'TIME', 'TIT1',
  'TIT2', 'TIT3', 'TKEY', 'TLAN', 'TLEN', 'TMED', 'TOAL', 'TOFN', 'TOLY', 'TOPE', 'TORY',
  'TOWN', 'TPE1', 'TPE2', 'TPE3', 'TPE4', 'TPOS', 'TPUB', 'TRCK', 'TRDA', 'TRSN', 'TRSO',
  'TSIZ', 'TSRC', 'TSSE', 'TYER', 'TCON', 'APIC',
  // Équivalents ID3v2.4 de champs déjà écrits (année, date) : on ne les garde pas.
  'TDRC', 'TDRL', 'TDOR',
};

class RawFrame {
  final String id;
  final Uint8List body;
  const RawFrame(this.id, this.body);
}

int _syncsafe(Uint8List d, int o) => (d[o] << 21) | (d[o + 1] << 14) | (d[o + 2] << 7) | d[o + 3];

int _plain(Uint8List d, int o) => (d[o] << 24) | (d[o + 1] << 16) | (d[o + 2] << 8) | d[o + 3];

bool _validId(Uint8List d, int o) {
  for (var i = 0; i < 4; i++) {
    final c = d[o + i];
    final ok = (c >= 0x41 && c <= 0x5A) || (c >= 0x30 && c <= 0x39);
    if (!ok) return false;
  }
  return true;
}

/// Cadres de l'en-tête ID3v2.3/2.4 au début du fichier que l'écrivain ne gère pas.
List<RawFrame> framesToPreserve(Uint8List data) {
  if (data.length < 10 || data[0] != 0x49 || data[1] != 0x44 || data[2] != 0x33) return const [];
  final major = data[3];
  final flags = data[5];
  if (major != 3 && major != 4) return const [];
  if (flags & 0x80 != 0) return const []; // désynchronisation globale : on ne prend pas de risque
  final tagEnd = 10 + _syncsafe(data, 6);
  if (tagEnd > data.length) return const [];
  var pos = 10;
  if (flags & 0x40 != 0) {
    // En-tête étendu
    final extSize = major == 4 ? _syncsafe(data, pos) : _plain(data, pos) + 4;
    pos += extSize;
  }
  final out = <RawFrame>[];
  while (pos + 10 <= tagEnd && _validId(data, pos)) {
    final id = String.fromCharCodes(data.sublist(pos, pos + 4));
    final size = major == 4 ? _syncsafe(data, pos + 4) : _plain(data, pos + 4);
    final formatFlags = data[pos + 9];
    final bodyStart = pos + 10;
    if (size <= 0 || bodyStart + size > tagEnd) break;
    // Cadres compressés, chiffrés ou désynchronisés : ignorés.
    final special = major == 4 ? formatFlags & 0x4F != 0 : formatFlags & 0xE0 != 0;
    if (!special && !_handledByWriter.contains(id)) {
      out.add(RawFrame(id, Uint8List.fromList(data.sublist(bodyStart, bodyStart + size))));
    }
    pos = bodyStart + size;
  }
  return out;
}

Uint8List _toSyncsafe(int v) => Uint8List.fromList([(v >> 21) & 0x7F, (v >> 14) & 0x7F, (v >> 7) & 0x7F, v & 0x7F]);

/// Ajoute [frames] dans l'en-tête ID3v2.4 placé au début de [data].
Uint8List? injectFrames(Uint8List data, List<RawFrame> frames) {
  if (frames.isEmpty) return null;
  if (data.length < 10 || data[0] != 0x49 || data[1] != 0x44 || data[2] != 0x33 || data[3] != 4) return null;
  if (data[5] & 0xD0 != 0) return null; // désynchronisation, en-tête étendu ou pied de page
  final size = _syncsafe(data, 6);
  final tagEnd = 10 + size;
  // Fin des cadres = début du remplissage (octets nuls).
  var pos = 10;
  while (pos + 10 <= tagEnd && _validId(data, pos)) {
    pos += 10 + _syncsafe(data, pos + 4);
  }
  final extra = BytesBuilder();
  for (final f in frames) {
    extra
      ..add(f.id.codeUnits)
      ..add(_toSyncsafe(f.body.length))
      ..add(const [0, 0])
      ..add(f.body);
  }
  final added = extra.toBytes();
  final out = BytesBuilder(copy: false)
    ..add(data.sublist(0, 6))
    ..add(_toSyncsafe(size + added.length))
    ..add(data.sublist(10, pos))
    ..add(added)
    ..add(data.sublist(pos));
  return out.toBytes();
}
