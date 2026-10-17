import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'common.dart';
import 'kit.dart';

/// Nuancier : carré saturation / luminosité, barre de teinte, code hexadécimal.
Future<Color?> pickColor(BuildContext context, {required Color initial, required String title}) {
  var hsv = HSVColor.fromColor(initial);
  final hex = TextEditingController(text: _hex(initial));
  return showLyraSheet<Color>(
    context,
    title: title,
    builder: (sheet) => StatefulBuilder(
      builder: (sheet, setState) {
        final c = sheet.c;
        final color = hsv.toColor();
        void set(HSVColor v) {
          setState(() => hsv = v);
          hex.text = _hex(v.toColor());
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: _SvSquare(hsv: hsv, onChanged: set),
              ),
              const SizedBox(height: 16),
              _HueBar(hsv: hsv, onChanged: set),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.dividerStrong),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: hex,
                      style: sheet.t.title.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
                      decoration: const InputDecoration(prefixText: ''),
                      onChanged: (v) {
                        final parsed = _parse(v);
                        if (parsed != null) setState(() => hsv = HSVColor.fromColor(parsed));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Couleurs de la charte et quelques classiques
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final s in _swatches)
                    Press(
                      onTap: () => set(HSVColor.fromColor(s)),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: s,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.dividerStrong),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              LyraButton(label: sheet.l.save, full: true, onPressed: () => Navigator.of(sheet).pop(hsv.toColor())),
            ],
          ),
        );
      },
    ),
  );
}

const _swatches = [
  Color(0xFF111111),
  Color(0xFF2E2E2E),
  Color(0xFFF3EBD8),
  Color(0xFFE8DCC6),
  Color(0xFFB7A78F),
  Color(0xFF8E9F7E),
  Color(0xFFFFFFFF),
  Color(0xFFE8C468),
  Color(0xFFFF7A59),
  Color(0xFFFF4FD8),
  Color(0xFF4FD1C5),
  Color(0xFF5E81AC),
  Color(0xFF3DDC97),
  Color(0xFFD9577B),
];

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

Color? _parse(String v) {
  final h = v.replaceAll('#', '');
  if (h.length != 6) return null;
  final n = int.tryParse(h, radix: 16);
  return n == null ? null : Color(0xFF000000 | n);
}

class _SvSquare extends StatelessWidget {
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;
  const _SvSquare({required this.hsv, required this.onChanged});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      void update(Offset p) {
        final s = (p.dx / box.maxWidth).clamp(0.0, 1.0);
        final v = 1 - (p.dy / box.maxHeight).clamp(0.0, 1.0);
        onChanged(hsv.withSaturation(s).withValue(v));
      }

      return GestureDetector(
        onPanDown: (d) => update(d.localPosition),
        onPanUpdate: (d) => update(d.localPosition),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radiusM),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor()]),
                  ),
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: hsv.saturation * box.maxWidth - 12,
                top: (1 - hsv.value) * box.maxHeight - 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hsv.toColor(),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _HueBar extends StatelessWidget {
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;
  const _HueBar({required this.hsv, required this.onChanged});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      void update(Offset p) => onChanged(hsv.withHue((p.dx / box.maxWidth).clamp(0.0, 1.0) * 359.9));
      return GestureDetector(
        onPanDown: (d) => update(d.localPosition),
        onPanUpdate: (d) => update(d.localPosition),
        child: SizedBox(
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: LinearGradient(
                    colors: [
                      for (var h = 0; h <= 360; h += 60) HSVColor.fromAHSV(1, h.toDouble() % 360, 1, 1).toColor(),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: hsv.hue / 360 * box.maxWidth - 14,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor(),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
