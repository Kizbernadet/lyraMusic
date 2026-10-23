import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lyra/data/onset.dart';
import 'package:lyra/data/lyrics.dart';
import 'package:lyra/models/track.dart';
import 'package:lyra/state/library.dart';
import 'package:lyra/utils/text.dart';

Track t(
  int id,
  String title, {
  int? no,
  int? disc,
  String? artist,
  String? album,
  String? albumArtist,
  String folder = '/m',
}) => Track(
  id: id,
  path: '$folder/$title.mp3',
  title: title,
  trackNumber: no,
  discNumber: disc,
  artist: artist,
  album: album,
  albumArtist: albumArtist,
  durationMs: 1000,
  size: 1,
  dateAdded: id,
  dateModified: 0,
);

void main() {
  group('Recherche sans accents (CA-08)', () {
    test('beyonce trouve Beyoncé', () => expect(fold('Beyoncé').contains(fold('beyonce')), isTrue));
    test('majuscules et accents', () => expect(fold('ÉTÉ Indien Ñandú'), 'ete indien nandu'));
    test('tri ignore les articles', () {
      expect(sortKey('The Beatles'), 'beatles');
      expect(sortKey('Les Rita Mitsouko'), 'rita mitsouko');
    });
  });

  group('Ordre dans un album (CA-07)', () {
    test('par numéro de piste, puis par titre si absent', () {
      final list = [t(1, 'C'), t(2, 'B', no: 2), t(3, 'A', no: 1), t(4, 'D', no: 1, disc: 2)]..sort(compareAlbumOrder);
      expect(list.map((e) => e.title), ['A', 'B', 'C', 'D']);
    });
  });

  group('Clé d\'album', () {
    test('même album, même dossier, sans artiste d\'album → un seul album', () {
      expect(t(1, 'a', album: 'X').albumKey, t(2, 'b', album: 'x').albumKey);
    });
    test('« Greatest Hits » de deux artistes dans deux dossiers → deux albums', () {
      expect(
        t(1, 'a', album: 'Greatest Hits', folder: '/m/A').albumKey,
        isNot(t(2, 'b', album: 'Greatest Hits', folder: '/m/B').albumKey),
      );
    });
  });

  group('Paroles', () {
    test('LRC synchronisé, plusieurs horodatages, métadonnées ignorées', () {
      final l = parseLyrics('[ar:Artiste]\n[00:01.00]Un\n[00:05.50][00:20.00]Refrain\n[00:10.00]Deux');
      expect(l.synced, isTrue);
      expect(l.lines.map((e) => e.text), ['Un', 'Refrain', 'Deux', 'Refrain']);
      expect(l.indexAt(const Duration(seconds: 0)), -1);
      expect(l.indexAt(const Duration(seconds: 6)), 1);
      expect(l.indexAt(const Duration(seconds: 12)), 2);
      expect(l.indexAt(const Duration(minutes: 3)), 3);
    });
    test('texte simple non synchronisé', () {
      final l = parseLyrics('\nLigne 1\nLigne 2\n\n');
      expect(l.synced, isFalse);
      expect(l.lines.map((e) => e.text), ['Ligne 1', 'Ligne 2']);
    });
    test('une pause (ligne vide horodatée) est conservée', () {
      final lines = [
        const LyricLine(Duration(seconds: 1), 'Un'),
        const LyricLine(Duration(seconds: 4), ''),
        const LyricLine(Duration(seconds: 12), 'Deux'),
      ];
      final l = parseLyrics(toLrc(lines));
      expect(l.synced, isTrue);
      expect(l.lines.map((e) => e.text), ['Un', '', 'Deux']);
      expect(l.indexAt(const Duration(seconds: 6)), 1);
    });
  });

  group('Aimantation sur la voix', () {
    // Silence puis une voix qui commence à 2,00 s (enveloppe toutes les 10 ms).
    final env = Uint8List(500);
    for (var i = 200; i < 500; i++) {
      env[i] = 180;
    }

    test("un appui en retard est ramené au début de l'attaque", () {
      final snapped = snapToOnset(env, const Duration(milliseconds: 2180));
      expect(snapped, isNotNull);
      expect((snapped!.inMilliseconds - 2000).abs(), lessThanOrEqualTo(30));
    });
    test('un appui un peu en avance est aussi corrigé', () {
      final snapped = snapToOnset(env, const Duration(milliseconds: 1880));
      expect((snapped!.inMilliseconds - 2000).abs(), lessThanOrEqualTo(30));
    });
    test("rien n'est déplacé sans attaque nette à proximité", () {
      expect(snapToOnset(env, const Duration(milliseconds: 3500)), isNull);
      expect(snapToOnset(Uint8List(500), const Duration(seconds: 2)), isNull);
    });
  });
}
