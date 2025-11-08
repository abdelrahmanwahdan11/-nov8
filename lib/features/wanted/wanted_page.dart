import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';

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
                return ListTile(
                  leading: const Icon(Icons.mark_unread_chat_alt_outlined),
                  title: Text('USD ${offer.amount.toStringAsFixed(0)}'),
                  subtitle: Text('${offer.fromUser} • ${offer.message}'),
                  trailing: Text('${offer.createdAt.hour}:${offer.createdAt.minute.toString().padLeft(2, '0')}'),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: offers.length,
            ),
    );
  }
}
