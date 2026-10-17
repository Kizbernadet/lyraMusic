import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/library.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/track_tile.dart';
import 'details_screen.dart';

/// Morceaux dont l'artiste ou l'album manque : à compléter.
class IncompleteScreen extends StatelessWidget {
  const IncompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final tracks = context.watch<LibraryController>().incomplete;
    return Scaffold(
      appBar: LyraAppBar(title: l.incompleteTitle, subtitle: l.songsCount(tracks.length)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: LyraBanner(
              tone: Tone.warn,
              icon: Icons.warning_amber_rounded,
              title: l.missingInfoTitle,
              text: l.incompleteBannerText,
            ),
          ),
          for (final t in tracks)
            TrackTile(
              track: t,
              onTap: () => context.push(DetailsScreen(trackId: t.id)),
              trailing: Padding(
                padding: const EdgeInsets.only(left: 8, right: 14),
                child: LyraBadge(l.badgeFix, tone: Tone.warn),
              ),
            ),
        ],
      ),
    );
  }
}
