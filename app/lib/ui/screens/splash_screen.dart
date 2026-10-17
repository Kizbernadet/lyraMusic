import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../brand/logo.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Écran de démarrage : le logo global LyraMusic, animé.
/// (L'icône système d'Android 12+ montre d'abord le symbole R-vinyle.)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final width = math.min(MediaQuery.sizeOf(context).width * 0.74, 420.0);
    return Scaffold(
      backgroundColor: c.paper,
      body: Center(
        child: SplashLogoAnimation(width: width, tagline: context.l.splashTagline),
      ),
    );
  }
}
