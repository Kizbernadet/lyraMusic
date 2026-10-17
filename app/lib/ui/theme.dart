import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Mode d'affichage : clair, sombre ou celui du téléphone.
enum AppearanceMode { system, light, dark }

/// Couleur principale, au choix de l'utilisateur. « Classique » suit la charte :
/// noir sur crème en clair, crème sur noir en sombre. Sable, taupe et sauge
/// viennent de la charte n° 2 ; les autres sont des propositions.
enum AccentColor { classic, sand, taupe, sage, terracotta, ocean, mint, violet }

class AccentSpec {
  final Color light; // couleur en mode clair
  final Color dark; // couleur en mode sombre
  final Color onLight;
  final Color onDark;
  const AccentSpec(this.light, this.dark, {this.onLight = Colors.white, this.onDark = const Color(0xFF111111)});
}

const accents = <AccentColor, AccentSpec>{
  AccentColor.classic: AccentSpec(Color(0xFF111111), Color(0xFFF3EBD8), onLight: Color(0xFFF3EBD8)),
  AccentColor.sand: AccentSpec(Color(0xFFA8875A), Color(0xFFE8DCC6)),
  AccentColor.taupe: AccentSpec(Color(0xFF8C7B62), Color(0xFFB7A78F)),
  AccentColor.sage: AccentSpec(Color(0xFF66785A), Color(0xFF8E9F7E)),
  AccentColor.terracotta: AccentSpec(Color(0xFFB85C3C), Color(0xFFE08A65)),
  AccentColor.ocean: AccentSpec(Color(0xFF3E5C8A), Color(0xFF8FA9D6)),
  AccentColor.mint: AccentSpec(Color(0xFF2E7D5B), Color(0xFF5FC79A)),
  AccentColor.violet: AccentSpec(Color(0xFF5B4AE0), Color(0xFF9B8CFF)),
};

/// Jetons de couleur (charte LyraMusic : noir profond #111111 et crème #F3EBD8).
class LyraColors extends ThemeExtension<LyraColors> {
  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color ink; // noir profond ou crème selon le mode : couleur du logo
  final Color paper; // fond du logo
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color elevated;
  final Color text;
  final Color text2;
  final Color text3;
  final Color divider;
  final Color dividerStrong;
  final Color overlay;
  final Color success;
  final Color warning;
  final Color error;

  const LyraColors({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.ink,
    required this.paper,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.elevated,
    required this.text,
    required this.text2,
    required this.text3,
    required this.divider,
    required this.dividerStrong,
    required this.overlay,
    required this.success,
    required this.warning,
    required this.error,
  });

  static const cream = Color(0xFFF3EBD8);
  static const black = Color(0xFF111111);

  factory LyraColors.make(Brightness b, AccentColor accent) {
    final a = accents[accent]!;
    if (b == Brightness.light) {
      return LyraColors(
        brightness: b,
        primary: a.light,
        onPrimary: a.onLight,
        ink: black,
        paper: cream,
        bg: cream,
        surface: const Color(0xFFFAF6EC),
        surface2: const Color(0xFFEAE1CC),
        elevated: const Color(0xFFFBF8F1),
        text: black,
        text2: const Color(0xFF4A4A4A),
        text3: const Color(0xFF8A8577),
        divider: const Color(0x1A111111),
        dividerStrong: const Color(0x2E111111),
        overlay: const Color(0x66111111),
        success: const Color(0xFF3F8A5A),
        warning: const Color(0xFFB27820),
        error: const Color(0xFFC0443C),
      );
    }
    return LyraColors(
      brightness: b,
      primary: a.dark,
      onPrimary: a.onDark,
      ink: cream,
      paper: black,
      bg: black,
      surface: const Color(0xFF1B1B1B),
      surface2: const Color(0xFF2E2E2E),
      elevated: const Color(0xFF232323),
      text: cream,
      text2: const Color(0xFFBDB8A9),
      text3: const Color(0xFF7E7A70),
      divider: const Color(0x17F3EBD8),
      dividerStrong: const Color(0x29F3EBD8),
      overlay: const Color(0xB8000000),
      success: const Color(0xFF7FBF8E),
      warning: const Color(0xFFE3A648),
      error: const Color(0xFFE5736B),
    );
  }

  Color get primarySoft => primary.withValues(alpha: isDark ? 0.16 : 0.10);
  bool get isDark => brightness == Brightness.dark;

  @override
  LyraColors copyWith() => this;

  @override
  LyraColors lerp(ThemeExtension<LyraColors>? other, double t) => t < 0.5 ? this : other as LyraColors;
}

/// Échelle typographique de la charte (Nunito pour les titres, Inter pour le texte).
class LyraText {
  final LyraColors c;
  const LyraText(this.c);

  static const heading = 'Nunito';
  static const ui = 'Inter';

  TextStyle get display => TextStyle(
    fontFamily: heading,
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.6,
    color: c.text,
  );
  TextStyle get h1 => TextStyle(
    fontFamily: heading,
    fontSize: 25,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: c.text,
  );
  TextStyle get h2 => TextStyle(
    fontFamily: heading,
    fontSize: 19,
    height: 1.25,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: c.text,
  );
  TextStyle get h3 => TextStyle(
    fontFamily: heading,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.1,
    color: c.text,
  );
  TextStyle get title => TextStyle(
    fontFamily: ui,
    fontSize: 14.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    color: c.text,
  );
  TextStyle get body =>
      TextStyle(fontFamily: ui, fontSize: 13.5, height: 1.5, fontWeight: FontWeight.w400, color: c.text2);
  TextStyle get meta =>
      TextStyle(fontFamily: ui, fontSize: 12, height: 1.45, fontWeight: FontWeight.w400, color: c.text2);
  TextStyle get label => TextStyle(
    fontFamily: ui,
    fontSize: 10.5,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.45,
    color: c.text3,
  );
  TextStyle get button => TextStyle(fontFamily: ui, fontSize: 13.5, fontWeight: FontWeight.w600, letterSpacing: -0.07);
  TextStyle get tech => TextStyle(
    fontFamily: ui,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: c.text3,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

extension LyraTheme on BuildContext {
  LyraColors get c => Theme.of(this).extension<LyraColors>()!;
  LyraText get t => LyraText(c);
}

// Grille de 8 points ; rayons de la charte.
const radiusXS = 8.0;
const radiusS = 12.0;
const radiusM = 16.0;
const radiusL = 20.0;
const radiusXL = 28.0;

const lyraCurve = Cubic(.22, .9, .3, 1);

/// Défilement « élastique » façon iPhone, sans halo Android.
class LyraScrollBehavior extends MaterialScrollBehavior {
  const LyraScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

ThemeData buildTheme(LyraColors c) {
  final t = LyraText(c);
  final scheme = ColorScheme.fromSeed(seedColor: c.primary, brightness: c.brightness).copyWith(
    primary: c.primary,
    onPrimary: c.onPrimary,
    secondary: c.primary,
    surface: c.bg,
    onSurface: c.text,
    onSurfaceVariant: c.text2,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.elevated,
    surfaceContainerHighest: c.surface2,
    error: c.error,
    outline: c.dividerStrong,
    outlineVariant: c.divider,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: LyraText.ui,
    extensions: [c],
    splashFactory: InkRipple.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: c.text, displayColor: c.text, fontFamily: LyraText.ui),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: t.h2,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.elevated,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: c.overlay,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.elevated,
      surfaceTintColor: Colors.transparent,
      barrierColor: c.overlay,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      titleTextStyle: t.h2,
      contentTextStyle: t.body,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.elevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
      textStyle: t.title,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: c.dividerStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: c.dividerStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: c.text, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: c.error),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusS),
        borderSide: BorderSide(color: c.divider),
      ),
      hintStyle: t.title.copyWith(color: c.text3, fontWeight: FontWeight.w500),
      helperStyle: t.meta.copyWith(color: c.text3),
      errorStyle: t.meta.copyWith(color: c.error),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.text,
      selectionColor: c.primary.withValues(alpha: 0.3),
      selectionHandleColor: c.primary,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: c.text,
      inactiveTrackColor: c.dividerStrong,
      thumbColor: c.text,
      overlayColor: c.text.withValues(alpha: 0.10),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6, elevation: 1),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      trackShape: const RoundedRectSliderTrackShape(),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary, linearTrackColor: c.dividerStrong),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onPrimary : c.text3),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : c.surface2),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.transparent : c.dividerStrong,
      ),
    ),
    listTileTheme: ListTileThemeData(iconColor: c.text2, textColor: c.text),
    dividerTheme: DividerThemeData(color: c.divider, space: 1, thickness: 1),
    iconTheme: IconThemeData(color: c.text2),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: c.text, textStyle: t.button),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        // Glissement latéral et retour par balayage depuis le bord (style iPhone).
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
