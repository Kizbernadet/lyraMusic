import 'package:flutter/material.dart';

import '../../models/track.dart';
import '../theme.dart';
import 'artwork.dart';
import 'common.dart';
import 'kit.dart';

/// Onglets soulignés (Suggestions, Titres, Artistes…), défilables.
class UnderlineTabs extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const UnderlineTabs({super.key, required this.labels, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.divider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: labels.length,
        itemBuilder: (context, i) {
          final active = i == index;
          return Semantics(
            selected: active,
            button: true,
            child: InkWell(
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      labels[i],
                      style: context.t.title.copyWith(
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? c.primary : c.text3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      width: active ? 36 : 0,
                      decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(3)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Option de tri affichée dans le menu.
class SortOption<T> {
  final T value;
  final String label;
  const SortOption(this.value, this.label);
}

/// Barre « 1 544 titres ............ Titre ⇅ » avec menu de tri à boutons radio.
class ListHeaderBar<T> extends StatelessWidget {
  final String count;
  final List<SortOption<T>> options;
  final T current;
  final bool ascending;
  final ValueChanged<T> onSort;
  final ValueChanged<bool> onAscending;
  final Widget? leading;

  const ListHeaderBar({
    super.key,
    required this.count,
    required this.options,
    required this.current,
    required this.ascending,
    required this.onSort,
    required this.onAscending,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    final label = options.firstWhere((o) => o.value == current, orElse: () => options.first).label;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
      child: Row(
        children: [
          Expanded(child: Text(count, style: context.t.h3)),
          ?leading,
          Builder(
            builder: (btnContext) => Press(
              onTap: () => _open(btnContext),
              semanticLabel: l.sortBy,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: context.t.title.copyWith(color: c.primary, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 17,
                      color: c.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext btnContext) async {
    final l = btnContext.l;
    final c = btnContext.c;
    final box = btnContext.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(btnContext).context.findRenderObject()! as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    PopupMenuItem<Object> item(Object value, String text, bool selected) => PopupMenuItem<Object>(
      value: value,
      height: 46,
      child: Row(
        children: [
          Expanded(child: Text(text, style: btnContext.t.title)),
          const SizedBox(width: 18),
          Icon(
            selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
            size: 20,
            color: selected ? c.primary : c.text3,
          ),
        ],
      ),
    );
    final picked = await showMenu<Object>(
      context: btnContext,
      position: pos,
      items: [
        item(true, l.ascending, ascending),
        item(false, l.descending, !ascending),
        const PopupMenuDivider(),
        for (final o in options) item(o, o.label, o.value == current),
      ],
    );
    if (picked is bool) onAscending(picked);
    if (picked is SortOption<T>) onSort(picked.value);
  }
}

/// En-tête d'une page de détail (artiste, album, dossier, playlist) :
/// grande image centrée, nom, informations, boutons Aléatoire et Lecture.
class DetailHeader extends StatelessWidget {
  final Widget cover;
  final String title;
  final List<String> meta;
  final VoidCallback? onShuffle;
  final VoidCallback? onPlay;
  const DetailHeader({
    super.key,
    required this.cover,
    required this.title,
    required this.meta,
    this.onShuffle,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: [
          cover,
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.t.h1),
          const SizedBox(height: 6),
          Text(meta.join('   |   '), textAlign: TextAlign.center, style: context.t.meta),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: LyraButton(label: l.shuffle, icon: Icons.shuffle_rounded, full: true, onPressed: onShuffle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LyraButton(
                  label: l.play,
                  icon: Icons.play_circle_fill_rounded,
                  full: true,
                  variant: BtnVariant.tonal,
                  onPressed: onPlay,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: c.divider),
        ],
      ),
    );
  }
}

/// Ligne « artiste » : photo ronde, nom, « 1 album | 20 titres ».
class ArtistRow extends StatelessWidget {
  final Group artist;
  final VoidCallback onTap;
  const ArtistRow({super.key, required this.artist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final name = artist.name ?? l.unknownArtist;
    final albums = artist.tracks.map((t) => t.albumKey).toSet().length;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
        child: Row(
          children: [
            Artwork(path: artist.art, size: 54, radius: 27, seed: name, icon: Icons.person_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text('${l.albumsCount(albums)}  |  ${l.songsCount(artist.tracks.length)}', style: context.t.meta),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.c.text3),
          ],
        ),
      ),
    );
  }
}

/// Ligne « dossier » : icône dossier dans la couleur principale.
class FolderRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback onTap;
  const FolderRow({super.key, required this.name, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
        child: Row(
          children: [
            FolderIcon(size: 54, color: c.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.title.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.meta),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: c.text3),
          ],
        ),
      ),
    );
  }
}

/// Dossier dessiné (onglet + corps), comme dans la maquette.
class FolderIcon extends StatelessWidget {
  final double size;
  final Color color;
  const FolderIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: size * 0.10,
            child: Container(
              width: size * 0.48,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: Color.lerp(color, Colors.black, 0.2),
                borderRadius: BorderRadius.circular(size * 0.12),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: size * 0.08,
            top: size * 0.22,
            child: Container(
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.16)),
              child: Center(
                child: Container(
                  width: size * 0.36,
                  height: size * 0.06,
                  decoration: BoxDecoration(color: c.onPrimary, borderRadius: BorderRadius.circular(size)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte carrée (album, morceau) pour les carrousels et la grille.
class SquareCard extends StatelessWidget {
  final String? art;
  final String seed;
  final String title;
  final String? subtitle;
  final double size;
  final bool round;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const SquareCard({
    super.key,
    required this.art,
    required this.seed,
    required this.title,
    this.subtitle,
    required this.size,
    this.round = false,
    this.icon = Icons.music_note_rounded,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Press(
    onTap: onTap,
    onLongPress: onLongPress,
    child: SizedBox(
      width: size,
      child: Column(
        crossAxisAlignment: round ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Artwork(path: art, size: size, radius: round ? size / 2 : 16, seed: seed, icon: icon),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: round ? 1 : 2,
            textAlign: round ? TextAlign.center : TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: context.t.title.copyWith(fontWeight: FontWeight.w700, height: 1.25),
          ),
          if (subtitle != null) Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.meta),
        ],
      ),
    ),
  );
}
