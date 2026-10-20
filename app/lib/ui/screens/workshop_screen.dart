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
import 'lyrics_card_screen.dart';
import 'lyrics_editor_screen.dart';
import 'lyrics_sync_screen.dart';
import 'tag_editor_screen.dart';
import 'workshop_guide.dart';

/// Atelier : les morceaux à compléter, pour les passionnés.
/// Sans paroles · À synchroniser · Synchronisées · Infos manquantes.
/// Toutes les contributions restent sur le téléphone.
/// Onglet de la barre de navigation ; l'onglet interne est dans [ShellNav.workshopTab].
class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  late final ValueNotifier<int> _tabs = context.shell.workshopTab;
  int get _tab => _tabs.value;
  set _tab(int i) => _tabs.value = i;

  void _onTab() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTab);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTab);
    // Première visite : le parcours explicatif s'ouvre tout seul.
    final settings = context.settings;
    if (!settings.workshopGuideSeen) {
      settings.setWorkshopGuideSeen();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openGuide();
      });
    }
  }

  void _openGuide() => context.pushFull(const WorkshopGuide());

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
      // Tout défile ensemble : en paysage, un en-tête figé ne laisserait plus de place à la liste.
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Les trois outils de l'Atelier, qui apparaissent en cascade.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                  child: Row(
                    children: [
                      for (final (i, (icon, label, onTap)) in [
                        (Icons.edit_note_rounded, l.wsAddLyrics, () => setState(() => _tab = 0)),
                        (Icons.timer_outlined, l.wsSyncSongs, () => setState(() => _tab = 1)),
                        (Icons.style_rounded, l.lcCreateShort, () => context.pushFull(const LyricsCardScreen())),
                      ].indexed) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _HubTile(order: i, icon: icon, label: label, highlight: i == 2, onTap: onTap),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _openGuide,
                      icon: Icon(Icons.play_circle_outline_rounded, size: 19, color: c.primary),
                      label: Text(l.guideLink, style: context.t.title.copyWith(color: c.primary, fontSize: 13.5)),
                    ),
                  ),
                ),
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
              ],
            ),
          ),
          if (list.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: LyraEmptyState(icon: Icons.check_circle_outline_rounded, title: l.wsAllDone, text: emptyText),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 6, bottom: 24),
              sliver: SliverList.builder(
                key: ValueKey('l$_tab'),
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
        ],
      ),
    );
  }
}

/// Tuile d'action de l'Atelier : entrée décalée selon [order], léger rebond.
class _HubTile extends StatelessWidget {
  final int order;
  final IconData icon;
  final String label;
  final bool highlight;
  final VoidCallback onTap;
  const _HubTile({
    required this.order,
    required this.icon,
    required this.label,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = highlight ? c.onPrimary : c.text;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + order * 140),
      curve: Interval(order * 0.2, 1, curve: Curves.easeOutBack),
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
      ),
      child: Press(
        onTap: () {
          Haptics.tap();
          onTap();
        },
        child: Container(
          height: 92,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: highlight ? c.primary : c.surface,
            borderRadius: BorderRadius.circular(radiusL),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: fg, size: 24),
              const Spacer(),
              Text(
                label,
                maxLines: 2,
                style: context.t.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800, color: fg, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
