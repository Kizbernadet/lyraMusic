import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/collections.dart';
import '../../state/library.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/track_tile.dart';

/// Historique d'écoute (prototype 17), regroupé par période.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<(int, DateTime)>> _future = context.collections.history();

  Future<void> _clear() async {
    final l = context.l;
    final ok = await confirmAction(context, title: l.clearHistoryTitle, body: l.clearHistoryBody, confirm: l.clear);
    if (!ok || !mounted) return;
    await context.collections.clearHistory();
    setState(() => _future = context.collections.history());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lib = context.watch<LibraryController>();
    context.watch<CollectionsController>(); // se met à jour après une écoute
    return Scaffold(
      appBar: LyraAppBar(
        title: l.history,
        subtitle: l.recentlyPlayed,
        actions: [LyraIconButton(icon: Icons.delete_sweep_outlined, tooltip: l.clearHistory, onPressed: _clear)],
      ),
      body: FutureBuilder<List<(int, DateTime)>>(
        future: _future,
        builder: (context, snap) {
          final entries = [
            for (final (id, at) in snap.data ?? const <(int, DateTime)>[])
              if (lib.byId(id) != null) (lib.byId(id)!, at),
          ];
          if (snap.connectionState == ConnectionState.done && entries.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                LyraEmptyState(icon: Icons.history_rounded, title: l.historyEmptyTitle, text: l.historyEmptyBody),
              ],
            );
          }
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          String bucket(DateTime d) {
            if (!d.isBefore(today)) return l.historyToday;
            if (!d.isBefore(today.subtract(const Duration(days: 1)))) return l.historyYesterday;
            if (!d.isBefore(today.subtract(const Duration(days: 6)))) return l.historyThisWeek;
            return l.historyEarlier;
          }

          final groups = <String, List<(Track, DateTime)>>{};
          for (final e in entries) {
            groups.putIfAbsent(bucket(e.$2), () => []).add(e);
          }
          final loc = MaterialLocalizations.of(context);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              for (final g in groups.entries) ...[
                SectionHead(g.key, padding: const EdgeInsets.fromLTRB(20, 18, 20, 6)),
                for (final (t, at) in g.value)
                  TrackTile(
                    track: t,
                    onTap: () => context.audio.playTracks([
                      for (final e in g.value) e.$1,
                    ], g.value.indexWhere((e) => e.$2 == at)),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 16),
                      child: Text(
                        g.key == l.historyToday || g.key == l.historyYesterday
                            ? loc.formatTimeOfDay(TimeOfDay.fromDateTime(at), alwaysUse24HourFormat: true)
                            : loc.formatShortMonthDay(at),
                        style: context.t.tech,
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
