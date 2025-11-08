import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations.dart';
import 'core/state/app_scope.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(AppRoot(preferences: prefs));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      preferences: preferences,
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope,
      builder: (context, child) {
        return MaterialApp(
          title: 'NeoEstate',
          debugShowCheckedModeBanner: false,
          locale: scope.localeNotifier.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.buildIvoryYellow(scope.themeNotifier.accentColor),
          darkTheme: AppTheme.buildNoirOrange(scope.themeNotifier.accentColor),
          themeMode: scope.themeNotifier.themeMode,
          initialRoute: '/onboarding',
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
