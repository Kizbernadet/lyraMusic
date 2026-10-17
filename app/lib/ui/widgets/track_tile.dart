import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/collections.dart';
import '../../state/library.dart';
import '../../utils/text.dart';
import '../screens/collection_screen.dart';
import '../screens/details_screen.dart';
import '../screens/lyrics_editor_screen.dart';
import '../screens/tag_editor_screen.dart';
import '../theme.dart';
import 'artwork.dart';
import 'common.dart';
import 'kit.dart';

/// Ligne « morceau » : pochette, titre, « Artiste | durée », bouton lecture
/// dans la couleur principale et menu ⋮.
class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onTap;
  final List<MenuExtra> extras;
  final Widget? trailing;
  final bool dense;
  final bool showPlay;
  final bool showDuration;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.extras = const [],
    this.trailing,
    this.dense = false,
    this.showPlay = true,
    this.showDuration = true,
    // Anciens paramètres, conservés pour compatibilité.
    int? number,
    bool showAlbum = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    return CurrentTrackBuilder(
      builder: (context, current) {
        final isCurrent = current?.id == track.id;
        final playing = isCurrent && context.audio.playing.value;
        final artSize = dense ? 44.0 : 54.0;
        final sub = [artistName(context, track.artist), if (showDuration) formatDuration(track.duration)].join('  |  ');
        return InkWell(
          onTap: onTap,
          onLongPress: () => showTrackMenu(context, track, extras: extras),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, dense ? 6 : 8, 8, dense ? 6 : 8),
            child: Row(
              children: [
                Artwork(path: track.art, size: artSize, radius: 12, seed: track.album ?? track.title),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.title.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? c.primary : c.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (track.isIncomplete) ...[
                            Icon(Icons.error_outline_rounded, size: 13, color: c.warning),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.meta),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showPlay)
                          RowPlayButton(
                            playing: playing,
                            current: isCurrent,
                            onTap: isCurrent ? (playing ? context.audio.pause : context.audio.play) : onTap,
                          ),
                        LyraIconButton(
                          icon: Icons.more_vert_rounded,
                          size: 20,
                          box: 40,
                          color: c.text2,
                          tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                          onPressed: () => showTrackMenu(context, track, extras: extras),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Petit bouton lecture rond, dans la couleur principale.
class RowPlayButton extends StatelessWidget {
  final bool playing;
  final bool current;
  final VoidCallback onTap;
  const RowPlayButton({super.key, required this.playing, required this.onTap, this.current = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    return Press(
      onTap: onTap,
      semanticLabel: playing ? l.pause : l.play,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
            child: Center(
              child: playing
                  ? EqBars(color: c.onPrimary, height: 11)
                  : Icon(Icons.play_arrow_rounded, size: 20, color: c.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuExtra {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const MenuExtra(this.icon, this.label, this.onTap, {this.danger = false});
}

/// Menu d'un morceau : en-tête (pochette, titre, ♡) puis actions.
Future<void> showTrackMenu(BuildContext context, Track track, {List<MenuExtra> extras = const []}) {
  final l = context.l;
  return showLyraSheet(
    context,
    builder: (sheet) {
      final c = sheet.c;
      void run(VoidCallback action) {
        Navigator.of(sheet).pop();
        action();
      }

      final isFav = sheet.watch<CollectionsController>().isFavorite(track.id);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 10, 16),
            child: Row(
              children: [
                Artwork(path: track.art, size: 56, radius: 12, seed: track.album ?? track.title),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sheet.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${artistName(sheet, track.artist)}  |  ${formatDuration(track.duration)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sheet.t.meta,
                      ),
                    ],
                  ),
                ),
                LyraIconButton(
                  icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? c.primary : c.text,
                  size: 24,
                  tooltip: isFav ? l.removeFromFavorites : l.addToFavorites,
                  onPressed: () => toggleFavorite(context, track),
                ),
              ],
            ),
          ),
          Divider(color: c.divider, height: 1, indent: 20, endIndent: 20),
          const SizedBox(height: 6),
          SheetAction(
            icon: Icons.playlist_play_rounded,
            label: l.playNext,
            onTap: () => run(() {
              context.audio.playNext([track]);
              context.toast(l.willPlayNext);
            }),
          ),
          SheetAction(
            icon: Icons.queue_music_rounded,
            label: l.addToQueue,
            onTap: () => run(() {
              context.audio.addToQueue([track]);
              context.toast(l.addedToQueue);
            }),
          ),
          SheetAction(
            icon: Icons.playlist_add_rounded,
            label: l.addToPlaylist,
            onTap: () => run(() => showAddToPlaylist(context, [track])),
          ),
          for (final e in extras)
            SheetAction(icon: e.icon, label: e.label, color: e.danger ? c.error : null, onTap: () => run(e.onTap)),
          SheetAction(
            icon: Icons.album_outlined,
            label: l.goToAlbum,
            onTap: () => run(() {
              final a = context.library.albumOf(track);
              if (a != null) context.push(CollectionScreen.album(a));
            }),
          ),
          SheetAction(
            icon: Icons.person_outline_rounded,
            label: l.goToArtist,
            onTap: () => run(() {
              final g = context.library.artistOf(track);
              if (g != null) context.push(CollectionScreen.artist(g));
            }),
          ),
          SheetAction(
            icon: Icons.info_outline_rounded,
            label: l.songDetails,
            onTap: () => run(() => context.push(DetailsScreen(trackId: track.id))),
          ),
          SheetAction(
            icon: Icons.lyrics_outlined,
            label: l.lyricsMenu,
            onTap: () => run(() => context.pushFull(LyricsEditorScreen(trackId: track.id))),
          ),
          SheetAction(
            icon: Icons.edit_outlined,
            label: l.editTags,
            onTap: () => run(() => context.pushFull(TagEditorScreen(trackId: track.id))),
          ),
        ],
      );
    },
  );
}

Future<void> toggleFavorite(BuildContext context, Track track) async {
  final l = context.l;
  Haptics.tap();
  final now = await context.collections.toggleFavorite(track.id);
  if (context.mounted) {
    context.toast(
      now ? l.addedToFavorites : l.removedFromFavorites,
      icon: now ? Icons.favorite_rounded : Icons.heart_broken_rounded,
    );
  }
}

/// Choix d'une playlist (ou création) pour y ajouter des morceaux.
Future<void> showAddToPlaylist(BuildContext context, List<Track> tracks) {
  final l = context.l;
  return showLyraSheet(
    context,
    title: l.addToPlaylist,
    builder: (sheet) {
      final c = sheet.c;
      final col = sheet.watch<CollectionsController>();
      final lib = sheet.watch<LibraryController>();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.add_rounded, color: c.primary),
            ),
            title: Text(l.newPlaylist, style: sheet.t.title.copyWith(fontWeight: FontWeight.w700)),
            onTap: () async {
              Navigator.of(sheet).pop();
              final name = await askPlaylistName(context);
              if (name == null || !context.mounted) return;
              await context.collections.create(name, trackIds: tracks.map((t) => t.id).toList());
              if (context.mounted) context.toast(l.addedToPlaylist(name));
            },
          ),
          for (final p in col.playlists)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Mosaic(
                arts: lib.resolve(p.trackIds).map((t) => t.art).toList(),
                size: 48,
                radius: 12,
                seed: p.name,
              ),
              title: Text(p.name, style: sheet.t.title.copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text(l.songsCount(p.trackIds.length), style: sheet.t.meta),
              onTap: () async {
                Navigator.of(sheet).pop();
                await context.collections.addTracks(p.id, tracks.map((t) => t.id).toList());
                if (context.mounted) context.toast(l.addedToPlaylist(p.name));
              },
            ),
        ],
      );
    },
  );
}

/// Boîte de dialogue « nom de la playlist ». Le bouton reste désactivé si vide (CA-22).
Future<String?> askPlaylistName(BuildContext context, {String initial = '', bool rename = false}) {
  final l = context.l;
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    useRootNavigator: true,
    builder: (dialog) => AlertDialog(
      title: Text(rename ? l.rename : l.newPlaylist),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 80,
        textCapitalization: TextCapitalization.sentences,
        style: dialog.t.title,
        decoration: InputDecoration(hintText: l.playlistName, counterText: ''),
        onSubmitted: (v) {
          if (v.trim().isNotEmpty) Navigator.of(dialog).pop(v.trim());
        },
      ),
      actions: [
        LyraButton(
          label: l.cancel,
          variant: BtnVariant.ghost,
          small: true,
          onPressed: () => Navigator.of(dialog).pop(),
        ),
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, _) => LyraButton(
            label: rename ? l.save : l.create,
            small: true,
            onPressed: value.text.trim().isEmpty ? null : () => Navigator.of(dialog).pop(value.text.trim()),
          ),
        ),
      ],
    ),
  );
}

/// Confirmation (suppression, effacement…).
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirm,
  bool danger = true,
}) async {
  final l = context.l;
  final ok = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        LyraButton(
          label: l.cancel,
          variant: BtnVariant.ghost,
          small: true,
          onPressed: () => Navigator.of(d).pop(false),
        ),
        LyraButton(
          label: confirm,
          small: true,
          variant: danger ? BtnVariant.danger : BtnVariant.primary,
          onPressed: () => Navigator.of(d).pop(true),
        ),
      ],
    ),
  );
  return ok ?? false;
}
