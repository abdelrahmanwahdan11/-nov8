import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/utils/formatters.dart';
import '../../core/state/notifiers/items_notifier.dart';
import '../../data/models/my_item.dart';
import '../../data/models/offer.dart';

class WantedPage extends StatelessWidget {
  const WantedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final notifier = scope.itemsNotifier;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('wanted_offers'))),
      body: AnimatedBuilder(
        animation: notifier,
        builder: (context, _) {
          final offers = notifier.offers;
          if (offers.isEmpty) {
            return Center(child: Text(l10n.t('no_results')));
          }
          final pending = offers.where((offer) => offer.status == OfferStatus.pending).toList();
          final history = offers.where((offer) => offer.status != OfferStatus.pending).toList();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (pending.isNotEmpty)
                _OfferSection(
                  title: l10n.t('offers_pending_section'),
                  emptyLabel: l10n.t('offers_pending_empty'),
                  offers: pending,
                  notifier: notifier,
                  l10n: l10n,
                  interactive: true,
                ),
              if (history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _OfferSection(
                    title: l10n.t('offers_history_section'),
                    emptyLabel: l10n.t('offers_history_empty'),
                    offers: history,
                    notifier: notifier,
                    l10n: l10n,
                    interactive: false,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OfferSection extends StatelessWidget {
  const _OfferSection({
    required this.title,
    required this.emptyLabel,
    required this.offers,
    required this.notifier,
    required this.l10n,
    required this.interactive,
  });

  final String title;
  final String emptyLabel;
  final List<Offer> offers;
  final ItemsNotifier notifier;
  final AppLocalizations l10n;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (offers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(emptyLabel),
          )
        else
          ...offers.map((offer) => _OfferCard(
                offer: offer,
                item: notifier.myItems.firstWhere((item) => item.id == offer.itemId, orElse: () => MyItem(
                      id: offer.itemId,
                      title: l10n.t('my_items'),
                      photos: const <String>[],
                      specs: MyItemSpecs(condition: '', brand: '', year: 0, notes: ''),
                      forSale: false,
                      tips: const <String>[],
                      status: 'waiting_offers',
                    )),
                notifier: notifier,
                l10n: l10n,
                interactive: interactive,
              )),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.item,
    required this.notifier,
    required this.l10n,
    required this.interactive,
  });

  final Offer offer;
  final MyItem item;
  final ItemsNotifier notifier;
  final AppLocalizations l10n;
  final bool interactive;

  Color _statusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (offer.status) {
      case OfferStatus.accepted:
        return theme.colorScheme.primary.withOpacity(0.12);
      case OfferStatus.declined:
        return theme.colorScheme.error.withOpacity(0.12);
      case OfferStatus.countered:
        return theme.colorScheme.secondary.withOpacity(0.12);
      case OfferStatus.pending:
        return theme.colorScheme.primary.withOpacity(0.08);
    }
  }

  String _statusLabel() {
    switch (offer.status) {
      case OfferStatus.accepted:
        return l10n.t('offer_status_accepted');
      case OfferStatus.declined:
        return l10n.t('offer_status_declined');
      case OfferStatus.countered:
        return l10n.t('offer_status_countered');
      case OfferStatus.pending:
        return l10n.t('offer_status_pending');
    }
  }

  void _respond(BuildContext context, OfferStatus status, {double? counterAmount, String? note}) {
    notifier.respondToOffer(offerId: offer.id, status: status, counterAmount: counterAmount, note: note);
    final message = switch (status) {
      OfferStatus.accepted => l10n.t('offer_response_accept'),
      OfferStatus.declined => l10n.t('offer_response_decline'),
      OfferStatus.countered => l10n.t('offer_response_counter'),
      _ => '',
    };
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showCounterSheet(BuildContext context) async {
    final controller = TextEditingController(text: offer.counterAmount?.toString() ?? offer.amount.toString());
    final noteController = TextEditingController(text: offer.responseNote ?? '');
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.t('offer_counter_title'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text(l10n.t('offer_counter_message')),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.t('offer_counter_label')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: l10n.t('offer_counter_hint')),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.t('offer_counter_submit')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true) {
      final amount = double.tryParse(controller.text.trim());
      final note = noteController.text.trim();
      _respond(
        context,
        OfferStatus.countered,
        counterAmount: amount,
        note: note.isEmpty ? null : note,
      );
    }
    controller.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final updatedLabel = localizations.formatShortDate(offer.updatedAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: _statusColor(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(_statusLabel()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${l10n.t('offer_amount')}: ${AppFormatters.currency(offer.amount)}'),
            const SizedBox(height: 4),
            Text('${l10n.t('offer_from')} ${offer.fromUser}'),
            const SizedBox(height: 8),
            Text(offer.message),
            if (offer.counterAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n
                      .t('offer_counter_value')
                      .replaceFirst('%s', AppFormatters.currency(offer.counterAmount!)),
                ),
              ),
            if (offer.responseNote != null && offer.responseNote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.t('offer_response_note').replaceFirst('%s', offer.responseNote!),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.t('offer_updated').replaceFirst('%s', updatedLabel),
                style: theme.textTheme.bodySmall,
              ),
            ),
            if (interactive) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _respond(context, OfferStatus.accepted),
                      child: Text(l10n.t('offer_accept')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _respond(context, OfferStatus.declined),
                      child: Text(l10n.t('offer_decline')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showCounterSheet(context),
                  child: Text(l10n.t('offer_counter')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
