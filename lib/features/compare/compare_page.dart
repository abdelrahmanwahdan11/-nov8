import 'package:flutter/material.dart';

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
      body: selected.isEmpty
          ? Center(child: Text(l10n.t('no_results')))
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
                  _row(l10n.t('mortgage'), selected.map((e) => e.mortgageEligible ? 'Yes' : 'No').toList()),
                  _row(l10n.t('city'), selected.map((e) => e.city).toList()),
                ],
              ),
            ),
      floatingActionButton: selected.isEmpty
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
