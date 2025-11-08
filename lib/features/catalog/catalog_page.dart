import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/catalog_notifier.dart';
import '../../core/widgets/pagination_list.dart';
import '../../core/widgets/property_card.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/mocks/mock_data.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final notifier = scope.catalogNotifier;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('catalog')),
        actions: [
          PopupMenuButton<CatalogSort>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.t('sort'),
            onSelected: (value) => setState(() => notifier.updateSort(value)),
            itemBuilder: (context) => CatalogSort.values
                .map(
                  (value) => CheckedPopupMenuItem<CatalogSort>(
                    value: value,
                    checked: notifier.sort == value,
                    child: Text(_sortLabel(l10n, value)),
                  ),
                )
                .toList(),
          ),
          IconButton(
            icon: Icon(notifier.listMode ? IconlyLight.category : IconlyLight.menu),
            tooltip: notifier.listMode ? l10n.t('grid_view') : l10n.t('list_view'),
            onPressed: () => setState(() => notifier.toggleViewMode()),
          ),
          IconButton(
            icon: const Icon(IconlyLight.filter),
            tooltip: l10n.t('filters'),
            onPressed: () async {
              final filters = await showModalBottomSheet<CatalogFilters>(
                context: context,
                isScrollControlled: true,
                builder: (context) => _FiltersSheet(filters: notifier.filters),
              );
              if (filters != null) {
                notifier.updateFilters(filters);
              }
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: notifier,
        builder: (context, child) {
          if (notifier.visible.isEmpty && notifier.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: SkeletonListCard(),
            );
          }

          final summary = _summarySection(context, notifier, l10n);
          final theme = Theme.of(context);

          if (notifier.visible.isEmpty) {
            return RefreshIndicator(
              onRefresh: notifier.refresh,
              child: ListView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 48),
                children: [
                  summary,
                  const SizedBox(height: 48),
                  Icon(
                    Icons.home_work_outlined,
                    size: 56,
                    color: theme.colorScheme.primary.withOpacity(0.25),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.t('no_results'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      l10n.t('no_results_filters'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                  if (notifier.activeFiltersCount > 0) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: OutlinedButton(
                        onPressed: notifier.clearFilters,
                        child: Text(l10n.t('clear_filters')),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          if (notifier.listMode) {
            return RefreshIndicator(
              onRefresh: notifier.refresh,
              child: PaginationList(
                controller: _controller,
                itemCount: notifier.visible.length,
                itemBuilder: (context, index) {
                  final property = notifier.visible[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                onLoadMore: notifier.loadMore,
                isLoading: notifier.isLoading,
                header: summary,
                padding: const EdgeInsets.only(bottom: 24),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (!notifier.isLoading && notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
                  notifier.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: summary),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final property = notifier.visible[index];
                          return PropertyCard(
                            property: property,
                            onTap: () => Navigator.of(context).pushNamed('/details', arguments: property.id),
                            onFavorite: () => scope.favoritesNotifier.toggle(property.id),
                            onCompare: () => scope.compareNotifier.toggle(property.id),
                            isFavorite: scope.favoritesNotifier.isFavorite(property.id),
                            isCompared: scope.compareNotifier.contains(property.id),
                          );
                        },
                        childCount: notifier.visible.length,
                      ),
                    ),
                  ),
                  if (notifier.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summarySection(BuildContext context, CatalogNotifier notifier, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: _buildSummary(context, notifier, l10n),
    );
  }

  Widget _buildSummary(BuildContext context, CatalogNotifier notifier, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final resultsLabel = l10n.t('catalog_results').replaceFirst('%d', notifier.visible.length.toString());
    final sortLabel = _sortLabel(l10n, notifier.sort);
    final filtersCount = notifier.activeFiltersCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(resultsLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SummaryChip(
                    icon: Icons.sort,
                    label: sortLabel,
                    background: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    iconColor: theme.colorScheme.primary,
                  ),
                  if (filtersCount > 0)
                    _SummaryChip(
                      icon: Icons.filter_list,
                      label: l10n.t('filters_active').replaceFirst('%d', filtersCount.toString()),
                      background: theme.colorScheme.primary.withOpacity(0.12),
                      iconColor: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
            if (filtersCount > 0)
              TextButton(
                onPressed: notifier.clearFilters,
                child: Text(l10n.t('clear_filters')),
              ),
          ],
        ),
      ],
    );
  }

  String _sortLabel(AppLocalizations l10n, CatalogSort sort) {
    switch (sort) {
      case CatalogSort.priceLowToHigh:
        return l10n.t('sort_price_low');
      case CatalogSort.priceHighToLow:
        return l10n.t('sort_price_high');
      case CatalogSort.areaHighToLow:
        return l10n.t('sort_area');
      case CatalogSort.recommended:
        return l10n.t('sort_recommended');
    }
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.filters});

  final CatalogFilters filters;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late CatalogFilters filters;
  final TextEditingController _maxPrice = TextEditingController();
  final TextEditingController _minBeds = TextEditingController();
  final TextEditingController _minBaths = TextEditingController();
  final TextEditingController _minArea = TextEditingController();
  String? _city;

  @override
  void initState() {
    super.initState();
    filters = widget.filters;
    _maxPrice.text = filters.maxPrice?.toString() ?? '';
    _minBeds.text = filters.minBeds?.toString() ?? '';
    _minBaths.text = filters.minBaths?.toString() ?? '';
    _minArea.text = filters.minArea?.toString() ?? '';
    _city = filters.city;
  }

  @override
  void dispose() {
    _maxPrice.dispose();
    _minBeds.dispose();
    _minBaths.dispose();
    _minArea.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.t('filters'), style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(CatalogFilters()),
                    child: Text(l10n.t('clear')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _maxPrice,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.t('max_price')),
                onChanged: (value) => filters = filters.copyWith(maxPrice: int.tryParse(value)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minBeds,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.t('min_beds')),
                onChanged: (value) => filters = filters.copyWith(minBeds: int.tryParse(value)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minBaths,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.t('min_baths')),
                onChanged: (value) => filters = filters.copyWith(minBaths: int.tryParse(value)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minArea,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.t('min_area')),
                onChanged: (value) => filters = filters.copyWith(minArea: int.tryParse(value)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _city,
                decoration: InputDecoration(labelText: l10n.t('city_filter')),
                items: MockData.properties
                    .map((property) => property.city)
                    .toSet()
                    .map((city) => DropdownMenuItem<String?>(value: city, child: Text(city)))
                    .toList()
                  ..insert(0, DropdownMenuItem<String?>(value: null, child: Text(l10n.t('all')))),
                onChanged: (value) {
                  setState(() {
                    _city = value;
                    filters = filters.copyWith(city: value);
                  });
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: MockData.properties
                    .expand((property) => property.tags)
                    .toSet()
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: filters.tags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            final updated = Set<String>.from(filters.tags);
                            if (selected) {
                              updated.add(tag);
                            } else {
                              updated.remove(tag);
                            }
                            filters = filters.copyWith(tags: updated);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(filters),
                  child: Text(l10n.t('apply')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    this.background,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? background;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackground = background ?? theme.colorScheme.surfaceVariant.withOpacity(0.3);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveIconColor),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
