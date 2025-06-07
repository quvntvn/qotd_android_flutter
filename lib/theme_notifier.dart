// lib/theme_notifier.dart
import 'package:flutter/material.dart';
import 'theme.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Fait passer System -> Light -> Dark -> System …
  void nextMode() {
    _mode = {
      ThemeMode.system: ThemeMode.light,
      ThemeMode.light: ThemeMode.dark,
      ThemeMode.dark: ThemeMode.system,
    }[_mode]!;
    notifyListeners();
  }

  ThemeData get light => AppTheme.light();
  ThemeData get dark => AppTheme.dark();
}
