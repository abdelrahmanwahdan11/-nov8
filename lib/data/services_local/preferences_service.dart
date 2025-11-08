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
  static const keyRememberEmail = 'remember_email';
  static const keyRememberFlag = 'remember_flag';
  static const keyAuthEmail = 'auth_email';
  static const keyAuthName = 'auth_name';
  static const keyAuthGuest = 'auth_guest';

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

  Future<void> rememberLogin(String email) async {
    await _prefs.setString(keyRememberEmail, email);
    await _prefs.setBool(keyRememberFlag, true);
  }

  Future<void> clearRememberedLogin() async {
    await _prefs.remove(keyRememberEmail);
    await _prefs.remove(keyRememberFlag);
  }

  String? loadRememberedEmail() => _prefs.getString(keyRememberEmail);

  bool loadRememberMe() => _prefs.getBool(keyRememberFlag) ?? false;

  Future<void> saveAuthState({String? name, String? email, required bool isGuest}) async {
    await _prefs.setBool(keyAuthGuest, isGuest);
    if (email != null && !isGuest) {
      await _prefs.setString(keyAuthEmail, email);
    } else {
      await _prefs.remove(keyAuthEmail);
    }
    if (name != null && !isGuest) {
      await _prefs.setString(keyAuthName, name);
    } else {
      await _prefs.remove(keyAuthName);
    }
  }

  StoredAuthState loadAuthState() {
    final isGuest = _prefs.getBool(keyAuthGuest) ?? false;
    final email = _prefs.getString(keyAuthEmail);
    final name = _prefs.getString(keyAuthName);
    return StoredAuthState(
      name: name,
      email: isGuest ? null : email,
      isGuest: isGuest,
    );
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

class StoredAuthState {
  const StoredAuthState({this.name, this.email, required this.isGuest});

  final String? name;
  final String? email;
  final bool isGuest;
}
