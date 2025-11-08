import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier({required bool darkMode, required this.accentColor})
      : _isDarkMode = darkMode;

  bool _isDarkMode;
  Color accentColor;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }

  void updateAccent(Color color) {
    if (accentColor != color) {
      accentColor = color;
      notifyListeners();
    }
  }
}
