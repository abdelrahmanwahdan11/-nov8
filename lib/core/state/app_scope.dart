import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services_local/preferences_service.dart';
import 'notifiers/auth_notifier.dart';
import 'notifiers/booking_notifier.dart';
import 'notifiers/catalog_notifier.dart';
import 'notifiers/coach_marks_notifier.dart';
import 'notifiers/compare_notifier.dart';
import 'notifiers/favorites_notifier.dart';
import 'notifiers/items_notifier.dart';
import 'notifiers/locale_notifier.dart';
import 'notifiers/notifications_notifier.dart';
import 'notifiers/search_notifier.dart';
import 'notifiers/theme_notifier.dart';

class AppScope extends StatefulWidget {
  const AppScope({super.key, required this.child, required this.preferences});

  final Widget child;
  final SharedPreferences preferences;

  @override
  State<AppScope> createState() => _AppScopeState();

  static AppScopeData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_AppScopeInherited>();
    assert(inherited != null, 'AppScope not found');
    return inherited!.notifier!;
  }
}

class _AppScopeState extends State<AppScope> {
  late PreferencesService service;
  late AppScopeData data;

  @override
  void initState() {
    super.initState();
    service = PreferencesService(widget.preferences);
    final accent = service.loadAccent() ?? const Color(0xFFFF8A00);
    final dark = service.loadDarkMode(true);
    final locale = service.loadLocale() ?? const Locale('en');
    final themeNotifier = ThemeNotifier(darkMode: dark, accentColor: accent);
    final localeNotifier = LocaleNotifier(locale);
    final favorites = FavoritesNotifier(initial: service.loadFavorites());
    final compare = CompareNotifier(initial: service.loadCompare());
    final storedSort = service.loadCatalogSort();
    final catalog = CatalogNotifier(
      initialSort: CatalogSort.values.firstWhere(
        (value) => value.name == storedSort,
        orElse: () => CatalogSort.recommended,
      ),
      initialListMode: service.loadCatalogListMode(true),
    );
    final storedBooking = service.loadLastBookingSelection();
    final booking = BookingNotifier(
      preferences: service,
      selectedDate: storedBooking.start,
      returnDate: storedBooking.end,
      selectedSlot: storedBooking.slot,
    );
    final items = ItemsNotifier(items: ItemsNotifier.fromJson(service.loadMyItems()));
    final coach = CoachMarksNotifier(isFirstRun: service.isFirstRun());
    final search = SearchNotifier(
      initialRecent: service.loadRecentSearches(),
      initialSaved: service.loadSavedSearches(),
    );
    final storedAuth = service.loadAuthState();
    final storedUser = storedAuth.email != null
        ? AuthUser(name: storedAuth.name ?? 'Explorer', email: storedAuth.email!)
        : null;
    final auth = AuthNotifier(
      user: storedAuth.isGuest ? null : storedUser,
      isGuest: storedAuth.isGuest,
    );
    final notifications = NotificationsNotifier(preferencesService: service);

    themeNotifier.addListener(() {
      service.saveDarkMode(themeNotifier.isDarkMode);
      service.saveAccent(themeNotifier.accentColor);
    });
    localeNotifier.addListener(() {
      service.saveLocale(localeNotifier.locale);
    });
    favorites.addListener(() {
      service.saveFavorites(favorites.ids);
    });
    compare.addListener(() {
      service.saveCompare(compare.ids);
    });
    catalog.addListener(() {
      service.saveCatalogListMode(catalog.listMode);
      service.saveCatalogSort(catalog.sort.name);
    });
    coach.addListener(() {
      if (!coach.shouldShow) {
        service.setFirstRunDone();
      }
    });
    search.addListener(() {
      service.saveRecentSearches(search.recent);
      service.saveSavedSearches(search.savedSearchStorage);
    });
    items.addListener(() {
      service.saveMyItems(items.toJson());
    });
    auth.addListener(() {
      final user = auth.user;
      service.saveAuthState(
        name: user?.name,
        email: user?.email,
        isGuest: auth.isGuest,
      );
    });

    data = AppScopeData(
      themeNotifier: themeNotifier,
      localeNotifier: localeNotifier,
      favoritesNotifier: favorites,
      compareNotifier: compare,
      catalogNotifier: catalog,
      bookingNotifier: booking,
      authNotifier: auth,
      itemsNotifier: items,
      notificationsNotifier: notifications,
      coachMarksNotifier: coach,
      searchNotifier: search,
      preferencesService: service,
    );
  }

  @override
  void dispose() {
    data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppScopeInherited(
      notifier: data,
      child: widget.child,
    );
  }
}

class AppScopeData extends ChangeNotifier {
  AppScopeData({
    required this.themeNotifier,
    required this.localeNotifier,
    required this.favoritesNotifier,
    required this.compareNotifier,
    required this.catalogNotifier,
    required this.bookingNotifier,
    required this.authNotifier,
    required this.itemsNotifier,
    required this.notificationsNotifier,
    required this.coachMarksNotifier,
    required this.searchNotifier,
    required this.preferencesService,
  }) {
    _listen(themeNotifier);
    _listen(localeNotifier);
    _listen(favoritesNotifier);
    _listen(compareNotifier);
    _listen(catalogNotifier);
    _listen(bookingNotifier);
    _listen(authNotifier);
    _listen(itemsNotifier);
    _listen(notificationsNotifier);
    _listen(coachMarksNotifier);
    _listen(searchNotifier);
  }

  final ThemeNotifier themeNotifier;
  final LocaleNotifier localeNotifier;
  final FavoritesNotifier favoritesNotifier;
  final CompareNotifier compareNotifier;
  final CatalogNotifier catalogNotifier;
  final BookingNotifier bookingNotifier;
  final AuthNotifier authNotifier;
  final ItemsNotifier itemsNotifier;
  final NotificationsNotifier notificationsNotifier;
  final CoachMarksNotifier coachMarksNotifier;
  final SearchNotifier searchNotifier;
  final PreferencesService preferencesService;
  final List<VoidCallback> _listeners = <VoidCallback>[];

  void _listen(Listenable listenable) {
    void listener() {
      notifyListeners();
    }

    listenable.addListener(listener);
    _listeners.add(() => listenable.removeListener(listener));
  }

  void resetState() {
    themeNotifier.reset(darkMode: true, accent: const Color(0xFFFF8A00));
    localeNotifier.reset(const Locale('en'));
    favoritesNotifier.clear();
    compareNotifier.clear();
    catalogNotifier.reset();
    bookingNotifier.reset();
    itemsNotifier.reset();
    notificationsNotifier.reset();
    searchNotifier.reset();
    coachMarksNotifier.reset();
    authNotifier.logout();
  }

  @override
  void dispose() {
    for (final remove in _listeners) {
      remove();
    }
    themeNotifier.dispose();
    localeNotifier.dispose();
    favoritesNotifier.dispose();
    compareNotifier.dispose();
    catalogNotifier.dispose();
    bookingNotifier.dispose();
    authNotifier.dispose();
    itemsNotifier.dispose();
    notificationsNotifier.dispose();
    coachMarksNotifier.dispose();
    searchNotifier.dispose();
    super.dispose();
  }
}

class _AppScopeInherited extends InheritedNotifier<AppScopeData> {
  const _AppScopeInherited({required super.notifier, required super.child});
}
