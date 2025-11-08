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
  static const keySavedSearches = 'saved_searches';
  static const keyLastBookingDate = 'last_booking';
  static const keyLastBookingReturn = 'last_booking_return';
  static const keyLastBookingSlot = 'last_booking_slot';
  static const keyRememberEmail = 'remember_email';
  static const keyRememberFlag = 'remember_flag';
  static const keyAuthEmail = 'auth_email';
  static const keyAuthName = 'auth_name';
  static const keyAuthGuest = 'auth_guest';
  static const keyCatalogListMode = 'catalog_list_mode';
  static const keyCatalogSort = 'catalog_sort';
  static const keyReadNotifications = 'read_notifications';

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

  Future<void> saveSavedSearches(List<String> entries) async {
    await _prefs.setStringList(keySavedSearches, entries);
  }

  List<String> loadSavedSearches() => _prefs.getStringList(keySavedSearches) ?? <String>[];

  Future<void> saveLastBookingSelection({
    required DateTime start,
    required DateTime end,
    String? slot,
  }) async {
    await _prefs.setString(keyLastBookingDate, start.toIso8601String());
    await _prefs.setString(keyLastBookingReturn, end.toIso8601String());
    if (slot != null) {
      await _prefs.setString(keyLastBookingSlot, slot);
    } else {
      await _prefs.remove(keyLastBookingSlot);
    }
  }

  StoredBookingSelection loadLastBookingSelection() {
    final startRaw = _prefs.getString(keyLastBookingDate);
    final endRaw = _prefs.getString(keyLastBookingReturn);
    final slot = _prefs.getString(keyLastBookingSlot);
    return StoredBookingSelection(
      start: startRaw != null ? DateTime.tryParse(startRaw) : null,
      end: endRaw != null ? DateTime.tryParse(endRaw) : null,
      slot: slot,
    );
  }

  Future<void> saveCatalogListMode(bool listMode) async {
    await _prefs.setBool(keyCatalogListMode, listMode);
  }

  bool loadCatalogListMode(bool fallback) => _prefs.getBool(keyCatalogListMode) ?? fallback;

  Future<void> saveCatalogSort(String value) async {
    await _prefs.setString(keyCatalogSort, value);
  }

  String? loadCatalogSort() => _prefs.getString(keyCatalogSort);

  Future<void> saveReadNotifications(List<String> ids) async {
    await _prefs.setStringList(keyReadNotifications, ids);
  }

  List<String> loadReadNotifications() => _prefs.getStringList(keyReadNotifications) ?? <String>[];

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

class StoredBookingSelection {
  const StoredBookingSelection({this.start, this.end, this.slot});

  final DateTime? start;
  final DateTime? end;
  final String? slot;
}
