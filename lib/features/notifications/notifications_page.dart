import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/offer.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifications = _collectNotifications(context, scope, l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('notifications'))),
      body: notifications.isEmpty
          ? Center(child: Text(l10n.t('notifications_empty')))
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.color ?? theme.colorScheme.primary.withOpacity(0.12),
                    child: Icon(item.icon, color: theme.colorScheme.primary),
                  ),
                  title: Text(item.title),
                  subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                  trailing: Text(item.timestampLabel),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: notifications.length,
            ),
    );
  }

  List<_NotificationItem> _collectNotifications(
    BuildContext context,
    AppScopeData scope,
    AppLocalizations l10n,
  ) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final items = <_NotificationItem>[];

    final booking = scope.bookingNotifier.selectedDate;
    if (booking != null) {
      final dateLabel = '${materialLocalizations.formatMediumDate(booking)} • ${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(booking))}';
      items.add(
        _NotificationItem(
          title: l10n.t('notification_booking_set').replaceFirst('%s', dateLabel),
          icon: Icons.calendar_month,
          timestamp: booking,
          timestampLabel: materialLocalizations.formatShortDate(booking),
        ),
      );
    }

    for (final offer in scope.itemsNotifier.offers) {
      final statusLabel = switch (offer.status) {
        OfferStatus.pending => l10n.t('offer_status_pending'),
        OfferStatus.accepted => l10n.t('offer_status_accepted'),
        OfferStatus.declined => l10n.t('offer_status_declined'),
        OfferStatus.countered => l10n.t('offer_status_countered'),
      };

      if (offer.status == OfferStatus.pending) {
        items.add(
          _NotificationItem(
            title: l10n.t('notifications_offer_pending').replaceFirst('%s', offer.fromUser),
            subtitle: AppFormatters.currency(offer.amount),
            icon: Icons.mark_unread_chat_alt_outlined,
            timestamp: offer.updatedAt,
            timestampLabel: materialLocalizations.formatShortDate(offer.updatedAt),
          ),
        );
      } else {
        items.add(
          _NotificationItem(
            title: l10n
                .t('notifications_offer_status')
                .replaceFirst('%s', offer.fromUser)
                .replaceFirst('%t', statusLabel),
            subtitle: offer.counterAmount != null
                ? l10n.t('offer_counter_value').replaceFirst('%s', AppFormatters.currency(offer.counterAmount!))
                : AppFormatters.currency(offer.amount),
            icon: offer.status == OfferStatus.accepted
                ? Icons.task_alt
                : offer.status == OfferStatus.declined
                    ? Icons.block
                    : Icons.swap_horiz,
            timestamp: offer.updatedAt,
            timestampLabel: materialLocalizations.formatShortDate(offer.updatedAt),
          ),
        );
      }
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.title,
    required this.icon,
    required this.timestamp,
    required this.timestampLabel,
    this.subtitle,
    this.color,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final DateTime timestamp;
  final String timestampLabel;
  final Color? color;
}
