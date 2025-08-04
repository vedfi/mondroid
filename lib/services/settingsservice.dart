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
  static const String _smartQuotes = 'smart_quotes';
  static const String _smartDashes = 'smart_dashes';


  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  bool showOidTimestamp = true;
  bool maskPassword = true;
  bool smartQuotes = true;
  bool smartDashes = true;

  Future<void> load() async {
    await loadTheme();
    await loadMaskPassword();
    await loadTimestamp();
    await loadSmartDashes();
    await loadSmartQuotes();
  }

  Future<void> loadSmartDashes() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_smartDashes);
    switch (stored) {
      case 'true':
        smartDashes = true;
        break;
      case 'false':
        smartDashes = false;
        break;
      default:
        smartDashes = true;
    }
  }

  Future<void> updateSmartDashes(bool val) async {
    smartDashes = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_smartDashes, val ? 'true' : 'false');
  }

  Future<void> loadSmartQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_smartQuotes);
    switch (stored) {
      case 'true':
        smartQuotes = true;
        break;
      case 'false':
        smartQuotes = false;
        break;
      default:
        smartQuotes = true;
    }
  }

  Future<void> updateSmartQuotes(bool val) async {
    smartQuotes = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_smartQuotes, val ? 'true' : 'false');
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
