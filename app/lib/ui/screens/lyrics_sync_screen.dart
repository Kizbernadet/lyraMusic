import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/lyrics.dart';
import '../../models/track.dart';
import '../../state/library.dart';
import '../../state/lyrics_store.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// Studio de synchronisation (façon Musixmatch) :
/// 1. on écoute le morceau et on touche le grand bouton au début de chaque ligne ;
/// 2. on vérifie et on ajuste chaque ligne au dixième de seconde ;
/// 3. on enregistre (sur le téléphone).
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
  List<String> _lines = [];
  List<Duration?> _times = [];
  int _cursor = 0; // prochaine ligne à horodater
  bool _review = false;
  int? _selected; // ligne sélectionnée en mode vérification
  bool _ready = false;
  final List<GlobalKey> _keys = [];

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final store = context.read<LyricsStore>();
    var lines = widget.lines;
    List<Duration?> times;
    if (lines.isEmpty) {
      final existing = await store.lyricsFor(_track);
      final ls = existing?.lines.where((e) => e.text.trim().isNotEmpty).toList() ?? [];
      lines = [for (final e in ls) e.text];
      times = [for (final e in ls) existing!.synced ? e.time : null];
    } else {
      times = List.filled(lines.length, null);
    }
    // Déjà synchronisées : on ouvre directement la vérification.
    final allTimed = times.isNotEmpty && times.every((t) => t != null);
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _times = times;
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

  Duration get _position => context.audio.player.position;

  void _haptic() => HapticFeedback.mediumImpact();

  void _tap() {
    if (_cursor >= _lines.length) return;
    _haptic();
    final audio = context.audio;
    if (!audio.playing.value) audio.play();
    setState(() {
      _times[_cursor] = _position;
      _cursor++;
      if (_cursor >= _lines.length) _review = true;
    });
    _scrollTo(_cursor.clamp(0, _lines.length - 1));
  }

  void _undo() {
    if (_cursor == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _cursor--;
      _times[_cursor] = null;
    });
    final back = _cursor > 0 ? _times[_cursor - 1]! : Duration.zero;
    context.audio.seek(back);
    _scrollTo(_cursor);
  }

  void _restart() {
    setState(() {
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

  void _nudge(int index, int ms) {
    final t = _times[index];
    if (t == null) return;
    HapticFeedback.selectionClick();
    final v = t + Duration(milliseconds: ms);
    setState(() => _times[index] = v.isNegative ? Duration.zero : v);
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
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: _lines.length,
              itemBuilder: (context, i) {
                final t = _times[i];
                final isNext = !_review && i == _cursor;
                final selected = _review && i == _selected;
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              child: AnimatedDefaultTextStyle(
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

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inMilliseconds % 60000) / 1000;
    return '$m:${s.toStringAsFixed(1).padLeft(4, '0')}';
  }

  /// Barre d'enregistrement : grand bouton « ligne suivante ».
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
                tooltip: l.back10,
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
            ],
          ),
          const SizedBox(height: 10),
          // Grand bouton : toute la largeur, facile à toucher en rythme.
          Press(
            onTap: _tap,
            scale: 0.96,
            semanticLabel: l.syncTap,
            child: Container(
              height: 84,
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de vérification : ajustement de la ligne choisie, décalage global.
  Widget _reviewBar(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final sel = _selected;
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
          Text((sel == null ? l.syncShiftAll : l.syncAdjustLine(sel + 1)).toUpperCase(), style: context.t.label),
          const SizedBox(height: 8),
          Row(
            children: [
              nudge('−0,5 s', -500, () => sel == null ? _shiftAll(-500) : _nudge(sel, -500)),
              const SizedBox(width: 6),
              nudge('−0,1 s', -100, () => sel == null ? _shiftAll(-100) : _nudge(sel, -100)),
              const SizedBox(width: 6),
              nudge('+0,1 s', 100, () => sel == null ? _shiftAll(100) : _nudge(sel, 100)),
              const SizedBox(width: 6),
              nudge('+0,5 s', 500, () => sel == null ? _shiftAll(500) : _nudge(sel, 500)),
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
