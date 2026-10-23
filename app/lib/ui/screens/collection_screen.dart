import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/library.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/library_widgets.dart';
import '../widgets/selection.dart';
import '../widgets/track_tile.dart';
import 'album_editor_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

enum CollectionKind { album, artist, genre, folder }

/// Page d'un album, d'un artiste, d'un genre ou d'un dossier.
class CollectionScreen extends StatefulWidget {
  final CollectionKind kind;
  final String id; // clé d'album, nom replié (artiste / genre) ou chemin du dossier

  const CollectionScreen._(this.kind, this.id);

  factory CollectionScreen.album(Album a) => CollectionScreen._(CollectionKind.album, a.key);
  factory CollectionScreen.artist(Group g) => CollectionScreen._(CollectionKind.artist, fold(g.name ?? ''));
  factory CollectionScreen.genre(Group g) => CollectionScreen._(CollectionKind.genre, fold(g.name ?? ''));
  factory CollectionScreen.folder(Group g) => CollectionScreen._(CollectionKind.folder, g.name!);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _selection = TrackSelection();

  CollectionKind get kind => widget.kind;
  String get id => widget.id;

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryController>();
    final l = context.l;
    final c = context.c;
    String title;
    List<String> meta;
    String? art;
    List<Track> tracks;
    List<Album> albums = const [];
    Widget? cover;

    switch (kind) {
      case CollectionKind.album:
        final a = lib.albums.where((a) => a.key == id).firstOrNull;
        tracks = a?.tracks ?? const [];
        title = albumName(context, a?.name);
        meta = [artistName(context, a?.artist), if (a?.year != null) '${a!.year}'];
        art = a?.art;
      case CollectionKind.artist:
        final g = lib.artists.where((g) => fold(g.name ?? '') == id).firstOrNull;
        tracks = g?.tracks ?? const [];
        title = artistName(context, g?.name);
        albums = g == null ? const [] : lib.albumsOfArtist(g);
        meta = [l.albumsCount(albums.length)];
        art = g?.art;
        cover = Artwork(path: art, size: 190, radius: 95, seed: title, icon: Icons.person_rounded, glow: true);
      case CollectionKind.genre:
        final g = lib.genres.where((g) => fold(g.name ?? '') == id).firstOrNull;
        tracks = g?.tracks ?? const [];
        title = g?.name ?? l.unknownGenre;
        meta = [];
        art = g?.art;
      case CollectionKind.folder:
        final g = lib.folders.where((g) => g.name == id).firstOrNull;
        tracks = g?.tracks ?? const [];
        title = folderName(id);
        meta = [];
        cover = FolderIcon(size: 170, color: c.primary);
    }

    final total = tracks.fold<int>(0, (s, t) => s + t.durationMs);
    meta = [...meta, l.songsCount(tracks.length), if (tracks.isNotEmpty) formatDuration(Duration(milliseconds: total))];

    return Scaffold(
      appBar: LyraAppBar(
        title: '',
        actions: [
          LyraIconButton(
            icon: Icons.search_rounded,
            color: c.text,
            tooltip: l.navSearch,
            onPressed: () => context.push(const SearchScreen()),
          ),
          if (kind == CollectionKind.album && tracks.isNotEmpty)
            LyraIconButton(icon: Icons.edit_outlined, color: c.text, tooltip: l.editAlbum, onPressed: _editAlbum),
          LyraIconButton(
            icon: Icons.more_horiz_rounded,
            color: c.text,
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            onPressed: tracks.isEmpty ? null : () => _menu(context, tracks, title),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _selection,
        builder: (context, _) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DetailHeader(
                cover: cover ?? Artwork(path: art, size: 210, radius: 22, seed: title, glow: true),
                title: title,
                meta: meta,
                onShuffle: tracks.isEmpty ? null : () => context.audio.playTracks(tracks, 0, shuffled: true),
                onPlay: tracks.isEmpty ? null : () => context.audio.playTracks(tracks, 0, shuffled: false),
              ),
            ),
            if (albums.length > 1) ...[
              SliverToBoxAdapter(child: SectionHead(l.tabAlbums, padding: const EdgeInsets.fromLTRB(20, 12, 20, 12))),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 196,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: albums.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => AlbumCard(album: albums[i], size: 132, showYear: true),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: _selection.active
                  ? SelectionBar(selection: _selection, tracks: tracks)
                  : SectionHead(
                      l.tabSongs,
                      action: tracks.isEmpty ? null : l.select,
                      onAction: _selection.start,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    ),
            ),
            SliverList.builder(
              itemCount: tracks.length,
              itemBuilder: (context, i) => _selection.tile(context, tracks, i),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Future<void> _editAlbum() async {
    final key = await context.pushFull<String>(AlbumEditorScreen(albumKey: id));
    if (key == null || key == id || !mounted) return;
    // Le nom ou l'artiste a changé : l'album a une nouvelle clé.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => CollectionScreen._(CollectionKind.album, key)));
  }

  Future<void> _deleteAlbum(List<Track> tracks, String name) async {
    final l = context.l;
    final ok = await deleteTracks(
      context,
      tracks,
      title: l.deleteAlbumTitle,
      body: l.deleteAlbumBody(name, tracks.length),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  void _menu(BuildContext context, List<Track> tracks, String title) {
    final l = context.l;
    showLyraSheet(
      context,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetAction(
            icon: Icons.playlist_play_rounded,
            label: l.playNext,
            onTap: () {
              Navigator.of(sheet).pop();
              context.audio.playNext(tracks);
              context.toast(l.willPlayNext);
            },
          ),
          SheetAction(
            icon: Icons.queue_music_rounded,
            label: l.addToQueue,
            onTap: () {
              Navigator.of(sheet).pop();
              context.audio.addToQueue(tracks);
              context.toast(l.addedToQueue);
            },
          ),
          SheetAction(
            icon: Icons.playlist_add_rounded,
            label: l.addToPlaylist,
            onTap: () {
              Navigator.of(sheet).pop();
              showAddToPlaylist(context, tracks);
            },
          ),
          if (kind == CollectionKind.album) ...[
            SheetAction(
              icon: Icons.edit_outlined,
              label: l.editAlbum,
              onTap: () {
                Navigator.of(sheet).pop();
                _editAlbum();
              },
            ),
            SheetAction(
              icon: Icons.delete_outline_rounded,
              label: l.deleteAlbum,
              color: sheet.c.error,
              onTap: () {
                Navigator.of(sheet).pop();
                _deleteAlbum(tracks, title);
              },
            ),
          ],
        ],
      ),
    );
  }
}
