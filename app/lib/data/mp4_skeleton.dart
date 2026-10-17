import 'dart:typed_data';

/// Ajoute la structure de tags iTunes (moov/udta/meta/ilst) à un fichier M4A
/// qui n'en a pas, pour que l'écriture des tags soit possible.
///
/// Insérer des octets dans `moov` décale les données audio situées après lui :
/// les tables de positions (`stco` / `co64`) sont donc corrigées.
/// Renvoie null si le fichier a déjà un `ilst` ou si sa structure n'est pas gérée.
Uint8List? addIlstIfMissing(Uint8List data) {
  final top = _children(data, 0, data.length);
  if (top == null) return null;
  final moov = top.where((b) => b.type == 'moov').firstOrNull;
  if (moov == null || moov.largeSize) return null;

  final moovKids = _children(data, moov.contentStart, moov.end);
  if (moovKids == null) return null;
  final udta = moovKids.where((b) => b.type == 'udta').firstOrNull;

  Uint8List newMoovContent;
  if (udta == null) {
    newMoovContent = _concat([data.sublist(moov.contentStart, moov.end), _box('udta', _meta())]);
  } else {
    if (udta.largeSize) return null;
    final udtaKids = _children(data, udta.contentStart, udta.end);
    if (udtaKids == null) return null;
    final meta = udtaKids.where((b) => b.type == 'meta').firstOrNull;
    Uint8List newUdtaContent;
    if (meta == null) {
      newUdtaContent = _concat([data.sublist(udta.contentStart, udta.end), _meta()]);
    } else {
      if (meta.largeSize) return null;
      // meta est une « full box » : 4 octets version/flags (à zéro) avant les
      // enfants ; certains fichiers QuickTime les omettent.
      final hasFullHeader =
          meta.end - meta.contentStart >= 4 &&
          data.sublist(meta.contentStart, meta.contentStart + 4).every((x) => x == 0);
      final kidsStart = hasFullHeader ? meta.contentStart + 4 : meta.contentStart;
      final metaKids = _children(data, kidsStart, meta.end);
      if (metaKids == null) return null;
      if (metaKids.any((b) => b.type == 'ilst')) return null; // déjà présent
      final newMeta = _box('meta', _concat([data.sublist(meta.contentStart, meta.end), _box('ilst', [])]));
      newUdtaContent = _concat([
        data.sublist(udta.contentStart, meta.start),
        newMeta,
        data.sublist(meta.end, udta.end),
      ]);
    }
    newMoovContent = _concat([
      data.sublist(moov.contentStart, udta.start),
      _box('udta', newUdtaContent),
      data.sublist(udta.end, moov.end),
    ]);
  }

  final delta = newMoovContent.length + 8 - moov.size;
  final mdatAfterMoov = top.any((b) => b.type == 'mdat' && b.start >= moov.end);
  if (mdatAfterMoov && delta != 0) {
    if (!_shiftChunkOffsets(newMoovContent, 0, newMoovContent.length, delta)) return null;
  }
  return _concat([data.sublist(0, moov.start), _box('moov', newMoovContent), data.sublist(moov.end)]);
}

class _Box {
  final String type;
  final int start;
  final int size;
  final int headerSize;
  _Box(this.type, this.start, this.size, this.headerSize);
  int get end => start + size;
  int get contentStart => start + headerSize;
  bool get largeSize => headerSize == 16;
}

List<_Box>? _children(Uint8List data, int start, int end) {
  final bd = ByteData.sublistView(data);
  final out = <_Box>[];
  var pos = start;
  while (pos + 8 <= end) {
    var size = bd.getUint32(pos);
    final type = String.fromCharCodes(data.sublist(pos + 4, pos + 8));
    var header = 8;
    if (size == 1) {
      if (pos + 16 > end) return null;
      size = bd.getUint64(pos + 8);
      header = 16;
    } else if (size == 0) {
      size = end - pos; // jusqu'à la fin
    }
    if (size < header || pos + size > end) return null;
    out.add(_Box(type, pos, size, header));
    pos += size;
  }
  return out;
}

const _containers = {'trak', 'mdia', 'minf', 'stbl', 'edts', 'dinf'};

/// Corrige en place les positions dans les boîtes stco / co64.
bool _shiftChunkOffsets(Uint8List data, int start, int end, int delta) {
  final kids = _children(data, start, end);
  if (kids == null) return false;
  final bd = ByteData.sublistView(data);
  for (final b in kids) {
    if (_containers.contains(b.type)) {
      if (!_shiftChunkOffsets(data, b.contentStart, b.end, delta)) return false;
    } else if (b.type == 'stco' || b.type == 'co64') {
      final wide = b.type == 'co64';
      final count = bd.getUint32(b.contentStart + 4);
      var p = b.contentStart + 8;
      for (var i = 0; i < count; i++) {
        if (wide) {
          bd.setUint64(p, bd.getUint64(p) + delta);
          p += 8;
        } else {
          final v = bd.getUint32(p) + delta;
          if (v > 0xFFFFFFFF) return false;
          bd.setUint32(p, v);
          p += 4;
        }
      }
    }
  }
  return true;
}

Uint8List _meta() {
  final hdlr = _box('hdlr', [
    0, 0, 0, 0, // version / flags
    0, 0, 0, 0, // pre_defined
    ...'mdir'.codeUnits,
    ...'appl'.codeUnits, 0, 0, 0, 0, 0, 0, 0, 0,
    0, // nom vide
  ]);
  return _box('meta', _concat([Uint8List(4), hdlr, _box('ilst', [])]));
}

Uint8List _box(String type, List<int> payload) {
  final out = Uint8List(8 + payload.length);
  ByteData.sublistView(out).setUint32(0, out.length);
  out.setRange(4, 8, type.codeUnits);
  out.setRange(8, out.length, payload);
  return out;
}

Uint8List _concat(List<List<int>> parts) {
  final b = BytesBuilder(copy: false);
  for (final p in parts) {
    b.add(p);
  }
  return b.toBytes();
}
