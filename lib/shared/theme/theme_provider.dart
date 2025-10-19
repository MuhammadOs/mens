import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The Notifier class
class ThemeNotifier extends Notifier<ThemeMode> {
  late SharedPreferences _prefs;
  static const _themeKey = 'themeMode';

  @override
  ThemeMode build() {
    // We run an async method to load the theme from storage
    // but return a default value synchronously.
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    if (state != themeMode) {
      state = themeMode;
      await _prefs.setInt(_themeKey, themeMode.index);
    }
  }
}

// The Provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);