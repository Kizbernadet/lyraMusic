import 'package:flutter/material.dart';

import 'playlists_screen.dart';

/// Onglet Favoris : les morceaux marqués d'un cœur.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaylistScreen.favorites();
}
