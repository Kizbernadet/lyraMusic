import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// Égaliseur (effets audio Android) : bandes de fréquence, préréglages, basses.
class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  late final _audio = context.audio;
  late final Future<AndroidEqualizerParameters> _params = _audio.equalizer.parameters.timeout(
    const Duration(seconds: 3),
  );
  late bool _on = _audio.equalizerOn;
  late double _boost = _audio.bassBoost;

  // Préréglages (gain relatif en dB par bande, de la plus grave à la plus aiguë).
  static const _presets = <String, List<double>>{
    'flat': [0, 0, 0, 0, 0],
    'bass': [5, 3, 0, 0, 1],
    'rock': [4, 2, -1, 2, 4],
    'pop': [-1, 2, 4, 2, -1],
    'vocal': [-2, 0, 3, 3, 1],
    'electronic': [4, 2, 0, 2, 3],
    'classical': [3, 1, -1, 1, 3],
  };

  Future<void> _applyPreset(AndroidEqualizerParameters p, List<double> gains) async {
    if (!_on) await _toggle(true);
    for (var i = 0; i < p.bands.length; i++) {
      final g = i < gains.length ? gains[i] : 0.0;
      await _audio.setBandGain(i, g.clamp(p.minDecibels, p.maxDecibels));
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggle(bool v) async {
    await _audio.setEqualizerEnabled(v);
    setState(() => _on = v);
  }

  String _hz(double f) => f >= 1000 ? '${(f / 1000).toStringAsFixed(f >= 10000 ? 0 : 1)}k' : f.round().toString();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final names = {
      'flat': l.eqFlat,
      'bass': l.eqBass,
      'rock': 'Rock',
      'pop': 'Pop',
      'vocal': l.eqVocal,
      'electronic': l.eqElectronic,
      'classical': l.eqClassical,
    };
    return Scaffold(
      appBar: LyraAppBar(
        title: l.equalizer,
        subtitle: l.audio,
        actions: [
          Switch(value: _on, onChanged: _toggle),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<AndroidEqualizerParameters>(
        future: _params,
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: LyraEmptyState(icon: Icons.equalizer_rounded, title: l.equalizer, text: l.eqUnavailable),
            );
          }
          final p = snap.data;
          if (p == null) return Center(child: CircularProgressIndicator(color: c.primary));
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final e in _presets.entries) ...[
                      LyraChip(label: names[e.key]!, onTap: () => _applyPreset(p, e.value)),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _on ? 1 : 0.4,
                child: LyraCard(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                  child: SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        for (final band in p.bands)
                          Expanded(
                            child: StreamBuilder<double>(
                              stream: band.gainStream,
                              builder: (context, g) {
                                final gain = g.data ?? band.gain;
                                return Column(
                                  children: [
                                    Text('${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}', style: context.t.tech),
                                    Expanded(
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: Slider(
                                          value: gain.clamp(p.minDecibels, p.maxDecibels),
                                          min: p.minDecibels,
                                          max: p.maxDecibels,
                                          onChanged: _on ? (v) => _audio.setBandGain(band.index, v) : null,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _hz(band.centerFrequency),
                                      style: context.t.meta.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LyraGroup(
                title: l.bassBoost,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.speaker_rounded, color: c.text2),
                        Expanded(
                          child: Slider(
                            value: _boost,
                            max: 10,
                            divisions: 20,
                            onChanged: (v) => setState(() => _boost = v),
                            onChangeEnd: _audio.setBassBoost,
                          ),
                        ),
                        SizedBox(width: 52, child: Text('+${_boost.toStringAsFixed(1)} dB', style: context.t.tech)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(l.eqHint, style: context.t.meta.copyWith(color: c.text3)),
            ],
          );
        },
      ),
    );
  }
}
