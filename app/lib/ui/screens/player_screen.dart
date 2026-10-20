import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../audio/handler.dart';
import '../../data/lyrics.dart';
import '../../data/system_bridge.dart';
import '../../models/track.dart';
import '../../state/collections.dart';
import '../../state/lyrics_store.dart';
import '../../state/settings.dart';
import '../../utils/text.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/playback_sheets.dart';
import '../widgets/track_tile.dart';
import 'details_screen.dart';
import 'equalizer_screen.dart';
import 'home_screen.dart';
import 'lyrics_card_screen.dart';
import 'lyrics_editor_screen.dart';
import 'lyrics_sync_screen.dart';
import 'queue_screen.dart';

void openPlayer(BuildContext context, {bool lyrics = false}) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => PlayerScreen(startWithLyrics: lyrics),
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: lyraCurve)),
        child: child,
      ),
    ),
  );
}

/// Pousse un écran plein en glissant du bas (file d'attente).
Future<void> pushSheetRoute(BuildContext context, Widget page) => Navigator.of(context, rootNavigator: true).push(
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, anim, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: lyraCurve)),
      child: FadeTransition(opacity: anim, child: child),
    ),
  ),
);

/// Lecteur plein écran : pochette, titre, progression, commandes, puis
/// « Paroles » qui fait remonter les paroles sur le même écran.
/// Chaque élément s'affiche ou se masque dans Réglages › Écran de lecture.
class PlayerScreen extends StatefulWidget {
  final bool startWithLyrics;
  const PlayerScreen({super.key, this.startWithLyrics = false});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late bool _lyrics = widget.startWithLyrics;

  // Glisser vers le bas pour fermer (comme une feuille iOS).
  double _drag = 0;
  late final AnimationController _back;
  double _backFrom = 0;

  @override
  void initState() {
    super.initState();
    // Créé ici et non à la demande : sinon le premier accès pourrait avoir lieu dans dispose().
    _back = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))
      ..addListener(() => setState(() => _drag = _backFrom * (1 - Curves.easeOutCubic.transform(_back.value))));
  }

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_lyrics) return;
    _back.stop();
    setState(() => _drag = (_drag + d.delta.dy).clamp(0.0, 2000.0));
  }

  void _onDragEnd(DragEndDetails d) {
    if (_lyrics) return;
    if (_drag > 140 || (d.primaryVelocity ?? 0) > 900) {
      Haptics.select();
      Navigator.of(context).pop();
      return;
    }
    _backFrom = _drag;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return CurrentTrackBuilder(
      builder: (context, track) {
        final l = context.l;
        if (track == null) {
          return Scaffold(
            appBar: const LyraAppBar(title: '', backIcon: Icons.keyboard_arrow_down_rounded),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: LyraEmptyState(icon: Icons.queue_music_rounded, title: l.queueEmpty, text: l.queueEmptyBody),
            ),
          );
        }
        return PopScope(
          canPop: !_lyrics,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) setState(() => _lyrics = false);
          },
          child: GestureDetector(
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            child: Transform.translate(
              offset: Offset(0, _drag),
              child: Transform.scale(
                scale: 1 - (_drag / 3000).clamp(0.0, 0.08),
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular((_drag / 4).clamp(0.0, 32.0)),
                  child: Scaffold(
                    body: Stack(
                      children: [
                        Positioned.fill(
                          child: PlayerBackdrop(track: track, style: settings.playerBackground),
                        ),
                        SafeArea(
                          child: _PlayerBody(
                            track: track,
                            settings: settings,
                            lyrics: _lyrics,
                            onLyrics: (v) => setState(() => _lyrics = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Fond du lecteur : uni (par défaut), pochette floutée ou dégradé de sa couleur.
class PlayerBackdrop extends StatelessWidget {
  final Track track;
  final PlayerBackground style;
  const PlayerBackdrop({super.key, required this.track, required this.style});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    switch (style) {
      case PlayerBackground.blur:
        return Ambient(art: track.art, seed: track.album ?? track.title);
      case PlayerBackground.plain:
        return ColoredBox(color: c.bg);
      case PlayerBackground.gradient:
        return FutureBuilder<Color?>(
          future: dominantColor(track.art),
          builder: (context, snap) {
            final tint = snap.data ?? placeholderColors(track.album ?? track.title).first;
            return TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: tint),
              duration: const Duration(milliseconds: 500),
              builder: (_, color, _) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.lerp(color, c.bg, 0.35)!, Color.lerp(color, c.bg, 0.8)!, c.bg],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            );
          },
        );
    }
  }
}

class _PlayerBody extends StatelessWidget {
  final Track track;
  final SettingsController settings;
  final bool lyrics;
  final ValueChanged<bool> onLyrics;
  const _PlayerBody({required this.track, required this.settings, required this.lyrics, required this.onLyrics});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final audio = context.audio;
    final fav = context.watch<CollectionsController>().isFavorite(track.id);
    bool on(Toggle t) => settings.on(t);

    final topBar = Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          LyraIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            size: 32,
            color: c.text,
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => lyrics ? onLyrics(false) : Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              (lyrics ? l.lyrics : l.nowPlaying).toUpperCase(),
              textAlign: TextAlign.center,
              style: context.t.label,
            ),
          ),
          LyraIconButton(
            icon: Icons.more_vert_rounded,
            color: c.text,
            tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
            onPressed: () => showTrackMenu(context, track),
          ),
        ],
      ),
    );

    // Titre et artiste centrés, ♡ à droite (et « ajouter à une playlist » à gauche pour l'équilibre).
    final titleBlock = Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: on(Toggle.playerFavorite)
                ? LyraIconButton(
                    icon: Icons.playlist_add_rounded,
                    size: 24,
                    color: c.text2,
                    tooltip: l.addToPlaylist,
                    onPressed: () => showAddToPlaylist(context, [track]),
                  )
                : null,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  track.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.h1,
                ),
                const SizedBox(height: 4),
                Text(
                  artistName(context, track.artist),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.body.copyWith(color: c.text2),
                ),
                if (on(Toggle.playerAlbumInfo))
                  Text(
                    [albumName(context, track.album), if (track.year != null) '${track.year}'].join('  |  '),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.meta.copyWith(color: c.text3),
                  ),
                if (on(Toggle.playerFormat))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(formatLabel(track), style: context.t.tech),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: on(Toggle.playerFavorite) ? _FavButton(fav: fav, onTap: () => toggleFavorite(context, track)) : null,
          ),
        ],
      ),
    );

    final controls = Column(
      children: [
        _SeekBar(track: track, remaining: on(Toggle.playerRemaining)),
        _Controls(
          audio: audio,
          seekButtons: on(Toggle.playerSeekButtons),
          shuffleRepeat: on(Toggle.playerShuffleRepeat),
        ),
        _SecondaryRow(
          track: track,
          settings: settings,
          extraShuffleRepeat: on(Toggle.playerSeekButtons) && on(Toggle.playerShuffleRepeat),
        ),
      ],
    );

    // Paysage : pochette (ou rappel + commandes) à gauche, le reste à droite.
    // Sur un écran aussi bas, une seule colonne déborderait.
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width > size.height;

    /// Colonne qui défile si la hauteur manque, et reste centrée sinon.
    Widget fit(List<Widget> children) => LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: children),
        ),
      ),
    );

    if (lyrics) {
      // Rappel compact du morceau
      final recap = Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(
          children: [
            Artwork(path: track.art, size: 48, radius: 10, seed: track.album ?? track.title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.title.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(artistName(context, track.artist), maxLines: 1, style: context.t.meta),
                ],
              ),
            ),
            _FavButton(fav: fav, onTap: () => toggleFavorite(context, track)),
          ],
        ),
      );
      final header = Padding(
        padding: EdgeInsets.fromLTRB(20, landscape ? 4 : 14, 8, 8),
        child: Row(
          children: [
            Expanded(child: Text(l.lyrics, style: context.t.h2, maxLines: 1, overflow: TextOverflow.ellipsis)),
            LyricsActions(track: track),
            LyraIconButton(
              icon: Icons.keyboard_arrow_down_rounded,
              color: c.text2,
              tooltip: l.artwork,
              onPressed: () => onLyrics(false),
            ),
          ],
        ),
      );
      final panel = Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: LyricsPanel(key: ValueKey('${track.id}-${context.watch<LyricsStore>().version}'), track: track),
        ),
      );
      if (landscape) {
        return Column(
          children: [
            topBar,
            Expanded(
              child: Row(
                children: [
                  Expanded(child: fit([recap, controls])),
                  Expanded(child: Column(children: [header, panel])),
                ],
              ),
            ),
          ],
        );
      }
      return Column(children: [topBar, recap, controls, header, panel]);
    }

    final artwork = LayoutBuilder(
      builder: (context, box) {
        final side = box.biggest.shortestSide.clamp(48.0, 360.0);
        final art = PlayerArtwork(track: track, size: side, style: settings.artworkStyle);
        return Center(
          child: on(Toggle.playerSwipe)
              ? GestureDetector(
                  onHorizontalDragEnd: (d) {
                    final v = d.primaryVelocity ?? 0;
                    if (v < -300) audio.skipToNext();
                    if (v > 300) audio.skipToPrevious();
                  },
                  onVerticalDragEnd: (d) {
                    if ((d.primaryVelocity ?? 0) < -300 && on(Toggle.actionLyrics)) onLyrics(true);
                  },
                  child: art,
                )
              : art,
        );
      },
    );
    final lyricsButton = on(Toggle.actionLyrics)
        ? InkWell(
            onTap: () => onLyrics(true),
            borderRadius: BorderRadius.circular(radiusM),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up_rounded, color: c.text2),
                  Text(l.lyrics, style: context.t.title.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          )
        : const SizedBox(height: 16);

    if (landscape) {
      return Column(
        children: [
          topBar,
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(padding: const EdgeInsets.fromLTRB(24, 4, 8, 16), child: artwork),
                ),
                Expanded(
                  flex: 6,
                  child: fit([
                    titleBlock,
                    controls,
                    if (on(Toggle.playerVolume)) const VolumeBar(),
                    if (on(Toggle.playerNextUp)) const _NextUp(),
                    lyricsButton,
                  ]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        topBar,
        Expanded(
          child: Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 16), child: artwork),
        ),
        titleBlock,
        const SizedBox(height: 6),
        controls,
        if (on(Toggle.playerVolume)) const VolumeBar(),
        if (on(Toggle.playerNextUp)) const _NextUp(),
        lyricsButton,
      ],
    );
  }
}

/// « FLAC · 1002 kbps · 44,1 kHz »
String formatLabel(Track t) {
  final b = t.bitrate;
  final kbps = b != null && b > 0
      ? '${b > 10000 ? (b / 1000).round() : b} kbps'
      : (t.durationMs > 0 ? '≈ ${(t.size * 8 / t.durationMs).round()} kbps' : null);
  return [
    t.extension.toUpperCase(),
    ?kbps,
    if (t.sampleRate != null) '${(t.sampleRate! / 1000).toStringAsFixed(1)} kHz',
  ].join(' · ');
}

/// Pochette selon le style choisi : arrondie, carrée, ou vinyle qui tourne.
class PlayerArtwork extends StatefulWidget {
  final Track track;
  final double size;
  final ArtworkStyle style;
  const PlayerArtwork({super.key, required this.track, required this.size, required this.style});

  @override
  State<PlayerArtwork> createState() => _PlayerArtworkState();
}

class _PlayerArtworkState extends State<PlayerArtwork> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 8));
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    final audio = context.audio;
    void sync(bool playing) {
      if (widget.style == ArtworkStyle.vinyl && playing) {
        _spin.repeat();
      } else {
        _spin.stop();
      }
    }

    sync(audio.playing.value);
    _sub = audio.player.playingStream.listen(sync);
  }

  @override
  void didUpdateWidget(PlayerArtwork old) {
    super.didUpdateWidget(old);
    if (widget.style != ArtworkStyle.vinyl) _spin.stop();
    if (widget.style == ArtworkStyle.vinyl && context.audio.playing.value && !_spin.isAnimating) _spin.repeat();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.track;
    final c = context.c;
    final size = widget.size;
    Widget child;
    switch (widget.style) {
      case ArtworkStyle.rounded:
        child = Artwork(key: ValueKey(t.id), path: t.art, size: size, radius: 22, glow: true, seed: t.album ?? t.title);
      case ArtworkStyle.square:
        child = Artwork(key: ValueKey(t.id), path: t.art, size: size, radius: 4, glow: true, seed: t.album ?? t.title);
      case ArtworkStyle.vinyl:
        child = RotationTransition(
          key: ValueKey(t.id),
          turns: _spin,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x88000000), blurRadius: 40, offset: Offset(0, 18), spreadRadius: -10),
              ],
              gradient: RadialGradient(
                colors: [Color(0xFF2A2A2A), Color(0xFF111111), Color(0xFF1C1C1C), Color(0xFF0E0E0E)],
                stops: [0.3, 0.55, 0.8, 1],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final f in const [0.92, 0.82, 0.72, 0.62])
                  Container(
                    width: size * f,
                    height: size * f,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                  ),
                ClipOval(
                  child: Artwork(path: t.art, size: size * 0.46, radius: 0, seed: t.album ?? t.title),
                ),
                Container(
                  width: size * 0.05,
                  height: size * 0.05,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
                ),
              ],
            ),
          ),
        );
    }
    // Comme Apple Music : la pochette rétrécit doucement quand la musique est en pause.
    final animated = widget.style == ArtworkStyle.vinyl
        ? child
        : ValueListenableBuilder(
            valueListenable: context.audio.playing,
            builder: (_, playing, inner) => AnimatedScale(
              scale: playing ? 1 : 0.86,
              duration: const Duration(milliseconds: 520),
              curve: playing ? Curves.easeOutBack : Curves.easeOutCubic,
              child: inner,
            ),
            child: child,
          );
    return Hero(
      tag: 'player-art',
      child: AnimatedSwitcher(duration: const Duration(milliseconds: 280), child: animated),
    );
  }
}

/// Cœur avec animation « pop » quand on l'active.
class _FavButton extends StatelessWidget {
  final bool fav;
  final VoidCallback onTap;
  const _FavButton({required this.fav, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = context.l;
    return TweenAnimationBuilder<double>(
      key: ValueKey(fav),
      tween: Tween(begin: fav ? 0.82 : 1, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: const Cubic(.3, 1.4, .5, 1),
      builder: (_, s, child) => Transform.scale(scale: s, child: child),
      child: LyraIconButton(
        icon: fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 26,
        color: fav ? c.primary : c.text2,
        tooltip: fav ? l.removeFromFavorites : l.addToFavorites,
        onPressed: onTap,
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  final Track track;
  final bool remaining;
  const _SeekBar({required this.track, required this.remaining});

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final audio = context.audio;
    final c = context.c;
    final total = widget.track.duration;
    return StreamBuilder<Duration>(
      stream: audio.player.positionStream,
      builder: (context, snap) {
        final max = total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
        final pos = (snap.data ?? Duration.zero).inMilliseconds.toDouble().clamp(0.0, max);
        final value = _drag ?? pos;
        final elapsed = Duration(milliseconds: value.round());
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
          child: Column(
            children: [
              SizedBox(
                height: 26,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: c.primary,
                    thumbColor: c.primary,
                    overlayColor: c.primary.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: value,
                    max: max,
                    onChanged: (v) => setState(() => _drag = v),
                    onChangeEnd: (v) async {
                      await audio.seek(Duration(milliseconds: v.round()));
                      if (mounted) setState(() => _drag = null);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDuration(elapsed), style: context.t.tech),
                    Text(
                      widget.remaining ? '−${formatDuration(total - elapsed)}' : formatDuration(total),
                      style: context.t.tech,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Commandes principales. Par défaut : aléatoire, précédent, lecture, suivant,
/// répétition. Avec « Boutons ±10 s » : précédent, −10 s, lecture, +10 s, suivant.
class _Controls extends StatelessWidget {
  final LyraAudioHandler audio;
  final bool seekButtons;
  final bool shuffleRepeat;
  const _Controls({required this.audio, required this.seekButtons, required this.shuffleRepeat});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    const spacer = SizedBox(width: 46);
    Widget jump(int seconds) => LyraIconButton(
      icon: seconds < 0 ? Icons.replay_10_rounded : Icons.forward_10_rounded,
      size: 28,
      color: c.text,
      tooltip: seconds < 0 ? l.back10 : l.forward10,
      onPressed: () {
        final p = audio.player.position + Duration(seconds: seconds);
        audio.seek(p.isNegative ? Duration.zero : p);
      },
    );
    final prev = LyraIconButton(
      icon: Icons.skip_previous_rounded,
      size: 36,
      box: 52,
      color: c.text,
      tooltip: l.previous,
      onPressed: audio.skipToPrevious,
    );
    final next = LyraIconButton(
      icon: Icons.skip_next_rounded,
      size: 36,
      box: 52,
      color: c.text,
      tooltip: l.next,
      onPressed: audio.skipToNext,
    );
    final play = ValueListenableBuilder(
      valueListenable: audio.playing,
      builder: (_, playing, _) => PlayButton(size: 70, playing: playing, onTap: playing ? audio.pause : audio.play),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: seekButtons
            ? [prev, jump(-10), play, jump(10), next]
            : [
                if (shuffleRepeat) ShuffleButton(audio: audio) else spacer,
                prev,
                play,
                next,
                if (shuffleRepeat) RepeatButton(audio: audio) else spacer,
              ],
      ),
    );
  }
}

class ShuffleButton extends StatelessWidget {
  final LyraAudioHandler audio;
  const ShuffleButton({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return ValueListenableBuilder(
      valueListenable: audio.shuffle,
      builder: (_, on, _) => _ModeButton(
        icon: Icons.shuffle_rounded,
        active: on,
        tooltip: on ? l.shuffleOn : l.shuffleOff,
        onTap: () {
          audio.toggleShuffle();
          context.toast(!on ? l.shuffleOn : l.shuffleOff, icon: Icons.shuffle_rounded);
        },
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  final LyraAudioHandler audio;
  const RepeatButton({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    String label(LoopSetting m) => switch (m) {
      LoopSetting.off => l.repeatOff,
      LoopSetting.all => l.repeatAll,
      LoopSetting.one => l.repeatOne,
    };
    return ValueListenableBuilder(
      valueListenable: audio.repeat,
      builder: (_, mode, _) => _ModeButton(
        icon: mode == LoopSetting.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
        active: mode != LoopSetting.off,
        tooltip: label(mode),
        onTap: () async {
          await audio.cycleRepeat();
          if (context.mounted) context.toast(label(audio.repeat.value), icon: Icons.repeat_rounded);
        },
      ),
    );
  }
}

/// Bouton de mode : actif = couleur ET point (jamais la couleur seule).
class _ModeButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;
  const _ModeButton({required this.icon, required this.active, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tooltip(
      message: tooltip,
      child: Press(
        onTap: onTap,
        semanticLabel: tooltip,
        child: SizedBox(
          width: 46,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 24, color: active ? c.primary : c.text2),
              Positioned(
                bottom: 5,
                child: AnimatedOpacity(
                  opacity: active ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rangée secondaire (vitesse, minuterie, file, égaliseur…), selon les réglages.
class _SecondaryRow extends StatelessWidget {
  final Track track;
  final SettingsController settings;
  final bool extraShuffleRepeat;
  const _SecondaryRow({required this.track, required this.settings, required this.extraShuffleRepeat});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final audio = context.audio;
    final items = <Widget>[
      if (settings.on(Toggle.actionSpeed))
        ValueListenableBuilder(
          valueListenable: audio.speed,
          builder: (_, s, _) => s == 1
              ? LyraIconButton(
                  icon: Icons.speed_rounded,
                  tooltip: l.playbackSpeed,
                  onPressed: () => showSpeedSheet(context),
                )
              : Press(
                  onTap: () => showSpeedSheet(context),
                  semanticLabel: l.playbackSpeed,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Text(
                        '${s.toStringAsFixed(2)}×',
                        style: context.t.meta.copyWith(color: c.primary, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
        ),
      if (settings.on(Toggle.actionSleep))
        ListenableBuilder(
          listenable: Listenable.merge([audio.sleepAt, audio.sleepAfterTrack]),
          builder: (_, _) {
            final active = audio.sleepAt.value != null || audio.sleepAfterTrack.value;
            return LyraIconButton(
              icon: active ? Icons.timer_rounded : Icons.timer_outlined,
              active: active,
              tooltip: l.sleepTimer,
              onPressed: () => showSleepTimerSheet(context),
            );
          },
        ),
      if (extraShuffleRepeat) ShuffleButton(audio: audio),
      if (extraShuffleRepeat) RepeatButton(audio: audio),
      if (settings.on(Toggle.actionQueue))
        LyraIconButton(
          icon: Icons.queue_music_rounded,
          tooltip: l.queue,
          onPressed: () => pushSheetRoute(context, const QueueScreen()),
        ),
      if (settings.on(Toggle.actionEqualizer))
        LyraIconButton(
          icon: Icons.equalizer_rounded,
          tooltip: l.equalizer,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EqualizerScreen())),
        ),
      if (settings.on(Toggle.actionPlaylist))
        LyraIconButton(
          icon: Icons.playlist_add_rounded,
          tooltip: l.addToPlaylist,
          onPressed: () => showAddToPlaylist(context, [track]),
        ),
      if (settings.on(Toggle.actionDetails))
        LyraIconButton(
          icon: Icons.info_outline_rounded,
          tooltip: l.songDetails,
          onPressed: () =>
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(trackId: track.id))),
        ),
    ];
    if (items.isEmpty) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
      child: Row(
        mainAxisAlignment: items.length == 1 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: items,
      ),
    );
  }
}

/// Volume média du téléphone (le même que les touches de volume).
class VolumeBar extends StatefulWidget {
  const VolumeBar({super.key});

  @override
  State<VolumeBar> createState() => _VolumeBarState();
}

class _VolumeBarState extends State<VolumeBar> {
  int _value = 0;
  int _max = 15;
  bool _dragging = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    if (!Platform.isAndroid) return;
    _read();
    // Suit les touches de volume du téléphone.
    _poll = Timer.periodic(const Duration(seconds: 1), (_) => _read());
  }

  Future<void> _read() async {
    if (_dragging || !Platform.isAndroid) return;
    try {
      final (v, m) = await SystemBridge.volume();
      if (mounted && (v != _value || m != _max)) {
        setState(() {
          _value = v;
          _max = m;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Icon(_value == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded, size: 20, color: c.text3),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(
                context,
              ).copyWith(trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5)),
              child: Slider(
                value: _value.clamp(0, _max).toDouble(),
                max: _max.toDouble(),
                onChangeStart: (_) => _dragging = true,
                onChanged: (v) {
                  setState(() => _value = v.round());
                  SystemBridge.setVolume(_value);
                },
                onChangeEnd: (_) => _dragging = false,
              ),
            ),
          ),
          Icon(Icons.volume_up_rounded, size: 20, color: c.text3),
        ],
      ),
    );
  }
}

/// « À suivre » : le prochain morceau de la file.
class _NextUp extends StatelessWidget {
  const _NextUp();

  @override
  Widget build(BuildContext context) {
    final audio = context.audio;
    final l = context.l;
    final c = context.c;
    final i = audio.index.value;
    final list = audio.tracks.value;
    final next = i != null && i + 1 < list.length ? list[i + 1] : null;
    if (next == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Press(
        onTap: () => pushSheetRoute(context, const QueueScreen()),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radiusM)),
          child: Row(
            children: [
              Artwork(path: next.art, size: 34, radius: 8, seed: next.album ?? next.title),
              const SizedBox(width: 10),
              Text('${l.upNext.toUpperCase()}  ', style: context.t.label),
              Expanded(
                child: Text(
                  '${next.title} · ${artistName(context, next.artist)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.t.meta.copyWith(color: c.text),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: c.text3),
            ],
          ),
        ),
      ),
    );
  }
}

/// Couleur de la ligne en cours : jaune par défaut ; la couleur du thème si elle
/// n'est pas blanche (ou presque). Sur fond clair, un jaune plus profond reste lisible.
Color lyricsHighlight(LyraColors c) {
  final hsl = HSLColor.fromColor(c.primary);
  final whiteish = hsl.lightness > 0.86 || (hsl.saturation < 0.25 && hsl.lightness > 0.75);
  if (!whiteish) return c.primary;
  final light = c.bg.computeLuminance() > 0.5;
  return light ? const Color(0xFFB98500) : const Color(0xFFFFD43B);
}

/// Panneau des paroles. Ligne en cours agrandie (taille de police animée) et colorée,
/// lignes voisines atténuées selon leur distance, défilement automatique et doux.
/// Si l'utilisateur fait défiler lui-même, le suivi reprend après quelques secondes.
/// Toucher une ligne synchronisée y amène la lecture.
class LyricsPanel extends StatefulWidget {
  final Track track;
  const LyricsPanel({super.key, required this.track});

  @override
  State<LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends State<LyricsPanel> {
  late final Future<Lyrics?> _future = context.read<LyricsStore>().lyricsFor(widget.track);
  final List<GlobalKey> _keys = [];
  Stream<int>? _index;
  int _current = -2;
  DateTime _userScroll = DateTime.fromMillisecondsSinceEpoch(0);

  /// Index de la ligne en cours ; n'émet que lorsqu'il change (pas à chaque tic de position).
  Stream<int> _indexStream(Lyrics lyrics) => _index ??= context.audio.player
      .createPositionStream(minPeriod: const Duration(milliseconds: 80), maxPeriod: const Duration(milliseconds: 200))
      // Petite avance : la ligne s'allume au moment où elle est chantée.
      .map((p) => lyrics.indexAt(p + const Duration(milliseconds: 250)))
      .distinct();

  void _follow(int index, {bool force = false}) {
    if (index == _current && !force) return;
    _current = index;
    if (index < 0 || index >= _keys.length) return;
    if (!force && DateTime.now().difference(_userScroll).inMilliseconds < 3500) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keys[index].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.38,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    return Container(
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radiusL)),
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder<Lyrics?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator(color: c.primary, strokeWidth: 2.4));
          }
          final lyrics = snap.data;
          if (lyrics == null || lyrics.lines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lyrics_outlined, size: 40, color: c.text3),
                    const SizedBox(height: 12),
                    Text(l.lyricsUnavailable, style: context.t.h3, textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text(l.lyricsNoneText, style: context.t.meta, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          final big = TextStyle(fontFamily: LyraText.heading, fontSize: 20, height: 1.4, fontWeight: FontWeight.w800);
          if (!lyrics.synced) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                Text(l.lyricsUnsynced.toUpperCase(), style: context.t.label),
                const SizedBox(height: 10),
                Text(lyrics.lines.map((e) => e.text).join('\n'), style: big.copyWith(color: c.text)),
              ],
            );
          }
          while (_keys.length < lyrics.lines.length) {
            _keys.add(GlobalKey());
          }
          final audio = context.audio;
          final hi = lyricsHighlight(c);
          return NotificationListener<ScrollStartNotification>(
            onNotification: (n) {
              if (n.dragDetails != null) _userScroll = DateTime.now();
              return false;
            },
            child: StreamBuilder<int>(
              stream: _indexStream(lyrics),
              initialData: lyrics.indexAt(audio.player.position + const Duration(milliseconds: 250)),
              builder: (context, snap) {
                final index = snap.data ?? -1;
                _follow(index);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < lyrics.lines.length; i++)
                        _LyricLineView(
                          key: _keys[i],
                          text: lyrics.lines[i].text,
                          distance: index < 0 ? 99 : i - index,
                          base: big,
                          highlight: hi,
                          color: c.text,
                          onTap: () {
                            _userScroll = DateTime.fromMillisecondsSinceEpoch(0);
                            audio.seek(lyrics.lines[i].time!);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _LyricLineView extends StatelessWidget {
  final String text;
  final int distance; // 0 = ligne en cours, négatif = déjà chantée
  final TextStyle base;
  final Color highlight;
  final Color color;
  final VoidCallback onTap;
  const _LyricLineView({
    super.key,
    required this.text,
    required this.distance,
    required this.base,
    required this.highlight,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = distance == 0;
    final d = distance.abs();
    // Lignes déjà chantées plus discrètes que celles à venir.
    final alpha = active ? 1.0 : (distance < 0 ? 0.32 : (d == 1 ? 0.62 : (d == 2 ? 0.48 : 0.38)));
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: active ? 7 : 3),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          style: base.copyWith(
            fontSize: active ? 27 : 20,
            height: active ? 1.25 : 1.4,
            color: active ? highlight : color.withValues(alpha: alpha),
            shadows: active ? [Shadow(color: highlight.withValues(alpha: 0.35), blurRadius: 18)] : const [],
          ),
          child: Text(text.isEmpty ? '♪' : text),
        ),
      ),
    );
  }
}

/// Boutons de l'en-tête « Paroles » : ajouter, synchroniser ou modifier.
class LyricsActions extends StatelessWidget {
  final Track track;
  const LyricsActions({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final status = context.watch<LyricsStore>().status(track);
    void edit() => context.pushFull(LyricsEditorScreen(trackId: track.id));
    void sync() => context.pushFull(LyricsSyncScreen(trackId: track.id));
    final main = switch (status) {
      LyricsStatus.none => LyraButton(label: l.wsAdd, icon: Icons.add_rounded, small: true, onPressed: edit),
      LyricsStatus.plain => LyraButton(label: l.wsSync, icon: Icons.timer_outlined, small: true, onPressed: sync),
      LyricsStatus.synced => PopupMenuButton<int>(
        tooltip: l.wsEdit,
        icon: Icon(Icons.edit_note_rounded, color: context.c.text2),
        onSelected: (v) => v == 0 ? edit() : sync(),
        itemBuilder: (_) => [
          PopupMenuItem(value: 0, child: Text(l.lyricsEditTitle)),
          PopupMenuItem(value: 1, child: Text(l.syncReview)),
        ],
      ),
    };
    if (status == LyricsStatus.none) return main;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LyraIconButton(
          icon: Icons.style_rounded,
          tooltip: l.lcCreate,
          color: context.c.text2,
          onPressed: () => context.pushFull(LyricsCardScreen(trackId: track.id)),
        ),
        main,
      ],
    );
  }
}
