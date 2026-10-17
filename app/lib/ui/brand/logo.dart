import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'logo_paths.dart' as lp;

/// Formes du logo (concept 1 : « LYRA » dont le R est un vinyle), créées une seule fois.
class _Shapes {
  static final l = lp.letterL();
  static final y = lp.letterY();
  static final r = lp.letterR();
  static final a = lp.letterA();
  static final vinyl = lp.vinyl();
  static final music = [lp.musicM(), lp.musicU(), lp.musicS(), lp.musicI(), lp.musicC()];
  static final musicCenters = [for (final p in music) p.getBounds().center.dx];
  static final musicBounds = lp.music().getBounds();
}

/// Rayon du disque (cuvette du R) autour du centre du vinyle.
const _discRadius = 74.0;

/// Dessine le vinyle (sillons, étiquette, trou central) tourné de [angle].
void _paintVinyl(Canvas canvas, Color paper, double angle) {
  const c = lp.vinylCenter;
  canvas.save();
  canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: _discRadius - 3)));
  canvas.translate(c.dx, c.dy);
  canvas.rotate(angle);
  canvas.translate(-c.dx, -c.dy);
  canvas.drawPath(_Shapes.vinyl, Paint()..color = paper);
  canvas.restore();
}

/// Logo complet, figé ou avec le vinyle qui tourne.
class LyraLogo extends StatefulWidget {
  final double width;
  final Color? ink;
  final Color? paper;
  final bool spin;
  final bool showMusic;
  const LyraLogo({super.key, required this.width, this.ink, this.paper, this.spin = false, this.showMusic = true});

  @override
  State<LyraLogo> createState() => _LyraLogoState();
}

class _LyraLogoState extends State<LyraLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1818));

  @override
  void initState() {
    super.initState();
    if (widget.spin) _spin.repeat();
  }

  @override
  void didUpdateWidget(LyraLogo old) {
    super.didUpdateWidget(old);
    if (widget.spin && !_spin.isAnimating) _spin.repeat();
    if (!widget.spin && _spin.isAnimating) _spin.stop();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final h = widget.showMusic ? lp.logoSize.height : lp.letterRBounds.bottom;
    return Semantics(
      label: 'LyraMusic',
      image: true,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, _) => CustomPaint(
          size: Size(widget.width, widget.width * h / lp.logoSize.width),
          painter: _LogoPainter(
            ink: widget.ink ?? c.ink,
            paper: widget.paper ?? c.paper,
            spin: _spin.value * 2 * math.pi,
            showMusic: widget.showMusic,
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color ink;
  final Color paper;
  final double spin;
  final bool showMusic;
  _LogoPainter({required this.ink, required this.paper, required this.spin, required this.showMusic});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / lp.logoSize.width);
    final p = Paint()..color = ink;
    for (final path in [_Shapes.l, _Shapes.y, _Shapes.r, _Shapes.a]) {
      canvas.drawPath(path, p);
    }
    if (showMusic) {
      for (final m in _Shapes.music) {
        canvas.drawPath(m, p);
      }
    }
    _paintVinyl(canvas, paper, spin);
  }

  @override
  bool shouldRepaint(_LogoPainter o) => o.spin != spin || o.ink != ink || o.paper != paper;
}

/// Symbole de l'application : le R-vinyle seul.
class LyraSymbol extends StatelessWidget {
  final double size;
  final Color? ink;
  final Color? paper;
  final double angle;
  const LyraSymbol({super.key, required this.size, this.ink, this.paper, this.angle = 0});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return CustomPaint(
      size: Size.square(size),
      painter: _SymbolPainter(ink: ink ?? c.ink, paper: paper ?? c.paper, angle: angle),
    );
  }
}

class _SymbolPainter extends CustomPainter {
  final Color ink;
  final Color paper;
  final double angle;
  _SymbolPainter({required this.ink, required this.paper, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    const b = lp.letterRBounds;
    final k = size.height / b.height;
    canvas.translate((size.width - b.width * k) / 2, 0);
    canvas.scale(k);
    canvas.translate(-b.left, -b.top);
    canvas.drawPath(_Shapes.r, Paint()..color = ink);
    _paintVinyl(canvas, paper, angle);
  }

  @override
  bool shouldRepaint(_SymbolPainter o) => o.angle != angle || o.ink != ink || o.paper != paper;
}

/// Icône de l'application : tuile arrondie + R-vinyle.
class LyraAppIcon extends StatelessWidget {
  final double size;
  const LyraAppIcon({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.ink, borderRadius: BorderRadius.circular(size * 0.24)),
      alignment: Alignment.center,
      child: LyraSymbol(size: size * 0.58, ink: c.paper, paper: c.ink),
    );
  }
}

// ---------------------------------------------------------------------------
// Animation de démarrage

/// Le vinyle arrive en roulant, le R se forme autour, L-Y-A tombent et
/// rebondissent, MUSIC s'écarte depuis le centre, des ondes sonores partent
/// du disque qui tourne à 33 tours.
class SplashLogoAnimation extends StatefulWidget {
  final double width;
  final String? tagline;
  const SplashLogoAnimation({super.key, required this.width, this.tagline});

  static const duration = Duration(milliseconds: 2400);

  @override
  State<SplashLogoAnimation> createState() => _SplashLogoAnimationState();
}

class _SplashLogoAnimationState extends State<SplashLogoAnimation> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: SplashLogoAnimation.duration)
    ..forward();
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(milliseconds: 1818))
    ..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) _intro.value = 1;
    final scale = widget.width / lp.logoSize.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_intro, _loop]),
          builder: (_, _) => CustomPaint(
            size: Size(widget.width, lp.logoSize.height * scale),
            painter: _SplashPainter(
              t: _intro.value,
              loop: _loop.value,
              ink: c.ink,
              paper: c.paper,
              screenWidth: MediaQuery.sizeOf(context).width / scale,
            ),
          ),
        ),
        if (widget.tagline != null) ...[
          SizedBox(height: widget.width * 0.1),
          AnimatedBuilder(
            animation: _intro,
            builder: (_, child) {
              final v = Curves.easeOut.transform(((_intro.value - 0.78) / 0.22).clamp(0.0, 1.0));
              return Opacity(
                opacity: v,
                child: Transform.translate(offset: Offset(0, 10 * (1 - v)), child: child),
              );
            },
            child: Text(
              widget.tagline!,
              textAlign: TextAlign.center,
              style: context.t.body.copyWith(color: c.text2),
            ),
          ),
        ],
      ],
    );
  }
}

class _SplashPainter extends CustomPainter {
  final double t; // 0 → 1 (intro)
  final double loop; // 0 → 1 en boucle (un tour de disque)
  final Color ink;
  final Color paper;
  final double screenWidth; // en unités du logo
  _SplashPainter({
    required this.t,
    required this.loop,
    required this.ink,
    required this.paper,
    required this.screenWidth,
  });

  double _seg(double a, double b, [Curve curve = Curves.linear]) =>
      curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / lp.logoSize.width);
    const c = lp.vinylCenter;
    final inkPaint = Paint()..color = ink;

    // 1. Le disque arrive en roulant depuis la droite (0 → 0,32).
    final roll = _seg(0, 0.32, Curves.easeOutCubic);
    final startX = screenWidth + _discRadius;
    final dx = (startX - c.dx) * (1 - roll);
    // Roulement : angle = distance / rayon, puis 33 tours/min.
    final spin = -dx / _discRadius + loop * 2 * math.pi;

    // 5. Ondes sonores depuis le disque, une fois posé.
    final wavesOn = _seg(0.30, 0.45);
    if (wavesOn > 0) {
      for (var i = 0; i < 3; i++) {
        final ph = (loop + i / 3) % 1.0;
        final radius = _discRadius + 20 + ph * 210;
        canvas.drawCircle(
          c,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = ink.withValues(alpha: 0.10 * (1 - ph) * wavesOn),
        );
      }
    }

    // 2. Le R se forme autour du disque (0,26 → 0,44).
    final rIn = _seg(0.26, 0.44, Curves.easeOutBack);
    if (rIn > 0) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.scale(0.6 + 0.4 * rIn);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawPath(_Shapes.r, Paint()..color = ink.withValues(alpha: _seg(0.26, 0.36)));
      canvas.restore();
    }
    // Disque seul tant que le R n'est pas complet.
    final discAlpha = 1 - _seg(0.38, 0.46);
    if (discAlpha > 0) {
      canvas.save();
      canvas.translate(dx, 0);
      canvas.drawCircle(c, _discRadius, Paint()..color = ink.withValues(alpha: discAlpha));
      canvas.restore();
    }
    canvas.save();
    canvas.translate(dx, 0);
    _paintVinyl(canvas, paper, spin);
    canvas.restore();

    // 3. L, Y, A tombent et rebondissent l'un après l'autre.
    void drop(Path p, double start) {
      final v = _seg(start, start + 0.26, Curves.bounceOut);
      if (v <= 0) return;
      final fade = _seg(start, start + 0.06);
      canvas.save();
      canvas.translate(0, -260 * (1 - v));
      canvas.drawPath(p, Paint()..color = ink.withValues(alpha: fade));
      canvas.restore();
    }

    drop(_Shapes.l, 0.36);
    drop(_Shapes.y, 0.42);
    drop(_Shapes.a, 0.48);

    // 4. MUSIC s'écarte depuis le centre (0,62 → 0,86).
    final m = _seg(0.62, 0.86, Curves.easeOutCubic);
    if (m > 0) {
      final center = _Shapes.musicBounds.center.dx;
      for (var i = 0; i < _Shapes.music.length; i++) {
        final off = (center - _Shapes.musicCenters[i]) * (1 - m);
        canvas.save();
        canvas.translate(off, 0);
        canvas.drawPath(_Shapes.music[i], Paint()..color = inkPaint.color.withValues(alpha: m));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_SplashPainter o) => o.t != t || o.loop != loop || o.ink != ink || o.paper != paper;
}
