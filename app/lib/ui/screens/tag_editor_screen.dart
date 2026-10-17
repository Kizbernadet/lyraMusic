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

/// Éditeur de tags (prototype 19 et 21) : écriture dans le fichier audio.
class TagEditorScreen extends StatefulWidget {
  final int trackId;
  const TagEditorScreen({super.key, required this.trackId});

  @override
  State<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends State<TagEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final Track _track = context.read<LibraryController>().byId(widget.trackId)!;
  late final _title = TextEditingController(text: _track.title);
  late final _artist = TextEditingController(text: _track.artist ?? '');
  late final _album = TextEditingController(text: _track.album ?? '');
  late final _albumArtist = TextEditingController(text: _track.albumArtist ?? '');
  late final _genre = TextEditingController(text: _track.genre ?? '');
  late final _year = TextEditingController(text: _track.year?.toString() ?? '');
  late final _trackNo = TextEditingController(text: _track.trackNumber?.toString() ?? '');

  bool _artChanged = false;
  Uint8List? _artBytes;
  String _artMime = 'image/jpeg';
  bool _saving = false;

  List<TextEditingController> get _fields => [_title, _artist, _album, _albumArtist, _genre, _year, _trackNo];

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

  bool get _dirty =>
      _artChanged ||
      _title.text.trim() != _track.title ||
      _v(_artist) != _track.artist ||
      _v(_album) != _track.album ||
      _v(_albumArtist) != _track.albumArtist ||
      _v(_genre) != _track.genre ||
      _v(_year) != _track.year?.toString() ||
      _v(_trackNo) != _track.trackNumber?.toString();

  bool get _hasArt => _artChanged ? _artBytes != null : _track.art != null;

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

  void _removeArt() => setState(() {
    _artChanged = true;
    _artBytes = null;
  });

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
                _removeArt();
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
    setState(() => _saving = true);
    final edit = TagEdit(
      title: _title.text.trim(),
      artist: _v(_artist),
      album: _v(_album),
      albumArtist: supportsAlbumArtist(_track) ? _v(_albumArtist) : _track.albumArtist,
      genre: _v(_genre),
      year: _v(_year) == null ? null : int.parse(_year.text.trim()),
      trackNumber: _v(_trackNo) == null ? null : int.parse(_trackNo.text.trim()),
      artChanged: _artChanged,
      artBytes: _artBytes,
      artMime: _artMime,
    );
    // Le fichier en cours de lecture est libéré pendant l'écriture (CA-35).
    final resume = await audio.releaseIfCurrent(_track.id);
    try {
      final updated = await writeTags(_track, edit, artDir: library.artDir);
      await library.replaceTrack(updated, previousArt: _track.art);
      audio.updateTrack(updated);
      if (!mounted) return;
      context.toast(l.tagsSaved);
      Navigator.of(context).pop();
    } on TagWriteException catch (e) {
      debugPrint('Tag write failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(e.kind == TagWriteError.denied ? l.tagsErrorDenied : l.tagsErrorWrite);
    } finally {
      await audio.resumeAfterEdit(resume);
    }
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
    final albumArtistOk = supportsAlbumArtist(_track);

    Widget field(
      TextEditingController ctrl,
      String label, {
      String? Function(String?)? validator,
      TextInputType? keyboard,
      List<TextInputFormatter>? formatters,
      bool enabled = true,
      String? helper,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: context.t.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            enabled: enabled && !_saving,
            validator: validator,
            keyboardType: keyboard,
            inputFormatters: formatters,
            textCapitalization: keyboard == null ? TextCapitalization.sentences : TextCapitalization.none,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: context.t.title,
            decoration: InputDecoration(hintText: '—', helperText: helper),
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
      return Artwork(
        path: _artChanged ? null : _track.art,
        size: 64,
        radius: radiusS,
        seed: _track.album ?? _track.title,
      );
    }

    final artStatus = _artChanged
        ? (_artBytes != null ? l.artworkNew : l.artworkNone)
        : (_track.art != null ? l.artworkEmbedded : l.artworkNone);

    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: LyraAppBar(
          title: l.editTags,
          subtitle: l.fileOfType(_track.extension.toUpperCase()),
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
              field(_title, l.fieldTitle, validator: (v) => (v ?? '').trim().isEmpty ? l.titleRequired : null),
              field(_artist, l.fieldArtist),
              field(_album, l.fieldAlbum),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: field(_genre, l.fieldGenre)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: field(
                      _trackNo,
                      l.fieldTrackNumber,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: field(
                      _year,
                      l.fieldYear,
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
                      _albumArtist,
                      l.fieldAlbumArtist,
                      enabled: albumArtistOk,
                      helper: albumArtistOk ? null : l.notSupportedForFormat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LyraBanner(
                icon: Icons.info_outline_rounded,
                title: l.fileOfType(_track.extension.toUpperCase()),
                text: l.tagsWriteInfo,
              ),
              const SizedBox(height: 12),
              Text(_track.fileName, style: context.t.tech),
            ],
          ),
        ),
      ),
    );
  }
}
