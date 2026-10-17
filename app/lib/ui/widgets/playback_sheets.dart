import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';
import 'kit.dart';

/// Minuterie de mise en veille (comme Spotify / Oto Music).
Future<void> showSleepTimerSheet(BuildContext context) {
  final l = context.l;
  final audio = context.audio;
  return showLyraSheet(
    context,
    title: l.sleepTimer,
    builder: (sheet) {
      final c = sheet.c;
      void pick(Duration? d, {bool endOfTrack = false}) {
        Navigator.of(sheet).pop();
        audio.setSleepTimer(d, endOfTrack: endOfTrack);
        if (d == null && !endOfTrack) {
          context.toast(l.sleepTimerOff, icon: Icons.bedtime_off_outlined);
        } else {
          context.toast(endOfTrack ? l.sleepEndOfTrack : l.sleepIn(d!.inMinutes), icon: Icons.bedtime_rounded);
        }
      }

      final active = audio.sleepAt.value != null || audio.sleepAfterTrack.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: ValueListenableBuilder(
                valueListenable: audio.sleepAt,
                builder: (_, at, _) => LyraBanner(
                  icon: Icons.bedtime_rounded,
                  title: at == null
                      ? l.sleepEndOfTrack
                      : l.sleepIn(at.difference(DateTime.now()).inMinutes.clamp(0, 999) + 1),
                ),
              ),
            ),
          for (final m in const [5, 10, 15, 30, 45, 60, 90])
            SheetAction(
              icon: Icons.timer_outlined,
              label: l.minutes(m),
              onTap: () => pick(Duration(minutes: m)),
            ),
          SheetAction(
            icon: Icons.music_off_outlined,
            label: l.sleepEndOfTrack,
            onTap: () => pick(null, endOfTrack: true),
          ),
          if (active)
            SheetAction(icon: Icons.close_rounded, label: l.sleepTimerOff, color: c.error, onTap: () => pick(null)),
        ],
      );
    },
  );
}

/// Vitesse de lecture.
Future<void> showSpeedSheet(BuildContext context) {
  final l = context.l;
  final audio = context.audio;
  return showLyraSheet(
    context,
    title: l.playbackSpeed,
    builder: (sheet) => StatefulBuilder(
      builder: (sheet, setState) {
        final c = sheet.c;
        final s = audio.speed.value;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${s.toStringAsFixed(2)}×', style: sheet.t.display),
              Slider(
                value: s,
                min: 0.5,
                max: 2.0,
                divisions: 30,
                onChanged: (v) {
                  audio.setSpeed(double.parse(v.toStringAsFixed(2)));
                  setState(() {});
                },
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final v in const [0.75, 1.0, 1.25, 1.5, 2.0])
                    LyraChip(
                      label: '$v×',
                      active: (s - v).abs() < 0.01,
                      onTap: () {
                        audio.setSpeed(v);
                        setState(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l.speedHint,
                textAlign: TextAlign.center,
                style: sheet.t.meta.copyWith(color: c.text3),
              ),
            ],
          ),
        );
      },
    ),
  );
}
