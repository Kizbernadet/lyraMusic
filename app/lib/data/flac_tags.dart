import 'dart:convert';
import 'dart:typed_data';

/// Écriture des tags d'un FLAC sans passer par l'écrivain de la bibliothèque,
/// qui ne réécrit qu'une partie des commentaires Vorbis (paroles, TRACKTOTAL,
/// DISCNUMBER, ReplayGain, commentaires… étaient perdus).
/// Ici, seuls les champs modifiés sont remplacés ; tout le reste est conservé,
/// y compris les autres blocs de métadonnées (SEEKTABLE, CUESHEET…).

class FlacPicture {
  final Uint8List bytes;
  final String mime;
  const FlacPicture(this.bytes, this.mime);
}

class _Block {
  final int type;
  final Uint8List body;
  const _Block(this.type, this.body);
}

const _streamInfo = 0, _padding = 1, _vorbis = 4, _picture = 6;

bool isFlac(Uint8List data) =>
    data.length >= 4 && data[0] == 0x66 && data[1] == 0x4C && data[2] == 0x61 && data[3] == 0x43; // fLaC

/// Blocs de métadonnées et position du début des données audio.
(List<_Block>, int) _readBlocks(Uint8List data) {
  if (!isFlac(data)) throw const FormatException('Not a FLAC file');
  final blocks = <_Block>[];
  var o = 4;
  while (true) {
    if (o + 4 > data.length) throw const FormatException('Truncated FLAC metadata');
    final header = data[o];
    final length = (data[o + 1] << 16) | (data[o + 2] << 8) | data[o + 3];
    o += 4;
    if (o + length > data.length) throw const FormatException('Truncated FLAC block');
    blocks.add(_Block(header & 0x7F, Uint8List.sublistView(data, o, o + length)));
    o += length;
    if (header & 0x80 != 0) break;
  }
  return (blocks, o);
}

/// Commentaires Vorbis (« CLÉ=valeur ») dans l'ordre du fichier, et le nom de l'encodeur.
(String, List<(String, String)>) _parseComments(Uint8List body) {
  final d = ByteData.sublistView(body);
  var o = 0;
  final vendorLength = d.getUint32(o, Endian.little);
  o += 4;
  final vendor = utf8.decode(body.sublist(o, o + vendorLength), allowMalformed: true);
  o += vendorLength;
  final count = d.getUint32(o, Endian.little);
  o += 4;
  final list = <(String, String)>[];
  for (var i = 0; i < count && o + 4 <= body.length; i++) {
    final n = d.getUint32(o, Endian.little);
    o += 4;
    if (o + n > body.length) break;
    final text = utf8.decode(body.sublist(o, o + n), allowMalformed: true);
    o += n;
    final eq = text.indexOf('=');
    if (eq > 0) list.add((text.substring(0, eq), text.substring(eq + 1)));
  }
  return (vendor, list);
}

Uint8List _buildComments(String vendor, List<(String, String)> list) {
  final b = BytesBuilder();
  void u32(int v) => b.add((ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List());
  final v = utf8.encode(vendor);
  u32(v.length);
  b.add(v);
  u32(list.length);
  for (final (key, value) in list) {
    final e = utf8.encode('$key=$value');
    u32(e.length);
    b.add(e);
  }
  return b.toBytes();
}

Uint8List _buildPicture(FlacPicture p) {
  final b = BytesBuilder();
  void u32(int v) => b.add((ByteData(4)..setUint32(0, v)).buffer.asUint8List());
  final mime = ascii.encode(p.mime);
  u32(3); // couverture (recto)
  u32(mime.length);
  b.add(mime);
  u32(0); // pas de description
  u32(0); // largeur, hauteur, profondeur, couleurs : inconnues
  u32(0);
  u32(0);
  u32(0);
  u32(p.bytes.length);
  b.add(p.bytes);
  return b.toBytes();
}

/// Commentaires Vorbis du fichier (pour la vérification et les tests).
List<(String, String)> readFlacComments(Uint8List data) {
  final (blocks, _) = _readBlocks(data);
  for (final b in blocks) {
    if (b.type == _vorbis) return _parseComments(b.body).$2;
  }
  return const [];
}

/// Remplace les champs [fields] (clé en majuscules → valeurs ; liste vide = suppression)
/// et, si [pictures] n'est pas null, les pochettes. Le reste du fichier est conservé.
Uint8List rewriteFlacTags(Uint8List data, Map<String, List<String>> fields, {List<FlacPicture>? pictures}) {
  final (blocks, audioStart) = _readBlocks(data);
  if (blocks.isEmpty || blocks.first.type != _streamInfo) throw const FormatException('Missing STREAMINFO');

  var vendor = 'LyraMusic';
  var comments = <(String, String)>[];
  for (final b in blocks) {
    if (b.type == _vorbis) (vendor, comments) = _parseComments(b.body);
  }
  final keys = fields.keys.map((k) => k.toUpperCase()).toSet();
  comments = [
    for (final c in comments)
      if (!keys.contains(c.$1.toUpperCase())) c,
    for (final e in fields.entries)
      for (final v in e.value) (e.key.toUpperCase(), v),
  ];

  final out = <_Block>[
    blocks.first,
    for (final b in blocks.skip(1))
      if (b.type != _vorbis && b.type != _padding && !(pictures != null && b.type == _picture)) b,
    _Block(_vorbis, _buildComments(vendor, comments)),
    if (pictures != null)
      for (final p in pictures) _Block(_picture, _buildPicture(p)),
    // Un peu de marge pour que d'autres logiciels puissent modifier les tags sur place.
    _Block(_padding, Uint8List(4096)),
  ];

  final b = BytesBuilder(copy: false);
  b.add(data.sublist(0, 4));
  for (var i = 0; i < out.length; i++) {
    final body = out[i].body;
    if (body.length >= 1 << 24) throw const FormatException('FLAC block too large');
    b.add([
      (i == out.length - 1 ? 0x80 : 0) | out[i].type,
      (body.length >> 16) & 0xFF,
      (body.length >> 8) & 0xFF,
      body.length & 0xFF,
    ]);
    b.add(body);
  }
  b.add(Uint8List.sublistView(data, audioStart));
  return b.toBytes();
}
