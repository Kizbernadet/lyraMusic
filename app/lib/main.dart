import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio/handler.dart';
import 'data/db.dart';
import 'l10n/app_localizations.dart';
import 'state/collections.dart';
import 'state/dynamic_palette.dart';
import 'state/lyrics_store.dart';
import 'state/library.dart';
import 'state/settings.dart';
import 'ui/shell.dart';
import 'ui/widgets/common.dart';
import 'ui/widgets/kit.dart';
import 'ui/theme.dart';
import 'ui/theme_presets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Licences des polices embarquées (écran « Licences open source »).
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in const [('Inter', 'OFL-Inter.txt'), ('Nunito', 'OFL-Nunito.txt')]) {
      yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString('assets/fonts/$file'));
    }
  });

  final prefs = await SharedPreferences.getInstance();
  final handler = await AudioService.init(
    builder: () => LyraAudioHandler(prefs),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.lyramusic.lyra.playback',
      androidNotificationChannelName: 'LyraMusic',
      androidNotificationIcon: 'drawable/ic_stat_lyra',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: Color(0xFF111111),
      artDownscaleWidth: 512,
      artDownscaleHeight: 512,
    ),
  );

  final db = await LyraDb.open();
  final support = await getApplicationSupportDirectory();
  final artDir = Directory(p.join(support.path, 'art'));
  await artDir.create(recursive: true);

  final settings = SettingsController(prefs);
  final library = LibraryController(db, artDir.path);
  final collections = CollectionsController(db);
  final lyrics = LyricsStore(db);
  await Future.wait([library.load(), collections.load(), lyrics.load()]);

  handler.onTrackStarted = (t) => collections.recordPlay(t.id);
  if (library.tracks.isNotEmpty) await handler.restore(library.byId);
  await handler.restoreEffects(skipSilence: settings.on(Toggle.skipSilence));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: collections),
        Provider<LyraAudioHandler>.value(value: handler),
        Provider<ShellNav>.value(value: ShellNav()),
        ChangeNotifierProvider.value(value: lyrics),
        ChangeNotifierProvider(create: (_) => DynamicPalette(handler)),
      ],
      child: const LyraApp(),
    ),
  );
}

class LyraApp extends StatelessWidget {
  const LyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    Haptics.enabled = settings.on(Toggle.haptics);
    final accent = settings.accent;
    final mode = settings.appearance;
    final choice = settings.themeChoice;
    final spec = settings.selectedSpec;
    final seed = choice == 'dynamic' ? context.watch<DynamicPalette>().seed : null;

    // Clair / sombre / système : thème classique (charte) et thème « Pochette ».
    LyraColors light = LyraColors.make(Brightness.light, accent);
    LyraColors dark = LyraColors.make(Brightness.dark, accent);
    var themeMode = switch (mode) {
      AppearanceMode.light => ThemeMode.light,
      AppearanceMode.dark => ThemeMode.dark,
      AppearanceMode.system => ThemeMode.system,
    };
    if (seed != null) {
      light = dynamicColors(seed, Brightness.light);
      dark = dynamicColors(seed, Brightness.dark);
    } else if (spec != null) {
      // Thème de la galerie ou créé par l'utilisateur : une seule ambiance.
      light = dark = spec.colors;
      themeMode = spec.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return MaterialApp(
      onGenerateTitle: (context) => L10n.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(light),
      darkTheme: buildTheme(dark),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 450),
      themeAnimationCurve: Curves.easeOutCubic,
      scrollBehavior: const LyraScrollBehavior(),
      locale: settings.locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: L10n.localizationsDelegates,
      // Langue non prise en charge → anglais (CA-40).
      localeListResolutionCallback: (locales, supported) {
        for (final locale in locales ?? const <Locale>[]) {
          for (final s in supported) {
            if (s.languageCode == locale.languageCode) return s;
          }
        }
        return const Locale('en');
      },
      home: const Gate(),
    );
  }
}
