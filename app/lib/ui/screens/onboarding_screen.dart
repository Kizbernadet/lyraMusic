import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../brand/logo.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import 'permission_screen.dart';

/// Présentation au premier lancement : 3 diapositives illustrées (vinyle de la
/// charte), la dernière demande l'accès aux fichiers audio.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGranted;
  const OnboardingScreen({super.key, required this.onGranted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _pages = PageController();
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 6))
    ..repeat();
  int _page = 0;
  bool _denied = false;
  bool _busy = false;

  @override
  void dispose() {
    _pages.dispose();
    _spin.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < 2) {
      _pages.nextPage(duration: const Duration(milliseconds: 380), curve: lyraCurve);
      return;
    }
    setState(() => _busy = true);
    final status = await (await audioPermission()).request();
    if (!mounted) return;
    if (status.isGranted || status.isLimited) {
      await Permission.notification.request();
      widget.onGranted();
    } else {
      setState(() {
        _busy = false;
        _denied = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_denied) return PermissionScreen(onGranted: widget.onGranted, startDenied: true);
    final l = context.l;
    final c = context.c;
    final slides = [(l.onb1Title, l.onb1Body), (l.onb2Title, l.onb2Body), (l.onb3Title, l.onb3Body)];
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView(
                  controller: _pages,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _VinylArt(spin: _spin),
                    const _TagsArt(),
                    const _LyricsArt(),
                  ],
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                    child: Row(
                      children: [
                        const Wordmark(size: 24),
                        const Spacer(),
                        if (_page < 2)
                          LyraButton(
                            label: l.skip,
                            small: true,
                            variant: BtnVariant.ghost,
                            onPressed: () =>
                                _pages.animateToPage(2, duration: const Duration(milliseconds: 420), curve: lyraCurve),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Panneau du bas : titre, texte, points, bouton.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: Column(
                        key: ValueKey(_page),
                        children: [
                          Text(
                            slides[_page].$1,
                            textAlign: TextAlign.center,
                            style: context.t.h1.copyWith(fontSize: 26),
                          ),
                          const SizedBox(height: 10),
                          Text(slides[_page].$2, textAlign: TextAlign.center, style: context.t.body),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 3; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _page ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: i == _page ? c.primary : c.dividerStrong,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    LyraButton(label: _page < 2 ? l.next : l.getStarted, full: true, onPressed: _busy ? null : _next),
                    if (_page == 2) ...[
                      const SizedBox(height: 10),
                      Text(
                        l.permFootnote,
                        textAlign: TextAlign.center,
                        style: context.t.meta.copyWith(color: c.text3),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diapositive 1 : un grand vinyle qui tourne, le R-vinyle en étiquette.
class _VinylArt extends StatelessWidget {
  final Animation<double> spin;
  const _VinylArt({required this.spin});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return LayoutBuilder(
      builder: (context, box) {
        final size = math.min(box.maxWidth * 1.05, box.maxHeight * 0.9);
        return Stack(
          children: [
            Positioned(
              right: -size * 0.28,
              top: box.maxHeight * 0.5 - size * 0.42,
              // Le disque tourne, l'étiquette (le logo) reste droite.
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: spin,
                    child: _Vinyl(size: size),
                  ),
                  LyraSymbol(size: size * 0.2, ink: LyraColors.black, paper: LyraColors.cream),
                ],
              ),
            ),
            Positioned(
              left: 24,
              bottom: 28,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radiusM)),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 18, color: c.primary),
                    const SizedBox(width: 8),
                    Text(context.l.permPoint2, style: context.t.title),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Vinyl extends StatelessWidget {
  final double size;
  const _Vinyl({required this.size});

  @override
  Widget build(BuildContext context) {
    const ink = LyraColors.black;
    const paper = LyraColors.cream;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Color(0xFF2A2A2A), ink, Color(0xFF1E1E1E), ink], stops: [0.32, 0.55, 0.8, 1]),
        boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 20))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final f in const [0.95, 0.86, 0.77, 0.68, 0.59])
            Container(
              width: size * f,
              height: size * f,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x18FFFFFF)),
              ),
            ),
          Container(
            width: size * 0.36,
            height: size * 0.36,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: paper),
          ),
        ],
      ),
    );
  }
}

/// Diapositive 2 : une fiche de morceau dont les tags se corrigent.
class _TagsArt extends StatelessWidget {
  const _TagsArt();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    Widget field(String label, String value, {bool fixed = false}) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(label, style: context.t.meta)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: fixed ? c.primary : c.divider),
              ),
              child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.title),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            fixed ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 18,
            color: fixed ? c.primary : c.warning,
          ),
        ],
      ),
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 60, 28, 16),
        child: Transform.rotate(
          angle: -0.04,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(radiusL),
              boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 30, offset: Offset(0, 14))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const LyraAppIcon(size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Track 07.mp3', style: context.t.title.copyWith(fontWeight: FontWeight.w700)),
                          Text(l.unknownArtist, style: context.t.meta),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_rounded, color: c.primary),
                  ],
                ),
                field(l.fieldTitle, 'Horizons', fixed: true),
                field(l.fieldArtist, 'LyraMusic', fixed: true),
                field(l.fieldAlbum, l.unknownAlbum),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Diapositive 3 : des paroles qui s'allument au rythme de la musique.
class _LyricsArt extends StatefulWidget {
  const _LyricsArt();

  @override
  State<_LyricsArt> createState() => _LyricsArtState();
}

class _LyricsArtState extends State<_LyricsArt> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final lines = context.l.onbLyrics.split('|');
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 70, 32, 16),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final active = (_c.value * lines.length).floor();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < lines.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontFamily: LyraText.heading,
                        fontSize: i == active ? 28 : 23,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: i <= active ? c.primary : c.text.withValues(alpha: 0.35),
                      ),
                      child: Text(lines[i]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
