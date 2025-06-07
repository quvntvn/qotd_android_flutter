import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
