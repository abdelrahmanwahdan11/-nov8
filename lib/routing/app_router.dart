import 'package:flutter/material.dart';

import '../features/about/about_page.dart';
import '../features/auth/forgot_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/booking/booking_page.dart';
import '../features/catalog/catalog_page.dart';
import '../features/compare/compare_page.dart';
import '../features/details/details_page.dart';
import '../features/favorites/favorites_page.dart';
import '../features/home/home_page.dart';
import '../features/mortgage/mortgage_page.dart';
import '../features/myitems/my_items_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/search/search_page.dart';
import '../features/settings/settings_page.dart';
import '../features/wanted/wanted_page.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case '/auth/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/auth/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/auth/forgot':
        return MaterialPageRoute(builder: (_) => const ForgotPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/details':
        return MaterialPageRoute(builder: (_) => const DetailsPage());
      case '/booking':
        return MaterialPageRoute(builder: (_) => const BookingPage());
      case '/mortgage':
        return MaterialPageRoute(builder: (_) => const MortgagePage());
      case '/catalog':
        return MaterialPageRoute(builder: (_) => const CatalogPage());
      case '/compare':
        return MaterialPageRoute(builder: (_) => const ComparePage());
      case '/myitems':
        return MaterialPageRoute(builder: (_) => const MyItemsPage());
      case '/wanted':
        return MaterialPageRoute(builder: (_) => const WantedPage());
      case '/favorites':
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchPage());
      case '/about':
        return MaterialPageRoute(builder: (_) => const AboutPage());
      default:
        return null;
    }
  }
}
