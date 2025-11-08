import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/search_notifier.dart';
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
              _SummaryBar(
                query: notifier.query,
                isLoading: notifier.isLoading,
                resultCount: notifier.results.length,
                activeRefinementCount: notifier.activeRefinementCount,
                onClear: () {
                  _controller.clear();
                  notifier.updateQuery('');
                  FocusScope.of(context).unfocus();
                },
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: notifier.popularCities.isEmpty && notifier.popularTags.isEmpty
                    ? const SizedBox.shrink()
                    : _RefinementSection(
                        key: const ValueKey('refinement_section'),
                        notifier: notifier,
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

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.query,
    required this.isLoading,
    required this.resultCount,
    required this.activeRefinementCount,
    required this.onClear,
  });

  final String query;
  final bool isLoading;
  final int resultCount;
  final int activeRefinementCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaryLabel = isLoading
        ? l10n.t('loading')
        : l10n.t('search_results_count').replaceFirst('%d', resultCount.toString());
    final hasRefinements = activeRefinementCount > 0;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: hasQuery
          ? Padding(
              key: const ValueKey('summary'),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Row(
                children: [
                  if (isLoading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.search, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          summaryLabel,
                          style: theme.textTheme.labelLarge,
                        ),
                        if (hasRefinements)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              l10n
                                  .t('active_refinements')
                                  .replaceFirst('%d', activeRefinementCount.toString()),
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                    label: Text(l10n.t('clear_search')),
                  ),
                ],
              ),
            )
          : const SizedBox(key: ValueKey('empty')),
    );
  }
}

class _RefinementSection extends StatelessWidget {
  const _RefinementSection({super.key, required this.notifier});

  final SearchNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.t('refine_results'),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (notifier.activeRefinementCount > 0)
                TextButton(
                  onPressed: notifier.clearRefinements,
                  child: Text(l10n.t('clear_refinements')),
                ),
            ],
          ),
          if (notifier.popularCities.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.t('matching_cities'), style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: notifier.popularCities
                  .map(
                    (city) => FilterChip(
                      label: Text(city),
                      selected: notifier.isCityActive(city),
                      onSelected: (_) => notifier.toggleCity(city),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (notifier.popularTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.t('matching_tags'), style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: notifier.popularTags
                  .map(
                    (tag) => FilterChip(
                      label: Text('#$tag'),
                      selected: notifier.isTagActive(tag),
                      onSelected: (_) => notifier.toggleTag(tag),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
