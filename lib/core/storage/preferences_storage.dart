import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  PreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'theme_mode';
  static const _onboardingDoneKey = 'onboarding_done';

  ThemeMode get themeMode {
    final value = _prefs.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  bool get onboardingDone => _prefs.getBool(_onboardingDoneKey) ?? false;

  Future<void> setOnboardingDone() =>
      _prefs.setBool(_onboardingDoneKey, true);
}
