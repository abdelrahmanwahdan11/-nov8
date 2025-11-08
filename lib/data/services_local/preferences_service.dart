import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const keyLocale = 'locale';
  static const keyDarkMode = 'dark_mode';
  static const keyAccent = 'accent_color';
  static const keyFirstRun = 'first_run_done';
  static const keyFavorites = 'favorites_ids';
  static const keyCompare = 'compare_ids';
  static const keyMyItems = 'my_items_cache';
  static const keyRecentSearches = 'recent_searches';
  static const keyLastBookingDate = 'last_booking';

  Future<void> saveLocale(Locale locale) async {
    await _prefs.setString(keyLocale, locale.languageCode);
  }

  Locale? loadLocale() {
    final code = _prefs.getString(keyLocale);
    if (code == null) return null;
    return Locale(code);
  }

  Future<void> saveDarkMode(bool value) async {
    await _prefs.setBool(keyDarkMode, value);
  }

  bool loadDarkMode(bool fallback) => _prefs.getBool(keyDarkMode) ?? fallback;

  Future<void> saveAccent(Color color) async {
    await _prefs.setInt(keyAccent, color.value);
  }

  Color? loadAccent() {
    final value = _prefs.getInt(keyAccent);
    if (value == null) return null;
    return Color(value);
  }

  Future<void> setFirstRunDone() async {
    await _prefs.setBool(keyFirstRun, true);
  }

  bool isFirstRun() => !(_prefs.getBool(keyFirstRun) ?? false);

  Future<void> saveFavorites(List<String> ids) async {
    await _prefs.setStringList(keyFavorites, ids);
  }

  List<String> loadFavorites() => _prefs.getStringList(keyFavorites) ?? <String>[];

  Future<void> saveCompare(List<String> ids) async {
    await _prefs.setStringList(keyCompare, ids);
  }

  List<String> loadCompare() => _prefs.getStringList(keyCompare) ?? <String>[];

  Future<void> saveMyItems(String json) async {
    await _prefs.setString(keyMyItems, json);
  }

  String? loadMyItems() => _prefs.getString(keyMyItems);

  Future<void> saveRecentSearches(List<String> queries) async {
    await _prefs.setStringList(keyRecentSearches, queries);
  }

  List<String> loadRecentSearches() => _prefs.getStringList(keyRecentSearches) ?? <String>[];

  Future<void> saveLastBooking(DateTime date) async {
    await _prefs.setString(keyLastBookingDate, date.toIso8601String());
  }

  DateTime? loadLastBooking() {
    final value = _prefs.getString(keyLastBookingDate);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
