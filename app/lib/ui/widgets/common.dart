import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../audio/handler.dart';
import '../../l10n/app_localizations.dart';
import '../../models/track.dart';
import '../../state/collections.dart';
import '../../state/library.dart';
import '../../state/settings.dart';
import 'kit.dart';

/// Navigation principale : 4 onglets (Accueil, Atelier, Playlists, Réglages),
/// onglet affiché dans l'Accueil (Suggestions, Titres, Artistes…) et dans l'Atelier.
class ShellNav {
  final ValueNotifier<int> tab = ValueNotifier(0);

  /// 0 Suggestions · 1 Titres · 2 Artistes · 3 Albums · 4 Dossiers · 5 Genres
  final ValueNotifier<int> homeTab = ValueNotifier(0);
  /// 0 Sans paroles · 1 À synchroniser · 2 Synchronisées · 3 Infos manquantes
  final ValueNotifier<int> workshopTab = ValueNotifier(0);
  final List<GlobalKey<NavigatorState>> navigators = List.generate(4, (_) => GlobalKey<NavigatorState>());

  static const home = 0, workshop = 1, playlists = 2, settings = 3;

  void goTab(int index, {int? homeTab, int? workshopTab}) {
    if (homeTab != null) this.homeTab.value = homeTab;
    if (workshopTab != null) this.workshopTab.value = workshopTab;
    // Revenir à la racine de l'onglet quand on y va depuis un autre écran.
    navigators[index].currentState?.popUntil((r) => r.isFirst);
    tab.value = index;
  }
}

extension Ctx on BuildContext {
  L10n get l => L10n.of(this);
  LyraAudioHandler get audio => read<LyraAudioHandler>();
  LibraryController get library => read<LibraryController>();
  CollectionsController get collections => read<CollectionsController>();
  SettingsController get settings => read<SettingsController>();
  ShellNav get shell => read<ShellNav>();

  void toast(String message, {IconData icon = Icons.check_rounded}) => showLyraToast(this, message, icon: icon);

  /// Écran dans l'onglet courant (mini-lecteur et onglets restent visibles).
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));

  /// Écran plein (lecteur, édition…) au-dessus de la navigation.
  Future<T?> pushFull<T>(Widget page) =>
      Navigator.of(this, rootNavigator: true).push<T>(MaterialPageRoute(builder: (_) => page));
}

String artistName(BuildContext context, String? artist) => artist ?? context.l.unknownArtist;
String albumName(BuildContext context, String? album) => album ?? context.l.unknownAlbum;

/// Le morceau en cours, mis à jour automatiquement.
class CurrentTrackBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Track? track) builder;
  const CurrentTrackBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final audio = context.audio;
    return ListenableBuilder(
      listenable: Listenable.merge([audio.index, audio.tracks, audio.playing]),
      builder: (context, _) => builder(context, audio.current),
    );
  }
}
