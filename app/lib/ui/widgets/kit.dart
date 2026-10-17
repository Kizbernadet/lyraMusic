import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../brand/logo.dart';
import 'artwork.dart';

/// Composants de l'interface, repris du prototype (src/lib/ui.tsx)
/// et de la planche assets/brand/05-composants.png.

// ---------------------------------------------------------------------------
// Appui : léger rétrécissement (échelle 0,97)

/// Retours haptiques légers, désactivables dans les réglages.
class Haptics {
  static bool enabled = true;
  static void tap() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void select() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void strong() {
    if (enabled) HapticFeedback.mediumImpact();
  }
}

class Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final String? semanticLabel;
  const Press({super.key, required this.child, this.onTap, this.onLongPress, this.scale = 0.97, this.semanticLabel});

  @override
  State<Press> createState() => _PressState();
}

class _PressState extends State<Press> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 140),
          curve: lyraCurve,
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Boutons

enum BtnVariant { primary, tonal, secondary, ghost, danger }

class LyraButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final BtnVariant variant;
  final bool small;
  final bool full;
  final Widget? child;

  const LyraButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
    this.variant = BtnVariant.primary,
    this.small = false,
    this.full = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final disabled = onPressed == null;
    final (Color bg, Color fg, Border? border) = switch (variant) {
      BtnVariant.primary => (c.primary, c.onPrimary, null),
      // « Lecture » de la maquette : fond neutre, icône dans la couleur principale.
      BtnVariant.tonal => (c.surface2, c.text, null),
      BtnVariant.secondary => (c.surface2, c.text, Border.all(color: c.divider)),
      BtnVariant.ghost => (Colors.transparent, c.text2, null),
      BtnVariant.danger => (c.error.withValues(alpha: 0.12), c.error, null),
    };
    final content = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: small ? 16 : 20, color: variant == BtnVariant.tonal ? c.primary : fg),
        if (icon != null && (label != null || child != null)) const SizedBox(width: 8),
        if (label != null)
          Flexible(
            child: Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.t.button.copyWith(color: fg),
            ),
          ),
        ?child,
      ],
    );
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Press(
        onTap: onPressed,
        child: Container(
          height: small ? 36 : 48,
          padding: EdgeInsets.symmetric(horizontal: small ? 14 : 20),
          decoration: BoxDecoration(color: bg, border: border, borderRadius: BorderRadius.circular(99)),
          child: content,
        ),
      ),
    );
  }
}

/// Bouton icône rond (zone tactile 44 px).
class LyraIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;
  final double size;
  final double box;
  final Color? color;
  final Color? background;

  const LyraIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.active = false,
    this.size = 21,
    this.box = 44,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tooltip(
      message: tooltip,
      child: Press(
        onTap: onPressed,
        semanticLabel: tooltip,
        child: Container(
          width: box,
          height: box,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: size, color: color ?? (active ? c.primary : c.text2)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Puces, badges, bannières

class LyraChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback? onTap;
  const LyraChip({super.key, required this.label, this.icon, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = active ? c.bg : c.text2;
    return Press(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: active ? c.text : c.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? Colors.transparent : c.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 6)],
            Text(
              label,
              style: context.t.meta.copyWith(color: fg, fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

enum Tone { neutral, accent, warn, ok, err }

Color toneColor(LyraColors c, Tone tone) => switch (tone) {
  Tone.neutral => c.text2,
  Tone.accent => c.primary,
  Tone.warn => c.warning,
  Tone.ok => c.success,
  Tone.err => c.error,
};

class LyraBadge extends StatelessWidget {
  final String text;
  final Tone tone;
  const LyraBadge(this.text, {super.key, this.tone = Tone.neutral});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = toneColor(c, tone);
    return Container(
      height: 21,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tone == Tone.neutral ? c.surface2 : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: tone == Tone.neutral ? Border.all(color: c.divider) : null,
      ),
      child: Text(text.toUpperCase(), style: context.t.label.copyWith(color: color, letterSpacing: 1.0, fontSize: 10)),
    );
  }
}

class LyraBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? text;
  final String? action;
  final VoidCallback? onAction;
  final Tone tone;
  const LyraBanner({
    super.key,
    required this.icon,
    required this.title,
    this.text,
    this.action,
    this.onAction,
    this.tone = Tone.accent,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = toneColor(c, tone == Tone.neutral ? Tone.accent : tone);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(radiusM),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.t.title),
                if (text != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(text!, style: context.t.meta),
                  ),
                if (action != null)
                  Press(
                    onTap: onAction,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 2),
                      child: Text(
                        '$action  →',
                        style: context.t.meta.copyWith(color: color, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Structure

/// En-tête d'écran : petit libellé au-dessus du titre, retour, actions.
class LyraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool large;
  final List<Widget> actions;
  final bool back;
  final IconData backIcon;
  final Color? background;

  const LyraAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.large = false,
    this.actions = const [],
    this.back = true,
    this.backIcon = Icons.chevron_left_rounded,
    this.background,
  });

  @override
  Size get preferredSize => Size.fromHeight(large ? 72 : 60);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final canPop = back && Navigator.of(context).canPop();
    return Material(
      color: background ?? c.bg,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: EdgeInsets.only(left: canPop ? 6 : 20, right: 10),
            child: Row(
              children: [
                if (canPop)
                  LyraIconButton(
                    icon: backIcon,
                    size: 26,
                    color: c.text,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.t.label,
                        ),
                      if (subtitle != null) const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: large ? context.t.h1 : context.t.h2,
                      ),
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;
  const SectionHead(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 12),
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: context.t.h2)),
        if (action != null)
          Press(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: Text(
                action!,
                style: context.t.title.copyWith(color: context.c.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    ),
  );
}

class LyraCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  const LyraCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(color: color ?? c.surface, borderRadius: BorderRadius.circular(radiusL)),
      child: child,
    );
    return onTap == null ? box : Press(onTap: onTap, child: box);
  }
}

/// Groupe de réglages : carte arrondie avec séparateurs.
class LyraGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const LyraGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(title!.toUpperCase(), style: context.t.label),
          ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radiusL)),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, color: c.divider),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? tone;
  final bool mono;
  const SettingRow({
    super.key,
    this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.trailing,
    this.tone,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(radiusXS)),
              child: Icon(icon, size: 17, color: tone ?? c.text2),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.title),
                if (value != null)
                  Text(
                    value!,
                    maxLines: mono ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: mono ? context.t.tech.copyWith(fontSize: 11.5, color: c.text2) : context.t.meta,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              (onTap != null ? Icon(Icons.chevron_right_rounded, size: 20, color: c.text3) : const SizedBox.shrink()),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

// ---------------------------------------------------------------------------
// États vides

class LyraEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final String? action;
  final VoidCallback? onAction;
  final String? secondary;
  final VoidCallback? onSecondary;
  final bool compact;
  const LyraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.action,
    this.onAction,
    this.secondary,
    this.onSecondary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dim = compact ? 46.0 : 58.0;
    return CustomPaint(
      painter: _DashedBorder(color: c.dividerStrong, radius: radiusL),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: compact ? 24 : 36),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radiusL)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dim,
              height: dim,
              decoration: BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
              child: Icon(icon, size: compact ? 20 : 24, color: c.primary),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: context.t.h3),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: Text(text, textAlign: TextAlign.center, style: context.t.meta),
            ),
            if (action != null || secondary != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (action != null) LyraButton(label: action, small: true, onPressed: onAction),
                  if (secondary != null)
                    LyraButton(label: secondary, small: true, variant: BtnVariant.ghost, onPressed: onSecondary),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorder({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 6, metric.length)), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Visuels

/// Mosaïque 2 × 2 de pochettes (playlists).
class Mosaic extends StatelessWidget {
  final List<String?> arts;
  final double size;
  final double radius;
  final String seed;
  const Mosaic({super.key, required this.arts, required this.size, this.radius = 16, this.seed = ''});

  @override
  Widget build(BuildContext context) {
    final unique = arts.whereType<String>().toSet().toList();
    if (unique.length < 4) {
      return Artwork(path: unique.firstOrNull, size: size, radius: radius, seed: seed, icon: Icons.queue_music_rounded);
    }
    final half = size / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: Wrap(
          children: [for (final a in unique.take(4)) Artwork(path: a, size: half, radius: 0)],
        ),
      ),
    );
  }
}

/// Barres animées « en cours de lecture ».
class EqBars extends StatefulWidget {
  final Color color;
  final bool animate;
  final double height;
  const EqBars({super.key, this.color = Colors.white, this.animate = true, this.height = 14});

  @override
  State<EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<EqBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void didUpdateWidget(EqBars old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) _c.repeat();
    if (!widget.animate && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Container(
              width: 2.6,
              height: widget.height * (0.35 + 0.65 * (0.5 + 0.5 * math.sin((_c.value + i * 0.18) * 2 * math.pi))),
              decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Icône de l'application (tuile + R-vinyle).
class LogoTile extends StatelessWidget {
  final double size;
  final bool glow;
  const LogoTile({super.key, required this.size, this.glow = false});

  @override
  Widget build(BuildContext context) => LyraAppIcon(size: size);
}

/// Logo « LYRA » (le R est un vinyle), pour les en-têtes.
class Wordmark extends StatelessWidget {
  final double size;
  final bool spin;
  const Wordmark({super.key, this.size = 30, this.spin = false});

  @override
  Widget build(BuildContext context) => LyraLogo(width: size * 3.6, showMusic: false, spin: spin);
}

/// Fond d'ambiance : la pochette très floutée sous un voile (lecteur, file, paroles).
/// La pochette est décodée en très petit puis agrandie : flou peu coûteux.
class Ambient extends StatelessWidget {
  final String? art;
  final String seed;
  const Ambient({super.key, required this.art, this.seed = ''});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final colors = placeholderColors(seed);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (art != null)
          Opacity(
            opacity: c.isDark ? 0.75 : 0.5,
            child: Image.file(
              File(art!),
              fit: BoxFit.cover,
              cacheWidth: 24,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.6),
                radius: 1.1,
                colors: [colors.first.withValues(alpha: 0.6), c.bg],
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.bg.withValues(alpha: 0.55), c.bg.withValues(alpha: 0.86), c.bg],
              stops: const [0, 0.48, 1],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Feuilles et notifications

/// Feuille du bas au style du prototype (poignée, titre en libellé).
Future<T?> showLyraSheet<T>(BuildContext context, {String? title, required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheet) {
      final c = sheet.c;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: c.dividerStrong, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Text(title.toUpperCase(), style: sheet.t.label),
                ),
              Flexible(
                child: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 12), child: builder(sheet)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Ligne d'action dans une feuille.
class SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const SheetAction({super.key, required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? context.c.text2),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: context.t.title.copyWith(color: color)),
          ),
        ],
      ),
    ),
  );
}

OverlayEntry? _toastEntry;

/// Notification en pilule, au-dessus du mini-lecteur (prototype : Toast).
void showLyraToast(BuildContext context, String message, {IconData icon = Icons.check_rounded}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _toastEntry?.remove();
  final c = context.c;
  final t = context.t;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 24,
      right: 24,
      bottom: MediaQuery.paddingOf(ctx).bottom + 150,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 280),
            curve: lyraCurve,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 8 * (1 - v)), child: child),
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: c.elevated.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: c.dividerStrong),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15, color: c.success),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: t.meta.copyWith(color: c.text, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _toastEntry = entry;
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2200), () {
    if (_toastEntry == entry) {
      entry.remove();
      _toastEntry = null;
    }
  });
}
