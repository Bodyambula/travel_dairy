import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_dairy/providers/locale_provider.dart';

void main() {
  group('LocaleProvider Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial locale should be Ukrainian (uk_UA) by default', () async {
      SharedPreferences.setMockInitialValues({}); // Empty prefs
      final provider = LocaleProvider();
      
      // We need to wait for the microtask or internal init to finish if it's async
      // But LocaleProvider constructor calls _loadLocale() which is async
      // Wait for it to finish
      await Future.delayed(Duration.zero);
      
      expect(provider.locale.languageCode, 'uk');
      expect(provider.locale.countryCode, 'UA');
    });

    test('initial locale should load from SharedPreferences if exists', () async {
      SharedPreferences.setMockInitialValues({
        'language_code': 'en',
      });
      
      final provider = LocaleProvider();
      await Future.delayed(Duration.zero);
      
      expect(provider.locale.languageCode, 'en');
      expect(provider.locale.countryCode, 'US');
    });

    test('setLocale should update locale and save to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();
      await Future.delayed(Duration.zero);
      
      await provider.setLocale('en');
      
      expect(provider.locale.languageCode, 'en');
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_code'), 'en');
    });

    test('setLocale triggers notifyListeners', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = LocaleProvider();
      await Future.delayed(Duration.zero);
      
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });
      
      await provider.setLocale('en');
      expect(notified, isTrue);
    });
  });
}
