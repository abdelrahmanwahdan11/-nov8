import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/widgets/property_card.dart';
import '../../core/widgets/search_bar_x.dart';
import '../../core/widgets/skeleton.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final scope = AppScope.of(context);
      _controller.text = scope.searchNotifier.query;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final notifier = scope.searchNotifier;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('search'))),
      body: AnimatedBuilder(
        animation: notifier,
        builder: (context, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: SearchBarX(
                  controller: _controller,
                  onChanged: notifier.updateQuery,
                  onSubmitted: (value) {
                    notifier.updateQuery(value);
                    notifier.commitQuery(value);
                  },
                  onFilters: () => Navigator.of(context).pushNamed('/catalog'),
                  suggestionsBuilder: notifier.suggestions,
                  isLoading: notifier.isLoading,
                ),
              ),
              if (notifier.recent.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.t('recent_searches'), style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: notifier.recent
                              .map(
                                (recent) => ActionChip(
                                  label: Text(recent),
                                  onPressed: () {
                                    _controller.text = recent;
                                    notifier.updateQuery(recent);
                                    notifier.commitQuery(recent);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: notifier.isLoading
                    ? ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: 4,
                        itemBuilder: (context, index) => const SkeletonListCard(),
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                      )
                    : notifier.results.isEmpty
                        ? Center(child: Text(l10n.t('no_results')))
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: notifier.results.length,
                            itemBuilder: (context, index) {
                              final property = notifier.results[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PropertyCard(
                                  property: property,
                                  onTap: () => Navigator.of(context).pushNamed('/details', arguments: property.id),
                                  onFavorite: () => scope.favoritesNotifier.toggle(property.id),
                                  onCompare: () => scope.compareNotifier.toggle(property.id),
                                  isFavorite: scope.favoritesNotifier.isFavorite(property.id),
                                  isCompared: scope.compareNotifier.contains(property.id),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
