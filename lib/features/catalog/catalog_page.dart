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
          IconButton(
            icon: Icon(notifier.listMode ? IconlyLight.category : IconlyLight.menu),
            onPressed: () => setState(() => notifier.toggleViewMode()),
          ),
          IconButton(
            icon: const Icon(IconlyLight.filter),
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
          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: notifier.listMode
                ? PaginationList(
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
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (!notifier.isLoading && notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
                        notifier.loadMore();
                      }
                      return false;
                    },
                    child: GridView.builder(
                      controller: _controller,
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.7),
                      itemCount: notifier.visible.length,
                      itemBuilder: (context, index) {
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
                    ),
                  ),
          );
        },
      ),
    );
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

  @override
  void initState() {
    super.initState();
    filters = widget.filters;
    _maxPrice.text = filters.maxPrice?.toString() ?? '';
    _minBeds.text = filters.minBeds?.toString() ?? '';
    _minBaths.text = filters.minBaths?.toString() ?? '';
  }

  @override
  void dispose() {
    _maxPrice.dispose();
    _minBeds.dispose();
    _minBaths.dispose();
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
                decoration: InputDecoration(labelText: l10n.t('price')),
                onChanged: (value) => filters = filters.copyWith(maxPrice: int.tryParse(value)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minBeds,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.t('beds')),
                onChanged: (value) => filters = filters.copyWith(minBeds: int.tryParse(value)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _minBaths,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.t('baths')),
                onChanged: (value) => filters = filters.copyWith(minBaths: int.tryParse(value)),
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
