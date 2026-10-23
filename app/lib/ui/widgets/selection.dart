import 'package:flutter/material.dart';

import '../../models/track.dart';
import '../theme.dart';
import 'common.dart';
import 'kit.dart';
import 'track_tile.dart';

/// Sélection multiple de morceaux (onglet Titres, pages album, artiste…).
class TrackSelection extends ChangeNotifier {
  final Set<int> _ids = {};
  bool active = false;

  bool contains(int id) => _ids.contains(id);

  void start([int? id]) {
    active = true;
    if (id != null) _ids.add(id);
    Haptics.select();
    notifyListeners();
  }

  void toggle(int id) {
    if (!_ids.remove(id)) _ids.add(id);
    if (_ids.isEmpty) active = false;
    notifyListeners();
  }

  /// Tout sélectionner, ou tout désélectionner si tout l'est déjà.
  void toggleAll(Iterable<int> ids) {
    if (ids.every(_ids.contains)) {
      _ids.removeAll(ids);
    } else {
      _ids.addAll(ids);
    }
    notifyListeners();
  }

  void clear() {
    _ids.clear();
    active = false;
    notifyListeners();
  }

  /// Morceaux sélectionnés, dans l'ordre de [tracks].
  List<Track> pick(List<Track> tracks) => [
    for (final t in tracks)
      if (_ids.contains(t.id)) t,
  ];

  /// Ligne de liste : toucher sélectionne en mode sélection, l'appui long y entre.
  Widget tile(BuildContext context, List<Track> tracks, int i) {
    final t = tracks[i];
    return TrackTile(
      track: t,
      selected: active ? contains(t.id) : null,
      onTap: active ? () => toggle(t.id) : () => context.audio.playTracks(tracks, i),
      onLongPress: active ? () => toggle(t.id) : () => start(t.id),
    );
  }
}

/// Barre d'actions de la sélection : remplace l'en-tête de la liste.
/// [actions] : actions propres à la liste (retirer de la playlist…), affichées
/// en icônes ; « Ajouter à une playlist » et « Supprimer » passent alors dans le menu.
class SelectionBar extends StatelessWidget {
  final TrackSelection selection;
  final List<Track> tracks;
  final List<MenuExtra> Function(List<Track> picked)? actions;
  const SelectionBar({super.key, required this.selection, required this.tracks, this.actions});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final picked = selection.pick(tracks);
    final none = picked.isEmpty;
    final extras = actions?.call(picked) ?? const <MenuExtra>[];

    Future<void> addToPlaylist() async {
      await showAddToPlaylist(context, picked);
      selection.clear();
    }

    Future<void> delete() async {
      if (await deleteTracks(context, picked)) selection.clear();
    }

    void more() => showLyraSheet(
      context,
      title: l.selectedCount(picked.length),
      builder: (sheet) {
        void run(VoidCallback f) {
          Navigator.of(sheet).pop();
          f();
          selection.clear();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetAction(
              icon: Icons.play_arrow_rounded,
              label: l.play,
              onTap: () => run(() => context.audio.playTracks(picked, 0, shuffled: false)),
            ),
            SheetAction(
              icon: Icons.playlist_play_rounded,
              label: l.playNext,
              onTap: () => run(() {
                context.audio.playNext(picked);
                context.toast(l.willPlayNext);
              }),
            ),
            SheetAction(
              icon: Icons.queue_music_rounded,
              label: l.addToQueue,
              onTap: () => run(() {
                context.audio.addToQueue(picked);
                context.toast(l.addedToQueue);
              }),
            ),
            if (extras.isNotEmpty) ...[
              SheetAction(
                icon: Icons.playlist_add_rounded,
                label: l.addToPlaylist,
                onTap: () {
                  Navigator.of(sheet).pop();
                  addToPlaylist();
                },
              ),
              SheetAction(
                icon: Icons.delete_outline_rounded,
                label: l.deleteFromDevice,
                color: sheet.c.error,
                onTap: () {
                  Navigator.of(sheet).pop();
                  delete();
                },
              ),
            ],
          ],
        );
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) selection.clear();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: Row(
          children: [
            LyraIconButton(
              icon: Icons.close_rounded,
              color: c.text,
              tooltip: l.clearSelection,
              onPressed: selection.clear,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l.selectedCount(picked.length),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.t.title.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            LyraIconButton(
              icon: Icons.select_all_rounded,
              color: c.text,
              tooltip: l.selectAll,
              onPressed: () => selection.toggleAll(tracks.map((t) => t.id)),
            ),
            for (final e in extras)
              LyraIconButton(
                icon: e.icon,
                color: e.danger ? c.error : c.text,
                tooltip: e.label,
                onPressed: none
                    ? null
                    : () {
                        e.onTap();
                        selection.clear();
                      },
              ),
            if (extras.isEmpty) ...[
              LyraIconButton(
                icon: Icons.playlist_add_rounded,
                color: c.text,
                tooltip: l.addToPlaylist,
                onPressed: none ? null : addToPlaylist,
              ),
              LyraIconButton(
                icon: Icons.delete_outline_rounded,
                color: c.error,
                tooltip: l.deleteFromDevice,
                onPressed: none ? null : delete,
              ),
            ],
            LyraIconButton(
              icon: Icons.more_vert_rounded,
              color: c.text,
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              onPressed: none ? null : more,
            ),
          ],
        ),
      ),
    );
  }
}
