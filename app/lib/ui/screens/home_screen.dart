import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/collections.dart';
import '../../state/library.dart';
import '../../state/settings.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/library_widgets.dart';
import '../widgets/selection.dart';
import '../widgets/track_tile.dart';
import 'collection_screen.dart';
import 'history_screen.dart';
import 'incomplete_screen.dart';
import 'search_screen.dart';
import 'track_list_screen.dart';
import 'favorites_screen.dart';
import '../../state/lyrics_store.dart';

/// Onglets de l'Accueil qu'on fait défiler du doigt, synchronisés avec les onglets soulignés.
class _HomePages extends StatefulWidget {
  final ValueNotifier<int> tab;
  const _HomePages({required this.tab});

  @override
  State<_HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<_HomePages> {
  late final _pages = PageController(initialPage: widget.tab.value);
  bool _fromSwipe = false;

  @override
  void initState() {
    super.initState();
    widget.tab.addListener(_sync);
  }

  @override
  void dispose() {
    widget.tab.removeListener(_sync);
    _pages.dispose();
    super.dispose();
  }

  void _sync() {
    if (_fromSwipe || !_pages.hasClients) return;
    final target = widget.tab.value;
    final current = _pages.page?.round() ?? target;
    if (current == target) return;
    // Onglet lointain : saut direct pour éviter de traverser toutes les pages.
    if ((current - target).abs() > 1) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) => PageView(
    controller: _pages,
    onPageChanged: (i) {
      if (widget.tab.value == i) return;
      Haptics.select();
      _fromSwipe = true;
      widget.tab.value = i;
      _fromSwipe = false;
    },
    children: const [_SuggestionsView(), _SongsView(), _ArtistsView(), _AlbumsView(), _FoldersView(), _GenresView()],
  );
}

/// Accueil : logo + recherche, puis la bibliothèque en onglets soulignés
/// (Suggestions, Titres, Artistes, Albums, Dossiers, Genres).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final lib = context.watch<LibraryController>();
    final nav = context.shell;
    final labels = [l.suggestions, l.tabSongs, l.tabArtists, l.tabAlbums, l.tabFolders, l.tabGenres];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
              child: Row(
                children: [
                  const Wordmark(size: 28),
                  const Spacer(),
                  LyraIconButton(
                    icon: Icons.search_rounded,
                    size: 26,
                    color: c.text,
                    tooltip: l.navSearch,
                    onPressed: () => context.push(const SearchScreen()),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: nav.homeTab,
              builder: (context, tab, _) =>
                  UnderlineTabs(labels: labels, index: tab, onChanged: (i) => nav.homeTab.value = i),
            ),
            if (lib.scanning)
              LinearProgressIndicator(
                value: lib.scanTotal > 0 ? lib.scanDone / lib.scanTotal : null,
                minHeight: 2,
                color: c.primary,
                backgroundColor: Colors.transparent,
              ),
            Expanded(
              child: lib.tracks.isEmpty && !lib.scanning
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        LyraEmptyState(
                          icon: Icons.library_music_outlined,
                          title: l.emptyLibraryTitle,
                          text: l.emptyLibraryBody,
                          action: l.rescan,
                          onAction: () => rescanLibrary(context),
                        ),
                      ],
                    )
                  : _HomePages(tab: nav.homeTab),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestions

class _SuggestionsView extends StatelessWidget {
  const _SuggestionsView();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lib = context.watch<LibraryController>();
    final col = context.watch<CollectionsController>();
    final nav = context.shell;
    final recent = lib.resolve(col.recentIds).take(15).toList();
    final most = lib.resolve(col.mostPlayedIds).take(15).toList();

    // Artistes : les plus écoutés d'abord, puis ceux qui ont le plus de morceaux.
    final artistScore = <String, int>{};
    for (final t in most) {
      if (t.artist != null) artistScore[fold(t.artist!)] = (artistScore[fold(t.artist!)] ?? 0) + 10;
    }
    final artists = lib.artists.where((g) => g.name != null).toList()
      ..sort((a, b) {
        final s = (artistScore[fold(b.name!)] ?? 0).compareTo(artistScore[fold(a.name!)] ?? 0);
        return s != 0 ? s : b.tracks.length.compareTo(a.tracks.length);
      });

    final addedAlbums = <Album>[];
    final seen = <String>{};
    for (final t in lib.recentlyAdded(limit: 200)) {
      if (seen.add(t.albumKey)) {
        final a = lib.albumOf(t);
        if (a != null) addedAlbums.add(a);
      }
      if (addedAlbums.length >= 12) break;
    }

    Widget carousel(int count, double height, Widget Function(int) item) => SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, i) => item(i),
      ),
    );

    return RefreshIndicator(
      color: context.c.primary,
      onRefresh: () => rescanLibrary(context),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _Shortcuts(),
          const _WorkshopCard(),
          if (recent.isNotEmpty) ...[
            SectionHead(l.recentlyPlayed, action: l.seeAll, onAction: () => context.push(const HistoryScreen())),
            carousel(
              recent.length,
              200,
              (i) => SquareCard(
                art: recent[i].art,
                seed: recent[i].album ?? recent[i].title,
                title: recent[i].title,
                subtitle: artistName(context, recent[i].artist),
                size: 132,
                onTap: () => context.audio.playTracks(recent, i),
                onLongPress: () => showTrackMenu(context, recent[i]),
              ),
            ),
          ],
          if (artists.isNotEmpty) ...[
            SectionHead(l.tabArtists, action: l.seeAll, onAction: () => nav.homeTab.value = 2),
            carousel(
              artists.length.clamp(0, 12),
              160,
              (i) => SquareCard(
                art: artists[i].art,
                seed: artists[i].name!,
                title: artists[i].name!,
                size: 112,
                round: true,
                icon: Icons.person_rounded,
                onTap: () => context.push(CollectionScreen.artist(artists[i])),
              ),
            ),
          ],
          if (most.isNotEmpty) ...[
            SectionHead(
              l.mostPlayed,
              action: l.seeAll,
              onAction: () => context.push(TrackListScreen(title: l.mostPlayed, tracks: most)),
            ),
            carousel(
              most.length,
              200,
              (i) => SquareCard(
                art: most[i].art,
                seed: most[i].album ?? most[i].title,
                title: most[i].title,
                subtitle: artistName(context, most[i].artist),
                size: 132,
                onTap: () => context.audio.playTracks(most, i),
                onLongPress: () => showTrackMenu(context, most[i]),
              ),
            ),
          ],
          if (addedAlbums.isNotEmpty) ...[
            SectionHead(
              l.recentlyAdded,
              action: l.seeAll,
              onAction: () {
                context.settings.setSongSort(SongSort.dateAdded);
                context.settings.setSongAscending(false);
                nav.homeTab.value = 1;
              },
            ),
            carousel(
              addedAlbums.length,
              200,
              (i) => SquareCard(
                art: addedAlbums[i].art,
                seed: addedAlbums[i].name ?? addedAlbums[i].key,
                title: albumName(context, addedAlbums[i].name),
                subtitle: artistName(context, addedAlbums[i].artist),
                size: 132,
                onTap: () => context.push(CollectionScreen.album(addedAlbums[i])),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Titres

class _SongsView extends StatefulWidget {
  const _SongsView();

  @override
  State<_SongsView> createState() => _SongsViewState();
}

class _SongsViewState extends State<_SongsView> {
  final _selection = TrackSelection();

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final lib = context.watch<LibraryController>();
    final s = context.watch<SettingsController>();
    final tracks = lib.sorted(s.songSort, ascending: s.songAscending);
    final incomplete = lib.incomplete.length;
    return ListenableBuilder(
      listenable: _selection,
      builder: (context, _) => Scrollbar(
        interactive: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _selection.active
                  ? SelectionBar(selection: _selection, tracks: tracks)
                  : ListHeaderBar<SongSort>(
                      count: l.songsCount(tracks.length),
                      current: s.songSort,
                      ascending: s.songAscending,
                      onSort: s.setSongSort,
                      onAscending: s.setSongAscending,
                      options: [
                        SortOption(SongSort.title, l.sortTitle),
                        SortOption(SongSort.artist, l.sortArtist),
                        SortOption(SongSort.album, l.sortAlbum),
                        SortOption(SongSort.year, l.fieldYear),
                        SortOption(SongSort.dateAdded, l.sortDateAdded),
                        SortOption(SongSort.duration, l.detailsDuration),
                      ],
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LyraIconButton(
                            icon: Icons.checklist_rounded,
                            color: c.text,
                            tooltip: l.select,
                            onPressed: tracks.isEmpty ? null : _selection.start,
                          ),
                          LyraIconButton(
                            icon: Icons.shuffle_rounded,
                            color: c.text,
                            tooltip: l.shuffleAll,
                            onPressed: () => context.audio.playTracks(tracks, 0, shuffled: true),
                          ),
                        ],
                      ),
                    ),
            ),
            if (incomplete > 0 && !_selection.active)
              SliverToBoxAdapter(
                child: InkWell(
                  onTap: () => context.push(const IncompleteScreen()),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 16, color: c.warning),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l.incompleteBannerTitle(incomplete), style: context.t.meta)),
                        Icon(Icons.chevron_right_rounded, size: 18, color: c.text3),
                      ],
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverFixedExtentList.builder(
                itemExtent: 70,
                itemCount: tracks.length,
                itemBuilder: (context, i) => _selection.tile(context, tracks, i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Artistes, albums, dossiers, genres

List<SortOption<GroupSort>> _groupOptions(BuildContext context, {bool album = false}) {
  final l = context.l;
  return [
    SortOption(GroupSort.name, l.sortName),
    if (album) SortOption(GroupSort.artist, l.sortArtist),
    if (album) SortOption(GroupSort.year, l.fieldYear),
    SortOption(GroupSort.count, l.sortSongCount),
  ];
}

class _ArtistsView extends StatelessWidget {
  const _ArtistsView();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lib = context.watch<LibraryController>();
    final s = context.watch<SettingsController>();
    final list = lib.groupsSorted(lib.artists, s.groupSort('artists'), s.groupAscending('artists'));
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ListHeaderBar<GroupSort>(
            count: l.artistsCount(list.length),
            options: _groupOptions(context),
            current: s.groupSort('artists'),
            ascending: s.groupAscending('artists'),
            onSort: (v) => s.setGroupSort('artists', v),
            onAscending: (v) => s.setGroupAscending('artists', v),
          ),
        ),
        SliverFixedExtentList.builder(
          itemExtent: 70,
          itemCount: list.length,
          itemBuilder: (context, i) =>
              ArtistRow(artist: list[i], onTap: () => context.push(CollectionScreen.artist(list[i]))),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _AlbumsView extends StatelessWidget {
  const _AlbumsView();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lib = context.watch<LibraryController>();
    final s = context.watch<SettingsController>();
    final list = lib.albumsSorted(s.groupSort('albums'), s.groupAscending('albums'));
    return LayoutBuilder(
      builder: (context, box) {
        const spacing = 16.0;
        final columns = box.maxWidth > 600 ? 3 : 2;
        final size = (box.maxWidth - 40 - spacing * (columns - 1)) / columns;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ListHeaderBar<GroupSort>(
                count: l.albumsCount(list.length),
                options: _groupOptions(context, album: true),
                current: s.groupSort('albums'),
                ascending: s.groupAscending('albums'),
                onSort: (v) => s.setGroupSort('albums', v),
                onAscending: (v) => s.setGroupAscending('albums', v),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: size + 62,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final a = list[i];
                  return SquareCard(
                    art: a.art,
                    seed: a.name ?? a.key,
                    title: albumName(context, a.name),
                    subtitle: [artistName(context, a.artist), if (a.year != null) '${a.year}'].join('  |  '),
                    size: size,
                    onTap: () => context.push(CollectionScreen.album(a)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

String folderName(String path) => path.split('/').where((s) => s.isNotEmpty).lastOrNull ?? path;

class _FoldersView extends StatelessWidget {
  const _FoldersView();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lib = context.watch<LibraryController>();
    final s = context.watch<SettingsController>();
    var list = lib.folders;
    if (s.groupSort('folders') == GroupSort.name) {
      list = List.of(list)..sort((a, b) => sortKey(folderName(a.name!)).compareTo(sortKey(folderName(b.name!))));
      if (!s.groupAscending('folders')) list = list.reversed.toList();
    } else {
      list = lib.groupsSorted(list, GroupSort.count, s.groupAscending('folders'));
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ListHeaderBar<GroupSort>(
            count: l.foldersCount(list.length),
            options: _groupOptions(context),
            current: s.groupSort('folders'),
            ascending: s.groupAscending('folders'),
            onSort: (v) => s.setGroupSort('folders', v),
            onAscending: (v) => s.setGroupAscending('folders', v),
          ),
        ),
        SliverFixedExtentList.builder(
          itemExtent: 70,
          itemCount: list.length,
          itemBuilder: (context, i) => FolderRow(
            name: folderName(list[i].name!),
            subtitle: l.songsCount(list[i].tracks.length),
            onTap: () => context.push(CollectionScreen.folder(list[i])),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _GenresView extends StatelessWidget {
  const _GenresView();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lib = context.watch<LibraryController>();
    final s = context.watch<SettingsController>();
    final list = lib.groupsSorted(lib.genres, s.groupSort('genres'), s.groupAscending('genres'));
    return LayoutBuilder(
      builder: (context, box) {
        const spacing = 16.0;
        final size = (box.maxWidth - 40 - spacing) / 2;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ListHeaderBar<GroupSort>(
                count: l.genresCount(list.length),
                options: _groupOptions(context),
                current: s.groupSort('genres'),
                ascending: s.groupAscending('genres'),
                onSort: (v) => s.setGroupSort('genres', v),
                onAscending: (v) => s.setGroupAscending('genres', v),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: size + 44,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final g = list[i];
                  final name = g.name ?? l.unknownGenre;
                  return SquareCard(
                    art: g.art,
                    seed: name,
                    title: name,
                    subtitle: l.songsCount(g.tracks.length),
                    size: size,
                    icon: Icons.graphic_eq_rounded,
                    onTap: () => context.push(CollectionScreen.genre(g)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

Future<void> rescanLibrary(BuildContext context) async {
  final l = context.l;
  final lib = context.library;
  final count = await lib.scan();
  if (!context.mounted) return;
  if (lib.scanError != null) {
    context.toast(l.scanError, icon: Icons.error_outline_rounded);
  } else {
    context.toast(l.scanResult(count));
  }
}

/// Grand bouton lecture/pause, dans la couleur principale.
class PlayButton extends StatelessWidget {
  final double size;
  final bool playing;
  final VoidCallback onTap;
  const PlayButton({super.key, required this.size, required this.playing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    return Press(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      semanticLabel: playing ? l.pause : l.play,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(playing),
            size: size * 0.5,
            color: c.onPrimary,
          ),
        ),
      ),
    );
  }
}

/// Carte d'album (utilisée dans les pages artiste et la recherche).
class AlbumCard extends StatelessWidget {
  final Album album;
  final double size;
  final bool showYear;
  const AlbumCard({super.key, required this.album, this.size = 150, this.showYear = false});

  @override
  Widget build(BuildContext context) => SquareCard(
    art: album.art,
    seed: album.name ?? album.key,
    title: albumName(context, album.name),
    subtitle: [artistName(context, album.artist), if (showYear && album.year != null) '${album.year}'].join('  |  '),
    size: size,
    onTap: () => context.push(CollectionScreen.album(album)),
  );
}

/// Barre de progression du scan (utilisée par d'autres écrans).
class ScanBanner extends StatelessWidget {
  final LibraryController lib;
  const ScanBanner({super.key, required this.lib});

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
    value: lib.scanTotal > 0 ? lib.scanDone / lib.scanTotal : null,
    minHeight: 2,
    color: context.c.primary,
    backgroundColor: Colors.transparent,
  );
}

/// Raccourcis de l'Accueil, sur une ligne : Favoris, Les plus écoutés,
/// Ajoutés récemment et lecture aléatoire de toute la bibliothèque.
class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final lib = context.watch<LibraryController>();
    final col = context.watch<CollectionsController>();

    Widget item(IconData icon, String label, VoidCallback onTap, {bool accent = false}) => Expanded(
      child: Press(
        onTap: () {
          Haptics.tap();
          onTap();
        },
        semanticLabel: label,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accent ? c.primary : c.primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: accent ? c.onPrimary : c.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: context.t.meta.copyWith(color: c.text, fontWeight: FontWeight.w600, height: 1.2),
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item(Icons.favorite_rounded, l.favorites, () => context.push(const FavoritesScreen())),
          item(
            Icons.trending_up_rounded,
            l.mostPlayed,
            () => context.push(TrackListScreen(title: l.mostPlayed, tracks: lib.resolve(col.mostPlayedIds))),
          ),
          item(
            Icons.fiber_new_rounded,
            l.recentlyAdded,
            () => context.push(TrackListScreen(title: l.recentlyAdded, tracks: lib.recentlyAdded(limit: 50))),
          ),
          item(
            Icons.shuffle_rounded,
            l.shuffle,
            () => context.audio.playTracks(lib.tracks, 0, shuffled: true),
            accent: true,
          ),
        ],
      ),
    );
  }
}

/// Carte « Atelier » : ce qu'il reste à compléter (paroles, synchro, tags).
class _WorkshopCard extends StatelessWidget {
  const _WorkshopCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final lib = context.watch<LibraryController>();
    final store = context.watch<LyricsStore>();
    var none = 0, plain = 0;
    for (final t in lib.tracks) {
      switch (store.status(t)) {
        case LyricsStatus.none:
          none++;
        case LyricsStatus.plain:
          plain++;
        case LyricsStatus.synced:
          break;
      }
    }
    final info = lib.incomplete.length;
    if (none + plain + info == 0) return const SizedBox(height: 4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Press(
        onTap: () => context.shell.goTab(ShellNav.workshop, workshopTab: plain > 0 ? 1 : (none > 0 ? 0 : 3)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusL),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.primary.withValues(alpha: 0.22), c.surface],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.auto_fix_high_rounded, color: c.onPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.workshop, style: context.t.h3),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (none > 0) l.wsCountNone(none),
                        if (plain > 0) l.wsCountPlain(plain),
                        if (info > 0) l.wsCountInfo(info),
                      ].join(' · '),
                      maxLines: 2,
                      style: context.t.meta,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.text2),
            ],
          ),
        ),
      ),
    );
  }
}
