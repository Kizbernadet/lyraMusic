import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;

/// Dossier temporaire de l'application, renseigné au démarrage. Les isolates
/// ne partagent pas les variables globales : le capturer avant `Isolate.run`.
String? metadataScratchDir;

/// `readMetadata`, protégé contre les M4A que la bibliothèque ne sait pas lire.
///
/// Le lecteur MP4 d'audio_metadata_reader ne gère ni les boîtes de taille 0
/// (« jusqu'à la fin du fichier ») ni les tailles 64 bits (taille = 1). Les longs
/// enregistrements M4A (dictaphones, convertisseurs, podcasts) en ont souvent
/// pour `mdat` : la bibliothèque boucle alors à l'infini ou alloue des
/// centaines de Mo, ce qui finissait par faire tomber l'application.
///
/// Pour ces fichiers, on ne lui donne que `ftyp` + `moov` (là où sont les tags),
/// copiés dans un petit fichier temporaire. Lève une exception si la structure
/// n'est pas lisible : les appelants se replient déjà sur MediaStore.
AudioMetadata readMetadataSafe(File file, {bool getImage = false, String? scratchDir}) {
  final layout = mp4Layout(file);
  if (layout == null || layout.plain) return readMetadata(file, getImage: getImage);

  final dir = scratchDir ?? metadataScratchDir ?? Directory.systemTemp.path;
  final tmp = File(p.join(dir, '.meta_${pid}_${DateTime.now().microsecondsSinceEpoch}.m4a'));
  final raf = file.openSync();
  try {
    final out = BytesBuilder(copy: false);
    for (final box in [?layout.ftyp, layout.moov]) {
      raf.setPositionSync(box.start);
      out.add(raf.readSync(box.size));
    }
    tmp.writeAsBytesSync(out.takeBytes());
  } finally {
    raf.closeSync();
  }
  try {
    return readMetadata(tmp, getImage: getImage);
  } finally {
    try {
      tmp.deleteSync();
    } catch (_) {}
  }
}

/// Avant d'écrire des tags dans un M4A : la bibliothèque doit pouvoir le
/// parcourir sans risque, sinon on refuse (plutôt que de bloquer l'appli).
void ensureWritableLayout(String path) {
  final layout = mp4Layout(File(path));
  if (layout != null && !layout.plain) {
    throw const FormatException('Unsupported MP4 layout (64-bit or open-ended box)');
  }
}

class Mp4Box {
  final String type;
  final int start;
  final int size;
  final int header;
  const Mp4Box(this.type, this.start, this.size, this.header);
  int get end => start + size;
}

class Mp4Layout {
  final Mp4Box? ftyp;
  final Mp4Box moov;

  /// Toutes les boîtes de premier niveau ont une taille 32 bits classique.
  final bool plain;
  const Mp4Layout(this.ftyp, this.moov, this.plain);
}

/// Structure d'un fichier MP4/M4A, ou null si ce n'en est pas un.
/// Lève une exception si `moov` est absent ou mal formé.
Mp4Layout? mp4Layout(File file) {
  final raf = file.openSync();
  try {
    final length = raf.lengthSync();
    if (length < 8) return null;
    raf.setPositionSync(4);
    if (String.fromCharCodes(raf.readSync(4)) != 'ftyp') return null;

    Mp4Box? ftyp, moov;
    var plain = true;
    var pos = 0;
    while (pos + 8 <= length) {
      final box = _readBox(raf, pos, length);
      if (box == null) throw const FormatException('Malformed MP4 box');
      if (box.header != 8) plain = false;
      if (box.type == 'ftyp') ftyp ??= box;
      if (box.type == 'moov') moov ??= box;
      pos = box.end;
    }
    if (moov == null) throw const FormatException('MP4 without moov');
    // Les tags tiennent en quelques Mo (pochette comprise).
    if (moov.header != 8 || moov.size > 64 << 20) throw const FormatException('Unsupported moov');
    if (!_treeOk(raf, moov)) throw const FormatException('Malformed moov');
    return Mp4Layout(ftyp, moov, plain);
  } finally {
    raf.closeSync();
  }
}

/// En-tête de boîte à [pos] ; gère les tailles 64 bits et « jusqu'à la fin ».
Mp4Box? _readBox(RandomAccessFile raf, int pos, int limit) {
  raf.setPositionSync(pos);
  final h = raf.readSync(8);
  if (h.length < 8) return null;
  final d = ByteData.sublistView(h);
  var size = d.getUint32(0);
  var header = 8;
  if (size == 1) {
    final ext = raf.readSync(8);
    if (ext.length < 8) return null;
    size = ByteData.sublistView(ext).getUint64(0);
    header = 16;
  } else if (size == 0) {
    size = limit - pos;
    header = 0; // marqueur : taille implicite
  }
  if (size < 8) return null;
  // Fichier tronqué : la dernière boîte dépasse, on la borne.
  if (pos + size > limit) size = limit - pos;
  if (size < 8) return null;
  return Mp4Box(String.fromCharCodes(h, 4, 8), pos, size, header);
}

const _containers = {'moov', 'udta', 'ilst', 'trak', 'mdia', 'minf', 'stbl', 'stsd', 'meta'};

/// Vérifie les boîtes que la bibliothèque parcourt dans `moov` :
/// tailles 32 bits, au moins 8 octets, contenues dans leur parent.
bool _treeOk(RandomAccessFile raf, Mp4Box box, [int depth = 0]) {
  if (depth > 12) return false;
  var pos = box.start + 8;
  if (box.type == 'stsd') pos += 8;
  if (box.type == 'meta') {
    raf.setPositionSync(pos);
    final h = raf.readSync(8);
    if (h.length < 8) return false;
    final size = ByteData.sublistView(h).getUint32(0);
    final printable = h.sublist(4).every((b) => b >= 0x20 && b <= 0x7e);
    if (!(size >= 8 && size <= box.size - 8 && printable)) pos += 4;
  }
  while (pos < box.end) {
    if (pos + 8 > box.end) return false;
    raf.setPositionSync(pos);
    final h = raf.readSync(8);
    if (h.length < 8) return false;
    final size = ByteData.sublistView(h).getUint32(0);
    if (size < 8 || pos + size > box.end) return false;
    final child = Mp4Box(String.fromCharCodes(h, 4, 8), pos, size, 8);
    if (_containers.contains(child.type) && !_treeOk(raf, child, depth + 1)) return false;
    pos += size;
  }
  return true;
}
