import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/collections.dart';
import '../../state/library.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/track_tile.dart';
import 'tag_editor_screen.dart';

/// Fiche d'un morceau (prototype 18).
class DetailsScreen extends StatelessWidget {
  final int trackId;
  const DetailsScreen({super.key, required this.trackId});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final track = context.watch<LibraryController>().byId(trackId);
    if (track == null) return const Scaffold(appBar: LyraAppBar(title: ''));
    final fav = context.watch<CollectionsController>().isFavorite(track.id);

    void edit() => context.pushFull(TagEditorScreen(trackId: track.id));

    String? bitrate;
    final b = track.bitrate;
    if (b != null && b > 0) {
      bitrate = '${b > 10000 ? (b / 1000).round() : b} kbps';
    } else if (track.durationMs > 0) {
      bitrate = '≈ ${(track.size * 8 / track.durationMs).round()} kbps';
    }
    final format = [
      track.extension.toUpperCase(),
      ?bitrate,
      if (track.sampleRate != null) '${(track.sampleRate! / 1000).toStringAsFixed(1)} kHz',
    ].join(' · ');
    final added = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime.fromMillisecondsSinceEpoch(track.dateAdded * 1000));

    Widget tag(String label, String? value) => SettingRow(
      title: label,
      value: value ?? '—',
      trailing: value == null ? LyraBadge(l.badgeMissing, tone: Tone.warn) : const SizedBox.shrink(),
    );

    return Scaffold(
      appBar: LyraAppBar(
        title: l.songDetails,
        actions: [LyraIconButton(icon: Icons.edit_outlined, tooltip: l.editTags, onPressed: edit)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Artwork(path: track.art, size: 150, radius: 22, glow: true, seed: track.album ?? track.title),
                if (track.isIncomplete) Positioned(bottom: -10, child: LyraBadge(l.badgeIncomplete, tone: Tone.warn)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(track.title, textAlign: TextAlign.center, style: context.t.h1),
          const SizedBox(height: 2),
          Text(artistName(context, track.artist), textAlign: TextAlign.center, style: context.t.body),
          Text(
            albumName(context, track.album),
            textAlign: TextAlign.center,
            style: context.t.meta.copyWith(color: c.text3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LyraButton(
                  label: l.play,
                  icon: Icons.play_arrow_rounded,
                  full: true,
                  onPressed: () => context.audio.playTracks([track], 0, shuffled: false),
                ),
              ),
              const SizedBox(width: 8),
              LyraButton(
                variant: BtnVariant.secondary,
                icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                onPressed: () => toggleFavorite(context, track),
              ),
              const SizedBox(width: 8),
              LyraButton(
                variant: BtnVariant.secondary,
                icon: Icons.queue_music_rounded,
                onPressed: () {
                  context.audio.addToQueue([track]);
                  context.toast(l.addedToQueue);
                },
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (track.isIncomplete) ...[
            LyraBanner(
              tone: Tone.warn,
              icon: Icons.warning_amber_rounded,
              title: l.missingInfoTitle,
              text: l.missingInfoText,
              action: l.editTags,
              onAction: edit,
            ),
            const SizedBox(height: 16),
          ],
          LyraGroup(
            title: l.detailsTags,
            children: [
              tag(l.fieldTitle, track.title),
              tag(l.fieldArtist, track.artist),
              tag(l.fieldAlbum, track.album),
              if (track.albumArtist != null) tag(l.fieldAlbumArtist, track.albumArtist),
              tag(l.fieldGenre, track.genre),
              tag(l.fieldYear, track.year?.toString()),
              tag(l.fieldTrackNumber, track.trackNumber?.toString()),
            ],
          ),
          const SizedBox(height: 16),
          LyraGroup(
            title: l.detailsFile,
            children: [
              SettingRow(icon: Icons.folder_outlined, title: l.detailsLocation, value: track.path, mono: true),
              SettingRow(icon: Icons.graphic_eq_rounded, title: l.detailsFormat, value: format),
              SettingRow(icon: Icons.schedule_rounded, title: l.detailsDuration, value: formatDuration(track.duration)),
              SettingRow(
                icon: Icons.info_outline_rounded,
                title: l.detailsSize,
                value: '${formatBytes(track.size)} · $added',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LyraButton(
                  label: l.editTags,
                  icon: Icons.edit_outlined,
                  small: true,
                  full: true,
                  variant: BtnVariant.secondary,
                  onPressed: edit,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LyraButton(
                  label: l.chooseArtwork,
                  icon: Icons.image_outlined,
                  small: true,
                  full: true,
                  variant: BtnVariant.secondary,
                  onPressed: edit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
