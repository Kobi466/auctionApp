import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _languageKey = 'language_code';

  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languageKey) ?? 'vi';
    _locale = Locale(_isSupported(languageCode) ? languageCode : 'vi');
  }

  Future<void> setLocale(String languageCode) async {
    if (!_isSupported(languageCode) || _locale.languageCode == languageCode) {
      return;
    }

    _locale = Locale(languageCode);
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, languageCode);
  }

  bool _isSupported(String languageCode) =>
      languageCode == 'vi' || languageCode == 'en';
}
