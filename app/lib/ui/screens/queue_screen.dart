import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/settings.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// File de lecture (prototype 12) : morceau en cours, puis « À suivre »
/// à réordonner par glisser-déposer.
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final audio = context.audio;
    final settings = context.watch<SettingsController>();
    return ListenableBuilder(
      listenable: Listenable.merge([audio.tracks, audio.index, audio.playing, audio.shuffle]),
      builder: (context, _) {
        final tracks = audio.tracks.value;
        final current = audio.index.value ?? -1;
        final now = audio.current;
        final upcoming = current >= 0 && current + 1 < tracks.length ? tracks.sublist(current + 1) : <Track>[];
        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                      child: Row(
                        children: [
                          LyraIconButton(
                            icon: Icons.keyboard_arrow_down_rounded,
                            size: 28,
                            color: c.text,
                            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.playingQueue.toUpperCase(), style: context.t.label),
                                Text(l.upNext, style: context.t.h2),
                              ],
                            ),
                          ),
                          if (upcoming.isNotEmpty)
                            LyraButton(
                              label: l.clear,
                              small: true,
                              variant: BtnVariant.ghost,
                              onPressed: () {
                                audio.clearUpcoming();
                                context.toast(l.queueCleared);
                              },
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          if (now != null && settings.on(Toggle.queueNowPlaying))
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: c.surface.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(radiusL),
                                  border: Border.all(color: c.divider),
                                ),
                                child: Row(
                                  children: [
                                    Artwork(path: now.art, size: 52, radius: 13, seed: now.album ?? now.title),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.nowPlaying.toUpperCase(),
                                            style: context.t.label.copyWith(color: c.primary),
                                          ),
                                          Text(
                                            now.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.t.title,
                                          ),
                                          Text(
                                            artistName(context, now.artist),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.t.meta,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (audio.playing.value)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: EqBars(color: c.primary),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l.nextUpCount(upcoming.length),
                                      style: context.t.h3.copyWith(fontSize: 16),
                                    ),
                                  ),
                                  if (upcoming.length > 1)
                                    Text(l.dragToReorder, style: context.t.meta.copyWith(color: c.text3)),
                                ],
                              ),
                            ),
                          ),
                          if (upcoming.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                                child: LyraEmptyState(
                                  icon: Icons.queue_music_rounded,
                                  title: l.queueEmpty,
                                  text: l.queueEmptyBody,
                                  action: l.openLibrary,
                                  onAction: () {
                                    Navigator.of(context).popUntil((r) => r.isFirst);
                                    context.shell.goTab(ShellNav.home, homeTab: 1);
                                  },
                                ),
                              ),
                            )
                          else
                            SliverReorderableList(
                              itemCount: upcoming.length,
                              onReorderItem: (from, to) => audio.moveInQueue(current + 1 + from, current + 1 + to),
                              itemBuilder: (context, i) {
                                final t = upcoming[i];
                                final queueIndex = current + 1 + i;
                                return ReorderableDelayedDragStartListener(
                                  key: ValueKey('q-$queueIndex-${t.id}'),
                                  index: i,
                                  child: Dismissible(
                                    key: ValueKey('d-$queueIndex-${t.id}'),
                                    direction: settings.on(Toggle.queueSwipeRemove)
                                        ? DismissDirection.endToStart
                                        : DismissDirection.none,
                                    background: Container(
                                      color: c.error.withValues(alpha: 0.85),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 24),
                                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                                    ),
                                    onDismissed: (_) => audio.removeFromQueue(queueIndex),
                                    child: _QueueRow(
                                      index: i,
                                      track: t,
                                      showArt: settings.on(Toggle.queueArtwork),
                                      showDuration: settings.on(Toggle.queueDuration),
                                      onTap: () => audio.skipToQueueItem(queueIndex),
                                      onRemove: () => audio.removeFromQueue(queueIndex),
                                    ),
                                  ),
                                );
                              },
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  LyraButton(
                                    label: l.shuffleQueue,
                                    icon: Icons.shuffle_rounded,
                                    small: true,
                                    variant: BtnVariant.secondary,
                                    onPressed: tracks.length < 2
                                        ? null
                                        : () {
                                            audio.toggleShuffle();
                                            context.toast(
                                              audio.shuffle.value ? l.shuffleOn : l.shuffleOff,
                                              icon: Icons.shuffle_rounded,
                                            );
                                          },
                                  ),
                                  LyraButton(
                                    label: l.addSongs,
                                    icon: Icons.add_rounded,
                                    small: true,
                                    variant: BtnVariant.secondary,
                                    onPressed: () {
                                      Navigator.of(context).popUntil((r) => r.isFirst);
                                      context.shell.goTab(ShellNav.home, homeTab: 1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QueueRow extends StatelessWidget {
  final int index;
  final Track track;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool showArt;
  final bool showDuration;
  const _QueueRow({
    required this.index,
    required this.track,
    required this.onTap,
    required this.onRemove,
    this.showArt = true,
    this.showDuration = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Icon(Icons.drag_indicator_rounded, size: 20, color: c.text3),
                ),
              ),
              if (showArt) ...[
                Artwork(path: track.art, size: 40, radius: 11, seed: track.album ?? track.title),
                const SizedBox(width: 12),
              ] else
                const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.title),
                    Text(
                      artistName(context, track.artist),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.t.meta,
                    ),
                  ],
                ),
              ),
              if (showDuration) Text(formatDuration(track.duration), style: context.t.tech),
              LyraIconButton(
                icon: Icons.close_rounded,
                size: 17,
                box: 40,
                color: c.text3,
                tooltip: l.removeFromQueue,
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
