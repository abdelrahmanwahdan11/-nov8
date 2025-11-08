import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notifications = [
      'Booking confirmed for Friday 11:00',
      'New wanted offer received',
      'Mortgage rate updates available',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('notifications'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(notifications[index]),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: notifications.length,
      ),
    );
  }
}
