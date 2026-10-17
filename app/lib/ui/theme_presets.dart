import 'dart:convert';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Génère une palette complète à partir de 2 ou 3 couleurs (fond, accent, texte).
/// Utilisé par les thèmes prédéfinis, les thèmes personnalisés et le thème dynamique.
LyraColors colorsFromSeed({required Brightness brightness, required Color bg, required Color accent, Color? text}) {
  final dark = brightness == Brightness.dark;
  final txt = text ?? (dark ? const Color(0xFFF5F2EA) : const Color(0xFF141414));
  Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;
  final onAccent = accent.computeLuminance() > 0.42 ? const Color(0xFF111111) : Colors.white;
  return LyraColors(
    brightness: brightness,
    primary: accent,
    onPrimary: onAccent,
    ink: txt,
    paper: bg,
    bg: bg,
    surface: dark ? mix(bg, txt, 0.06) : mix(bg, Colors.white, 0.55),
    surface2: mix(bg, txt, dark ? 0.13 : 0.07),
    elevated: dark ? mix(bg, txt, 0.09) : mix(bg, Colors.white, 0.7),
    text: txt,
    text2: mix(txt, bg, 0.28),
    text3: mix(txt, bg, 0.5),
    divider: txt.withValues(alpha: dark ? 0.09 : 0.10),
    dividerStrong: txt.withValues(alpha: dark ? 0.16 : 0.18),
    overlay: Colors.black.withValues(alpha: dark ? 0.62 : 0.4),
    success: dark ? const Color(0xFF7FBF8E) : const Color(0xFF3F8A5A),
    warning: dark ? const Color(0xFFE3A648) : const Color(0xFFB27820),
    error: dark ? const Color(0xFFE5736B) : const Color(0xFFC0443C),
  );
}

/// Thème prédéfini (ou créé par l'utilisateur).
class ThemeSpec {
  final String id;
  final String name; // nom affiché (les thèmes prédéfinis ont un nom fixe)
  final Brightness brightness;
  final Color bg;
  final Color accent;
  final Color? text;
  final bool custom;

  const ThemeSpec({
    required this.id,
    required this.name,
    required this.brightness,
    required this.bg,
    required this.accent,
    this.text,
    this.custom = false,
  });

  LyraColors get colors => colorsFromSeed(brightness: brightness, bg: bg, accent: accent, text: text);

  ThemeSpec copyWith({String? name, Brightness? brightness, Color? bg, Color? accent, Color? Function()? text}) =>
      ThemeSpec(
        id: id,
        name: name ?? this.name,
        brightness: brightness ?? this.brightness,
        bg: bg ?? this.bg,
        accent: accent ?? this.accent,
        text: text != null ? text() : this.text,
        custom: custom,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'dark': brightness == Brightness.dark,
    'bg': bg.toARGB32(),
    'accent': accent.toARGB32(),
    'text': text?.toARGB32(),
  };

  factory ThemeSpec.fromJson(Map<String, Object?> j) => ThemeSpec(
    id: j['id'] as String,
    name: j['name'] as String,
    brightness: j['dark'] == true ? Brightness.dark : Brightness.light,
    bg: Color(j['bg'] as int),
    accent: Color(j['accent'] as int),
    text: j['text'] == null ? null : Color(j['text'] as int),
    custom: true,
  );

  static String encodeList(List<ThemeSpec> list) => jsonEncode([for (final t in list) t.toJson()]);

  static List<ThemeSpec> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return [for (final j in jsonDecode(raw) as List) ThemeSpec.fromJson((j as Map).cast<String, Object?>())];
    } catch (_) {
      return [];
    }
  }
}

/// Collection de thèmes LyraMusic : chacun a une ambiance musicale.
const presetThemes = <ThemeSpec>[
  ThemeSpec(
    id: 'midnight',
    name: 'Minuit',
    brightness: Brightness.dark,
    bg: Color(0xFF0D1322),
    accent: Color(0xFFE8C468),
    text: Color(0xFFEEF1F7),
  ),
  ThemeSpec(
    id: 'oled',
    name: 'Noir absolu',
    brightness: Brightness.dark,
    bg: Color(0xFF000000),
    accent: Color(0xFFFFFFFF),
    text: Color(0xFFFFFFFF),
  ),
  ThemeSpec(
    id: 'studio',
    name: 'Studio',
    brightness: Brightness.dark,
    bg: Color(0xFF15171A),
    accent: Color(0xFF3DDC97),
    text: Color(0xFFE9ECEF),
  ),
  ThemeSpec(
    id: 'sunset',
    name: 'Golden hour',
    brightness: Brightness.dark,
    bg: Color(0xFF1E1220),
    accent: Color(0xFFFF7A59),
    text: Color(0xFFFCEDE7),
  ),
  ThemeSpec(
    id: 'synthwave',
    name: 'Synthwave',
    brightness: Brightness.dark,
    bg: Color(0xFF130E2B),
    accent: Color(0xFFFF4FD8),
    text: Color(0xFFF2E9FF),
  ),
  ThemeSpec(
    id: 'abyss',
    name: 'Abysses',
    brightness: Brightness.dark,
    bg: Color(0xFF061C24),
    accent: Color(0xFF4FD1C5),
    text: Color(0xFFE3F4F4),
  ),
  ThemeSpec(
    id: 'lofi',
    name: 'Lo-fi',
    brightness: Brightness.light,
    bg: Color(0xFFE9E4D4),
    accent: Color(0xFF66785A),
    text: Color(0xFF2B2A26),
  ),
  ThemeSpec(
    id: 'sakura',
    name: 'Sakura',
    brightness: Brightness.light,
    bg: Color(0xFFFBEFF1),
    accent: Color(0xFFD9577B),
    text: Color(0xFF2A1B20),
  ),
  ThemeSpec(
    id: 'nordic',
    name: 'Nordique',
    brightness: Brightness.light,
    bg: Color(0xFFECEFF4),
    accent: Color(0xFF5E81AC),
    text: Color(0xFF2E3440),
  ),
];

/// Thème « Pochette » : couleurs tirées de la pochette en cours de lecture.
LyraColors dynamicColors(Color seed, Brightness brightness) {
  final hsl = HSLColor.fromColor(seed);
  if (brightness == Brightness.dark) {
    return colorsFromSeed(
      brightness: brightness,
      bg: hsl.withSaturation((hsl.saturation * 0.45).clamp(0, 0.4)).withLightness(0.08).toColor(),
      accent: hsl.withSaturation((hsl.saturation * 1.1).clamp(0.35, 0.85)).withLightness(0.68).toColor(),
    );
  }
  return colorsFromSeed(
    brightness: brightness,
    bg: hsl.withSaturation((hsl.saturation * 0.4).clamp(0, 0.35)).withLightness(0.93).toColor(),
    accent: hsl.withSaturation((hsl.saturation * 1.1).clamp(0.35, 0.8)).withLightness(0.38).toColor(),
  );
}
