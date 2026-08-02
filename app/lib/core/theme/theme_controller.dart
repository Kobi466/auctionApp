import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _darkModeKey = 'dark_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _themeMode = (preferences.getBool(_darkModeKey) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> setDarkMode(bool value) async {
    final nextMode = value ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == nextMode) return;

    _themeMode = nextMode;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, value);
  }

  Future<void> toggleTheme() {
    return setDarkMode(!isDarkMode);
  }
}
