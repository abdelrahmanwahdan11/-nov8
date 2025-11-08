import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/notifications_notifier.dart';
import '../../core/utils/notifications_builder.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final notifier = scope.notificationsNotifier;
    final animation = Listenable.merge([
      notifier,
      scope.bookingNotifier,
      scope.itemsNotifier,
    ]);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final notifications = buildNotifications(
          scope: scope,
          l10n: l10n,
          material: MaterialLocalizations.of(context),
        );
        final unreadCount =
            notifications.where((item) => !notifier.isRead(item.id)).length;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.t('notifications')),
            actions: [
              if (unreadCount > 0)
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: l10n.t('mark_all_read'),
                  onPressed: () => _markAll(context, notifications, notifier, l10n),
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
                          final isRead = notifier.isRead(item.id);
                          return _NotificationTile(
                            item: item,
                            isRead: isRead,
                            l10n: l10n,
                            onMarked: () =>
                                _markNotification(context, item, notifier, l10n),
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

  void _markNotification(
    BuildContext context,
    NotificationDescriptor item,
    NotificationsNotifier notifier,
    AppLocalizations l10n,
  ) {
    final changed = notifier.markRead(item.id);
    if (changed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.t('notification_marked'))));
    }
  }

  void _markAll(
    BuildContext context,
    List<NotificationDescriptor> items,
    NotificationsNotifier notifier,
    AppLocalizations l10n,
  ) {
    final changed = notifier.markAll(items.map((item) => item.id));
    if (changed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.t('marked_all_read'))));
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.isRead,
    required this.onMarked,
    required this.l10n,
  });

  final NotificationDescriptor item;
  final bool isRead;
  final VoidCallback onMarked;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        isRead ? theme.colorScheme.surface : theme.colorScheme.primary.withOpacity(0.08);
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
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onPrimary),
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
