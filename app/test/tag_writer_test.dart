import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyra/data/tag_writer.dart';

/// Fichiers audio minimaux générés octet par octet (sans ffmpeg).

Uint8List mp3NoTags({int frames = 40}) {
  // MPEG-1 Layer III, 128 kbps, 44,1 kHz, sans padding : 417 octets par trame.
  final b = BytesBuilder();
  for (var i = 0; i < frames; i++) {
    b.add([0xFF, 0xFB, 0x90, 0x64]);
    b.add(Uint8List(413));
  }
  return b.toBytes();
}

Uint8List flacNoTags() {
  final b = BytesBuilder();
  b.add('fLaC'.codeUnits);
  b.add([0x80, 0x00, 0x00, 0x22]); // dernier bloc, STREAMINFO, 34 octets
  final si = ByteData(34);
  si.setUint16(0, 4096);
  si.setUint16(2, 4096);
  // 44100 Hz (20 bits) | 2 canaux - 1 (3 bits) | 16 bits - 1 (5 bits) | 36 bits d'échantillons
  final sampleRate = 44100, channels = 2, bps = 16, total = 44100;
  final packed = (BigInt.from(sampleRate) << 44) |
      (BigInt.from(channels - 1) << 41) |
      (BigInt.from(bps - 1) << 36) |
      BigInt.from(total);
  for (var i = 0; i < 8; i++) {
    si.setUint8(10 + i, ((packed >> (8 * (7 - i))) & BigInt.from(0xFF)).toInt());
  }
  b.add(si.buffer.asUint8List());
  b.add([0xFF, 0xF8, 0x69, 0x18]); // début de trame FLAC (factice)
  b.add(Uint8List(2000));
  return b.toBytes();
}

Uint8List _box(String type, List<int> payload) {
  final d = ByteData(8);
  d.setUint32(0, 8 + payload.length);
  return Uint8List.fromList([...d.buffer.asUint8List(0, 4), ...type.codeUnits, ...payload]);
}

const audioMarker = 'AUDIODATA-START';

Uint8List m4aNoTags() {
  final ftyp = _box('ftyp', [...'M4A '.codeUnits, 0, 0, 0, 0, ...'M4A '.codeUnits, ...'isom'.codeUnits]);
  final mvhd = ByteData(100);
  mvhd.setUint32(12, 1000); // échelle de temps
  mvhd.setUint32(16, 1000); // durée : 1 s
  mvhd.setUint32(20, 0x00010000);
  mvhd.setUint16(24, 0x0100);
  final mdhd = ByteData(24);
  mdhd.setUint32(12, 44100);
  mdhd.setUint32(16, 44100);
  Uint8List build(int chunkOffset) {
    final stco = ByteData(12)
      ..setUint32(4, 1)
      ..setUint32(8, chunkOffset);
    final stbl = _box('stbl', _box('stco', stco.buffer.asUint8List()));
    final mdia = _box('mdia', [..._box('mdhd', mdhd.buffer.asUint8List()), ..._box('minf', stbl)]);
    final moov = _box('moov', [..._box('mvhd', mvhd.buffer.asUint8List()), ..._box('trak', mdia)]);
    final mdat = _box('mdat', [...audioMarker.codeUnits, ...Uint8List(1000)]);
    return Uint8List.fromList([...ftyp, ...moov, ...mdat]);
  }
  final probe = build(0);
  // Position des données audio = taille totale - contenu de mdat.
  final offset = probe.length - (audioMarker.length + 1000);
  return build(offset);
}

/// Lit la première position de la table stco et renvoie les octets pointés.
String chunkAt(Uint8List data) {
  final bd = ByteData.sublistView(data);
  final i = String.fromCharCodes(data).indexOf('stco');
  final offset = bd.getUint32(i + 4 + 8);
  return String.fromCharCodes(data.sublist(offset, offset + audioMarker.length));
}

// Petite image PNG 1x1 valide.
final png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
  0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Uint8List _frame23(String id, List<int> body) {
  final d = ByteData(4)..setUint32(0, body.length);
  return Uint8List.fromList([...id.codeUnits, ...d.buffer.asUint8List(), 0, 0, ...body]);
}

/// MP3 avec un tag ID3v2.3 contenant titre, paroles (USLT), commentaire et TXXX.
Uint8List mp3WithLyrics(String lyrics) {
  final frames = <int>[
    ..._frame23('TIT2', [0, ...'Ancien titre'.codeUnits]),
    ..._frame23('USLT', [0, ...'eng'.codeUnits, 0, ...lyrics.codeUnits]),
    ..._frame23('COMM', [0, ...'eng'.codeUnits, 0, ...'Un commentaire'.codeUnits]),
    ..._frame23('TXXX', [0, ...'SOURCE'.codeUnits, 0, ...'CD'.codeUnits]),
  ];
  final size = frames.length + 100; // + remplissage
  final header = [0x49, 0x44, 0x33, 3, 0, 0, (size >> 21) & 0x7F, (size >> 14) & 0x7F, (size >> 7) & 0x7F, size & 0x7F];
  return Uint8List.fromList([...header, ...frames, ...Uint8List(100), ...mp3NoTags()]);
}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('lyra_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  const edit = TagEdit(
    title: 'Été indien',
    artist: 'Joe Dassin',
    album: 'Le Costume blanc',
    albumArtist: 'Joe Dassin',
    genre: 'Chanson',
    year: 1975,
    trackNumber: 3,
    artChanged: true,
    artBytes: null,
  );

  final cases = {
    'mp3': mp3NoTags,
    'flac': flacNoTags,
    'm4a': m4aNoTags,
  };

  test('mp3 : les paroles et commentaires sont conservés après modification', () {
    const lrc = '[00:01.00]Hello\n[00:02.00]World';
    final file = File('${dir.path}/lyrics.mp3')..writeAsBytesSync(mp3WithLyrics(lrc));
    expect(readMetadata(file).lyrics, contains('Hello'));
    applyEdit(file.path, const TagEdit(title: 'Nouveau titre', artist: 'Moi'));
    final m = readMetadata(file);
    expect(m.title, 'Nouveau titre');
    expect(m.artist, 'Moi');
    expect(m.lyrics, contains('[00:02.00]World'));
    final raw = String.fromCharCodes(file.readAsBytesSync().sublist(0, 400));
    expect(raw, contains('Un commentaire'));
    expect(raw, contains('SOURCE'));
    expect(raw, isNot(contains('Ancien titre')));
  });

  for (final entry in cases.entries) {
    group('${entry.key} sans tags', () {
      test('écrit titre, artiste, album, genre, année, piste et pochette', () {
        final file = File('${dir.path}/song.${entry.key}')..writeAsBytesSync(entry.value());
        final withArt = TagEdit(
          title: edit.title,
          artist: edit.artist,
          album: edit.album,
          albumArtist: edit.albumArtist,
          genre: edit.genre,
          year: edit.year,
          trackNumber: edit.trackNumber,
          artChanged: true,
          artBytes: png,
          artMime: 'image/png',
        );
        applyEdit(file.path, withArt);
        verify(file.path, withArt.title);

        final m = readMetadata(file, getImage: true);
        expect(m.title, 'Été indien');
        expect(m.artist, 'Joe Dassin');
        expect(m.album, 'Le Costume blanc');
        expect(m.genres, contains('Chanson'));
        expect(m.year?.year, 1975);
        expect(m.trackNumber, 3);
        expect(m.pictures, isNotEmpty);
        expect(m.pictures.first.bytes, png);
      });

      test('une deuxième modification remplace la première et retire la pochette', () {
        final file = File('${dir.path}/song.${entry.key}')..writeAsBytesSync(entry.value());
        applyEdit(file.path, TagEdit(title: 'Premier', artist: 'A', artChanged: true, artBytes: png, artMime: 'image/png'));
        applyEdit(file.path, const TagEdit(title: 'Second', artist: null, genre: null, artChanged: true));
        final m = readMetadata(file, getImage: true);
        expect(m.title, 'Second');
        expect(m.artist, isNull);
        expect(m.pictures, isEmpty);
      });

      test('modifier les tags ne change pas les données audio', () {
        final original = entry.value();
        final file = File('${dir.path}/song.${entry.key}')..writeAsBytesSync(original);
        applyEdit(file.path, const TagEdit(title: 'Test'));
        final after = file.readAsBytesSync();
        if (entry.key == 'm4a') expect(chunkAt(after), audioMarker); // positions corrigées
        // Les dernières données (audio) sont identiques.
        final tail = original.sublist(original.length - 400);
        expect(after.sublist(after.length - 400), tail);
      });
    });
  }
}
