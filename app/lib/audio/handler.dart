import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/system_bridge.dart';
import '../models/track.dart';

enum LoopSetting { off, all, one }

/// Moteur de lecture : file d'attente, aléatoire, répétition,
/// notification / écran verrouillé (audio_service) et reprise au redémarrage.
///
/// La liste [tracks] est toujours l'ordre réel de lecture : en mode aléatoire,
/// elle est physiquement mélangée et l'ordre d'origine est gardé à part.
class LyraAudioHandler extends BaseAudioHandler with SeekHandler {
  /// Égaliseur et amplification (effets audio Android).
  final AndroidEqualizer equalizer = AndroidEqualizer();
  final AndroidLoudnessEnhancer loudness = AndroidLoudnessEnhancer();
  late final AudioPlayer player = AudioPlayer(audioPipeline: AudioPipeline(androidAudioEffects: [loudness, equalizer]));

  /// Minuterie de mise en veille : heure de fin, ou fin du morceau en cours.
  final ValueNotifier<DateTime?> sleepAt = ValueNotifier(null);
  final ValueNotifier<bool> sleepAfterTrack = ValueNotifier(false);
  Timer? _sleepTimer;
  final ValueNotifier<double> speed = ValueNotifier(1.0);
  final SharedPreferences prefs;

  final ValueNotifier<List<Track>> tracks = ValueNotifier(const []);
  final ValueNotifier<int?> index = ValueNotifier(null);
  final ValueNotifier<bool> shuffle = ValueNotifier(false);
  final ValueNotifier<LoopSetting> repeat = ValueNotifier(LoopSetting.off);
  final ValueNotifier<bool> playing = ValueNotifier(false);

  /// Erreurs de lecture à afficher (fichier introuvable, illisible…).
  final StreamController<Object> errors = StreamController.broadcast();

  /// Appelé quand un nouveau morceau commence (historique).
  void Function(Track track)? onTrackStarted;

  String unknownArtist = 'Unknown artist';
  String unknownAlbum = 'Unknown album';

  List<Track>? _original;
  int? _lastStartedId;
  bool _restoring = false;
  Timer? _saveTimer;
  final _random = Random();

  LyraAudioHandler(this.prefs) {
    _init();
  }

  Track? get current {
    final i = index.value;
    final list = tracks.value;
    return i != null && i >= 0 && i < list.length ? list[i] : null;
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Casque débranché / Bluetooth déconnecté → pause (CA-17).
    session.becomingNoisyEventStream.listen((_) => player.pause());

    player.playbackEventStream.listen((_) => _broadcastState(), onError: (Object e, StackTrace _) => errors.add(e));
    player.playingStream.listen((playing) {
      this.playing.value = playing;
      _syncSystem();
      _broadcastState();
      if (!playing) _save();
      _saveTimer?.cancel();
      if (playing) {
        _saveTimer = Timer.periodic(const Duration(seconds: 15), (_) => _save());
      }
    });
    player.currentIndexStream.listen(_onIndex);
    player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        // Fin de la file sans répétition : on s'arrête sur le dernier morceau.
        await player.pause();
        await player.seek(Duration.zero);
      }
    });
  }

  void _onIndex(int? i) {
    // « Arrêter à la fin du morceau » : on s'arrête au changement de morceau.
    if (sleepAfterTrack.value && i != index.value && index.value != null && !_restoring) {
      sleepAfterTrack.value = false;
      player.pause();
    }
    index.value = i;
    final t = current;
    if (t == null) return;
    mediaItem.add(_item(t));
    _syncSystem();
    if (!_restoring && t.id != _lastStartedId) {
      _lastStartedId = t.id;
      onTrackStarted?.call(t);
    }
    _save();
  }

  MediaItem _item(Track t) => t.toMediaItem(unknownArtist: unknownArtist, unknownAlbum: unknownAlbum);

  AudioSource _source(Track t) => AudioSource.file(t.path, tag: t.id);

  void _publishQueue() => queue.add(tracks.value.map(_item).toList());

  void _broadcastState() {
    final playing = player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek, MediaAction.seekForward, MediaAction.seekBackward},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: player.currentIndex,
        shuffleMode: shuffle.value ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        repeatMode: switch (repeat.value) {
          LoopSetting.off => AudioServiceRepeatMode.none,
          LoopSetting.all => AudioServiceRepeatMode.all,
          LoopSetting.one => AudioServiceRepeatMode.one,
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lancer la lecture

  /// Lit [list] à partir de [start]. Toute la liste devient la file (CA-10).
  Future<void> playTracks(List<Track> list, int start, {bool? shuffled}) async {
    if (list.isEmpty) return;
    if (shuffled != null) shuffle.value = shuffled;
    var order = list;
    var startIndex = start.clamp(0, list.length - 1);
    if (shuffle.value) {
      _original = List.of(list);
      final first = shuffled == true && start == 0 ? list[_random.nextInt(list.length)] : list[startIndex];
      final others = List.of(list)..remove(first);
      others.shuffle(_random);
      order = [first, ...others];
      startIndex = 0;
    } else {
      _original = null;
    }
    tracks.value = List.unmodifiable(order);
    _publishQueue();
    try {
      await player.setAudioSources(
        order.map(_source).toList(),
        initialIndex: startIndex,
        initialPosition: Duration.zero,
      );
      player.play();
    } catch (e) {
      errors.add(e);
    }
    _broadcastState();
  }

  /// « Lire ensuite » : juste après le morceau en cours (CA-20).
  Future<void> playNext(List<Track> items) async {
    if (items.isEmpty) return;
    final i = index.value;
    if (tracks.value.isEmpty || i == null) return playTracks(items, 0);
    final list = List.of(tracks.value)..insertAll(i + 1, items);
    if (_original != null) {
      final pos = _original!.indexOf(tracks.value[i]);
      _original!.insertAll(pos + 1, items);
    }
    tracks.value = List.unmodifiable(list);
    _publishQueue();
    await player.insertAudioSources(i + 1, items.map(_source).toList());
    _save();
  }

  /// « Ajouter à la file » : à la fin.
  Future<void> addToQueue(List<Track> items) async {
    if (items.isEmpty) return;
    if (tracks.value.isEmpty) {
      await playTracks(items, 0);
      return;
    }
    tracks.value = List.unmodifiable([...tracks.value, ...items]);
    _original?.addAll(items);
    _publishQueue();
    await player.addAudioSources(items.map(_source).toList());
    _save();
  }

  /// Retire un morceau de la file sans interrompre la lecture (CA-21).
  Future<void> removeFromQueue(int i) async {
    final list = List.of(tracks.value);
    if (i < 0 || i >= list.length) return;
    if (list.length == 1) {
      await clearAll();
      return;
    }
    final removed = list.removeAt(i);
    _original?.remove(removed);
    tracks.value = List.unmodifiable(list);
    _publishQueue();
    await player.removeAudioSourceAt(i);
    _save();
  }

  /// Retire de la file des morceaux supprimés du téléphone.
  Future<void> removeTracks(Set<int> ids) async {
    final list = tracks.value;
    if (list.every((t) => ids.contains(t.id))) {
      if (list.isNotEmpty) await clearAll();
      return;
    }
    for (var i = list.length - 1; i >= 0; i--) {
      if (ids.contains(list[i].id)) await removeFromQueue(i);
    }
  }

  Future<void> moveInQueue(int from, int to) async {
    if (from == to) return;
    final list = List.of(tracks.value);
    final item = list.removeAt(from);
    list.insert(to, item);
    tracks.value = List.unmodifiable(list);
    _publishQueue();
    await player.moveAudioSource(from, to);
    _save();
  }

  /// Vide la file : garde seulement le morceau en cours.
  Future<void> clearUpcoming() async {
    final i = index.value;
    if (i == null) return;
    final list = tracks.value;
    final keep = list[i];
    if (i + 1 < list.length) await player.removeAudioSourceRange(i + 1, list.length);
    if (i > 0) await player.removeAudioSourceRange(0, i);
    tracks.value = List.unmodifiable([keep]);
    if (_original != null) _original = [keep];
    _publishQueue();
    _save();
  }

  Future<void> clearAll() async {
    await player.stop();
    await player.clearAudioSources();
    tracks.value = const [];
    _original = null;
    index.value = null;
    queue.add(const []);
    mediaItem.add(null);
    _save();
  }

  // ---------------------------------------------------------------------------
  // Modes

  Future<void> toggleShuffle() async {
    final enable = !shuffle.value;
    shuffle.value = enable;
    final i = index.value;
    final list = tracks.value;
    if (i == null || list.length < 2) {
      _original = enable ? List.of(list) : null;
      _broadcastState();
      _save();
      return;
    }
    final now = list[i];
    // Le morceau en cours continue ; seuls les autres changent de place (CA-13).
    final List<Track> before, after;
    if (enable) {
      _original = List.of(list);
      before = const [];
      after = List.of(list)..removeAt(i);
      after.shuffle(_random);
    } else {
      final orig = _original ?? list;
      final pos = orig.indexOf(now);
      before = orig.sublist(0, pos);
      after = orig.sublist(pos + 1);
      _original = null;
    }
    if (i + 1 < list.length) await player.removeAudioSourceRange(i + 1, list.length);
    if (i > 0) await player.removeAudioSourceRange(0, i);
    if (before.isNotEmpty) await player.insertAudioSources(0, before.map(_source).toList());
    if (after.isNotEmpty) await player.addAudioSources(after.map(_source).toList());
    tracks.value = List.unmodifiable([...before, now, ...after]);
    index.value = before.length;
    _publishQueue();
    _broadcastState();
    _save();
  }

  Future<void> cycleRepeat() async {
    final next = LoopSetting.values[(repeat.value.index + 1) % LoopSetting.values.length];
    await _setRepeat(next);
  }

  Future<void> _setRepeat(LoopSetting mode) async {
    repeat.value = mode;
    await player.setLoopMode(switch (mode) {
      LoopSetting.off => LoopMode.off,
      LoopSetting.all => LoopMode.all,
      LoopSetting.one => LoopMode.one,
    });
    _broadcastState();
    _save();
  }

  // ---------------------------------------------------------------------------
  // Commandes (application, notification, écran verrouillé, casque)

  @override
  Future<void> play() async {
    if (tracks.value.isEmpty) return;
    player.play();
  }

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    await _save();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (player.hasNext) {
      await player.seekToNext();
    } else if (tracks.value.isNotEmpty) {
      await player.seek(Duration.zero, index: 0);
    }
  }

  /// Précédent : revient au début si plus de 3 s ont été lues (CA-11).
  @override
  Future<void> skipToPrevious() async {
    if (player.position > const Duration(seconds: 3) || !player.hasPrevious) {
      await player.seek(Duration.zero);
    } else {
      await player.seekToPrevious();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= tracks.value.length) return;
    await player.seek(Duration.zero, index: index);
    player.play();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enable = shuffleMode != AudioServiceShuffleMode.none;
    if (enable != shuffle.value) await toggleShuffle();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) => _setRepeat(switch (repeatMode) {
    AudioServiceRepeatMode.none => LoopSetting.off,
    AudioServiceRepeatMode.one => LoopSetting.one,
    _ => LoopSetting.all,
  });

  @override
  Future<void> onTaskRemoved() async {
    if (!player.playing) await stop();
  }

  // ---------------------------------------------------------------------------
  // Édition des tags d'un morceau de la file (CA-35)

  /// Libère le fichier s'il est en cours de lecture. Renvoie l'état à restaurer.
  Future<({int index, Duration position, bool playing})?> releaseIfCurrent(int trackId) async {
    final i = index.value;
    if (current?.id != trackId || i == null) return null;
    final state = (index: i, position: player.position, playing: player.playing);
    await player.stop();
    return state;
  }

  Future<void> resumeAfterEdit(({int index, Duration position, bool playing})? state) async {
    if (state == null) return;
    try {
      await player.load();
      await player.seek(state.position, index: state.index);
      if (state.playing) player.play();
    } catch (e) {
      errors.add(e);
    }
  }

  /// Met à jour un morceau modifié dans la file et la notification.
  void updateTrack(Track t) {
    if (!tracks.value.any((x) => x.id == t.id)) return;
    tracks.value = List.unmodifiable([for (final x in tracks.value) x.id == t.id ? t : x]);
    if (_original != null) _original = [for (final x in _original!) x.id == t.id ? t : x];
    _publishQueue();
    final c = current;
    if (c != null) mediaItem.add(_item(c));
  }

  /// Rafraîchit les libellés « Artiste inconnu »… après un changement de langue.
  void setUnknownLabels(String artist, String album) {
    if (artist == unknownArtist && album == unknownAlbum) return;
    unknownArtist = artist;
    unknownAlbum = album;
    if (tracks.value.isEmpty) return;
    _publishQueue();
    final c = current;
    if (c != null) mediaItem.add(_item(c));
  }

  // ---------------------------------------------------------------------------
  // Minuterie, vitesse, effets

  void setSleepTimer(Duration? duration, {bool endOfTrack = false}) {
    _sleepTimer?.cancel();
    sleepAfterTrack.value = endOfTrack;
    if (duration == null) {
      sleepAt.value = null;
      return;
    }
    sleepAt.value = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () {
      sleepAt.value = null;
      player.pause();
    });
  }

  @override
  Future<void> setSpeed(double speed) async {
    this.speed.value = speed;
    await player.setSpeed(speed);
    await prefs.setDouble('speed', speed);
    _broadcastState();
  }

  Future<void> setSkipSilence(bool value) => player.setSkipSilenceEnabled(value);

  Future<void> setEqualizerEnabled(bool value) async {
    await equalizer.setEnabled(value);
    await prefs.setBool('eq_on', value);
  }

  Future<void> setBandGain(int band, double gain) async {
    final params = await equalizer.parameters;
    await params.bands[band].setGain(gain);
    await prefs.setStringList('eq_gains', [for (final b in params.bands) b.gain.toStringAsFixed(2)]);
  }

  Future<void> setBassBoost(double db) async {
    await loudness.setEnabled(db > 0);
    await loudness.setTargetGain(db);
    await prefs.setDouble('loudness', db);
  }

  double get bassBoost => prefs.getDouble('loudness') ?? 0;
  bool get equalizerOn => prefs.getBool('eq_on') ?? false;

  /// Réglages audio enregistrés, appliqués au démarrage.
  Future<void> restoreEffects({required bool skipSilence}) async {
    final s = prefs.getDouble('speed') ?? 1.0;
    speed.value = s;
    await player.setSpeed(s);
    await player.setSkipSilenceEnabled(skipSilence);
    final boost = bassBoost;
    if (boost > 0) {
      await loudness.setEnabled(true);
      await loudness.setTargetGain(boost);
    }
    if (equalizerOn) await equalizer.setEnabled(true);
    final gains = prefs.getStringList('eq_gains');
    if (gains != null) {
      // Les paramètres de l'égaliseur ne sont connus qu'une fois le lecteur prêt.
      unawaited(
        equalizer.parameters.then((p) async {
          for (var i = 0; i < p.bands.length && i < gains.length; i++) {
            await p.bands[i].setGain(double.tryParse(gains[i]) ?? 0);
          }
        }),
      );
    }
  }

  /// Widgets d'écran d'accueil et écran de verrouillage LyraMusic.
  void _syncSystem() {
    final t = current;
    SystemBridge.updateNowPlaying(
      title: t?.title,
      artist: t?.artist ?? (t == null ? null : unknownArtist),
      art: t?.art,
      playing: player.playing,
    );
  }

  // ---------------------------------------------------------------------------
  // Sauvegarde / reprise (F29)

  Future<void> _save() async {
    if (_restoring) return;
    final list = tracks.value;
    await prefs.setStringList('q_ids', list.map((t) => t.id.toString()).toList());
    if (_original != null) {
      await prefs.setStringList('q_orig', _original!.map((t) => t.id.toString()).toList());
    } else {
      await prefs.remove('q_orig');
    }
    await prefs.setInt('q_index', index.value ?? 0);
    await prefs.setInt('q_pos', player.position.inMilliseconds);
    await prefs.setBool('q_shuffle', shuffle.value);
    await prefs.setInt('q_repeat', repeat.value.index);
  }

  /// Recharge la dernière file, sans lancer la lecture.
  Future<void> restore(Track? Function(int id) lookup) async {
    final ids = prefs.getStringList('q_ids') ?? const [];
    shuffle.value = prefs.getBool('q_shuffle') ?? false;
    final rep = LoopSetting.values[(prefs.getInt('q_repeat') ?? 0).clamp(0, 2)];
    repeat.value = rep;
    await player.setLoopMode(switch (rep) {
      LoopSetting.off => LoopMode.off,
      LoopSetting.all => LoopMode.all,
      LoopSetting.one => LoopMode.one,
    });
    if (ids.isEmpty) return;
    final savedIndex = prefs.getInt('q_index') ?? 0;
    final currentId = savedIndex < ids.length ? int.tryParse(ids[savedIndex]) : null;
    final list = [for (final s in ids) ?lookup(int.parse(s))];
    if (list.isEmpty) return;
    final orig = prefs.getStringList('q_orig');
    _original = orig == null ? null : [for (final s in orig) ?lookup(int.parse(s))];
    var start = list.indexWhere((t) => t.id == currentId);
    var position = Duration(milliseconds: prefs.getInt('q_pos') ?? 0);
    if (start < 0) {
      start = 0;
      position = Duration.zero;
    }
    _restoring = true;
    try {
      tracks.value = List.unmodifiable(list);
      _publishQueue();
      _lastStartedId = list[start].id;
      await player.setAudioSources(list.map(_source).toList(), initialIndex: start, initialPosition: position);
    } catch (e) {
      errors.add(e);
    } finally {
      _restoring = false;
    }
    _broadcastState();
  }
}
