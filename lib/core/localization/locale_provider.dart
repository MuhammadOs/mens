import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocales {
  static const english = Locale('en');
  static const arabic = Locale('ar');
  static const List<Locale> supported = [english, arabic];
}

final initialLocaleProvider = Provider<Locale>((ref) {
  throw UnimplementedError();
});

class LocaleNotifier extends Notifier<Locale> {
  SharedPreferences? _prefs;
  static const _localeKey = 'languageCode';

  @override
  Locale build() {
    return ref.watch(initialLocaleProvider);
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode != locale.languageCode) {
      state = locale;
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(_localeKey, locale.languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);