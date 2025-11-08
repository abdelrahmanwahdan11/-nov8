import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/offer.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Set<String> _read = <String>{};
  AppScopeData? _scope;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    if (_scope != scope) {
      _scope = scope;
    }
    if (!_loaded && _scope != null) {
      _read.addAll(_scope!.preferencesService.loadReadNotifications());
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    return AnimatedBuilder(
      animation: scope,
      builder: (context, _) {
        final notifications = _collectNotifications(context, scope, l10n);
        final unreadCount = notifications.where((item) => !_read.contains(item.id)).length;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.t('notifications')),
            actions: [
              if (unreadCount > 0)
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: l10n.t('mark_all_read'),
                  onPressed: () => _markAll(notifications, l10n),
                ),
            ],
          ),
          body: notifications.isEmpty
              ? Center(child: Text(l10n.t('notifications_empty')))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text(
                        l10n.t('swipe_to_mark_read'),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          final isRead = _read.contains(item.id);
                          return _NotificationTile(
                            item: item,
                            isRead: isRead,
                            l10n: l10n,
                            onMarked: () => _markNotification(item, l10n),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _markNotification(_NotificationItem item, AppLocalizations l10n) {
    if (_read.contains(item.id)) return;
    setState(() {
      _read.add(item.id);
    });
    _saveRead();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('notification_marked'))));
  }

  void _markAll(List<_NotificationItem> items, AppLocalizations l10n) {
    var changed = false;
    for (final item in items) {
      if (_read.add(item.id)) {
        changed = true;
      }
    }
    if (changed) {
      setState(() {});
      _saveRead();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('marked_all_read'))));
    }
  }

  void _saveRead() {
    final scope = _scope;
    if (scope != null) {
      scope.preferencesService.saveReadNotifications(_read.toList());
    }
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
          id: 'booking_${booking.toIso8601String()}',
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

      final idBase = 'offer_${offer.id}_${offer.updatedAt.toIso8601String()}';
      if (offer.status == OfferStatus.pending) {
        items.add(
          _NotificationItem(
            id: '${idBase}_pending',
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
            id: '${idBase}_${offer.status.name}',
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.isRead,
    required this.onMarked,
    required this.l10n,
  });

  final _NotificationItem item;
  final bool isRead;
  final VoidCallback onMarked;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isRead ? theme.colorScheme.surface : theme.colorScheme.primary.withOpacity(0.08);
    final leadingColor = item.color ?? theme.colorScheme.primary.withOpacity(0.12);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onMarked();
        return false;
      },
      background: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.done, color: theme.colorScheme.primary),
        ),
      ),
      child: InkWell(
        onTap: onMarked,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: leadingColor,
                child: Icon(item.icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: theme.textTheme.titleMedium),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(item.subtitle!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.timestampLabel, style: theme.textTheme.labelSmall),
                  if (!isRead)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.t('badge_new'),
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem {
  _NotificationItem({
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
