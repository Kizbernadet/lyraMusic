import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lyra/data/safe_metadata.dart';
import 'package:path/path.dart' as p;

Uint8List _box(String type, List<int> payload) {
  final d = ByteData(4)..setUint32(0, 8 + payload.length);
  return Uint8List.fromList([...d.buffer.asUint8List(), ...type.codeUnits, ...payload]);
}

/// M4A minimal : ftyp, moov (durée + titre), mdat dont l'en-tête varie.
Uint8List _m4a(List<int> mdat, {bool moovFirst = true}) {
  final ftyp = _box('ftyp', [...'M4A '.codeUnits, 0, 0, 0, 0, ...'M4A '.codeUnits]);
  final mvhd = ByteData(100)
    ..setUint32(12, 1000)
    ..setUint32(16, 5000);
  final title = _box('data', [0, 0, 0, 1, 0, 0, 0, 0, ...'Long enregistrement'.codeUnits]);
  final ilst = _box('ilst', _box('©nam', title));
  final meta = _box('meta', [0, 0, 0, 0, ...ilst]);
  final moov = _box('moov', [..._box('mvhd', mvhd.buffer.asUint8List()), ..._box('udta', meta)]);
  return Uint8List.fromList(moovFirst ? [...ftyp, ...moov, ...mdat] : [...ftyp, ...mdat, ...moov]);
}

final _audio = List.filled(4000, 7);

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('lyra_meta'));
  tearDown(() => dir.deleteSync(recursive: true));

  Future<String?> title(Uint8List bytes) {
    final path = p.join(dir.path, 'a.m4a');
    File(path).writeAsBytesSync(bytes);
    final scratch = dir.path;
    // Dans un isolate avec délai : l'ancien comportement bouclait à l'infini.
    return Isolate.run(
      () => readMetadataSafe(File(path), scratchDir: scratch).title,
    ).timeout(const Duration(seconds: 10));
  }

  test('M4A classique', () async {
    expect(await title(_m4a(_box('mdat', _audio))), 'Long enregistrement');
  });

  test('mdat de taille 0 (« jusqu\'à la fin du fichier »)', () async {
    final mdat = [0, 0, 0, 0, ...'mdat'.codeUnits, ..._audio];
    expect(await title(_m4a(mdat)), 'Long enregistrement');
  });

  test('mdat en taille 64 bits avant moov', () async {
    final size = ByteData(8)..setUint64(0, 16 + _audio.length);
    final mdat = [0, 0, 0, 1, ...'mdat'.codeUnits, ...size.buffer.asUint8List(), ..._audio];
    expect(await title(_m4a(mdat, moovFirst: false)), 'Long enregistrement');
    expect(dir.listSync().where((f) => p.basename(f.path).startsWith('.meta_')), isEmpty);
  });

  test('écriture des tags refusée sur une structure non gérée', () {
    final path = p.join(dir.path, 'b.m4a');
    File(path).writeAsBytesSync(_m4a([0, 0, 0, 0, ...'mdat'.codeUnits, ..._audio]));
    expect(() => ensureWritableLayout(path), throwsFormatException);
  });
}
