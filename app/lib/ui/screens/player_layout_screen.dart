import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import 'player_screen.dart';

/// Ligne de réglage avec interrupteur.
class SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool on;
  final ValueChanged<bool> onChanged;
  const SwitchRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    required this.on,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SettingRow(
    icon: icon,
    title: title,
    value: value,
    onTap: () => onChanged(!on),
    trailing: Switch(value: on, onChanged: onChanged),
  );
}

/// Personnalisation de l'écran de lecture, de la file d'attente et du mini-lecteur
/// (inspiré d'Oto Music) : chaque élément s'affiche ou se masque.
class PlayerLayoutScreen extends StatelessWidget {
  const PlayerLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<SettingsController>();

    Widget sw(Toggle t, IconData icon, String title, [String? value]) =>
        SwitchRow(icon: icon, title: title, value: value, on: s.on(t), onChanged: (v) => s.set(t, v));

    Widget choice<T>(List<(T, IconData, String)> options, T current, ValueChanged<T> onPick) => Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          for (final (value, icon, label) in options) ...[
            Expanded(
              child: _ChoiceTile(icon: icon, label: label, selected: value == current, onTap: () => onPick(value)),
            ),
            if (value != options.last.$1) const SizedBox(width: 8),
          ],
        ],
      ),
    );

    return Scaffold(
      appBar: LyraAppBar(
        title: l.playerLayout,
        subtitle: l.settings,
        actions: [
          LyraIconButton(
            icon: Icons.play_circle_outline_rounded,
            tooltip: l.preview,
            onPressed: () => openPlayer(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        children: [
          Text(l.playerLayoutHint, style: context.t.meta),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.artwork,
            children: [
              choice(
                [
                  (ArtworkStyle.rounded, Icons.rounded_corner_rounded, l.artRounded),
                  (ArtworkStyle.square, Icons.crop_square_rounded, l.artSquare),
                  (ArtworkStyle.vinyl, Icons.album_rounded, l.artVinyl),
                ],
                s.artworkStyle,
                s.setArtworkStyle,
              ),
              choice(
                [
                  (PlayerBackground.blur, Icons.blur_on_rounded, l.bgBlur),
                  (PlayerBackground.gradient, Icons.gradient_rounded, l.bgGradient),
                  (PlayerBackground.plain, Icons.square_outlined, l.bgPlain),
                ],
                s.playerBackground,
                s.setPlayerBackground,
              ),
              sw(Toggle.playerSwipe, Icons.swipe_rounded, l.optSwipe, l.optSwipeSub),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.groupInfo,
            children: [
              sw(Toggle.playerAlbumInfo, Icons.album_outlined, l.optAlbumInfo),
              sw(Toggle.playerFormat, Icons.graphic_eq_rounded, l.optFormat, 'FLAC · 1002 kbps · 44.1 kHz'),
              sw(Toggle.playerRemaining, Icons.timelapse_rounded, l.optRemaining, l.optRemainingSub),
              sw(Toggle.playerNextUp, Icons.skip_next_outlined, l.optNextUp),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.groupControls,
            children: [
              sw(Toggle.playerVolume, Icons.volume_up_outlined, l.optVolume, l.optVolumeSub),
              sw(Toggle.playerFavorite, Icons.favorite_border_rounded, l.optFavorite),
              sw(Toggle.playerShuffleRepeat, Icons.shuffle_rounded, l.optShuffleRepeat),
              sw(Toggle.playerSeekButtons, Icons.forward_10_rounded, l.optSeekButtons, l.optSeekButtonsSub),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.groupActionBar,
            children: [
              sw(Toggle.actionQueue, Icons.queue_music_rounded, l.queue),
              sw(Toggle.actionLyrics, Icons.lyrics_outlined, l.lyrics),
              sw(Toggle.actionSleep, Icons.bedtime_outlined, l.sleepTimer),
              sw(Toggle.actionSpeed, Icons.speed_rounded, l.playbackSpeed),
              sw(Toggle.actionEqualizer, Icons.equalizer_rounded, l.equalizer),
              sw(Toggle.actionPlaylist, Icons.playlist_add_rounded, l.addToPlaylist),
              sw(Toggle.actionDetails, Icons.info_outline_rounded, l.songDetails),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.queue,
            children: [
              sw(Toggle.queueNowPlaying, Icons.music_note_outlined, l.optQueueNowPlaying),
              sw(Toggle.queueArtwork, Icons.image_outlined, l.optQueueArtwork),
              sw(Toggle.queueDuration, Icons.schedule_rounded, l.optQueueDuration),
              sw(Toggle.queueSwipeRemove, Icons.swipe_left_rounded, l.optQueueSwipe),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.miniPlayer,
            children: [
              sw(Toggle.miniProgress, Icons.linear_scale_rounded, l.optMiniProgress),
              sw(Toggle.miniFavorite, Icons.favorite_border_rounded, l.optFavorite),
              sw(Toggle.miniNext, Icons.skip_next_rounded, l.optMiniNext),
            ],
          ),
          const SizedBox(height: 20),
          LyraButton(
            label: l.resetLayout,
            icon: Icons.restart_alt_rounded,
            variant: BtnVariant.secondary,
            full: true,
            onPressed: () {
              s.resetPlayerLayout();
              context.toast(l.resetLayoutDone);
            },
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceTile({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Press(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface2,
          borderRadius: BorderRadius.circular(radiusS),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: selected ? c.onPrimary : c.text2),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.t.meta.copyWith(color: selected ? c.onPrimary : c.text, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
