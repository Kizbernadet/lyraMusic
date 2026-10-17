import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../brand/logo.dart';
import '../theme.dart';
import '../theme_presets.dart';
import '../widgets/color_picker.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// Contraste WCAG entre deux couleurs (1 à 21).
double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Création d'un thème personnalisé, avec aperçu en direct.
/// Le thème est enregistré sur le téléphone.
class ThemeEditorScreen extends StatefulWidget {
  final ThemeSpec? initial;
  const ThemeEditorScreen({super.key, this.initial});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  late ThemeSpec _spec =
      widget.initial ??
      ThemeSpec(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        brightness: Brightness.dark,
        bg: const Color(0xFF151515),
        accent: const Color(0xFFFF7A59),
        custom: true,
      );
  late final _name = TextEditingController(text: _spec.name);
  final _random = math.Random();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _dark => _spec.brightness == Brightness.dark;

  void _setBrightness(Brightness b) {
    if (b == _spec.brightness) return;
    HapticFeedback.selectionClick();
    // Fond de départ cohérent avec le nouveau mode, couleur d'accent conservée.
    final hsl = HSLColor.fromColor(_spec.bg);
    setState(() {
      _spec = _spec.copyWith(
        brightness: b,
        bg: hsl.withLightness(b == Brightness.dark ? 0.08 : 0.94).toColor(),
        text: () => null,
      );
    });
  }

  /// Palette harmonieuse au hasard (fond désaturé + accent vif complémentaire ou voisin).
  void _surprise() {
    HapticFeedback.mediumImpact();
    final hue = _random.nextDouble() * 360;
    final dark = _random.nextDouble() < 0.7;
    final accentHue = (hue + [150.0, 180.0, 30.0, -30.0, 200.0][_random.nextInt(5)]) % 360;
    setState(() {
      _spec = _spec.copyWith(
        brightness: dark ? Brightness.dark : Brightness.light,
        bg: HSLColor.fromAHSL(1, hue, dark ? 0.35 : 0.25, dark ? 0.09 : 0.93).toColor(),
        accent: HSLColor.fromAHSL(1, accentHue, 0.75, dark ? 0.62 : 0.42).toColor(),
        text: () => null,
      );
    });
  }

  Future<void> _pick(String title, Color initial, void Function(Color) apply) async {
    final c = await pickColor(context, initial: initial, title: title);
    if (c != null) setState(() => apply(c));
  }

  Future<void> _save() async {
    final l = context.l;
    final name = _name.text.trim().isEmpty ? l.themeMine : _name.text.trim();
    final spec = _spec.copyWith(name: name);
    final s = context.settings;
    await s.saveCustomTheme(spec);
    await s.setThemeChoice('custom:${spec.id}');
    if (!mounted) return;
    context.toast(l.themeSaved, icon: Icons.palette_rounded);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final colors = _spec.colors;
    final textContrast = contrast(colors.text, colors.bg);
    final accentContrast = contrast(colors.primary, colors.bg);

    Widget colorRow(String title, Color value, VoidCallback onTap, {Widget? trailing}) => SettingRow(
      title: title,
      value: '#${(value.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
      onTap: onTap,
      trailing:
          trailing ??
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: value,
              shape: BoxShape.circle,
              border: Border.all(color: c.dividerStrong),
            ),
          ),
    );

    return Scaffold(
      appBar: LyraAppBar(
        title: widget.initial == null ? l.themeCreate : l.themeEdit,
        backIcon: Icons.close_rounded,
        actions: [
          if (widget.initial != null)
            LyraIconButton(
              icon: Icons.delete_outline_rounded,
              color: c.error,
              tooltip: l.delete,
              onPressed: () async {
                await context.settings.deleteCustomTheme(_spec.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          LyraButton(label: l.save, small: true, onPressed: _save),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // Aperçu en direct
          AnimatedTheme(
            data: buildTheme(colors),
            duration: const Duration(milliseconds: 300),
            child: Builder(builder: (context) => _LivePreview(colors: colors)),
          ),
          const SizedBox(height: 16),
          LyraButton(
            label: l.themeSurprise,
            icon: Icons.casino_rounded,
            full: true,
            variant: BtnVariant.tonal,
            onPressed: _surprise,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            maxLength: 30,
            textCapitalization: TextCapitalization.sentences,
            style: context.t.title,
            decoration: InputDecoration(hintText: l.themeName, counterText: ''),
          ),
          const SizedBox(height: 16),
          // Base claire ou sombre
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(radiusM)),
            child: Row(
              children: [
                for (final (b, icon, label) in [
                  (Brightness.light, Icons.light_mode_rounded, l.themeLight),
                  (Brightness.dark, Icons.dark_mode_rounded, l.themeDark),
                ])
                  Expanded(
                    child: Press(
                      onTap: () => _setBrightness(b),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: _spec.brightness == b ? c.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(radiusS),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 17, color: _spec.brightness == b ? c.primary : c.text3),
                            const SizedBox(width: 6),
                            Text(label, style: context.t.title.copyWith(fontSize: 13.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LyraGroup(
            title: l.themeColors,
            children: [
              colorRow(
                l.themeBackground,
                _spec.bg,
                () => _pick(l.themeBackground, _spec.bg, (v) => _spec = _spec.copyWith(bg: v)),
              ),
              colorRow(
                l.accentColor,
                _spec.accent,
                () => _pick(l.accentColor, _spec.accent, (v) => _spec = _spec.copyWith(accent: v)),
              ),
              colorRow(
                l.themeText,
                colors.text,
                () => _pick(l.themeText, colors.text, (v) => _spec = _spec.copyWith(text: () => v)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_spec.text != null)
                      LyraButton(
                        label: l.auto,
                        small: true,
                        variant: BtnVariant.ghost,
                        onPressed: () => setState(() => _spec = _spec.copyWith(text: () => null)),
                      ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colors.text,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.dividerStrong),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Lisibilité
          if (textContrast < 4.5 || accentContrast < 2.2)
            LyraBanner(
              tone: Tone.warn,
              icon: Icons.visibility_outlined,
              title: l.themeContrastLow,
              text: l.themeContrastText(textContrast.toStringAsFixed(1)),
            )
          else
            LyraBanner(
              tone: Tone.ok,
              icon: Icons.check_circle_outline_rounded,
              title: l.themeContrastOk,
              text: l.themeContrastText(textContrast.toStringAsFixed(1)),
            ),
          const SizedBox(height: 10),
          Text(_dark ? l.themeTipDark : l.themeTipLight, style: context.t.meta.copyWith(color: c.text3)),
        ],
      ),
    );
  }
}

/// Mini-application dans le thème en cours d'édition.
class _LivePreview extends StatelessWidget {
  final LyraColors colors;
  const _LivePreview({required this.colors});

  @override
  Widget build(BuildContext context) {
    final s = colors;
    final t = LyraText(s);
    Widget row(String title, String artist, {bool active = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: s.surface2, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.music_note_rounded, size: 18, color: s.text3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.title.copyWith(color: active ? s.primary : s.text, fontWeight: FontWeight.w700),
                ),
                Text(artist, style: t.meta),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: s.primary, shape: BoxShape.circle),
            child: Icon(Icons.play_arrow_rounded, size: 18, color: s.onPrimary),
          ),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(radiusXL),
        border: Border.all(color: s.dividerStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LyraLogo(width: 70, showMusic: false, ink: s.ink, paper: s.paper),
              const Spacer(),
              Icon(Icons.search_rounded, color: s.text),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    'Suggestions',
                    style: t.title.copyWith(color: s.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(color: s.primary, borderRadius: BorderRadius.circular(3)),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text('Titres', style: t.title.copyWith(color: s.text3)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          row('Horizons', 'LyraMusic', active: true),
          row('Golden hour', 'Artiste'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: s.surface, borderRadius: BorderRadius.circular(radiusM)),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: s.surface2, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Horizons', style: t.title.copyWith(fontWeight: FontWeight.w700)),
                ),
                Icon(Icons.pause_circle_filled_rounded, color: s.primary, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
