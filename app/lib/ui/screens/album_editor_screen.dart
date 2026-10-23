import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/tag_writer.dart';
import '../../models/track.dart';
import '../../state/library.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// Édition d'un album entier : artiste, nom, année, nombre de pistes et pochette
/// sont écrits dans chacun de ses morceaux. Un champ laissé tel quel n'est pas
/// modifié (utile quand les morceaux ont des valeurs différentes).
/// Renvoie la nouvelle clé de l'album.
class AlbumEditorScreen extends StatefulWidget {
  final String albumKey;
  const AlbumEditorScreen({super.key, required this.albumKey});

  @override
  State<AlbumEditorScreen> createState() => _AlbumEditorScreenState();
}

class _AlbumEditorScreenState extends State<AlbumEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final Album _album = context.read<LibraryController>().albums.firstWhere((a) => a.key == widget.albumKey);
  late final List<Track> _tracks = _album.tracks;

  /// Valeur commune à tous les morceaux, ou null si elles diffèrent.
  static String? _common(Iterable<String?> values) => values.toSet().length == 1 ? values.first : null;

  late final _initArtist = _common(_tracks.map((t) => t.albumArtist ?? t.artist)) ?? '';
  late final _initAlbum = _common(_tracks.map((t) => t.album)) ?? '';
  late final _initYear = _common(_tracks.map((t) => t.year?.toString())) ?? '';
  late final _mixedArtist = _common(_tracks.map((t) => t.albumArtist ?? t.artist)) == null;
  late final _mixedAlbum = _common(_tracks.map((t) => t.album)) == null;
  late final _mixedYear = _common(_tracks.map((t) => t.year?.toString())) == null;

  late final _artist = TextEditingController(text: _initArtist);
  late final _name = TextEditingController(text: _initAlbum);
  late final _year = TextEditingController(text: _initYear);
  final _total = TextEditingController();

  bool _artChanged = false;
  Uint8List? _artBytes;
  String _artMime = 'image/jpeg';
  bool _saving = false;
  int _done = 0;

  List<TextEditingController> get _fields => [_artist, _name, _year, _total];

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      f.addListener(_onChanged);
    }
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  String? _v(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  bool get _artistChanged => _artist.text.trim() != _initArtist;
  bool get _nameChanged => _name.text.trim() != _initAlbum;
  bool get _yearChanged => _year.text.trim() != _initYear;
  bool get _dirty => _artChanged || _artistChanged || _nameChanged || _yearChanged || _v(_total) != null;

  bool get _hasArt => _artChanged ? _artBytes != null : _album.art != null;

  Future<void> _pickArt() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final isPng = bytes.length > 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
    setState(() {
      _artChanged = true;
      _artBytes = bytes;
      _artMime = isPng ? 'image/png' : 'image/jpeg';
    });
  }

  void _artSheet() {
    final l = context.l;
    showLyraSheet(
      context,
      title: l.artwork,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetAction(
            icon: Icons.photo_library_outlined,
            label: l.artworkChoose,
            onTap: () {
              Navigator.of(sheet).pop();
              _pickArt();
            },
          ),
          if (_hasArt)
            SheetAction(
              icon: Icons.hide_image_outlined,
              label: l.artworkRemove,
              color: sheet.c.error,
              onTap: () {
                Navigator.of(sheet).pop();
                setState(() {
                  _artChanged = true;
                  _artBytes = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l = context.l;
    final library = context.read<LibraryController>();
    final audio = context.audio;
    setState(() {
      _saving = true;
      _done = 0;
    });
    // Une seule demande d'autorisation pour tous les fichiers de l'album.
    try {
      await requestWriteAll(_tracks);
    } on TagWriteException {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(l.tagsErrorDenied);
      return;
    }

    final artist = _v(_artist);
    final name = _v(_name);
    final year = _v(_year) == null ? null : int.parse(_year.text.trim());
    final total = _v(_total) == null ? null : int.parse(_total.text.trim());
    final updated = <Track>[];
    var failed = 0;
    for (final t in _tracks) {
      final edit = TagEdit(
        title: t.title,
        artist: _artistChanged ? artist : t.artist,
        albumArtist: _artistChanged && supportsAlbumArtist(t) ? artist : t.albumArtist,
        album: _nameChanged ? name : t.album,
        genre: t.genre,
        year: _yearChanged ? year : t.year,
        trackNumber: t.trackNumber,
        trackTotal: total,
        artChanged: _artChanged,
        artBytes: _artBytes,
        artMime: _artMime,
      );
      // Le fichier en cours de lecture est libéré pendant l'écriture (CA-35).
      final resume = await audio.releaseIfCurrent(t.id);
      try {
        updated.add(await writeTags(t, edit, artDir: library.artDir, askPermission: false));
      } on TagWriteException catch (e) {
        debugPrint('Album tag write failed for ${t.path}: $e');
        failed++;
      } finally {
        await audio.resumeAfterEdit(resume);
      }
      if (mounted) setState(() => _done++);
    }

    if (updated.isNotEmpty) {
      await library.replaceTracks(updated);
      for (final t in updated) {
        audio.updateTrack(t);
      }
    }
    if (!mounted) return;
    if (failed > 0) {
      setState(() => _saving = false);
      _showError(l.albumSavePartial(failed));
      return;
    }
    context.toast(l.albumSaved);
    Navigator.of(context).pop(updated.first.albumKey);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        icon: Icon(Icons.error_outline_rounded, color: d.c.error, size: 32),
        content: Text(message, textAlign: TextAlign.center),
        actions: [LyraButton(label: 'OK', small: true, onPressed: () => Navigator.of(d).pop())],
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    final l = context.l;
    final result = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.discardTitle),
        content: Text(l.discardBody),
        actions: [
          LyraButton(
            label: l.keepEditing,
            small: true,
            variant: BtnVariant.ghost,
            onPressed: () => Navigator.of(d).pop(false),
          ),
          LyraButton(
            label: l.discard,
            small: true,
            variant: BtnVariant.danger,
            onPressed: () => Navigator.of(d).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;

    Widget field(
      TextEditingController ctrl,
      String label, {
      bool mixed = false,
      String? hint,
      String? helper,
      String? Function(String?)? validator,
      TextInputType? keyboard,
      List<TextInputFormatter>? formatters,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: context.t.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            enabled: !_saving,
            validator: validator,
            keyboardType: keyboard,
            inputFormatters: formatters,
            textCapitalization: keyboard == null ? TextCapitalization.sentences : TextCapitalization.none,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: context.t.title,
            decoration: InputDecoration(hintText: mixed ? l.multipleValues : (hint ?? '—'), helperText: helper),
          ),
        ],
      ),
    );

    Widget artPreview() {
      if (_artChanged && _artBytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radiusS),
          child: Image.memory(_artBytes!, width: 64, height: 64, fit: BoxFit.cover),
        );
      }
      return Artwork(path: _artChanged ? null : _album.art, size: 64, radius: radiusS, seed: _album.name ?? _album.key);
    }

    final artStatus = _artChanged
        ? (_artBytes != null ? l.artworkNew : l.artworkNone)
        : (_album.art != null ? l.artworkEmbedded : l.artworkNone);

    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: LyraAppBar(
          title: l.editAlbum,
          subtitle: _saving ? l.albumSaving(_done, _tracks.length) : l.songsCount(_tracks.length),
          backIcon: Icons.close_rounded,
          actions: [
            LyraButton(
              small: true,
              onPressed: _dirty && !_saving ? _save : null,
              label: _saving ? null : l.save,
              child: _saving
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: c.onPrimary),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (_saving) ...[
                LinearProgressIndicator(
                  value: _tracks.isEmpty ? null : _done / _tracks.length,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(3),
                  color: c.primary,
                  backgroundColor: c.dividerStrong,
                ),
                const SizedBox(height: 14),
              ],
              LyraCard(
                onTap: _saving ? null : _artSheet,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    artPreview(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.artwork, style: context.t.title),
                          Text(artStatus, style: context.t.meta),
                        ],
                      ),
                    ),
                    Text(
                      l.change,
                      style: context.t.meta.copyWith(color: c.primary, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              field(_artist, l.fieldArtist, mixed: _mixedArtist),
              field(_name, l.fieldAlbum, mixed: _mixedAlbum),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: field(
                      _year,
                      l.fieldYear,
                      mixed: _mixedYear,
                      keyboard: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                      validator: (v) {
                        final s = (v ?? '').trim();
                        return s.isEmpty || RegExp(r'^\d{4}$').hasMatch(s) ? null : l.yearInvalid;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: field(
                      _total,
                      l.fieldTrackTotal,
                      hint: '${_tracks.length}',
                      keyboard: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                      validator: (v) {
                        final s = (v ?? '').trim();
                        return s.isEmpty || (int.tryParse(s) ?? 0) > 0 ? null : l.numberInvalid;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LyraBanner(icon: Icons.info_outline_rounded, title: l.editAlbum, text: l.albumEditInfo(_tracks.length)),
            ],
          ),
        ),
      ),
    );
  }
}
