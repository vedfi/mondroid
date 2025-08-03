import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _settingsService = SettingsService._internal();

  factory SettingsService() {
    return _settingsService;
  }

  SettingsService._internal();

  static const String _themeKey = 'theme_mode';
  static const String _maskPasswordKey = 'mask_password';
  static const String _timestampKey = 'oid_timestamp';

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  bool showOidTimestamp = true;
  bool maskPassword = true;

  Future<void> load() async {
    await loadTheme();
    await loadMaskPassword();
    await loadTimestamp();
  }

  Future<void> loadMaskPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_maskPasswordKey);
    switch (stored) {
      case 'true':
        maskPassword = true;
        break;
      case 'false':
        maskPassword = false;
        break;
      default:
        maskPassword = true;
    }
  }

  Future<void> updateMaskPassword(bool val) async {
    maskPassword = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_maskPasswordKey, val ? 'true' : 'false');
  }

  Future<void> loadTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_timestampKey);
    switch (stored) {
      case 'true':
        showOidTimestamp = true;
        break;
      case 'false':
        showOidTimestamp = false;
        break;
      default:
        showOidTimestamp = true;
    }
  }

  Future<void> updateTimestamp(bool val) async {
    showOidTimestamp = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timestampKey, val ? 'true' : 'false');
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeKey);
    switch (stored) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }

  Future<void> updateTheme(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system',
    );
  }
}
