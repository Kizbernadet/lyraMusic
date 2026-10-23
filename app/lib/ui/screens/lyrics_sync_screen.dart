import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../audio/handler.dart';
import '../../data/lyrics.dart';
import '../../data/media_store.dart';
import '../../data/onset.dart';
import '../../models/track.dart';
import '../../state/library.dart';
import '../../state/lyrics_store.dart';
import '../../state/settings.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// Studio de synchronisation (façon Musixmatch) :
/// 1. on écoute le morceau et on touche le grand bouton au début de chaque ligne ;
/// 2. on vérifie et on ajuste chaque ligne au vingtième de seconde ;
/// 3. on enregistre (sur le téléphone).
/// Pour la précision : le temps est pris quand le doigt se pose (pas quand il
/// se lève), le morceau peut être ralenti (les temps restent ceux du morceau)
/// et un temps de réaction réglable est retiré de chaque appui.
/// En vérification, la forme d'onde autour de la ligne montre où la voix
/// commence, et « Aimanter » cale la ligne sur cette attaque.
/// Les pauses (ligne vide horodatée) marquent la fin d'une ligne avant un
/// passage instrumental.
class LyricsSyncScreen extends StatefulWidget {
  final int trackId;

  /// Lignes à synchroniser. Vide : on reprend les paroles existantes.
  final List<String> lines;
  const LyricsSyncScreen({super.key, required this.trackId, this.lines = const []});

  @override
  State<LyricsSyncScreen> createState() => _LyricsSyncScreenState();
}

class _LyricsSyncScreenState extends State<LyricsSyncScreen> {
  late final Track _track = context.read<LibraryController>().byId(widget.trackId)!;
  List<String> _lines = []; // '' = pause
  List<Duration?> _times = [];
  int _cursor = 0; // prochaine ligne à horodater
  bool _review = false;
  int? _selected; // ligne sélectionnée en mode vérification
  bool _ready = false;
  final List<GlobalKey> _keys = [];

  /// Vitesse pendant la synchro ; celle du lecteur est rétablie en sortant.
  double _speed = 1.0;
  late final LyraAudioHandler _audio;

  /// Volume du morceau toutes les 10 ms (forme d'onde, aimantation). null : en cours.
  Uint8List? _envelope;
  bool _envelopeFailed = false;

  static const _speeds = [1.0, 0.75, 0.5];
  static const _latencies = [0, 100, 150, 200, 300];

  @override
  void initState() {
    super.initState();
    _audio = context.audio;
    _prepare();
    _loadEnvelope();
  }

  @override
  void dispose() {
    if (_speed != 1.0) _audio.player.setSpeed(_audio.speed.value);
    super.dispose();
  }

  Future<void> _loadEnvelope() async {
    try {
      final env = await MediaStoreBridge.audioEnvelope(_track.path);
      if (!mounted) return;
      setState(() {
        if (env.isEmpty) {
          _envelopeFailed = true;
        } else {
          _envelope = env;
        }
      });
    } catch (e) {
      debugPrint('Envelope failed: $e');
      if (mounted) setState(() => _envelopeFailed = true);
    }
  }

  Future<void> _prepare() async {
    final store = context.read<LyricsStore>();
    var lines = widget.lines;
    List<Duration?> times;
    if (lines.isEmpty) {
      final existing = await store.lyricsFor(_track);
      final synced = existing?.synced ?? false;
      // Lignes vides : ignorées, sauf les pauses des paroles déjà synchronisées.
      final ls = existing?.lines.where((e) => e.text.trim().isNotEmpty || (synced && e.time != null)).toList() ?? [];
      // Pas de pause en tête ni deux pauses de suite.
      final kept = <LyricLine>[];
      for (final e in ls) {
        final isBreak = e.text.trim().isEmpty;
        if (isBreak && (kept.isEmpty || kept.last.text.trim().isEmpty)) continue;
        kept.add(e);
      }
      lines = [for (final e in kept) e.text.trim().isEmpty ? '' : e.text];
      times = [for (final e in kept) synced ? e.time : null];
    } else {
      times = List.filled(lines.length, null);
    }
    // Déjà synchronisées : on ouvre directement la vérification.
    final allTimed = times.isNotEmpty && times.every((t) => t != null);
    if (!mounted) return;
    setState(() {
      _lines = List.of(lines);
      _times = List.of(times);
      _keys.addAll(List.generate(lines.length, (_) => GlobalKey()));
      _review = allTimed;
      _ready = true;
    });
    // Le morceau à synchroniser doit être celui qui joue.
    final audio = context.audio;
    if (audio.current?.id != _track.id) {
      await audio.playTracks([_track], 0, shuffled: false);
      if (!allTimed) await audio.pause();
    }
    if (!allTimed) await audio.seek(Duration.zero);
  }

  bool _isBreak(int i) => _lines[i].isEmpty;

  Duration get _position => context.audio.player.position;

  /// Position de lecture au moment d'un appui, moins le temps de réaction.
  /// Au ralenti, le morceau avance moins pendant ce temps : on en tient compte.
  Duration get _tapPosition {
    final latency = context.read<SettingsController>().syncLatencyMs * _speed;
    final at = _position - Duration(milliseconds: latency.round());
    return at.isNegative ? Duration.zero : at;
  }

  void _haptic() => HapticFeedback.mediumImpact();

  /// Temps d'un appui, jamais avant la ligne précédente.
  Duration _stamp(bool playing) {
    final previous = _cursor > 0 ? _times[_cursor - 1] : null;
    final at = playing ? _tapPosition : _position;
    return previous != null && at < previous ? previous : at;
  }

  void _tap() {
    if (_cursor >= _lines.length) return;
    _haptic();
    final audio = context.audio;
    final playing = audio.playing.value;
    if (!playing) audio.play();
    setState(() {
      _times[_cursor] = _stamp(playing);
      _cursor++;
      if (_cursor >= _lines.length) _review = true;
    });
    _scrollTo(_cursor.clamp(0, _lines.length - 1));
  }

  /// Fin de la ligne qui vient d'être chantée : une pause est insérée avant la suivante.
  void _markBreak() {
    if (_cursor == 0 || _isBreak(_cursor - 1) || !context.audio.playing.value) return;
    HapticFeedback.lightImpact();
    setState(() {
      final at = _stamp(true);
      _lines.insert(_cursor, '');
      _times.insert(_cursor, at);
      _keys.insert(_cursor, GlobalKey());
      _cursor++;
    });
  }

  void _removeAt(int i) {
    setState(() {
      _lines.removeAt(i);
      _times.removeAt(i);
      _keys.removeAt(i);
      if (_cursor > i) _cursor--;
      _selected = null;
    });
  }

  void _undo() {
    if (_cursor == 0) return;
    HapticFeedback.selectionClick();
    if (_isBreak(_cursor - 1)) {
      // Une pause annulée disparaît, on ne la retape pas.
      _removeAt(_cursor - 1);
    } else {
      setState(() {
        _cursor--;
        _times[_cursor] = null;
      });
    }
    final back = _cursor > 0 ? _times[_cursor - 1]! : Duration.zero;
    context.audio.seek(back);
    _scrollTo(_cursor);
  }

  void _restart() {
    setState(() {
      // Les pauses seront remarquées pendant la nouvelle écoute.
      for (var i = _lines.length - 1; i >= 0; i--) {
        if (_isBreak(i)) {
          _lines.removeAt(i);
          _keys.removeAt(i);
        }
      }
      _times = List.filled(_lines.length, null);
      _cursor = 0;
      _review = false;
      _selected = null;
    });
    context.audio.seek(Duration.zero);
    context.audio.play();
    _scrollTo(0);
  }

  void _scrollTo(int i) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = i < _keys.length ? _keys[i].currentContext : null;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.4, duration: const Duration(milliseconds: 300));
    });
  }

  void _setTime(int index, Duration value) {
    setState(() => _times[index] = value.isNegative ? Duration.zero : value);
  }

  void _nudge(int index, int ms) {
    final t = _times[index];
    if (t == null) return;
    HapticFeedback.selectionClick();
    _setTime(index, t + Duration(milliseconds: ms));
  }

  void _shiftAll(int ms) {
    HapticFeedback.selectionClick();
    setState(() {
      _times = [
        for (final t in _times)
          if (t == null)
            null
          else
            (t + Duration(milliseconds: ms)).isNegative ? Duration.zero : t + Duration(milliseconds: ms),
      ];
    });
  }

  /// Cale la ligne sur la position de lecture actuelle (en écoutant).
  void _setHere(int index) {
    HapticFeedback.mediumImpact();
    _setTime(index, _tapPosition);
  }

  /// Cale une ligne (ou toutes) sur l'attaque la plus proche. Les pauses ne bougent pas.
  void _snap(int? index) {
    final env = _envelope;
    if (env == null) return;
    var moved = 0;
    final indexes = index == null ? List.generate(_lines.length, (i) => i) : [index];
    setState(() {
      for (final i in indexes) {
        final t = _times[i];
        if (t == null || _isBreak(i)) continue;
        final snapped = snapToOnset(env, t);
        if (snapped != null && snapped != t) {
          _times[i] = snapped;
          moved++;
        }
      }
    });
    HapticFeedback.mediumImpact();
    context.toast(context.l.syncSnapped(moved), icon: Icons.graphic_eq_rounded);
    if (index != null && moved > 0) _listen(index);
  }

  Future<void> _setSpeed(double value) async {
    setState(() => _speed = value);
    await context.audio.player.setSpeed(value);
  }

  void _cycleSpeed() => _setSpeed(_speeds[(_speeds.indexOf(_speed) + 1) % _speeds.length]);

  String _speedLabel(double v) => '${NumberFormat('0.##', Localizations.localeOf(context).toString()).format(v)}×';

  void _settingsSheet() {
    final l = context.l;
    showLyraSheet(
      context,
      title: l.syncSettings,
      builder: (sheet) {
        final settings = sheet.watch<SettingsController>();
        return StatefulBuilder(
          builder: (sheet, setSheet) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.syncSpeed.toUpperCase(), style: sheet.t.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final v in _speeds)
                      LyraChip(
                        label: _speedLabel(v),
                        active: _speed == v,
                        onTap: () async {
                          await _setSpeed(v);
                          setSheet(() {});
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l.syncSpeedHint, style: sheet.t.meta),
                const SizedBox(height: 18),
                Text(l.syncLatency.toUpperCase(), style: sheet.t.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final ms in _latencies)
                      LyraChip(
                        label: '$ms ms',
                        active: settings.syncLatencyMs == ms,
                        onTap: () => settings.setSyncLatencyMs(ms),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l.syncLatencyHint, style: sheet.t.meta),
              ],
            ),
          ),
        );
      },
    );
  }

  void _listen(int index) {
    final t = _times[index];
    if (t == null) return;
    final from = t - const Duration(milliseconds: 1500);
    context.audio.seek(from.isNegative ? Duration.zero : from);
    context.audio.play();
  }

  Future<void> _save() async {
    final l = context.l;
    // On complète les lignes non horodatées et on garde l'ordre chronologique.
    var last = Duration.zero;
    final lines = <LyricLine>[];
    for (var i = 0; i < _lines.length; i++) {
      final t = _times[i] ?? last;
      last = t < last ? last : t;
      // Une pause sans temps ne sert à rien.
      if (_isBreak(i) && _times[i] == null) continue;
      lines.add(LyricLine(last, _lines[i]));
    }
    await context.read<LyricsStore>().save(_track.id, toLrc(lines), synced: true);
    if (!mounted) return;
    context.toast(l.syncSaved, icon: Icons.lyrics_rounded);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final audio = context.audio;
    if (!_ready) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: c.primary)),
      );
    }
    final done = _times.where((t) => t != null).length;

    return Scaffold(
      appBar: LyraAppBar(
        title: _review ? l.syncReview : l.syncTitle,
        subtitle: _track.title,
        backIcon: Icons.close_rounded,
        actions: [
          LyraIconButton(icon: Icons.tune_rounded, color: c.text, tooltip: l.syncSettings, onPressed: _settingsSheet),
          LyraButton(label: l.save, small: true, onPressed: done == 0 ? null : _save),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Progression du morceau
          StreamBuilder<Duration>(
            stream: audio.player.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final total = _track.duration.inMilliseconds;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Text(formatDuration(pos), style: context.t.tech),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: total > 0 ? (pos.inMilliseconds / total).clamp(0.0, 1.0) : 0,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(4),
                        color: c.primary,
                        backgroundColor: c.dividerStrong,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(l.syncProgress(done, _lines.length), style: context.t.tech),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(_review ? l.syncReviewHint : l.syncHint, style: context.t.meta),
          ),
          Expanded(
            child: StreamBuilder<Duration>(
              // En vérification, la ligne entendue s'allume : on voit tout de suite
              // si elle arrive trop tôt ou trop tard.
              stream: _review ? audio.player.positionStream : const Stream.empty(),
              builder: (context, snap) {
                final pos = snap.data;
                var live = -1;
                if (_review && pos != null && audio.playing.value) {
                  for (var i = 0; i < _times.length; i++) {
                    final t = _times[i];
                    if (t != null && t <= pos) live = i;
                  }
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  itemCount: _lines.length,
                  itemBuilder: (context, i) {
                    final t = _times[i];
                    final isNext = (!_review && i == _cursor) || i == live;
                    final selected = _review && i == _selected;
                    final pause = _isBreak(i);
                    return Padding(
                      key: _keys[i],
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Material(
                        color: selected ? c.primarySoft : (isNext ? c.surface : Colors.transparent),
                        borderRadius: BorderRadius.circular(radiusS),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(radiusS),
                          onTap: _review
                              ? () {
                                  setState(() => _selected = i);
                                  _listen(i);
                                }
                              : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: pause ? 4 : 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 62,
                                  child: Text(
                                    t == null ? '--:--' : _fmt(t),
                                    style: context.t.tech.copyWith(color: t == null ? c.text3 : c.primary),
                                  ),
                                ),
                                Expanded(
                                  child: pause
                                      ? Text(
                                          '♪  ${l.syncBreakLine}',
                                          style: context.t.meta.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: isNext ? c.text : c.text3,
                                          ),
                                        )
                                      : AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontFamily: LyraText.heading,
                                            fontSize: isNext ? 21 : 17,
                                            height: 1.3,
                                            fontWeight: isNext ? FontWeight.w900 : FontWeight.w700,
                                            color: isNext ? c.text : (t != null ? c.text2 : c.text3),
                                          ),
                                          child: Text(_lines[i]),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _review ? _reviewBar(context) : _tapBar(context),
            ),
          ),
        ],
      ),
    );
  }

  /// « −0,5 », « +0,05 »… (secondes, virgule décimale de la langue).
  String _nudgeLabel(int ms) {
    final f = NumberFormat('0.0#', Localizations.localeOf(context).toString());
    return '${ms < 0 ? '−' : '+'}${f.format(ms.abs() / 1000)}';
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inMilliseconds % 60000) / 1000;
    return '$m:${s.toStringAsFixed(1).padLeft(4, '0')}';
  }

  /// Bouton qui réagit dès que le doigt se pose (un « tap » n'est reconnu
  /// qu'au lever du doigt, soit 80 à 150 ms plus tard).
  Widget _instantButton({required String label, required VoidCallback onDown, required Widget child}) => Semantics(
    button: true,
    label: label,
    onTap: onDown,
    excludeSemantics: true,
    child: Listener(
      onPointerDown: (_) => onDown(),
      child: Press(onTap: () {}, scale: 0.96, child: child),
    ),
  );

  /// Barre d'enregistrement : grand bouton « ligne suivante » et bouton « pause ».
  Widget _tapBar(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final audio = context.audio;
    return Container(
      key: const ValueKey('tap'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              LyraIconButton(icon: Icons.undo_rounded, tooltip: l.syncUndo, onPressed: _cursor == 0 ? null : _undo),
              LyraIconButton(
                icon: Icons.replay_5_rounded,
                tooltip: l.back5,
                onPressed: () {
                  final p = audio.player.position - const Duration(seconds: 5);
                  audio.seek(p.isNegative ? Duration.zero : p);
                },
              ),
              ValueListenableBuilder(
                valueListenable: audio.playing,
                builder: (_, playing, _) => LyraIconButton(
                  icon: playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  size: 40,
                  box: 52,
                  color: c.primary,
                  tooltip: playing ? l.pause : l.play,
                  onPressed: playing ? audio.pause : audio.play,
                ),
              ),
              LyraIconButton(icon: Icons.restart_alt_rounded, tooltip: l.syncRestart, onPressed: _restart),
              LyraChip(
                label: _speedLabel(_speed),
                icon: Icons.speed_rounded,
                active: _speed != 1.0,
                onTap: _cycleSpeed,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Grand bouton : presque toute la largeur, facile à toucher en rythme.
              Expanded(
                child: _instantButton(
                  label: l.syncTap,
                  onDown: _tap,
                  child: Container(
                    height: 84,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(radiusL)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l.syncTap.toUpperCase(),
                          style: context.t.label.copyWith(color: c.onPrimary.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cursor < _lines.length ? _lines[_cursor] : '✓',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.t.h3.copyWith(color: c.onPrimary, fontSize: 18),
                        ),
                        // Ligne d'après : on la voit venir pour anticiper.
                        if (_cursor + 1 < _lines.length)
                          Text(
                            _lines[_cursor + 1],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.t.meta.copyWith(color: c.onPrimary.withValues(alpha: 0.6)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Pause : la ligne précédente est terminée (passage instrumental).
              Tooltip(
                message: l.syncBreakHint,
                child: _instantButton(
                  label: l.syncBreakHint,
                  onDown: _markBreak,
                  child: Container(
                    width: 72,
                    height: 84,
                    decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(radiusL)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note_rounded, color: c.text2),
                        const SizedBox(height: 4),
                        Text(
                          l.syncBreak,
                          style: context.t.meta.copyWith(color: c.text2, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Barre de vérification : forme d'onde et ajustement de la ligne choisie, décalage global.
  Widget _reviewBar(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final sel = _selected;
    final selTime = sel == null ? null : _times[sel];
    Widget nudge(String label, int ms, VoidCallback onTap) => Expanded(
      child: LyraButton(label: label, small: true, variant: BtnVariant.tonal, onPressed: onTap),
    );
    return Container(
      key: const ValueKey('review'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (sel == null ? l.syncShiftAll : l.syncAdjustLine(sel + 1)).toUpperCase(),
                  style: context.t.label,
                ),
              ),
              if (sel != null && _isBreak(sel))
                LyraButton(
                  label: l.syncRemoveBreak,
                  icon: Icons.close_rounded,
                  small: true,
                  variant: BtnVariant.ghost,
                  onPressed: () => _removeAt(sel),
                )
              else if (_envelope != null)
                LyraButton(
                  label: sel == null ? l.syncSnapAll : l.syncSnap,
                  icon: Icons.graphic_eq_rounded,
                  small: true,
                  variant: BtnVariant.ghost,
                  onPressed: () => _snap(sel),
                ),
            ],
          ),
          if (sel != null && selTime != null) ...[
            const SizedBox(height: 6),
            if (_envelope != null)
              _Waveform(
                envelope: _envelope!,
                time: selTime,
                others: [
                  for (var i = 0; i < _times.length; i++)
                    if (i != sel) ?_times[i],
                ],
                position: context.audio.player.positionStream,
                onChanged: (t) => _setTime(sel, t),
              )
            else
              SizedBox(
                height: 24,
                child: Text(_envelopeFailed ? '' : l.syncWaveLoading, style: context.t.meta.copyWith(color: c.text3)),
              ),
            if (_envelope != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l.syncWaveHint, style: context.t.meta.copyWith(fontSize: 11, color: c.text3)),
              ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              for (final ms in const [-500, -100, -50, 50, 100, 500]) ...[
                if (ms != -500) const SizedBox(width: 4),
                nudge(_nudgeLabel(ms), ms, () => sel == null ? _shiftAll(ms) : _nudge(sel, ms)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LyraButton(
                  label: l.syncRestart,
                  icon: Icons.restart_alt_rounded,
                  small: true,
                  variant: BtnVariant.secondary,
                  full: true,
                  onPressed: _restart,
                ),
              ),
              const SizedBox(width: 8),
              if (sel != null) ...[
                Expanded(
                  child: LyraButton(
                    label: l.syncSetHere,
                    icon: Icons.my_location_rounded,
                    small: true,
                    variant: BtnVariant.secondary,
                    full: true,
                    onPressed: () => _setHere(sel),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: LyraButton(
                  label: sel == null ? l.syncPlayAll : l.syncListen,
                  icon: Icons.play_arrow_rounded,
                  small: true,
                  variant: BtnVariant.secondary,
                  full: true,
                  onPressed: () {
                    if (sel != null) {
                      _listen(sel);
                    } else {
                      context.audio.seek(Duration.zero);
                      context.audio.play();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Forme d'onde sur 4 s autour d'une ligne : le trait de couleur est le début
/// de la ligne, les traits fins les autres lignes, le trait clair la lecture.
/// Glisser déplace la ligne (la vue reste fixe pendant le geste) ; toucher la
/// place à l'endroit touché.
class _Waveform extends StatefulWidget {
  final Uint8List envelope;
  final Duration time;
  final List<Duration> others;
  final Stream<Duration> position;
  final ValueChanged<Duration> onChanged;

  const _Waveform({
    required this.envelope,
    required this.time,
    required this.others,
    required this.position,
    required this.onChanged,
  });

  @override
  State<_Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<_Waveform> {
  static const _spanMs = 4000;

  /// Centre de la vue pendant un glissement.
  Duration? _anchor;
  Duration _dragStart = Duration.zero;
  double _dragDx = 0;

  Duration get _center => _anchor ?? widget.time;

  Duration _timeAt(double x, double width) => _center + Duration(milliseconds: ((x / width - 0.5) * _spanMs).round());

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            HapticFeedback.selectionClick();
            widget.onChanged(_timeAt(d.localPosition.dx, width));
          },
          onHorizontalDragStart: (_) => setState(() {
            _anchor = widget.time;
            _dragStart = widget.time;
            _dragDx = 0;
          }),
          onHorizontalDragUpdate: (d) {
            _dragDx += d.delta.dx;
            widget.onChanged(_dragStart + Duration(milliseconds: (_dragDx / width * _spanMs).round()));
          },
          onHorizontalDragEnd: (_) => setState(() => _anchor = null),
          onHorizontalDragCancel: () => setState(() => _anchor = null),
          child: StreamBuilder<Duration>(
            stream: widget.position,
            builder: (context, snap) => CustomPaint(
              size: Size(width, 64),
              painter: _WavePainter(
                envelope: widget.envelope,
                center: _center,
                spanMs: _spanMs,
                time: widget.time,
                others: widget.others,
                playhead: snap.data,
                wave: c.text3,
                marker: c.primary,
                other: c.dividerStrong,
                head: c.text,
                background: c.surface2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final Uint8List envelope;
  final Duration center;
  final int spanMs;
  final Duration time;
  final List<Duration> others;
  final Duration? playhead;
  final Color wave, marker, other, head, background;

  _WavePainter({
    required this.envelope,
    required this.center,
    required this.spanMs,
    required this.time,
    required this.others,
    required this.playhead,
    required this.wave,
    required this.marker,
    required this.other,
    required this.head,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10));
    canvas.drawRRect(rrect, Paint()..color = background);
    canvas.save();
    canvas.clipRRect(rrect);
    final startMs = center.inMilliseconds - spanMs / 2;
    double xOf(Duration d) => (d.inMilliseconds - startMs) / spanMs * size.width;

    // Barres de 3 px : volume maximal sur la tranche de temps correspondante.
    final bar = Paint()..color = wave;
    const step = 3.0;
    final mid = size.height / 2;
    for (var x = 0.0; x < size.width; x += step) {
      final from = ((startMs + x / size.width * spanMs) / envelopeFrameMs).floor();
      final to = ((startMs + (x + step) / size.width * spanMs) / envelopeFrameMs).ceil();
      var v = 0;
      for (var f = math.max(0, from); f < math.min(envelope.length, to); f++) {
        v = math.max(v, envelope[f]);
      }
      // Racine carrée : les passages calmes restent visibles.
      final h = math.max(1.0, math.sqrt(v / 255) * (size.height / 2 - 4));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(x, mid - h, x + step - 1, mid + h), const Radius.circular(1)),
        bar,
      );
    }

    final thin = Paint()
      ..color = other
      ..strokeWidth = 1.5;
    for (final o in others) {
      final x = xOf(o);
      if (x >= 0 && x <= size.width) canvas.drawLine(Offset(x, 0), Offset(x, size.height), thin);
    }
    final p = playhead;
    if (p != null) {
      final x = xOf(p);
      if (x >= 0 && x <= size.width) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          Paint()
            ..color = head.withValues(alpha: 0.7)
            ..strokeWidth = 1.5,
        );
      }
    }
    final x = xOf(time);
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = marker
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(Offset(x, 5), 4, Paint()..color = marker);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.center != center ||
      old.time != time ||
      old.playhead != playhead ||
      old.envelope != envelope ||
      old.wave != wave ||
      old.others != others;
}
