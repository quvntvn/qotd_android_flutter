import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Collection de thèmes utilisés dans l'application.
class AppTheme {
  static final _seed = Colors.blue;
  static TextTheme _font(TextTheme base) => GoogleFonts.poppinsTextTheme(base);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        textTheme: _font(Typography.blackCupertino),
      );

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: _seed,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: _font(Typography.whiteCupertino),
      );
}

// Extensions utilitaires -----------------------------------------------------

/// Espacements et tailles cohérents dans toute l'UI.
extension SpacingExtension on BuildContext {
  EdgeInsets get smallPadding => const EdgeInsets.all(8);
  EdgeInsets get mediumPadding => const EdgeInsets.all(16);
  EdgeInsets get largePadding => const EdgeInsets.all(24);

  SizedBox get smallGap => const SizedBox(height: 12);
  SizedBox get mediumGap => const SizedBox(height: 24);
  SizedBox get largeGap => const SizedBox(height: 36);

  double get iconSizeSmall => 24;
  double get iconSizeMedium => 36;
  double get iconSizeLarge => 48;
}

/// Durées et courbes d'animation courantes.
extension AnimationExtension on BuildContext {
  Duration get shortAnimation => const Duration(milliseconds: 200);
  Duration get mediumAnimation => const Duration(milliseconds: 350);
  Duration get longAnimation => const Duration(milliseconds: 500);

  Curve get standardCurve => Curves.easeInOutCubic;
}
