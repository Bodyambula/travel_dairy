import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('uk', 'UA');
  
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'uk';
    _locale = Locale(langCode, (langCode == 'uk') ? 'UA' : 'US');
    notifyListeners();
  }

  Future<void> setLocale(String langCode) async {
    _locale = Locale(langCode, (langCode == 'uk') ? 'UA' : 'US');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    notifyListeners();
  }
}
