import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../state/library_sync.dart';
import 'brand/logo.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/playlists_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/workshop_screen.dart';
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
  late final LibrarySync _sync;

  @override
  void dispose() {
    _sync.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sync = LibrarySync(context.library);
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
  /// Ensuite, les nouveaux fichiers sont détectés automatiquement.
  void _startScan() => _sync.start();

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

/// Navigation principale : Accueil, Atelier, Playlists, Réglages.
/// Chaque onglet a sa propre pile d'écrans ; mini-lecteur et barre restent visibles.
/// En paysage (écran bas), la barre devient un rail latéral pour libérer la hauteur.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  StreamSubscription<Object>? _errors;
  late final ShellNav _nav = context.shell;

  static const _roots = [HomeScreen(), WorkshopScreen(), PlaylistsScreen(), SettingsScreen()];

  /// Onglets déjà ouverts : les autres ne sont construits qu'à la première visite
  /// (démarrage plus léger, et le guide de l'Atelier ne s'ouvre pas au lancement).
  final Set<int> _visited = {0};

  @override
  void initState() {
    super.initState();
    _nav.tab.addListener(_onTab);
    _visited.add(_nav.tab.value);
    _errors = context.audio.errors.stream.listen((e) {
      debugPrint('Playback error: $e');
      if (mounted) context.toast(context.l.cannotPlay, icon: Icons.error_outline_rounded);
    });
  }

  void _onTab() {
    if (_visited.add(_nav.tab.value)) setState(() {});
  }

  @override
  void dispose() {
    _nav.tab.removeListener(_onTab);
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
    final size = MediaQuery.sizeOf(context);
    final rail = size.width > size.height && size.height < 520;
    final pages = Expanded(
      child: ValueListenableBuilder(
        valueListenable: _nav.tab,
        builder: (context, tab, _) => IndexedStack(
          index: tab,
          children: [
            for (var i = 0; i < _roots.length; i++)
              _visited.contains(i)
                  ? HeroControllerScope.none(
                      child: Navigator(
                        key: _nav.navigators[i],
                        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _roots[i]),
                      ),
                    )
                  : const SizedBox.shrink(),
          ],
        ),
      ),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        body: rail
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SideRail(),
                  Expanded(child: Column(children: [pages, const MiniPlayer()])),
                ],
              )
            : Column(children: [pages, const MiniPlayer(), const _BottomBar()]),
      ),
    );
  }
}

typedef _NavItem = (IconData icon, IconData activeIcon, String label);

List<_NavItem> _navItems(BuildContext context) {
  final l = context.l;
  return [
    (Icons.home_outlined, Icons.home_rounded, l.navHome),
    (Icons.auto_fix_high_outlined, Icons.auto_fix_high_rounded, l.workshop),
    (Icons.queue_music_outlined, Icons.queue_music_rounded, l.navPlaylists),
    (Icons.settings_outlined, Icons.settings_rounded, l.navSettings),
  ];
}

void _select(ShellNav nav, int i) {
  Haptics.select();
  // Toucher l'onglet actif ramène à sa racine.
  i == nav.tab.value ? nav.goTab(i) : nav.tab.value = i;
}

/// Dock flottant : l'onglet actif s'élargit en pilule (icône + libellé),
/// les autres n'affichent que leur icône.
class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final nav = context.shell;
    final items = _navItems(context);
    return ColoredBox(
      color: c.bg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(31),
              border: Border.all(color: c.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: c.brightness == Brightness.dark ? 0.35 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ValueListenableBuilder(
              valueListenable: nav.tab,
              builder: (context, tab, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _DockItem(item: items[i], active: i == tab, onTap: () => _select(nav, i)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _DockItem({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      selected: active,
      button: true,
      label: item.$3,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 62,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 340),
              curve: lyraCurve,
              height: 44,
              padding: EdgeInsets.symmetric(horizontal: active ? 16 : 12),
              decoration: BoxDecoration(
                color: active ? c.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(active ? item.$2 : item.$1, size: 24, color: active ? c.onPrimary : c.text3),
                  // Le libellé n'apparaît que sur l'onglet actif.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 340),
                    curve: lyraCurve,
                    child: active
                        ? Container(
                            padding: const EdgeInsets.only(left: 8),
                            constraints: const BoxConstraints(maxWidth: 104),
                            child: Text(
                              item.$3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontFamily: LyraText.heading,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: c.onPrimary,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rail latéral (paysage) : mêmes onglets, empilés verticalement.
class _SideRail extends StatelessWidget {
  const _SideRail();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final nav = context.shell;
    final items = _navItems(context);
    return ColoredBox(
      color: c.surface,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: 84,
          child: ValueListenableBuilder(
            valueListenable: nav.tab,
            builder: (context, tab, _) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Semantics(
                      selected: i == tab,
                      button: true,
                      label: items[i].$3,
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _select(nav, i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: lyraCurve,
                                width: 54,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: i == tab ? c.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Icon(
                                  i == tab ? items[i].$2 : items[i].$1,
                                  size: 22,
                                  color: i == tab ? c.onPrimary : c.text3,
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
                                  color: i == tab ? c.text : c.text3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
