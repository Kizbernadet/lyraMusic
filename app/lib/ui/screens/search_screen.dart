import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/collections.dart';
import '../../state/library.dart';
import '../../state/settings.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/library_widgets.dart';
import '../widgets/track_tile.dart';
import 'collection_screen.dart';
import 'home_screen.dart';
import 'playlists_screen.dart';

/// Recherche : champ en haut, recherches récentes, résultats par type.
/// Instantanée, sans accents ni majuscules (CA-08).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(seconds: 2), _remember);
    });
  }

  void _remember() {
    if (mounted && _controller.text.trim().length >= 2) context.settings.addRecentSearch(_controller.text);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final lib = context.watch<LibraryController>();
    final col = context.watch<CollectionsController>();
    final settings = context.watch<SettingsController>();
    final query = _controller.text.trim();
    final results = lib.search(query);
    final q = fold(query);
    final playlists = q.isEmpty ? const [] : col.playlists.where((p) => fold(p.name).contains(q)).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 16, 8),
              child: Row(
                children: [
                  LyraIconButton(
                    icon: Icons.arrow_back_rounded,
                    color: c.text,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _remember(),
                      style: context.t.title,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        filled: true,
                        fillColor: c.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radiusM),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radiusM),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(radiusM),
                          borderSide: BorderSide(color: c.primary, width: 1.5),
                        ),
                        suffixIcon: query.isEmpty
                            ? Icon(Icons.search_rounded, color: c.text3)
                            : IconButton(
                                tooltip: l.clear,
                                icon: Icon(Icons.close_rounded, color: c.text2),
                                onPressed: _controller.clear,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: query.isEmpty
                  ? _recent(context, settings)
                  : results.isEmpty && playlists.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        LyraEmptyState(
                          icon: Icons.search_off_rounded,
                          title: l.searchNoResults(query),
                          text: l.searchNoResultsText,
                          action: l.rescan,
                          onAction: () => rescanLibrary(context),
                          secondary: l.clearSearch,
                          onSecondary: _controller.clear,
                        ),
                      ],
                    )
                  : ListView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        if (results.songs.isNotEmpty) ...[
                          SectionHead(
                            l.tabSongs,
                            action: l.resultsCount(results.songs.length),
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                          ),
                          for (var i = 0; i < results.songs.length && i < 30; i++)
                            TrackTile(
                              track: results.songs[i],
                              onTap: () {
                                _remember();
                                context.audio.playTracks(results.songs, i);
                              },
                            ),
                        ],
                        if (results.artists.isNotEmpty) ...[
                          SectionHead(l.tabArtists, padding: const EdgeInsets.fromLTRB(20, 20, 20, 4)),
                          for (final g in results.artists)
                            ArtistRow(
                              artist: g,
                              onTap: () {
                                _remember();
                                context.push(CollectionScreen.artist(g));
                              },
                            ),
                        ],
                        if (results.albums.isNotEmpty) ...[
                          SectionHead(l.tabAlbums, padding: const EdgeInsets.fromLTRB(20, 20, 20, 12)),
                          SizedBox(
                            height: 190,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: results.albums.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 16),
                              itemBuilder: (_, i) => AlbumCard(album: results.albums[i], size: 128),
                            ),
                          ),
                        ],
                        if (playlists.isNotEmpty) ...[
                          SectionHead(l.playlists, padding: const EdgeInsets.fromLTRB(20, 20, 20, 4)),
                          for (final p in playlists)
                            InkWell(
                              onTap: () => context.push(PlaylistScreen(playlistId: p.id)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                                child: Row(
                                  children: [
                                    Mosaic(
                                      arts: lib.resolve(p.trackIds).map((t) => t.art).toList(),
                                      size: 54,
                                      radius: 12,
                                      seed: p.name,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name, style: context.t.title.copyWith(fontWeight: FontWeight.w700)),
                                          Text(l.songsCount(p.trackIds.length), style: context.t.meta),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recent(BuildContext context, SettingsController settings) {
    final l = context.l;
    final c = context.c;
    final recent = settings.recentSearches;
    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          children: [
            Icon(Icons.manage_search_rounded, size: 52, color: c.text3),
            const SizedBox(height: 12),
            Text(l.searchIntro, style: context.t.h3, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(l.searchSubtitle, style: context.t.meta, textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        SectionHead(
          l.recentSearches,
          action: l.clearAll,
          onAction: settings.clearRecentSearches,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        ),
        for (final q in recent)
          InkWell(
            onTap: () => _setQuery(q),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 20, color: c.text3),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(q, style: context.t.title.copyWith(fontWeight: FontWeight.w500)),
                  ),
                  LyraIconButton(
                    icon: Icons.close_rounded,
                    size: 18,
                    color: c.text3,
                    tooltip: l.clear,
                    onPressed: () => settings.removeRecentSearch(q),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
