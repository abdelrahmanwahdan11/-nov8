import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../state/app_scope.dart';
import '../utils/formatters.dart';
import '../../data/models/offer.dart';

class NotificationDescriptor {
  const NotificationDescriptor({
    required this.id,
    required this.title,
    required this.icon,
    required this.timestamp,
    required this.timestampLabel,
    this.subtitle,
    this.color,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final DateTime timestamp;
  final String timestampLabel;
  final Color? color;
}

List<NotificationDescriptor> buildNotifications({
  required AppScopeData scope,
  required AppLocalizations l10n,
  required MaterialLocalizations material,
}) {
  final items = <NotificationDescriptor>[];

  final booking = scope.bookingNotifier.selectedDate;
  if (booking != null) {
    final dateLabel =
        '${material.formatMediumDate(booking)} • ${material.formatTimeOfDay(TimeOfDay.fromDateTime(booking))}';
    items.add(
      NotificationDescriptor(
        id: 'booking_${booking.toIso8601String()}',
        title: l10n.t('notification_booking_set').replaceFirst('%s', dateLabel),
        icon: Icons.calendar_month,
        timestamp: booking,
        timestampLabel: material.formatShortDate(booking),
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

    final idBase = 'offer_${offer.id}_${offer.updatedAt.toIso8601String()}';
    if (offer.status == OfferStatus.pending) {
      items.add(
        NotificationDescriptor(
          id: '${idBase}_pending',
          title: l10n.t('notifications_offer_pending').replaceFirst('%s', offer.fromUser),
          subtitle: AppFormatters.currency(offer.amount),
          icon: Icons.mark_unread_chat_alt_outlined,
          timestamp: offer.updatedAt,
          timestampLabel: material.formatShortDate(offer.updatedAt),
        ),
      );
    } else {
      items.add(
        NotificationDescriptor(
          id: '${idBase}_${offer.status.name}',
          title: l10n.t('notifications_offer_status')
              .replaceFirst('%s', offer.fromUser)
              .replaceFirst('%t', statusLabel),
          subtitle: offer.counterAmount != null
              ? l10n
                  .t('offer_counter_value')
                  .replaceFirst('%s', AppFormatters.currency(offer.counterAmount!))
              : AppFormatters.currency(offer.amount),
          icon: offer.status == OfferStatus.accepted
              ? Icons.task_alt
              : offer.status == OfferStatus.declined
                  ? Icons.block
                  : Icons.swap_horiz,
          timestamp: offer.updatedAt,
          timestampLabel: material.formatShortDate(offer.updatedAt),
        ),
      );
    }
  }

  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items;
}
