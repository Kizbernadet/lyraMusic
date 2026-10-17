import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state/settings.dart';
import '../brand/logo.dart';
import '../theme.dart';
import '../theme_presets.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import 'theme_editor_screen.dart';

String appearanceLabel(BuildContext context, AppearanceMode m) => switch (m) {
  AppearanceMode.light => context.l.themeLight,
  AppearanceMode.dark => context.l.themeDark,
  AppearanceMode.system => context.l.themeSystem,
};

String accentLabel(BuildContext context, AccentColor a) {
  final l = context.l;
  return switch (a) {
    AccentColor.classic => l.accentClassic,
    AccentColor.sand => l.accentSand,
    AccentColor.taupe => l.accentTaupe,
    AccentColor.sage => l.accentSage,
    AccentColor.terracotta => l.accentTerracotta,
    AccentColor.ocean => l.accentOcean,
    AccentColor.mint => l.accentMint,
    AccentColor.violet => l.accentViolet,
  };
}

/// Nom du thème choisi (pour les réglages).
String themeChoiceLabel(BuildContext context, SettingsController s) {
  final l = context.l;
  if (s.themeChoice == 'dynamic') return l.themeDynamic;
  final spec = s.selectedSpec;
  if (spec != null) return spec.name;
  return '${l.themeClassic} · ${appearanceLabel(context, s.appearance)} · ${accentLabel(context, s.accent)}';
}

/// Apparence : galerie de thèmes, thème « Pochette », thèmes personnalisés.
class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<SettingsController>();
    final choice = s.themeChoice;
    final classicPreview = LyraColors.make(
      s.appearance == AppearanceMode.light ? Brightness.light : Brightness.dark,
      s.accent,
    );

    void select(String id) {
      HapticFeedback.selectionClick();
      s.setThemeChoice(id);
    }

    final cards = <Widget>[
      ThemeCard(
        name: l.themeClassic,
        colors: classicPreview,
        selected: choice == 'classic',
        onTap: () => select('classic'),
      ),
      ThemeCard(
        name: l.themeDynamic,
        colors: classicPreview,
        dynamic: true,
        selected: choice == 'dynamic',
        onTap: () => select('dynamic'),
      ),
      for (final t in presetThemes)
        ThemeCard(
          name: t.name,
          colors: t.colors,
          selected: choice == 'preset:${t.id}',
          onTap: () => select('preset:${t.id}'),
        ),
      for (final t in s.customThemes)
        ThemeCard(
          name: t.name,
          colors: t.colors,
          custom: true,
          selected: choice == 'custom:${t.id}',
          onTap: () => select('custom:${t.id}'),
          onEdit: () => context.pushFull(ThemeEditorScreen(initial: t)),
        ),
      _CreateCard(onTap: () => context.pushFull(const ThemeEditorScreen())),
    ];

    return Scaffold(
      appBar: LyraAppBar(title: l.appearance, subtitle: l.settings),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Text(l.themesGalleryHint, style: context.t.meta),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 14,
                children: [for (final card in cards) SizedBox(width: w, child: card)],
              );
            },
          ),
          // Réglages du thème classique et du thème « Pochette »
          if (choice == 'classic' || choice == 'dynamic') ...[
            const SizedBox(height: 28),
            Text(l.theme.toUpperCase(), style: context.t.label),
            const SizedBox(height: 10),
            _ModeSelector(settings: s),
          ],
          if (choice == 'classic') ...[
            const SizedBox(height: 24),
            Text(l.accentColor.toUpperCase(), style: context.t.label),
            const SizedBox(height: 4),
            Text(l.accentHint, style: context.t.meta),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final a in AccentColor.values)
                  Press(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      s.setAccent(a);
                    },
                    semanticLabel: accentLabel(context, a),
                    child: _Swatch(accent: a, selected: s.accent == a),
                  ),
              ],
            ),
          ],
          if (choice == 'dynamic') ...[
            const SizedBox(height: 16),
            LyraBanner(icon: Icons.auto_awesome_rounded, title: l.themeDynamic, text: l.themeDynamicHint),
          ],
        ],
      ),
    );
  }
}

/// Aperçu miniature d'un thème (logo, ligne de morceau, bouton, progression).
class ThemeCard extends StatelessWidget {
  final String name;
  final LyraColors colors;
  final bool selected;
  final bool dynamic;
  final bool custom;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  const ThemeCard({
    super.key,
    required this.name,
    required this.colors,
    required this.selected,
    required this.onTap,
    this.dynamic = false,
    this.custom = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = colors;
    return Press(
      onTap: onTap,
      semanticLabel: name,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusL + 4),
          border: Border.all(color: selected ? c.primary : Colors.transparent, width: 2.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(radiusL),
              child: Container(
                height: 132,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: s.bg,
                  gradient: dynamic
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3B1C4A), Color(0xFF1C3B4A), Color(0xFF4A3B1C)],
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        LyraLogo(
                          width: 46,
                          showMusic: false,
                          ink: dynamic ? Colors.white : s.ink,
                          paper: dynamic ? const Color(0xFF2A2A3A) : s.paper,
                        ),
                        const Spacer(),
                        if (dynamic) const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: dynamic ? Colors.white24 : s.surface2,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bar(dynamic ? Colors.white70 : s.text, 0.9),
                              const SizedBox(height: 4),
                              _bar(dynamic ? Colors.white38 : s.text3, 0.55),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: dynamic ? const Color(0xFFFF9F6B) : s.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.play_arrow_rounded, size: 15, color: dynamic ? Colors.black : s.onPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 4,
                        color: dynamic ? const Color(0xFFFF9F6B) : s.primary,
                        backgroundColor: dynamic ? Colors.white24 : s.dividerStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.t.title.copyWith(fontWeight: selected ? FontWeight.w800 : FontWeight.w600),
                    ),
                  ),
                ),
                if (onEdit != null)
                  LyraIconButton(
                    icon: Icons.edit_rounded,
                    size: 17,
                    box: 32,
                    tooltip: context.l.edit,
                    onPressed: onEdit,
                  ),
                if (selected) Icon(Icons.check_circle_rounded, size: 20, color: c.primary),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(Color color, double widthFactor) => FractionallySizedBox(
    widthFactor: widthFactor,
    child: Container(
      height: 5,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
    ),
  );
}

class _CreateCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Press(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 132,
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(radiusL),
                border: Border.all(color: c.dividerStrong),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                    child: Icon(Icons.add_rounded, color: c.onPrimary),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.palette_outlined, color: c.text3, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(context.l.themeCreate, style: context.t.title.copyWith(color: c.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clair / Sombre / Système, en segments.
class _ModeSelector extends StatelessWidget {
  final SettingsController settings;
  const _ModeSelector({required this.settings});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final modes = [
      (AppearanceMode.light, Icons.light_mode_rounded),
      (AppearanceMode.dark, Icons.dark_mode_rounded),
      (AppearanceMode.system, Icons.brightness_auto_rounded),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(radiusM)),
      child: Row(
        children: [
          for (final (m, icon) in modes)
            Expanded(
              child: Press(
                onTap: () {
                  HapticFeedback.selectionClick();
                  settings.setAppearance(m);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: lyraCurve,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: settings.appearance == m ? c.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(radiusS),
                    boxShadow: settings.appearance == m
                        ? const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2))]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 17, color: settings.appearance == m ? c.primary : c.text3),
                      const SizedBox(width: 6),
                      Text(
                        appearanceLabel(context, m),
                        style: context.t.title.copyWith(
                          fontSize: 13.5,
                          color: settings.appearance == m ? c.text : c.text2,
                        ),
                      ),
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

/// Pastille : moitié couleur en mode clair, moitié en mode sombre.
class _Swatch extends StatelessWidget {
  final AccentColor accent;
  final bool selected;
  const _Swatch({required this.accent, required this.selected});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final a = accents[accent]!;
    const size = 50.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? c.text : Colors.transparent, width: 2),
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: a.light),
            ClipPath(
              clipper: _Half(),
              child: ColoredBox(color: a.dark),
            ),
            if (selected) Center(child: Icon(Icons.check_rounded, color: c.isDark ? a.onDark : a.onLight, size: 20)),
          ],
        ),
      ),
    );
  }
}

class _Half extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(s.width, 0)
    ..lineTo(s.width, s.height)
    ..lineTo(0, s.height)
    ..close();

  @override
  bool shouldReclip(_Half oldClipper) => false;
}
