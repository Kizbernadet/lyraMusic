import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/library.dart';
import '../../state/lyrics_store.dart';
import '../../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/library_widgets.dart';
import '../widgets/track_tile.dart';
import 'lyrics_editor_screen.dart';
import 'lyrics_sync_screen.dart';
import 'tag_editor_screen.dart';

/// Atelier : les morceaux à compléter, pour les passionnés.
/// Sans paroles · À synchroniser · Synchronisées · Infos manquantes.
/// Toutes les contributions restent sur le téléphone.
class WorkshopScreen extends StatefulWidget {
  final int initialTab;
  const WorkshopScreen({super.key, this.initialTab = 0});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final lib = context.watch<LibraryController>();
    final store = context.watch<LyricsStore>();
    final all = lib.sorted(SongSort.title);
    final none = <Track>[], plain = <Track>[], synced = <Track>[];
    for (final t in all) {
      switch (store.status(t)) {
        case LyricsStatus.none:
          none.add(t);
        case LyricsStatus.plain:
          plain.add(t);
        case LyricsStatus.synced:
          synced.add(t);
      }
    }
    final incomplete = lib.incomplete;
    final lists = [none, plain, synced, incomplete];
    final labels = [
      '${l.wsNoLyrics} · ${none.length}',
      '${l.wsToSync} · ${plain.length}',
      '${l.wsSynced} · ${synced.length}',
      '${l.wsMissingInfo} · ${incomplete.length}',
    ];
    final list = lists[_tab];

    void open(Track t) {
      switch (_tab) {
        case 0:
          context.pushFull(LyricsEditorScreen(trackId: t.id));
        case 1:
        case 2:
          context.pushFull(LyricsSyncScreen(trackId: t.id));
        default:
          context.pushFull(TagEditorScreen(trackId: t.id));
      }
    }

    final actionLabel = [l.wsAdd, l.wsSync, l.wsEdit, l.wsComplete][_tab];
    final emptyText = [l.wsEmptyNone, l.wsEmptyPlain, l.wsEmptySynced, l.wsEmptyInfo][_tab];

    return Scaffold(
      appBar: LyraAppBar(title: l.workshop, subtitle: l.workshopSub),
      body: Column(
        children: [
          // Progression globale : part de la bibliothèque avec paroles synchronisées.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radiusL)),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: all.isEmpty ? 0 : synced.length / all.length,
                          strokeWidth: 5,
                          strokeCap: StrokeCap.round,
                          color: c.primary,
                          backgroundColor: c.dividerStrong,
                        ),
                        Text(
                          all.isEmpty ? '0%' : '${(synced.length * 100 / all.length).round()}%',
                          style: context.t.tech.copyWith(color: c.text, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.wsProgressTitle, style: context.t.title.copyWith(fontWeight: FontWeight.w700)),
                        Text(l.wsProgressBody(store.count), style: context.t.meta),
                      ],
                    ),
                  ),
                  Icon(Icons.phone_android_rounded, color: c.text3, size: 20),
                ],
              ),
            ),
          ),
          UnderlineTabs(labels: labels, index: _tab, onChanged: (i) => setState(() => _tab = i)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: list.isEmpty
                  ? ListView(
                      key: ValueKey('e$_tab'),
                      padding: const EdgeInsets.all(20),
                      children: [
                        LyraEmptyState(icon: Icons.check_circle_outline_rounded, title: l.wsAllDone, text: emptyText),
                      ],
                    )
                  : ListView.builder(
                      key: ValueKey('l$_tab'),
                      padding: const EdgeInsets.only(top: 6, bottom: 24),
                      itemCount: list.length,
                      itemBuilder: (context, i) => TrackTile(
                        track: list[i],
                        onTap: () => open(list[i]),
                        trailing: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 12),
                          child: LyraButton(
                            label: actionLabel,
                            small: true,
                            variant: _tab == 2 ? BtnVariant.tonal : BtnVariant.primary,
                            onPressed: () => open(list[i]),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
