import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/track.dart';
import '../../state/library.dart';
import '../../state/lyrics_store.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import 'lyrics_sync_screen.dart';

/// Ajouter ou modifier les paroles d'un morceau (texte), puis les synchroniser.
/// Les paroles sont enregistrées sur le téléphone, jamais envoyées.
class LyricsEditorScreen extends StatefulWidget {
  final int trackId;
  const LyricsEditorScreen({super.key, required this.trackId});

  @override
  State<LyricsEditorScreen> createState() => _LyricsEditorScreenState();
}

class _LyricsEditorScreenState extends State<LyricsEditorScreen> {
  final _text = TextEditingController();
  late final Track _track = context.read<LibraryController>().byId(widget.trackId)!;
  String _initial = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
    context.read<LyricsStore>().plainTextFor(_track).then((t) {
      if (!mounted) return;
      _initial = t;
      _text.text = t;
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  List<String> get _lines =>
      _text.text.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final t = data?.text?.trim();
    if (t == null || t.isEmpty) return;
    _text.text = _text.text.trim().isEmpty ? t : '${_text.text.trimRight()}\n$t';
  }

  Future<void> _save({required bool thenSync}) async {
    final l = context.l;
    final store = context.read<LyricsStore>();
    final text = _lines.join('\n');
    if (text.isEmpty) return;
    // Texte inchangé et déjà synchronisé : on garde la synchronisation.
    final keepSynced = text == _initial.trim() && store.status(_track) == LyricsStatus.synced;
    if (!keepSynced) await store.save(_track.id, text, synced: false);
    if (!mounted) return;
    if (thenSync) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LyricsSyncScreen(trackId: _track.id, lines: _lines),
        ),
      );
    } else {
      context.toast(l.lyricsSaved);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final store = context.watch<LyricsStore>();
    final hasUser = store.of(_track.id) != null;
    final lines = _lines.length;
    return Scaffold(
      appBar: LyraAppBar(
        title: l.lyricsEditTitle,
        subtitle: _track.title,
        backIcon: Icons.close_rounded,
        actions: [
          if (hasUser)
            LyraIconButton(
              icon: Icons.delete_outline_rounded,
              color: c.error,
              tooltip: l.lyricsDelete,
              onPressed: () async {
                await store.remove(_track.id);
                if (context.mounted) {
                  context.toast(l.lyricsDeleted);
                  Navigator.of(context).pop();
                }
              },
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: c.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Artwork(path: _track.art, size: 52, radius: 12, seed: _track.album ?? _track.title),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.title),
                            Text(artistName(context, _track.artist), maxLines: 1, style: context.t.meta),
                          ],
                        ),
                      ),
                      LyraButton(
                        label: l.paste,
                        icon: Icons.content_paste_rounded,
                        small: true,
                        variant: BtnVariant.tonal,
                        onPressed: _paste,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _text,
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: context.t.title.copyWith(height: 1.6, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(hintText: l.lyricsHint2, contentPadding: const EdgeInsets.all(16)),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      children: [
                        Text(l.linesCount(lines), style: context.t.meta.copyWith(color: c.text3)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: LyraButton(
                                label: l.save,
                                full: true,
                                variant: BtnVariant.tonal,
                                onPressed: lines == 0 ? null : () => _save(thenSync: false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LyraButton(
                                label: l.syncNow,
                                icon: Icons.timer_outlined,
                                full: true,
                                onPressed: lines == 0 ? null : () => _save(thenSync: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
