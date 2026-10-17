import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/collections.dart';
import '../../state/library.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/library_widgets.dart';
import '../widgets/track_tile.dart';
import 'history_screen.dart';
import 'search_screen.dart';
import 'track_picker_screen.dart';

/// Onglet Playlists : nouvelle playlist, historique, puis vos playlists.
class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final col = context.watch<CollectionsController>();
    final lib = context.watch<LibraryController>();

    Widget specialRow(IconData icon, String title, String sub, VoidCallback onTap, {bool accent = false}) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent ? c.primary : c.surface2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: accent ? c.onPrimary : c.text),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(sub, style: context.t.meta),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: c.text3),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: LyraAppBar(
        title: l.playlists,
        large: true,
        actions: [
          LyraIconButton(
            icon: Icons.search_rounded,
            color: c.text,
            tooltip: l.navSearch,
            onPressed: () => context.push(const SearchScreen()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          specialRow(Icons.add_rounded, l.newPlaylist, l.newPlaylistSub, () => createPlaylist(context), accent: true),
          specialRow(Icons.history_rounded, l.history, l.recentlyPlayed, () => context.push(const HistoryScreen())),
          if (col.playlists.isNotEmpty)
            SectionHead(l.localPlaylists(col.playlists.length), padding: const EdgeInsets.fromLTRB(20, 20, 20, 6)),
          if (col.playlists.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: LyraEmptyState(
                icon: Icons.queue_music_rounded,
                title: l.noPlaylistsTitle,
                text: l.noPlaylistsBody,
              ),
            ),
          for (final p in col.playlists)
            InkWell(
              onTap: () => context.push(PlaylistScreen(playlistId: p.id)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                child: Row(
                  children: [
                    Mosaic(
                      arts: lib.resolve(p.trackIds).map((t) => t.art).toList(),
                      size: 56,
                      radius: 14,
                      seed: p.name,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(l.songsCount(lib.resolve(p.trackIds).length), style: context.t.meta),
                        ],
                      ),
                    ),
                    _PlaylistMenuButton(playlist: p),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaylistMenuButton extends StatelessWidget {
  final Playlist playlist;
  const _PlaylistMenuButton({required this.playlist});

  @override
  Widget build(BuildContext context) => LyraIconButton(
    icon: Icons.more_vert_rounded,
    size: 20,
    color: context.c.text2,
    tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
    onPressed: () => showPlaylistMenu(context, playlist),
  );
}

/// Menu d'une playlist : lecture suivante, renommer, ajouter, supprimer.
void showPlaylistMenu(BuildContext context, Playlist p, {bool popOnDelete = false}) {
  final l = context.l;
  final lib = context.library;
  showLyraSheet(
    context,
    builder: (sheet) {
      void run(VoidCallback f) {
        Navigator.of(sheet).pop();
        f();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              children: [
                Mosaic(arts: lib.resolve(p.trackIds).map((t) => t.art).toList(), size: 56, radius: 12, seed: p.name),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: sheet.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(l.songsCount(p.trackIds.length), style: sheet.t.meta),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, indent: 20, endIndent: 20, color: sheet.c.divider),
          const SizedBox(height: 6),
          SheetAction(
            icon: Icons.playlist_play_rounded,
            label: l.playNext,
            onTap: () => run(() {
              context.audio.playNext(lib.resolve(p.trackIds));
              context.toast(l.willPlayNext);
            }),
          ),
          SheetAction(icon: Icons.add_rounded, label: l.addSongs, onTap: () => run(() => addSongsTo(context, p))),
          SheetAction(
            icon: Icons.edit_outlined,
            label: l.rename,
            onTap: () => run(() async {
              final n = await askPlaylistName(context, initial: p.name, rename: true);
              if (n != null && context.mounted) await context.collections.rename(p.id, n);
            }),
          ),
          SheetAction(
            icon: Icons.delete_outline_rounded,
            label: l.delete,
            color: sheet.c.error,
            onTap: () => run(() async {
              if (await confirmDeletePlaylist(context, p) && popOnDelete && context.mounted) {
                Navigator.of(context).pop();
              }
            }),
          ),
        ],
      );
    },
  );
}

/// Nouvelle playlist : écran plein avec nom et choix des morceaux.
Future<void> createPlaylist(BuildContext context) async {
  final l = context.l;
  final result = await context.pushFull<PickerResult>(const TrackPickerScreen(askName: true));
  if (result == null || !context.mounted) return;
  final id = await context.collections.create(result.name!, trackIds: result.ids);
  if (!context.mounted) return;
  context.toast(l.playlistCreated);
  context.push(PlaylistScreen(playlistId: id));
}

Future<void> addSongsTo(BuildContext context, Playlist p) async {
  final l = context.l;
  final result = await context.pushFull<PickerResult>(const TrackPickerScreen(askName: false));
  if (result == null || result.ids.isEmpty || !context.mounted) return;
  await context.collections.addTracks(p.id, result.ids);
  if (context.mounted) context.toast(l.addedToPlaylist(p.name));
}

/// Suppression avec confirmation ; les fichiers audio ne sont jamais supprimés (CA-24).
Future<bool> confirmDeletePlaylist(BuildContext context, Playlist p) async {
  final l = context.l;
  final ok = await confirmAction(
    context,
    title: l.deletePlaylistTitle,
    body: l.deletePlaylistBody(p.name),
    confirm: l.delete,
  );
  if (ok && context.mounted) {
    await context.collections.delete(p.id);
    return true;
  }
  return false;
}

/// Détail d'une playlist, ou des favoris (onglet Favoris).
class PlaylistScreen extends StatelessWidget {
  final int? playlistId; // null = favoris
  const PlaylistScreen({super.key, required int this.playlistId});
  const PlaylistScreen.favorites({super.key}) : playlistId = null;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final col = context.watch<CollectionsController>();
    final lib = context.watch<LibraryController>();
    final playlist = playlistId == null ? null : col.playlist(playlistId!);
    if (playlistId != null && playlist == null) return const Scaffold(appBar: LyraAppBar(title: ''));

    final ids = playlist?.trackIds ?? col.favoriteIds;
    // Position d'origine conservée pour retirer / déplacer le bon élément.
    final entries = <(int, Track)>[
      for (var i = 0; i < ids.length; i++)
        if (lib.byId(ids[i]) != null) (i, lib.byId(ids[i])!),
    ];
    final tracks = [for (final e in entries) e.$2];
    final name = playlist?.name ?? l.favorites;
    final total = tracks.fold<int>(0, (s, t) => s + t.durationMs);
    final isFavorites = playlist == null;

    final header = DetailHeader(
      cover: isFavorites
          ? Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(28)),
              child: Icon(Icons.favorite_rounded, size: 76, color: c.onPrimary),
            )
          : Mosaic(arts: tracks.map((t) => t.art).toList(), size: 200, radius: 22, seed: name),
      title: name,
      meta: [
        l.songsCount(tracks.length),
        if (tracks.isNotEmpty) formatDuration(Duration(milliseconds: total)),
      ],
      onShuffle: tracks.isEmpty ? null : () => context.audio.playTracks(tracks, 0, shuffled: true),
      onPlay: tracks.isEmpty ? null : () => context.audio.playTracks(tracks, 0, shuffled: false),
    );

    Widget body;
    if (tracks.isEmpty) {
      body = ListView(
        children: [
          header,
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: isFavorites
                ? LyraEmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: l.noFavoritesTitle,
                    text: l.noFavoritesBody,
                  )
                : LyraEmptyState(
                    icon: Icons.playlist_add_rounded,
                    title: l.emptyPlaylistTitle,
                    text: l.emptyPlaylistBody,
                    action: l.addSongs,
                    onAction: () => addSongsTo(context, playlist),
                  ),
          ),
        ],
      );
    } else if (!isFavorites) {
      body = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          SliverReorderableList(
            itemCount: entries.length,
            onReorderItem: (from, to) => context.collections.move(playlist.id, entries[from].$1, entries[to].$1),
            itemBuilder: (context, i) => ReorderableDelayedDragStartListener(
              key: ValueKey('p-${entries[i].$1}-${tracks[i].id}'),
              index: i,
              child: Material(
                type: MaterialType.transparency,
                child: TrackTile(
                  track: tracks[i],
                  onTap: () => context.audio.playTracks(tracks, i),
                  extras: [
                    MenuExtra(
                      Icons.playlist_remove_rounded,
                      l.removeFromPlaylist,
                      () => context.collections.removeAt(playlist.id, entries[i].$1),
                      danger: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: tracks.length + 1,
        itemBuilder: (context, i) =>
            i == 0 ? header : TrackTile(track: tracks[i - 1], onTap: () => context.audio.playTracks(tracks, i - 1)),
      );
    }

    return Scaffold(
      appBar: LyraAppBar(
        title: isFavorites ? l.favorites : '',
        large: isFavorites,
        actions: [
          LyraIconButton(
            icon: Icons.search_rounded,
            color: c.text,
            tooltip: l.navSearch,
            onPressed: () => context.push(const SearchScreen()),
          ),
          if (!isFavorites)
            LyraIconButton(
              icon: Icons.more_horiz_rounded,
              color: c.text,
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              onPressed: () => showPlaylistMenu(context, playlist, popOnDelete: true),
            ),
        ],
      ),
      body: body,
    );
  }
}
