import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// « Comment fonctionne l'Atelier ? » : parcours en trois étapes, chacune avec
/// une petite scène animée (ajouter des paroles, synchroniser, créer une LyricsCard).
/// Une seule animation tourne à la fois : celle de l'étape affichée.
class WorkshopGuide extends StatefulWidget {
  const WorkshopGuide({super.key});

  @override
  State<WorkshopGuide> createState() => _WorkshopGuideState();
}

class _WorkshopGuideState extends State<WorkshopGuide> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == 2) {
      Navigator.of(context).pop();
      return;
    }
    _pages.nextPage(duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width > size.height;
    final steps = [
      (l.guide1Title, l.guide1Body, (bool on) => _TypeScene(active: on)),
      (l.guide2Title, l.guide2Body, (bool on) => _SyncScene(active: on)),
      (l.guide3Title, l.guide3Body, (bool on) => _CardScene(active: on)),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  LyraIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l.close,
                    color: c.text2,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(l.workshop.toUpperCase(), style: context.t.label),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: steps.length,
                onPageChanged: (i) {
                  Haptics.select();
                  setState(() => _page = i);
                },
                itemBuilder: (context, i) => AnimatedBuilder(
                  animation: _pages,
                  builder: (context, child) {
                    // Parallaxe : la scène glisse moins vite que le texte et pivote légèrement.
                    final delta = _pages.hasClients && _pages.position.haveDimensions ? (_pages.page ?? 0) - i : 0.0;
                    final scene = Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..translateByDouble(delta * 140, 0, 0, 1)
                        ..rotateY(delta * 0.5),
                      child: Opacity(
                        opacity: (1 - delta.abs()).clamp(0.0, 1.0),
                        child: RepaintBoundary(child: steps[i].$3(i == _page)),
                      ),
                    );
                    final text = _StepText(
                      key: ValueKey('t$i-${i == _page}'),
                      step: i + 1,
                      title: steps[i].$1,
                      body: steps[i].$2,
                      animate: i == _page,
                    );
                    // Paysage : la scène à gauche, le texte à droite.
                    if (landscape) {
                      return Row(
                        children: [
                          Expanded(child: scene),
                          Expanded(child: Center(child: SingleChildScrollView(child: text))),
                        ],
                      );
                    }
                    return Column(children: [Expanded(child: scene), text]);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  for (var i = 0; i < steps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _page ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? c.primary : c.dividerStrong,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: LyraButton(
                      key: ValueKey(_page == 2),
                      label: _page == 2 ? l.guideStart : l.next,
                      icon: _page == 2 ? Icons.auto_fix_high_rounded : Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Texte de l'étape : numéro, titre puis description apparaissent en cascade.
class _StepText extends StatelessWidget {
  final int step;
  final String title;
  final String body;
  final bool animate;
  const _StepText({super.key, required this.step, required this.title, required this.body, required this.animate});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget cascade(int order, Widget child) => TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : 1, end: 1),
      duration: Duration(milliseconds: 450 + order * 110),
      curve: Interval(order * 0.18, 1, curve: Curves.easeOutCubic),
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: child),
      ),
      child: child,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cascade(
            0,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$step / 3',
                style: context.t.tech.copyWith(color: c.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          cascade(1, Text(title, style: context.t.h1)),
          const SizedBox(height: 8),
          cascade(
            2,
            SizedBox(
              height: 72,
              child: Text(body, style: context.t.body.copyWith(color: c.text2)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Base des scènes : une animation en boucle, arrêtée quand l'étape n'est pas visible.
abstract class _Scene extends StatefulWidget {
  final bool active;
  const _Scene({required this.active});
  Duration get period;
  Widget paint(BuildContext context, double t);

  @override
  State<_Scene> createState() => _SceneState();
}

class _SceneState extends State<_Scene> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period);
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(_Scene old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) _c.repeat(); // repart du début de la boucle
    if (!widget.active && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedBuilder(animation: _c, builder: (context, _) => widget.paint(context, _c.value)),
  );
}

/// Progression 0→1 de `t` entre `a` et `b`, avec une courbe.
double _seg(double t, double a, double b, [Curve curve = Curves.easeOutCubic]) =>
    curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

/// Cadre « téléphone » commun aux scènes.
Widget _frame(BuildContext context, Widget child) {
  final c = context.c;
  return Container(
    width: 250,
    height: 290,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: c.surface,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: c.divider),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 14))],
    ),
    child: child,
  );
}

List<String> _sampleLines(BuildContext context) => context.l.onbLyrics.split('|');

// ---- 1. Ajouter des paroles : le texte se tape ligne après ligne.

class _TypeScene extends _Scene {
  const _TypeScene({required super.active});

  @override
  Duration get period => const Duration(milliseconds: 5200);

  @override
  Widget paint(BuildContext context, double t) {
    final c = context.c;
    final lines = _sampleLines(context);
    final total = lines.fold<int>(0, (a, s) => a + s.length);
    // Le texte apparaît entre 15 % et 75 % de la boucle, puis reste affiché.
    // Caractères visibles par ligne.
    var left = (_seg(t, 0.15, 0.75, Curves.linear) * total).round();
    final counts = <int>[];
    for (final line in lines) {
      counts.add(left.clamp(0, line.length));
      left -= line.length;
    }
    final fade = 1 - _seg(t, 0.92, 1);
    final paste = _seg(t, 0.0, 0.14, Curves.elasticOut);
    final saved = _seg(t, 0.78, 0.88, Curves.easeOutBack);
    return Opacity(
      opacity: fade,
      child: _frame(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 0.6 + 0.4 * paste,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.content_paste_rounded, size: 13, color: c.onPrimary),
                        const SizedBox(width: 4),
                        Text(
                          context.l.paste,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: saved,
                  child: Icon(Icons.check_circle_rounded, color: c.success, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final (i, line) in lines.indexed)
              Builder(
                builder: (context) {
                  final n = counts[i];
                  final typing = n > 0 && n < line.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: line.substring(0, n)),
                          if (typing)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Opacity(
                                // Curseur qui clignote.
                                opacity: (t * 26).floor().isEven ? 1 : 0.2,
                                child: Container(
                                  width: 2.5,
                                  height: 17,
                                  margin: const EdgeInsets.only(left: 2),
                                  color: c.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      style: context.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ---- 2. Synchroniser : un toucher par ligne, l'horodatage se pose.

class _SyncScene extends _Scene {
  const _SyncScene({required super.active});

  @override
  Duration get period => const Duration(milliseconds: 5600);

  @override
  Widget paint(BuildContext context, double t) {
    final c = context.c;
    final lines = _sampleLines(context).take(4).toList();
    const yellow = Color(0xFFFFD43B);
    // Quatre touchers, à 15 %, 33 %, 51 % et 69 % de la boucle.
    final taps = [for (var i = 0; i < lines.length; i++) 0.15 + i * 0.18];
    final done = taps.where((x) => t >= x).length;
    final current = done - 1;
    final lastTap = done > 0 ? taps[done - 1] : -1.0;
    final ripple = done > 0 ? _seg(t, lastTap, lastTap + 0.14) : 0.0;
    final fade = 1 - _seg(t, 0.93, 1);
    return Opacity(
      opacity: fade,
      child: _frame(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    // L'horodatage arrive de la gauche quand la ligne est touchée.
                    SizedBox(
                      width: 58,
                      child: i < done
                          ? Opacity(
                              opacity: _seg(t, taps[i], taps[i] + 0.08),
                              child: Transform.translate(
                                offset: Offset(-14 * (1 - _seg(t, taps[i], taps[i] + 0.1)), 0),
                                child: Text(
                                  '00:${(4 + i * 3).toString().padLeft(2, '0')}.${(i * 37 % 100).toString().padLeft(2, '0')}',
                                  style: context.t.tech.copyWith(fontSize: 10.5, color: c.text3),
                                ),
                              ),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        lines[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.t.title.copyWith(
                          fontSize: i == current ? 16.5 : 14,
                          fontWeight: FontWeight.w800,
                          color: i == current ? yellow : c.text.withValues(alpha: i < done ? 0.4 : 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 110,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Onde à chaque toucher.
                    Container(
                      width: 60 + 50 * ripple,
                      height: 60 + 50 * ripple,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.primary.withValues(alpha: (1 - ripple) * 0.8), width: 2),
                      ),
                    ),
                    Transform.scale(
                      scale: 1 - 0.12 * math.sin(ripple * math.pi),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                        child: Icon(Icons.touch_app_rounded, color: c.onPrimary, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- 3. LyricsCard : la carte se compose, pivote, brille, puis s'envole.

class _CardScene extends _Scene {
  const _CardScene({required super.active});

  @override
  Duration get period => const Duration(milliseconds: 6400);

  @override
  Widget paint(BuildContext context, double t) {
    final words = _sampleLines(context).take(2).join(' ').split(' ');
    final bg = _seg(t, 0.0, 0.16);
    final quote = _seg(t, 0.12, 0.3, Curves.elasticOut);
    final shown = (_seg(t, 0.25, 0.55, Curves.linear) * words.length).ceil();
    final footer = _seg(t, 0.52, 0.64);
    final tilt = _seg(t, 0.62, 0.86, Curves.easeInOut);
    final shine = _seg(t, 0.66, 0.84, Curves.easeInOut);
    final fly = _seg(t, 0.86, 1, Curves.easeInCubic);
    final angle = math.sin(tilt * math.pi * 2) * 0.32;
    return Transform.translate(
      offset: Offset(0, -fly * 70),
      child: Opacity(
        opacity: 1 - fly,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle)
            ..rotateX(-angle * 0.3)
            ..scaleByDouble(0.92 + 0.08 * bg, 0.92 + 0.08 * bg, 1, 1),
          child: Container(
            width: 216,
            height: 270,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF2A2A2A), const Color(0xFF2B1055), bg)!,
                  Color.lerp(const Color(0xFF2A2A2A), const Color(0xFFD9339B), bg)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD9339B).withValues(alpha: 0.35 * bg),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: quote,
                        alignment: Alignment.topLeft,
                        child: const Text(
                          '“',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 58,
                            height: 0.9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFD43B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          for (var i = 0; i < words.length; i++)
                            AnimatedOpacity(
                              opacity: i < shown ? 1 : 0,
                              duration: const Duration(milliseconds: 220),
                              child: AnimatedSlide(
                                offset: i < shown ? Offset.zero : const Offset(0, 0.4),
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutBack,
                                child: Text(
                                  words[i],
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Opacity(
                        opacity: footer,
                        child: Transform.translate(
                          offset: Offset(0, 10 * (1 - footer)),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Icon(Icons.music_note_rounded, size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'LyraMusic',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.ios_share_rounded,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.6 + 0.4 * fly),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Reflet qui traverse la carte.
                if (shine > 0 && shine < 1)
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(-260 + 520 * shine, 0),
                      child: Transform.rotate(
                        angle: 0.35,
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
