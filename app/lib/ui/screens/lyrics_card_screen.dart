import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/card_export.dart';
import '../../models/track.dart';
import '../../state/library.dart';
import '../../state/lyrics_store.dart';
import '../../state/settings.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/library_widgets.dart';
import '../widgets/lyrics_card_canvas.dart';
import '../widgets/track_tile.dart';

/// Création d'une LyricsCard : un extrait de paroles (113 caractères au plus)
/// sur un fond personnalisable, exporté en JPEG haute résolution.
/// Onglets : Texte · Image · Police, avec aperçu en direct.
class LyricsCardScreen extends StatefulWidget {
  final int? trackId;
  const LyricsCardScreen({super.key, this.trackId});

  @override
  State<LyricsCardScreen> createState() => _LyricsCardScreenState();
}

class _LyricsCardScreenState extends State<LyricsCardScreen> {
  final _boundary = GlobalKey();
  final _lyrics = TextEditingController();
  Track? _track;
  bool _loading = false;
  int _tab = 0;
  CardStyle _style = const CardStyle();
  TextSelection? _range;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _lyrics.addListener(_onSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickInitial());
  }

  @override
  void dispose() {
    _lyrics.dispose();
    super.dispose();
  }

  List<Track> _withLyrics() {
    final store = context.read<LyricsStore>();
    return context
        .read<LibraryController>()
        .sorted(SongSort.title)
        .where((t) => store.status(t) != LyricsStatus.none)
        .toList();
  }

  /// Morceau demandé, sinon celui qui joue s'il a des paroles, sinon le premier qui en a.
  void _pickInitial() {
    final lib = context.read<LibraryController>();
    final store = context.read<LyricsStore>();
    bool has(Track? t) => t != null && store.status(t) != LyricsStatus.none;
    final asked = widget.trackId == null ? null : lib.byId(widget.trackId!);
    final playing = context.audio.current;
    final pick = has(asked) ? asked : (has(playing) ? playing : _withLyrics().firstOrNull);
    if (pick != null) _load(pick);
  }

  Future<void> _load(Track t) async {
    setState(() {
      _track = t;
      _loading = true;
      _range = null;
      // La pochette du morceau est le fond par défaut ; sans pochette, un fond prédéfini.
      if (_style.background == CardBackground.artwork && t.art == null) {
        _style = _style.copyWith(background: CardBackground.preset);
      }
    });
    final text = await context.read<LyricsStore>().plainTextFor(t);
    if (!mounted || _track?.id != t.id) return;
    // Lignes vides superflues retirées : la sélection reste lisible.
    _lyrics.value = TextEditingValue(text: text.replaceAll(RegExp(r'\n{3,}'), '\n\n'));
    setState(() => _loading = false);
  }

  void _onSelection() {
    final sel = _lyrics.selection;
    if (sel.isValid && !sel.isCollapsed) _range = sel;
    setState(() {});
  }

  /// Toucher une ligne la sélectionne ; toucher une autre ligne étend la sélection.
  /// L'appui long et les poignées permettent d'ajuster au caractère près.
  void _onTapLyrics() {
    final text = _lyrics.text;
    final pos = _lyrics.selection.baseOffset;
    if (pos < 0 || text.isEmpty) return;
    var start = text.lastIndexOf('\n', pos > 0 ? pos - 1 : 0);
    start = start < 0 ? 0 : start + 1;
    if (pos == 0) start = 0;
    var end = text.indexOf('\n', pos);
    if (end < 0) end = text.length;
    var next = TextSelection(baseOffset: start, extentOffset: end);
    final prev = _range;
    if (prev != null && !prev.isCollapsed && (pos < prev.start || pos > prev.end)) {
      next = TextSelection(
        baseOffset: start < prev.start ? start : prev.start,
        extentOffset: end > prev.end ? end : prev.end,
      );
    }
    Haptics.select();
    _range = next;
    _lyrics.selection = next;
  }

  String get _selected {
    final r = _range;
    if (r == null || r.isCollapsed || r.end > _lyrics.text.length) return '';
    return r.textInside(_lyrics.text).trim();
  }

  Future<void> _chooseSong() async {
    final t = await context.push<Track>(_SongPicker(tracks: _withLyrics()));
    if (t != null && t.id != _track?.id) _load(t);
  }

  Future<void> _fromGallery() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2160,
      maxHeight: 2160,
      imageQuality: 95,
    );
    if (file == null) return;
    setState(() => _style = _style.copyWith(background: CardBackground.gallery, galleryPath: file.path));
  }

  Future<ui.Image> _render() async {
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: cardExportScale);
  }

  Future<void> _export() async {
    final l = context.l;
    final share = await showLyraSheet<bool>(
      context,
      title: l.lcExport,
      builder: (sheet) => Column(
        children: [
          SheetAction(icon: Icons.download_rounded, label: l.lcSave, onTap: () => Navigator.of(sheet).pop(false)),
          SheetAction(icon: Icons.ios_share_rounded, label: l.lcShare, onTap: () => Navigator.of(sheet).pop(true)),
        ],
      ),
    );
    if (share == null || !mounted) return;
    setState(() => _exporting = true);
    try {
      final image = await _render();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final png = data!.buffer.asUint8List();
      final name = 'LyraCard_${fnv(_track!.title)}_${DateTime.now().millisecondsSinceEpoch}';
      if (share) {
        await CardExport.share(png, name, title: l.lcShare);
      } else {
        final ok = await CardExport.save(png, name);
        if (mounted) {
          context.toast(ok ? l.lcSaved : l.lcSaveDenied, icon: ok ? Icons.check_rounded : Icons.block_rounded);
        }
      }
    } catch (e) {
      debugPrint('LyricsCard export: $e');
      if (mounted) context.toast(l.lcError, icon: Icons.error_outline_rounded);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final track = _track;
    final count = _selected.length;
    final valid = count > 0 && count <= cardMaxChars;

    if (track == null) {
      return Scaffold(
        appBar: LyraAppBar(title: l.lcCreate, backIcon: Icons.close_rounded),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [LyraEmptyState(icon: Icons.lyrics_outlined, title: l.lcNoSongs, text: l.lcNoSongsBody)],
        ),
      );
    }

    final canvas = RepaintBoundary(
      key: _boundary,
      child: LyricsCardCanvas(
        style: _style,
        text: _selected,
        title: track.title,
        artist: track.artist,
        artPath: track.art,
        placeholder: l.lcPlaceholder,
      ),
    );

    return Scaffold(
      appBar: LyraAppBar(
        title: l.lcCreate,
        backIcon: Icons.close_rounded,
        actions: [
          LyraButton(
            label: l.lcExport,
            icon: Icons.ios_share_rounded,
            small: true,
            onPressed: valid && !_exporting ? _export : null,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Aperçu en direct, mis à l'échelle de l'écran (rendu identique à l'export).
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Container(
                    key: ValueKey(_style.ratio),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radiusM),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FittedBox(child: canvas),
                  ),
                ),
              ),
            ),
          ),
          UnderlineTabs(
            labels: [l.lcTabText, l.lcTabImage, l.lcTabFont],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          Expanded(
            flex: 6,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: switch (_tab) {
                  0 => _textTab(context, track, count),
                  1 => _imageTab(context, track),
                  _ => _fontTab(context),
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: _tab < 2
                  ? LyraButton(label: l.lcContinue, full: true, onPressed: valid ? () => setState(() => _tab++) : null)
                  : LyraButton(
                      label: l.lcExport,
                      icon: Icons.ios_share_rounded,
                      full: true,
                      onPressed: valid && !_exporting ? _export : null,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Texte

  Widget _textTab(BuildContext context, Track track, int count) {
    final l = context.l;
    final c = context.c;
    // Vert, puis orange à l'approche de la limite, rouge au-delà.
    final color = count > cardMaxChars ? c.error : (count > cardMaxChars * 0.8 ? c.warning : c.success);
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
          leading: Artwork(path: track.art, size: 42, radius: 10, seed: track.album ?? track.title),
          title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.title),
          subtitle: Text(artistName(context, track.artist), maxLines: 1, style: context.t.meta),
          trailing: LyraButton(label: l.lcChange, small: true, variant: BtnVariant.tonal, onPressed: _chooseSong),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(l.lcSelectHint, style: context.t.meta.copyWith(color: c.text3)),
              ),
              if (count > 0)
                LyraIconButton(
                  icon: Icons.backspace_outlined,
                  tooltip: l.lcClear,
                  size: 18,
                  box: 36,
                  color: c.text3,
                  onPressed: () {
                    _range = null;
                    _lyrics.selection = const TextSelection.collapsed(offset: 0);
                  },
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                child: Text(
                  '$count / $cardMaxChars',
                  style: context.t.tech.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        if (count > cardMaxChars)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(l.lcTooLong, style: context.t.meta.copyWith(color: c.error)),
            ),
          ),
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: c.primary, strokeWidth: 2.4))
              : TextField(
                  controller: _lyrics,
                  readOnly: true,
                  showCursor: false,
                  maxLines: null,
                  expands: true,
                  onTap: _onTapLyrics,
                  // Pas de menu Copier/Coller : seule la sélection compte ici.
                  contextMenuBuilder: (_, _) => const SizedBox.shrink(),
                  style: context.t.title.copyWith(fontSize: 16, height: 1.65, color: c.text),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(20, 4, 20, 16),
                  ),
                ),
        ),
      ],
    );
  }

  // ---- Image

  Widget _imageTab(BuildContext context, Track track) {
    final l = context.l;
    final c = context.c;
    final s = _style;
    Widget tile({required bool selected, required VoidCallback onTap, required Widget child, String? label}) => Press(
      onTap: () {
        Haptics.select();
        onTap();
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? c.primary : Colors.transparent, width: 2.5),
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(label, style: context.t.meta.copyWith(fontSize: 11.5)),
          ],
        ],
      ),
    );
    final image = s.background != CardBackground.preset;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (track.art != null)
              tile(
                selected: s.background == CardBackground.artwork,
                label: l.lcArtwork,
                onTap: () => setState(() => _style = s.copyWith(background: CardBackground.artwork)),
                child: Artwork(path: track.art, size: 56, radius: 0, seed: track.title),
              ),
            tile(
              selected: s.background == CardBackground.gallery,
              label: l.lcGallery,
              onTap: _fromGallery,
              child: ColoredBox(
                color: c.surface2,
                child: Icon(Icons.add_photo_alternate_outlined, color: c.text2),
              ),
            ),
            for (final p in cardPresets)
              tile(
                selected: s.background == CardBackground.preset && s.preset == p.id,
                onTap: () => setState(() => _style = s.copyWith(background: CardBackground.preset, preset: p.id)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: p.colors),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        ),
        if (image) ...[
          const SizedBox(height: 14),
          _SliderRow(
            icon: Icons.brightness_6_outlined,
            label: l.lcDim,
            value: s.dim,
            max: 0.8,
            onChanged: (v) => setState(() => _style = s.copyWith(dim: v)),
          ),
          _SliderRow(
            icon: Icons.blur_on_rounded,
            label: l.lcBlur,
            value: s.blur,
            max: 20,
            onChanged: (v) => setState(() => _style = s.copyWith(blur: v)),
          ),
        ],
        const SizedBox(height: 14),
        Text(l.lcFormat.toUpperCase(), style: context.t.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final r in CardRatio.values)
              LyraChip(
                label: r.label,
                active: s.ratio == r,
                onTap: () => setState(() => _style = s.copyWith(ratio: r)),
              ),
          ],
        ),
      ],
    );
  }

  // ---- Police

  Widget _fontTab(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final s = _style;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      children: [
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cardFonts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final f = cardFonts[i];
              final on = s.font == f.id;
              return Press(
                onTap: () {
                  Haptics.select();
                  setState(() => _style = s.copyWith(font: f.id));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 84,
                  decoration: BoxDecoration(
                    color: on ? c.primary.withValues(alpha: 0.14) : c.surface,
                    borderRadius: BorderRadius.circular(radiusM),
                    border: Border.all(color: on ? c.primary : c.divider, width: on ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(f.upper ? 'AA' : 'Aa', style: f.textStyle(22, on ? c.primary : c.text)),
                      const SizedBox(height: 2),
                      Text(f.label, style: context.t.meta.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _SliderRow(
          icon: Icons.format_size_rounded,
          label: l.lcSize,
          value: s.fontSize,
          min: 16,
          max: 44,
          onChanged: (v) => setState(() => _style = s.copyWith(fontSize: v)),
        ),
        const SizedBox(height: 6),
        Text(l.lcAlign.toUpperCase(), style: context.t.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(radiusM)),
          child: Row(
            children: [
              for (final (a, icon) in const [
                (TextAlign.left, Icons.format_align_left_rounded),
                (TextAlign.center, Icons.format_align_center_rounded),
                (TextAlign.right, Icons.format_align_right_rounded),
                (TextAlign.justify, Icons.format_align_justify_rounded),
              ])
                Expanded(
                  child: Press(
                    onTap: () => setState(() => _style = s.copyWith(align: a)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: s.align == a ? c.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(radiusS),
                      ),
                      child: Icon(icon, size: 20, color: s.align == a ? c.primary : c.text3),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(l.lcColor.toUpperCase(), style: context.t.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: [
            for (final col in cardTextColors)
              Press(
                onTap: () => setState(() => _style = s.copyWith(textColor: () => col)),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: col ?? c.surface2,
                    border: Border.all(
                      color: s.textColor == col ? c.primary : c.dividerStrong,
                      width: s.textColor == col ? 2.5 : 1,
                    ),
                  ),
                  child: col == null ? Center(child: Text(l.auto, style: context.t.meta.copyWith(fontSize: 10))) : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.lcShowInfo, style: context.t.title),
          value: s.showInfo,
          onChanged: (v) => setState(() => _style = s.copyWith(showInfo: v)),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    this.min = 0,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: context.c.text2),
      const SizedBox(width: 10),
      SizedBox(width: 82, child: Text(label, style: context.t.title.copyWith(fontSize: 13.5))),
      Expanded(
        child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ),
    ],
  );
}

/// Choix d'une chanson, limité à celles qui ont des paroles.
class _SongPicker extends StatefulWidget {
  final List<Track> tracks;
  const _SongPicker({required this.tracks});

  @override
  State<_SongPicker> createState() => _SongPickerState();
}

class _SongPickerState extends State<_SongPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = fold(_q.trim());
    final list = q.isEmpty ? widget.tracks : widget.tracks.where((t) => t.searchText.contains(q)).toList();
    return Scaffold(
      appBar: LyraAppBar(title: l.lcPickSong, subtitle: l.songsCount(widget.tracks.length)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: l.searchSongs),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [LyraEmptyState(icon: Icons.lyrics_outlined, title: l.lcNoSongs, text: l.lcNoSongsBody)],
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) =>
                        TrackTile(track: list[i], showPlay: false, onTap: () => Navigator.of(context).pop(list[i])),
                  ),
          ),
        ],
      ),
    );
  }
}
