import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/utils/formatters.dart';
import '../../data/mocks/mock_data.dart';
import '../../data/models/property.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  List<Property> _selected(List<String> ids) {
    return MockData.properties.where((property) => ids.contains(property.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final selected = _selected(scope.compareNotifier.ids);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('compare'))),
      body: selected.length < 2
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconlyLight.compare, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(l10n.t('compare_min_notice'), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/catalog'),
                      child: Text(l10n.t('catalog')),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(l10n.t('facilities'))),
                  for (final property in selected) DataColumn(label: Text(property.title)),
                ],
                rows: [
                  _row(l10n.t('price'), selected.map((e) => AppFormatters.currency(e.price)).toList()),
                  _row(l10n.t('beds'), selected.map((e) => e.facilities.beds.toString()).toList()),
                  _row(l10n.t('baths'), selected.map((e) => e.facilities.baths.toString()).toList()),
                  _row(l10n.t('area'), selected.map((e) => '${e.area} m²').toList()),
                  _row(l10n.t('mortgage'), selected.map((e) => l10n.t(e.mortgageEligible ? 'yes' : 'no')).toList()),
                  _row(l10n.t('city'), selected.map((e) => e.city).toList()),
                  _row(l10n.t('rating'), selected.map((e) => e.rating.toStringAsFixed(1)).toList()),
                ],
              ),
            ),
      floatingActionButton: selected.length < 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                scope.compareNotifier.clear();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.t('clear'))));
              },
              label: Text(l10n.t('clear')),
              icon: const Icon(Icons.delete_outline),
            ),
    );
  }

  DataRow _row(String label, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        for (final value in values) DataCell(Text(value)),
      ],
    );
  }
}
