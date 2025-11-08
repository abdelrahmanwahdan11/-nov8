import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/widgets/property_card.dart';
import '../../data/mocks/mock_data.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final favorites = scope.favoritesNotifier.ids;
    final properties = MockData.properties.where((property) => favorites.contains(property.id)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('favorites'))),
      body: properties.isEmpty
          ? Center(child: Text(l10n.t('no_results')))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyCard(
                    property: property,
                    onTap: () => Navigator.of(context).pushNamed('/details', arguments: property.id),
                    onFavorite: () => scope.favoritesNotifier.toggle(property.id),
                    onCompare: () => scope.compareNotifier.toggle(property.id),
                    isFavorite: true,
                    isCompared: scope.compareNotifier.contains(property.id),
                  ),
                );
              },
            ),
    );
  }
}
