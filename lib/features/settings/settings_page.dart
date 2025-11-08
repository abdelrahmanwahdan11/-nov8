import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/widgets/color_picker_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _editProfile(BuildContext context, AppScopeData scope) async {
    final user = scope.authNotifier.user;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: user.name);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.t('edit_profile')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.t('name')),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(l10n.t('save')),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result == null) return;
    final trimmed = result.trim();
    if (trimmed.isEmpty) return;
    scope.authNotifier.updateProfile(trimmed);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('profile_updated'))));
  }

  Future<void> _confirmReset(BuildContext context, AppScopeData scope) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.t('clear_data_title')),
          content: Text(l10n.t('clear_data_message')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.t('clear')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await scope.preferencesService.clearAll();
    scope.resetState();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('data_cleared'))));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final themeNotifier = scope.themeNotifier;
    final localeNotifier = scope.localeNotifier;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settings'))),
      body: AnimatedBuilder(
        animation: scope,
        builder: (context, child) {
          final user = scope.authNotifier.user;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (user != null)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l10n.t('edit_profile')),
                  subtitle: Text('${user.name} • ${user.email}'),
                  onTap: () => _editProfile(context, scope),
                ),
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
                    builder: (sheetContext) {
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
                  final newLocale = localeNotifier.locale.languageCode == 'en'
                      ? const Locale('ar')
                      : const Locale('en');
                  localeNotifier.update(newLocale);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_outlined),
                title: Text(l10n.t('clear_data')),
                onTap: () => _confirmReset(context, scope),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
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
          );
        },
      ),
    );
  }
}
