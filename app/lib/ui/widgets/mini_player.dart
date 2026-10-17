import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/collections.dart';
import '../../state/settings.dart';
import '../screens/player_screen.dart';
import '../theme.dart';
import 'artwork.dart';
import 'common.dart';
import 'kit.dart';
import 'track_tile.dart';

/// Mini-lecteur flottant au-dessus de la barre de navigation.
/// Toucher ou glisser vers le haut : ouvre le lecteur.
/// Glisser à gauche / à droite : morceau suivant / précédent.
class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  double _dx = 0;
  double _from = 0;
  late final AnimationController _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
    ..addListener(() => setState(() => _dx = _from * (1 - Curves.easeOutCubic.transform(_back.value))));

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _end(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    final audio = context.audio;
    if (_dx < -70 || v < -700) {
      Haptics.select();
      audio.skipToNext();
    } else if (_dx > 70 || v > 700) {
      Haptics.select();
      audio.skipToPrevious();
    }
    _from = _dx;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.audio;
    final l = context.l;
    return CurrentTrackBuilder(
      builder: (context, track) {
        if (track == null) return const SizedBox.shrink();
        final c = context.c;
        final playing = audio.playing.value;
        final settings = context.watch<SettingsController>();
        final fav = context.watch<CollectionsController>().isFavorite(track.id);
        final progress = settings.on(Toggle.miniProgress);
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: GestureDetector(
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) < -200) openPlayer(context);
            },
            onHorizontalDragStart: (_) => _back.stop(),
            onHorizontalDragUpdate: (d) => setState(() => _dx = (_dx + d.delta.dx).clamp(-160.0, 160.0)),
            onHorizontalDragEnd: _end,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radiusL),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6)),
                ],
              ),
              child: Material(
                color: c.surface,
                borderRadius: BorderRadius.circular(radiusL),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => openPlayer(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                        child: Transform.translate(
                          offset: Offset(_dx, 0),
                          child: Opacity(
                            opacity: (1 - _dx.abs() / 220).clamp(0.3, 1.0),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'player-art',
                                  child: Artwork(
                                    path: track.art,
                                    size: 46,
                                    radius: 10,
                                    seed: track.album ?? track.title,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.t.title.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        artistName(context, track.artist),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.t.meta,
                                      ),
                                    ],
                                  ),
                                ),
                                if (settings.on(Toggle.miniFavorite))
                                  LyraIconButton(
                                    icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    tooltip: fav ? l.removeFromFavorites : l.addToFavorites,
                                    size: 21,
                                    box: 42,
                                    color: fav ? c.primary : c.text2,
                                    onPressed: () => toggleFavorite(context, track),
                                  ),
                                LyraIconButton(
                                  icon: playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                  tooltip: playing ? l.pause : l.play,
                                  size: 38,
                                  box: 48,
                                  color: c.primary,
                                  onPressed: playing ? audio.pause : audio.play,
                                ),
                                if (settings.on(Toggle.miniNext))
                                  LyraIconButton(
                                    icon: Icons.skip_next_rounded,
                                    tooltip: l.next,
                                    size: 28,
                                    box: 44,
                                    color: c.text,
                                    onPressed: audio.skipToNext,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (progress)
                        StreamBuilder<Duration>(
                          stream: audio.player.positionStream,
                          builder: (context, snap) {
                            final total = track.duration.inMilliseconds;
                            final pos = snap.data?.inMilliseconds ?? 0;
                            return LinearProgressIndicator(
                              value: total > 0 ? (pos / total).clamp(0.0, 1.0) : 0,
                              minHeight: 2,
                              backgroundColor: c.divider,
                              color: c.primary,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
