import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/library.dart';
import '../../state/settings.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/track_tile.dart';

class PickerResult {
  final String? name;
  final List<int> ids;
  const PickerResult(this.name, this.ids);
}

/// Choix de morceaux : création de playlist (prototype 14) ou ajout à une playlist.
class TrackPickerScreen extends StatefulWidget {
  final bool askName;

  /// Morceaux déjà dans la playlist : affichés cochés et grisés, jamais ajoutés deux fois.
  final Set<int> exclude;
  const TrackPickerScreen({super.key, required this.askName, this.exclude = const {}});

  @override
  State<TrackPickerScreen> createState() => _TrackPickerScreenState();
}

class _TrackPickerScreenState extends State<TrackPickerScreen> {
  final _name = TextEditingController();
  final _query = TextEditingController();
  final List<int> _picked = [];

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _query.dispose();
    super.dispose();
  }

  bool get _canSave => widget.askName ? _name.text.trim().isNotEmpty : _picked.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final lib = context.watch<LibraryController>();
    final q = _query.text.trim();
    final tracks = q.isEmpty ? lib.sorted(context.watch<SettingsController>().songSort) : lib.search(q).songs;

    return Scaffold(
      appBar: LyraAppBar(
        title: widget.askName ? l.newPlaylist : l.addSongs,
        subtitle: l.selectedCount(_picked.length),
        backIcon: Icons.close_rounded,
        actions: [
          LyraButton(
            label: l.save,
            small: true,
            onPressed: _canSave
                ? () => Navigator.of(
                    context,
                  ).pop(PickerResult(widget.askName ? _name.text.trim() : null, List.of(_picked)))
                : null,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          if (widget.askName)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: [
                  Mosaic(
                    arts: [for (final id in _picked.take(8)) lib.byId(id)?.art],
                    size: 64,
                    radius: 16,
                    seed: _name.text,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _name,
                      autofocus: true,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.sentences,
                      style: context.t.h2,
                      decoration: InputDecoration(
                        hintText: l.playlistName,
                        counterText: '',
                        hintStyle: context.t.h2.copyWith(color: c.text3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
            child: TextField(
              controller: _query,
              style: context.t.body.copyWith(color: c.text),
              decoration: InputDecoration(
                hintText: l.searchSongs,
                prefixIcon: Icon(Icons.search_rounded, size: 19, color: c.text3),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemExtent: 60,
              itemCount: tracks.length,
              itemBuilder: (context, i) {
                final t = tracks[i];
                final present = widget.exclude.contains(t.id);
                final picked = _picked.contains(t.id);
                return InkWell(
                  onTap: present ? null : () => setState(() => picked ? _picked.remove(t.id) : _picked.add(t.id)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 12, 6),
                    child: Row(
                      children: [
                        Artwork(path: t.art, size: 44, radius: 12, seed: t.album ?? t.title),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.t.title.copyWith(
                                  color: present ? c.text3 : (picked ? c.primary : c.text),
                                ),
                              ),
                              Text(
                                present ? l.inPlaylist : artistName(context, t.artist),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.t.meta,
                              ),
                            ],
                          ),
                        ),
                        CheckDot(checked: picked || present, disabled: present),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
