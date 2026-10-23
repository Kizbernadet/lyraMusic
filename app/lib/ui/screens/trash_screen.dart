import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/media_store.dart';
import '../../state/lyrics_store.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/track_tile.dart';

/// Corbeille du téléphone (Android 11+) : morceaux supprimés depuis LyraMusic
/// ou une autre application, restaurables pendant 30 jours.
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<TrashedRow>? _rows;
  bool _supported = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supported = await MediaStoreBridge.hasTrash();
    List<TrashedRow> rows = const [];
    if (supported) {
      try {
        rows = await MediaStoreBridge.queryTrash();
      } catch (e) {
        debugPrint('Trash query failed: $e');
      }
    }
    rows.sort((a, b) => a.expires.compareTo(b.expires));
    if (mounted) {
      setState(() {
        _supported = supported;
        _rows = rows;
      });
    }
  }

  Future<void> _restore(List<TrashedRow> rows) async {
    if (rows.isEmpty) return;
    await restoreTracks(context, [for (final r in rows) r.id]);
    await _load();
  }

  Future<void> _deleteForever(List<TrashedRow> rows) async {
    final l = context.l;
    if (rows.isEmpty) return;
    final library = context.library;
    final collections = context.collections;
    final lyrics = context.read<LyricsStore>();
    final ids = [for (final r in rows) r.id];
    try {
      if (!await MediaStoreBridge.deleteAudio(ids, [for (final r in rows) r.path])) return;
    } catch (e) {
      debugPrint('Delete failed: $e');
      if (mounted) context.toast(l.deleteError, icon: Icons.error_outline_rounded);
      return;
    }
    // Plus aucune restauration possible : on oublie favoris, playlists, paroles…
    await library.forget(ids);
    await collections.reload();
    await lyrics.load();
    if (mounted) context.toast(l.deletedCount(ids.length), icon: Icons.delete_forever_rounded);
    await _load();
  }

  Future<void> _emptyTrash() async {
    final l = context.l;
    final rows = _rows ?? const [];
    if (rows.isEmpty) return;
    final ok = await confirmAction(context, title: l.emptyTrashTitle, body: l.emptyTrashBody, confirm: l.emptyTrash);
    if (ok && mounted) await _deleteForever(rows);
  }

  void _menu(TrashedRow r) {
    final l = context.l;
    showLyraSheet(
      context,
      title: r.title ?? r.path.split('/').last,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetAction(
            icon: Icons.restore_rounded,
            label: l.restore,
            onTap: () {
              Navigator.of(sheet).pop();
              _restore([r]);
            },
          ),
          SheetAction(
            icon: Icons.delete_forever_rounded,
            label: l.deleteForever,
            color: sheet.c.error,
            onTap: () {
              Navigator.of(sheet).pop();
              _deleteForever([r]);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final rows = _rows;
    final now = DateTime.now();

    Widget body;
    if (rows == null) {
      body = Center(child: CircularProgressIndicator(color: c.primary));
    } else if (!_supported || rows.isEmpty) {
      body = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LyraEmptyState(
            icon: Icons.delete_outline_rounded,
            title: _supported ? l.trashEmptyTitle : l.trash,
            text: _supported ? l.trashEmptyBody : l.trashUnsupported,
          ),
        ],
      );
    } else {
      body = RefreshIndicator(
        color: c.primary,
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final r = rows[i];
            final days = r.expires.difference(now).inDays.clamp(0, 99);
            final sub = [
              artistName(context, r.artist),
              if (r.durationMs > 0) formatDuration(Duration(milliseconds: r.durationMs)),
              l.trashExpires(days),
            ].join('  |  ');
            return InkWell(
              onTap: () => _menu(r),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.music_off_rounded, color: c.text3),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title ?? r.path.split('/').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.meta),
                        ],
                      ),
                    ),
                    LyraIconButton(
                      icon: Icons.restore_rounded,
                      color: c.primary,
                      tooltip: l.restore,
                      onPressed: () => _restore([r]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    final hasRows = rows != null && rows.isNotEmpty;
    return Scaffold(
      appBar: LyraAppBar(
        title: l.trash,
        subtitle: hasRows ? l.songsCount(rows.length) : null,
        actions: [
          if (hasRows) ...[
            LyraIconButton(
              icon: Icons.restore_page_outlined,
              color: c.text,
              tooltip: l.restoreAll,
              onPressed: () => _restore(rows),
            ),
            LyraIconButton(
              icon: Icons.delete_sweep_outlined,
              color: c.error,
              tooltip: l.emptyTrash,
              onPressed: _emptyTrash,
            ),
          ],
        ],
      ),
      body: body,
    );
  }
}
