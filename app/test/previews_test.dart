// Aperçus des écrans (captures PNG dans test/previews/), avec des données
// d'exemple. Générer : flutter test test/previews_test.dart --update-goldens
@Tags(['previews'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyra/audio/handler.dart';
import 'package:lyra/data/db.dart';
import 'package:lyra/data/lyrics.dart';
import 'package:lyra/l10n/app_localizations.dart';
import 'package:lyra/models/track.dart';
import 'package:lyra/state/collections.dart';
import 'package:lyra/state/dynamic_palette.dart';
import 'package:lyra/state/library.dart';
import 'package:lyra/state/lyrics_store.dart';
import 'package:lyra/state/settings.dart';
import 'package:lyra/ui/screens/collection_screen.dart';
import 'package:lyra/ui/screens/lyrics_card_screen.dart';
import 'package:lyra/ui/screens/workshop_guide.dart';
import 'package:lyra/ui/screens/workshop_screen.dart';
import 'package:lyra/ui/screens/onboarding_screen.dart';
import 'package:lyra/ui/screens/player_screen.dart';
import 'package:lyra/ui/screens/playlists_screen.dart';
import 'package:lyra/ui/screens/search_screen.dart';
import 'package:lyra/ui/screens/settings_screen.dart';
import 'package:lyra/ui/shell.dart';
import 'package:lyra/ui/theme.dart';
import 'package:lyra/ui/widgets/common.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base factice : les aperçus n'utilisent pas SQLite.
class _FakeDb implements LyraDb {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Paroles de démonstration pour les morceaux 1 à 5 (synchronisées pour les 3 premiers).
class _DemoLyricsStore extends LyricsStore {
  _DemoLyricsStore() : super(_FakeDb());

  static const _lrc =
      '[00:00.00]Sous les néons de la ville\n'
      '[00:04.00]On danse au bord de la nuit\n'
      '[00:08.00]Chaque refrain nous rapproche\n'
      '[00:12.00]La musique nous relie\n'
      '[00:16.00]Une bande-son pour chaque histoire\n'
      '[00:20.00]Et les étoiles suivent le rythme\n'
      '[00:24.00]Jusqu\'au lever du jour\n'
      '[00:28.00]On garde la mélodie\n';

  @override
  LyricsStatus status(Track t) =>
      t.id <= 3 ? LyricsStatus.synced : (t.id <= 5 ? LyricsStatus.plain : LyricsStatus.none);

  @override
  Future<Lyrics?> lyricsFor(Track t) async => t.id <= 5 ? parseLyrics(_lrc) : null;
}

Track _t(int id, String title, String? artist, String? album, {int? year, int sec = 215, String? genre}) => Track(
  id: id,
  path: '/storage/emulated/0/Music/${album ?? 'Divers'}/$title.mp3',
  title: title,
  artist: artist,
  album: album,
  genre: genre,
  year: year,
  trackNumber: id % 12 + 1,
  durationMs: sec * 1000,
  size: 6000000,
  dateAdded: 1700000000 + id * 1000,
  dateModified: 0,
);

final _tracks = [
  _t(1, 'Starboy', 'The Weeknd', 'Starboy', year: 2016, sec: 230, genre: 'R&B'),
  _t(2, 'Blinding Lights', 'The Weeknd', 'After Hours', year: 2020, sec: 200, genre: 'Pop'),
  _t(3, 'Disaster', 'Conan Gray', 'Superache', year: 2022, sec: 238, genre: 'Pop'),
  _t(4, 'Handsome', 'Warren Hue', 'Boy of the Year', year: 2021, sec: 283, genre: 'Hip-hop'),
  _t(5, 'Sharks', 'Imagine Dragons', 'Mercury', year: 2022, sec: 191, genre: 'Rock'),
  _t(6, 'Fly Me To The Sun', 'Romantic Echoes', 'Echoes', year: 2019, sec: 260, genre: 'Indie'),
  _t(7, 'The Bended Man', 'Sunwich', 'Daydream', year: 2018, sec: 228, genre: 'Indie'),
  _t(8, 'Mayonaka no Orchestra', 'Aqua Timez', 'Openings', year: 2009, sec: 290, genre: 'J-Rock'),
  _t(9, 'Zankyou Sanka', 'Aimer', 'Openings', year: 2022, sec: 185, genre: 'J-Pop'),
  _t(10, 'Bling-Bang-Bang-Born', 'Creepy Nuts', 'Openings', year: 2024, sec: 168, genre: 'Hip-hop'),
  _t(11, 'Track 07', null, null, sec: 177),
  _t(12, 'Dangerous Woman', 'Ariana Grande', 'Dangerous Woman', year: 2016, sec: 235, genre: 'Pop'),
  _t(13, 'Bang Bang', 'Ariana Grande', 'Dangerous Woman', year: 2016, sec: 199, genre: 'Pop'),
  _t(14, 'IGNITE', 'Aoi Eir', 'Openings', year: 2014, sec: 245, genre: 'J-Pop'),
];

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(File(f).readAsBytes().then((b) => ByteData.view(b.buffer)));
  }
  await loader.load();
}

late SharedPreferences _prefs;
late LyraAudioHandler _audio;

Future<void> _shot(
  WidgetTester tester,
  String name,
  Widget home, {
  Brightness brightness = Brightness.dark,
  AccentColor accent = AccentColor.classic,
  Future<void> Function()? after,
  bool lyrics = false,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  final settings = SettingsController(_prefs);
  final library = LibraryController(_FakeDb(), '/tmp')..debugSetTracks(_tracks);
  final collections = CollectionsController(_FakeDb())
    ..debugSeed(
      playlists: const [
        Playlist(1, 'Sunday Archive', [1, 3, 5, 6], 0),
        Playlist(2, 'Openings', [8, 9, 10, 14], 0),
      ],
      favorites: const [1, 9, 12],
      recent: const [1, 9, 3, 5, 12],
      most: const [9, 1, 10, 5],
    );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: collections),
        Provider<LyraAudioHandler>.value(value: _audio),
        Provider<ShellNav>.value(value: ShellNav()),
        ChangeNotifierProvider<LyricsStore>(create: (_) => lyrics ? _DemoLyricsStore() : EmptyLyricsStore(_FakeDb())),
        ChangeNotifierProvider(create: (_) => DynamicPalette(_audio)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(LyraColors.make(brightness, accent)),
        locale: const Locale('fr'),
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: L10n.localizationsDelegates,
        home: home,
      ),
    ),
  );
  _audio.index.value = 0;
  await tester.pump(const Duration(milliseconds: 600));
  if (after != null) await after();
  await tester.pump(const Duration(milliseconds: 600));
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('previews/$name.png'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final ch in [
      'com.ryanheise.audio_session',
      'com.ryanheise.android_audio_manager',
      'com.ryanheise.av_audio_session',
      'com.ryanheise.just_audio.methods',
      'lyra/system',
      'lyra/media',
    ]) {
      m.setMockMethodCallHandler(MethodChannel(ch), (_) async => null);
    }
    const sdk = 'C:/Users/DILITECH/Documents/Flutter_SDK/src/bin/cache/artifacts/material_fonts';
    await _loadFont('MaterialIcons', ['$sdk/materialicons-regular.otf']);
    await _loadFont('Nunito', [
      for (final w in [500, 600, 700, 800, 900]) 'assets/fonts/Nunito-$w.ttf',
    ]);
    await _loadFont('Inter', [
      for (final w in [400, 500, 600, 700]) 'assets/fonts/Inter-$w.ttf',
    ]);
    await _loadFont('Roboto', ['assets/fonts/Inter-400.ttf']);
    for (final f in ['PlayfairDisplay', 'BebasNeue', 'Caveat']) {
      await _loadFont(f, ['assets/fonts/$f.ttf']);
    }
    await _loadFont('SpaceMono', ['assets/fonts/SpaceMono-Bold.ttf']);
    SharedPreferences.setMockInitialValues({'onboarded': true, 'workshopGuideSeen': true});
    _prefs = await SharedPreferences.getInstance();
    _audio = LyraAudioHandler(_prefs);
    _audio.tracks.value = _tracks.sublist(0, 6);
    _audio.index.value = 0;
  });

  testWidgets('accueil sombre', (t) => _shot(t, 'accueil-sombre', const Shell()));
  testWidgets('accueil clair', (t) => _shot(t, 'accueil-clair', const Shell(), brightness: Brightness.light));
  testWidgets('accueil sauge', (t) => _shot(t, 'accueil-sauge', const Shell(), accent: AccentColor.sage));
  testWidgets('titres', (t) async {
    final nav = ShellNav()..homeTab.value = 1;
    await _shot(t, 'titres', Provider<ShellNav>.value(value: nav, child: const Shell()));
  });
  testWidgets('albums', (t) async {
    final nav = ShellNav()..homeTab.value = 3;
    await _shot(t, 'albums', Provider<ShellNav>.value(value: nav, child: const Shell()));
  });
  testWidgets(
    'artiste',
    (t) => _shot(t, 'artiste', CollectionScreen.artist(Group('Ariana Grande', [_tracks[11], _tracks[12]]))),
  );
  testWidgets('lecteur', (t) => _shot(t, 'lecteur', const PlayerScreen()));
  testWidgets(
    'lecteur clair',
    (t) =>
        _shot(t, 'lecteur-clair', const PlayerScreen(), brightness: Brightness.light, accent: AccentColor.terracotta),
  );
  testWidgets('recherche', (t) => _shot(t, 'recherche', const SearchScreen()));
  testWidgets('playlists', (t) => _shot(t, 'playlists', const PlaylistsScreen()));
  testWidgets('reglages', (t) => _shot(t, 'reglages', const SettingsScreen()));
  testWidgets('presentation', (t) => _shot(t, 'presentation', OnboardingScreen(onGranted: () {})));
  testWidgets('paroles', (t) => _shot(t, 'paroles', const PlayerScreen(startWithLyrics: true), lyrics: true));
  testWidgets('atelier', (t) => _shot(t, 'atelier', const WorkshopScreen(), lyrics: true));
  testWidgets('atelier guide', (t) => _shot(t, 'atelier-guide', const WorkshopGuide(), lyrics: true));
  testWidgets('lyricscard', (t) async {
    await _shot(
      t,
      'lyricscard',
      const LyricsCardScreen(trackId: 2),
      lyrics: true,
      after: () async {
        await t.pump(const Duration(milliseconds: 300));
        await t.tapAt(t.getTopLeft(find.byType(TextField)) + const Offset(60, 20));
        await t.pump(const Duration(milliseconds: 800)); // pas un double toucher
        await t.tapAt(t.getTopLeft(find.byType(TextField)) + const Offset(60, 105));
      },
    );
  });
}
