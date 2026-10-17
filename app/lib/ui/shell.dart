import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'brand/logo.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/kit.dart';
import 'widgets/mini_player.dart';

/// Démarrage : logo animé, présentation (premier lancement) avec l'autorisation,
/// puis l'application.
class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool? _granted;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _check();
    // L'écran de démarrage reste le temps de son animation.
    Future.delayed(SplashLogoAnimation.duration + const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  Future<void> _check() async {
    final granted = await (await audioPermission()).isGranted;
    if (!mounted) return;
    setState(() => _granted = granted);
    if (granted) _startScan();
  }

  void _onGranted() {
    context.settings.setOnboarded();
    setState(() => _granted = true);
    _startScan();
  }

  /// Le scan tourne en arrière-plan ; la bibliothèque en cache s'affiche tout de suite.
  void _startScan() => context.library.scan();

  @override
  Widget build(BuildContext context) {
    final Widget child = switch ((_granted, _splashDone)) {
      (null, _) || (_, false) => const SplashScreen(key: ValueKey('splash')),
      // Premier lancement : 3 diapositives, la dernière demande l'accès.
      // Plus tard (accès retiré) : directement l'écran d'autorisation.
      (false, _) when !context.settings.onboarded => OnboardingScreen(
        key: const ValueKey('onb'),
        onGranted: _onGranted,
      ),
      (false, _) => PermissionScreen(key: const ValueKey('perm'), onGranted: _onGranted),
      _ => const Shell(key: ValueKey('shell')),
    };
    return AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: child);
  }
}

/// Navigation principale : Accueil, Favoris, Playlists, Réglages.
/// Chaque onglet a sa propre pile d'écrans ; mini-lecteur et barre restent visibles.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  StreamSubscription<Object>? _errors;
  late final ShellNav _nav = context.shell;

  static const _roots = [HomeScreen(), FavoritesScreen(), PlaylistsScreen(), SettingsScreen()];

  @override
  void initState() {
    super.initState();
    _errors = context.audio.errors.stream.listen((e) {
      debugPrint('Playback error: $e');
      if (mounted) context.toast(context.l.cannotPlay, icon: Icons.error_outline_rounded);
    });
  }

  @override
  void dispose() {
    _errors?.cancel();
    super.dispose();
  }

  void _onBack() {
    final nav = _nav.navigators[_nav.tab.value].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    } else if (_nav.tab.value != ShellNav.home) {
      _nav.goTab(ShellNav.home);
    } else if (_nav.homeTab.value != 0) {
      _nav.homeTab.value = 0;
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    // Libellés de la notification dans la langue choisie.
    context.audio.setUnknownLabels(l.unknownArtist, l.unknownAlbum);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _nav.tab,
                builder: (context, tab, _) => IndexedStack(
                  index: tab,
                  children: [
                    for (var i = 0; i < _roots.length; i++)
                      HeroControllerScope.none(
                        child: Navigator(
                          key: _nav.navigators[i],
                          onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _roots[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const MiniPlayer(),
            const _BottomBar(),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final nav = context.shell;
    final items = [
      (Icons.home_outlined, Icons.home_rounded, l.navHome),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, l.favorites),
      (Icons.queue_music_outlined, Icons.queue_music_rounded, l.navPlaylists),
      (Icons.settings_outlined, Icons.settings_rounded, l.navSettings),
    ];
    return Container(
      color: c.surface,
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder(
          valueListenable: nav.tab,
          builder: (context, tab, _) => SizedBox(
            height: 62,
            child: Stack(
              children: [
                // Capsule qui glisse derrière l'icône de l'onglet actif.
                AnimatedAlign(
                  alignment: Alignment(-1 + 2 * tab / (items.length - 1), -1),
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  child: FractionallySizedBox(
                    widthFactor: 1 / items.length,
                    child: Center(
                      heightFactor: 1,
                      child: Container(
                        margin: const EdgeInsets.only(top: 7),
                        width: 60,
                        height: 31,
                        decoration: BoxDecoration(
                          color: c.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: i == tab,
                          button: true,
                          label: items[i].$3,
                          child: InkResponse(
                            radius: 40,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              Haptics.select();
                              i == tab ? nav.goTab(i) : nav.tab.value = i;
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: i == tab ? 1.08 : 1,
                                  duration: const Duration(milliseconds: 180),
                                  child: Icon(
                                    i == tab ? items[i].$2 : items[i].$1,
                                    size: 25,
                                    color: i == tab ? c.primary : c.text3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  items[i].$3,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: i == tab ? FontWeight.w700 : FontWeight.w500,
                                    color: i == tab ? c.primary : c.text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
