import 'package:flutter/material.dart';

import '../../models/track.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/track_tile.dart';

/// Liste simple de morceaux (« Les plus écoutés »…), avec Aléatoire / Lecture.
class TrackListScreen extends StatelessWidget {
  final String title;
  final List<Track> tracks;
  const TrackListScreen({super.key, required this.title, required this.tracks});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: LyraAppBar(title: title, subtitle: l.songsCount(tracks.length)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: LyraButton(
                    label: l.shuffle,
                    icon: Icons.shuffle_rounded,
                    full: true,
                    onPressed: () => context.audio.playTracks(tracks, 0, shuffled: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LyraButton(
                    label: l.play,
                    icon: Icons.play_circle_fill_rounded,
                    full: true,
                    variant: BtnVariant.tonal,
                    onPressed: () => context.audio.playTracks(tracks, 0, shuffled: false),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < tracks.length; i++)
            TrackTile(track: tracks[i], onTap: () => context.audio.playTracks(tracks, i)),
        ],
      ),
    );
  }
}
