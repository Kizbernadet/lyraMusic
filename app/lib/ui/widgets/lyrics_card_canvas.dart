import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../brand/logo.dart';

/// Une LyricsCard : extrait de paroles posé sur un fond, avec titre et artiste.
/// Le même widget sert à l'aperçu et à l'export : l'aperçu est fidèle au fichier.

/// Largeur logique de la carte ; l'export la multiplie (×3 → 1080 px de large).
const cardWidth = 360.0;
const cardExportScale = 3.0;

/// Limite de l'extrait (en caractères).
const cardMaxChars = 113;

enum CardRatio {
  portrait(4 / 5, '4:5'),
  square(1, '1:1'),
  story(9 / 16, '9:16');

  final double value;
  final String label;
  const CardRatio(this.value, this.label);
}

enum CardBackground { artwork, gallery, preset }

/// Polices proposées (toutes embarquées dans l'application, licence OFL).
class CardFont {
  final String id;
  final String label;
  final String family;
  final FontWeight weight;
  final double scale; // compense les différences de taille apparente
  final bool upper;
  final double spacing;
  final FontStyle style;
  const CardFont(
    this.id,
    this.label,
    this.family, {
    this.weight = FontWeight.w700,
    this.scale = 1,
    this.upper = false,
    this.spacing = 0,
    this.style = FontStyle.normal,
  });

  TextStyle textStyle(double size, Color color) => TextStyle(
    fontFamily: family,
    fontSize: size * scale,
    fontWeight: weight,
    fontStyle: style,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    letterSpacing: spacing,
    height: family == 'BebasNeue' ? 1.05 : 1.28,
    color: color,
  );
}

const cardFonts = [
  CardFont('nunito', 'Nunito', 'Nunito', weight: FontWeight.w800),
  CardFont('playfair', 'Playfair', 'PlayfairDisplay', weight: FontWeight.w600, style: FontStyle.italic),
  CardFont('bebas', 'Bebas Neue', 'BebasNeue', weight: FontWeight.w400, scale: 1.3, upper: true, spacing: 1),
  CardFont('caveat', 'Caveat', 'Caveat', weight: FontWeight.w600, scale: 1.35),
  CardFont('mono', 'Space Mono', 'SpaceMono', scale: 0.82),
  CardFont('inter', 'Inter', 'Inter', weight: FontWeight.w600, scale: 0.95),
];

enum CardPattern { none, grooves, waves, grain }

/// Fonds prédéfinis : couleurs de la charte (noir, crème, sable, sauge) et des thèmes.
class CardPreset {
  final String id;
  final List<Color> colors;
  final CardPattern pattern;
  const CardPreset(this.id, this.colors, this.pattern);

  bool get isLight => colors.map((c) => c.computeLuminance()).reduce((a, b) => a + b) / colors.length > 0.45;
}

const cardPresets = [
  CardPreset('vinyl', [Color(0xFF111111), Color(0xFF2E2A24)], CardPattern.grooves),
  CardPreset('cream', [Color(0xFFF3EBD8), Color(0xFFE8DCC6)], CardPattern.grain),
  CardPreset('sage', [Color(0xFF8E9F7E), Color(0xFF3F4A38)], CardPattern.waves),
  CardPreset('sunset', [Color(0xFFFF7A59), Color(0xFFE8C468)], CardPattern.none),
  CardPreset('synth', [Color(0xFF2B1055), Color(0xFFD9339B)], CardPattern.grooves),
  CardPreset('ocean', [Color(0xFF0F2027), Color(0xFF2C5364)], CardPattern.waves),
  CardPreset('sakura', [Color(0xFFF7D6E0), Color(0xFFD9577B)], CardPattern.none),
  CardPreset('sand', [Color(0xFFB7A78F), Color(0xFF5C4F3D)], CardPattern.grain),
];

/// Couleurs de texte proposées ; `null` = automatique selon le fond.
const cardTextColors = <Color?>[null, Colors.white, Color(0xFFF3EBD8), Color(0xFF111111), Color(0xFFFFD43B)];

class CardStyle {
  final CardRatio ratio;
  final CardBackground background;
  final String? galleryPath;
  final String preset;
  final double dim; // 0 à 0,8 : assombrit les images
  final double blur; // 0 à 20
  final String font;
  final double fontSize;
  final TextAlign align;
  final Color? textColor;
  final bool showInfo;

  const CardStyle({
    this.ratio = CardRatio.portrait,
    this.background = CardBackground.artwork,
    this.galleryPath,
    this.preset = 'vinyl',
    this.dim = 0.45,
    this.blur = 6,
    this.font = 'nunito',
    this.fontSize = 26,
    this.align = TextAlign.left,
    this.textColor,
    this.showInfo = true,
  });

  CardStyle copyWith({
    CardRatio? ratio,
    CardBackground? background,
    String? galleryPath,
    String? preset,
    double? dim,
    double? blur,
    String? font,
    double? fontSize,
    TextAlign? align,
    Color? Function()? textColor,
    bool? showInfo,
  }) => CardStyle(
    ratio: ratio ?? this.ratio,
    background: background ?? this.background,
    galleryPath: galleryPath ?? this.galleryPath,
    preset: preset ?? this.preset,
    dim: dim ?? this.dim,
    blur: blur ?? this.blur,
    font: font ?? this.font,
    fontSize: fontSize ?? this.fontSize,
    align: align ?? this.align,
    textColor: textColor != null ? textColor() : this.textColor,
    showInfo: showInfo ?? this.showInfo,
  );

  CardFont get cardFont => cardFonts.firstWhere((f) => f.id == font, orElse: () => cardFonts.first);
  CardPreset get cardPreset => cardPresets.firstWhere((p) => p.id == preset, orElse: () => cardPresets.first);
}

class LyricsCardCanvas extends StatelessWidget {
  final CardStyle style;
  final String text;
  final String title;
  final String? artist;
  final String? artPath;
  final String placeholder;

  const LyricsCardCanvas({
    super.key,
    required this.style,
    required this.text,
    required this.title,
    required this.artist,
    required this.artPath,
    this.placeholder = '',
  });

  /// Image de fond effective (null : fond prédéfini).
  String? get _image => switch (style.background) {
    CardBackground.artwork => artPath,
    CardBackground.gallery => style.galleryPath,
    CardBackground.preset => null,
  };

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final preset = style.cardPreset;
    final lightBg = image == null && preset.isLight;
    final fg = style.textColor ?? (lightBg ? const Color(0xFF111111) : Colors.white);
    final soft = fg.withValues(alpha: 0.72);
    // Guillemet : jaune sur fond sombre, encre sur fond clair.
    final quote = lightBg ? fg.withValues(alpha: 0.85) : const Color(0xFFFFD43B);
    final font = style.cardFont;
    final shown = text.trim().isEmpty ? placeholder : text.trim();
    final body = font.upper ? shown.toUpperCase() : shown;
    final height = cardWidth / style.ratio.value;

    return SizedBox(
      width: cardWidth,
      height: height,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null) ...[
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: style.blur, sigmaY: style.blur, tileMode: TileMode.clamp),
                child: Image.file(
                  File(image),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                ),
              ),
              ColoredBox(color: Colors.black.withValues(alpha: style.dim)),
            ] else
              _PresetBackground(preset: preset),
            // Léger dégradé en bas : le pied de carte reste lisible.
            if (!lightBg)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x66000000)],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 26, 30, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: switch (style.align) {
                      TextAlign.center => Alignment.topCenter,
                      TextAlign.right => Alignment.topRight,
                      _ => Alignment.topLeft,
                    },
                    child: Text(
                      '“',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 76,
                        height: 0.9,
                        fontWeight: FontWeight.w700,
                        fontVariations: const [FontVariation('wght', 700)],
                        color: quote,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: switch (style.align) {
                        TextAlign.center => Alignment.center,
                        TextAlign.right => Alignment.centerRight,
                        _ => Alignment.centerLeft,
                      },
                      // Trop long pour la taille choisie : le texte se réduit au lieu de déborder.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: cardWidth - 60,
                          child: Text(
                            body,
                            textAlign: style.align,
                            style: font
                                .textStyle(style.fontSize, text.trim().isEmpty ? fg.withValues(alpha: 0.45) : fg)
                                .copyWith(
                                  shadows: lightBg
                                      ? null
                                      : [Shadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 12)],
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (style.showInfo) ...[
                        if (artPath != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.file(File(artPath!), width: 36, height: 36, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: fg,
                                ),
                              ),
                              if (artist != null)
                                Text(
                                  artist!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: soft),
                                ),
                            ],
                          ),
                        ),
                      ] else
                        const Spacer(),
                      const SizedBox(width: 10),
                      Opacity(
                        opacity: 0.85,
                        child: LyraLogo(
                          width: 46,
                          showMusic: false,
                          ink: fg,
                          paper: lightBg ? preset.colors.first : Colors.black,
                        ),
                      ),
                    ],
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

class _PresetBackground extends StatelessWidget {
  final CardPreset preset;
  const _PresetBackground({required this.preset});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: preset.colors),
    ),
    child: CustomPaint(painter: _PatternPainter(preset)),
  );
}

/// Motifs dessinés (pas d'image à embarquer) : sillons de vinyle, vagues, grain.
class _PatternPainter extends CustomPainter {
  final CardPreset preset;
  _PatternPainter(this.preset);

  @override
  void paint(Canvas canvas, Size size) {
    final ink = preset.isLight ? Colors.black : Colors.white;
    switch (preset.pattern) {
      case CardPattern.none:
        // Halo lumineux doux.
        final paint = Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.28), Colors.transparent],
          ).createShader(Rect.fromCircle(center: Offset(size.width * 0.85, size.height * 0.1), radius: size.width));
        canvas.drawRect(Offset.zero & size, paint);
      case CardPattern.grooves:
        final center = Offset(size.width * 1.02, size.height * 0.95);
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = ink.withValues(alpha: 0.07);
        for (var r = 30.0; r < size.height * 1.4; r += 7) {
          canvas.drawCircle(center, r, paint);
        }
        canvas.drawCircle(center, 26, Paint()..color = ink.withValues(alpha: 0.08));
      case CardPattern.waves:
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = ink.withValues(alpha: 0.08);
        for (var row = 0; row < 14; row++) {
          final y0 = size.height * (0.35 + row * 0.05);
          final path = Path()..moveTo(0, y0);
          for (var x = 0.0; x <= size.width; x += 6) {
            path.lineTo(x, y0 + math.sin(x / 38 + row * 0.6) * 10);
          }
          canvas.drawPath(path, paint);
        }
      case CardPattern.grain:
        final random = math.Random(7); // grain identique entre l'aperçu et l'export
        final paint = Paint()..color = ink.withValues(alpha: 0.05);
        for (var i = 0; i < 1400; i++) {
          canvas.drawCircle(
            Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
            random.nextDouble() * 0.9 + 0.2,
            paint,
          );
        }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.preset.id != preset.id;
}
