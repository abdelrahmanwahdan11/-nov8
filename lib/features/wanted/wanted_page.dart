import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/utils/formatters.dart';

class WantedPage extends StatelessWidget {
  const WantedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offers = AppScope.of(context).itemsNotifier.offers;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('wanted_offers'))),
      body: offers.isEmpty
          ? Center(child: Text(l10n.t('no_results')))
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemBuilder: (context, index) {
                final offer = offers[index];
                final time = TimeOfDay.fromDateTime(offer.createdAt);
                final timeLabel = MaterialLocalizations.of(context).formatTimeOfDay(time, alwaysUse24HourFormat: true);
                return ListTile(
                  leading: const Icon(Icons.mark_unread_chat_alt_outlined),
                  title: Text('${l10n.t('offer_amount')}: ${AppFormatters.currency(offer.amount)}'),
                  subtitle: Text('${l10n.t('offer_from')} ${offer.fromUser} • ${offer.message}'),
                  trailing: Text(timeLabel),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: offers.length,
            ),
    );
  }
}
