import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/widgets/color_picker_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final themeNotifier = scope.themeNotifier;
    final localeNotifier = scope.localeNotifier;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: Text(l10n.t('dark_mode')),
            value: themeNotifier.isDarkMode,
            onChanged: (value) => themeNotifier.setDarkMode(value),
          ),
          ListTile(
            title: Text(l10n.t('accent_color')),
            trailing: CircleAvatar(backgroundColor: themeNotifier.accentColor),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ColorPickerSheet(
                    initialColor: themeNotifier.accentColor,
                    onChanged: (color) => themeNotifier.updateAccent(color),
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text(l10n.t('language')),
            subtitle: Text(localeNotifier.locale.languageCode == 'en' ? l10n.t('english') : l10n.t('arabic')),
            onTap: () {
              final newLocale = localeNotifier.locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
              localeNotifier.update(newLocale);
            },
          ),
          ListTile(
            title: Text(l10n.t('clear_data')),
            onTap: () async {
              await scope.preferencesService.clearAll();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('clear_data'))));
            },
          ),
          ListTile(
            title: Text(l10n.t('logout')),
            onTap: () {
              scope.authNotifier.logout();
              scope.preferencesService.clearRememberedLogin();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.t('logout_success'))));
              Navigator.of(context).pushNamedAndRemoveUntil('/auth/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
