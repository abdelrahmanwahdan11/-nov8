import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/search_notifier.dart';
import '../../core/widgets/coach_marks.dart';
import '../../core/widgets/compare_tray.dart';
import '../../core/widgets/property_card.dart';
import '../../core/widgets/search_bar_x.dart';
import '../../core/widgets/spin_gallery_3d.dart';
import '../../core/utils/notifications_builder.dart';
import '../../data/mocks/mock_data.dart';
import '../../data/models/property.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _chipsKey = GlobalKey();
  final GlobalKey _compareKey = GlobalKey();
  final GlobalKey _bookKey = GlobalKey();

  String _selectedChip = 'all';
  CoachMarksOverlay? _coachOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scope = AppScope.of(context);
      if (scope.coachMarksNotifier.shouldShow) {
        final l10n = AppLocalizations.of(context);
        _coachOverlay?.dismiss();
        _coachOverlay = CoachMarksOverlay(
          context: context,
          steps: [
            CoachMarkStep(
              key: _searchKey,
              title: l10n.t('tutorial_1'),
              message: l10n.t('tutorial_1_hint'),
            ),
            CoachMarkStep(
              key: _heroKey,
              title: l10n.t('tutorial_2'),
              message: l10n.t('tutorial_2_hint'),
            ),
            CoachMarkStep(
              key: _chipsKey,
              title: l10n.t('tutorial_3'),
              message: l10n.t('tutorial_3_hint'),
            ),
            CoachMarkStep(
              key: _compareKey,
              title: l10n.t('compare'),
              message: l10n.t('coach_compare_hint'),
            ),
            CoachMarkStep(
              key: _bookKey,
              title: l10n.t('tutorial_4'),
              message: l10n.t('tutorial_4_hint'),
            ),
          ],
          onComplete: () {
            scope.coachMarksNotifier.complete();
            _coachOverlay = null;
          },
        )
          ..show();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _coachOverlay?.dismiss();
    super.dispose();
  }

  List<Property> _filteredProperties(List<Property> source) {
    switch (_selectedChip) {
      case 'best_offer':
        return source.where((p) => p.price < 2000000).toList();
      case 'for_sale':
        return List<Property>.from(source);
      case 'for_rent':
        return source.where((p) => p.tags.contains('deal')).toList();
      case 'mortgage':
        return source.where((p) => p.mortgageEligible).toList();
      default:
        return List<Property>.from(source);
    }
  }

  void _openProperty(AppScopeData scope, String propertyId) {
    Navigator.of(context)
        .pushNamed('/details', arguments: propertyId)
        .then((_) {
      if (!mounted) return;
      scope.searchNotifier.recordPropertyOpened(propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('find_place'), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              scope.authNotifier.user?.name ?? l10n.t('greeting_guest'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: scope.itemsNotifier,
            builder: (context, _) {
              final pending = scope.itemsNotifier.pendingOffersCount();
              return _buildBadgeIcon(
                context,
                icon: Icons.mark_unread_chat_alt_outlined,
                count: pending,
                tooltip: l10n.t('offers_pending_section'),
                onTap: () => Navigator.of(context).pushNamed('/wanted'),
              );
            },
          ),
          AnimatedBuilder(
            animation: Listenable.merge([
              scope.notificationsNotifier,
              scope.bookingNotifier,
              scope.itemsNotifier,
              scope.searchNotifier,
            ]),
            builder: (context, _) {
              final notifications = buildNotifications(
                scope: scope,
                l10n: l10n,
                material: MaterialLocalizations.of(context),
              );
              final unread =
                  notifications.where((item) => !scope.notificationsNotifier.isRead(item.id)).length;
              return _buildBadgeIcon(
                context,
                icon: IconlyLight.notification,
                count: unread,
                tooltip: l10n.t('notifications'),
                onTap: () => Navigator.of(context).pushNamed('/notifications'),
              );
            },
          ),
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final rootContext = context;
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (sheetContext) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  runSpacing: 12,
                  children: [
                    ListTile(
                      leading: const Icon(IconlyBold.heart),
                      title: Text(l10n.t('favorites')),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(rootContext).pushNamed('/favorites');
                      },
                    ),
                    ListTile(
                      leading: const Icon(IconlyBold.folder),
                      title: Text(l10n.t('catalog')),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(rootContext).pushNamed('/catalog');
                      },
                    ),
                    ListTile(
                      leading: const Icon(IconlyBold.chart),
                      title: Text(l10n.t('compare')),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(rootContext).pushNamed('/compare');
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.apps),
      ),
      body: AnimatedBuilder(
        animation: scope.catalogNotifier,
        builder: (context, _) {
          final catalog = scope.catalogNotifier;
          final catalogAll = catalog.allProperties;
          final fallbackAll = catalogAll.isNotEmpty ? catalogAll : MockData.properties;
          final primaryList = catalog.visible.isNotEmpty ? catalog.visible : fallbackAll;
          final filtered = _filteredProperties(primaryList);
          final heroProperty = filtered.isNotEmpty ? filtered.first : fallbackAll.first;
          final modernCandidates = fallbackAll.where((p) => p.tags.contains('modern')).toList();
          final modernSource = modernCandidates.isEmpty ? fallbackAll : modernCandidates;
          final cityCandidates = fallbackAll
              .where((p) => p.tags.contains('cityscape') || p.tags.contains('skyline'))
              .toList();
          final citySource = cityCandidates.isEmpty ? fallbackAll : cityCandidates;

          return RefreshIndicator(
            onRefresh: () async {
              await catalog.refresh();
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
            Container(
              key: _searchKey,
              child: AnimatedBuilder(
                animation: scope.searchNotifier,
                builder: (context, _) {
                  return SearchBarX(
                    controller: _searchController,
                    onChanged: (value) => scope.searchNotifier.updateQuery(value),
                    onSubmitted: (value) {
                      scope.searchNotifier.updateQuery(value);
                      scope.searchNotifier.commitQuery(value);
                      Navigator.of(context).pushNamed('/search');
                    },
                    onFilters: () => Navigator.of(context).pushNamed('/catalog'),
                    suggestionsBuilder: (query) => scope.searchNotifier.suggestions(query),
                    isLoading: scope.searchNotifier.isLoading,
                  );
                },
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: catalog.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedBuilder(
              animation: scope.searchNotifier,
              builder: (context, _) {
                final highlights = scope.searchNotifier.savedSnapshots;
                if (highlights.isEmpty) {
                  return const SizedBox.shrink();
                }
                final previewList = highlights.take(4).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      l10n.t('saved_search_quick_title'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 210,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: previewList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final snapshot = previewList[index];
                  return _SavedSearchQuickCard(
                    snapshot: snapshot,
                    onTap: () {
                      scope.searchNotifier.applySavedSearch(snapshot.entry.id);
                      final message = snapshot.unseenCount > 0
                          ? l10n
                              .t('saved_search_applied_with_new')
                              .replaceFirst('%d', snapshot.unseenCount.toString())
                          : l10n.t('saved_search_applied');
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(message)));
                      Navigator.of(context).pushNamed('/search');
                    },
                    onManage: () => Navigator.of(context).pushNamed('/search'),
                  );
                },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _FeatureChips(
              key: _chipsKey,
              selected: _selectedChip,
              onChanged: (value) => setState(() => _selectedChip = value),
            ),
            const SizedBox(height: 20),
            Container(
              key: _heroKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: SpinGallery3D(
                  key: ValueKey(heroProperty.id),
                  frames: heroProperty.spinFrames,
                  heroTag: heroProperty.id,
                  onTap: () => _openProperty(scope, heroProperty.id),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.t('section_modern'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: modernSource.length,
                itemBuilder: (context, index) {
                  final property = modernSource[index];
                  return SizedBox(
                    width: 280,
                    child: PropertyCard(
                      property: property,
                      onTap: () => _openProperty(scope, property.id),
                      onFavorite: () => scope.favoritesNotifier.toggle(property.id),
                      onCompare: () => scope.compareNotifier.toggle(property.id),
                      isFavorite: scope.favoritesNotifier.isFavorite(property.id),
                      isCompared: scope.compareNotifier.contains(property.id),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 16),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.t('section_city'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: citySource.length,
                itemBuilder: (context, index) {
                  final property = citySource[index];
                  return GestureDetector(
                    onTap: () => _openProperty(scope, property.id),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Image.network(
                            property.images.first,
                            width: 220,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  property.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: _bookKey,
              onPressed: () => Navigator.of(context).pushNamed('/booking'),
              icon: const Icon(Icons.calendar_month),
              label: Text(l10n.t('book_now')),
            ),
          ],
        ),
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: scope.compareNotifier,
        builder: (context, child) {
          Property? _findById(String id) {
            for (final property in MockData.properties) {
              if (property.id == id) {
                return property;
              }
            }
            return null;
          }

          final compareItems = scope.compareNotifier.ids
              .map(_findById)
              .whereType<Property>()
              .map((property) => CompareTrayItem(id: property.id, label: property.title))
              .toList();
          return CompareTray(
            key: _compareKey,
            items: compareItems,
            onRemove: (id) => scope.compareNotifier.remove(id),
            onOpen: () => Navigator.of(context).pushNamed('/compare'),
          );
        },
      ),
    );
  }
}

class _SavedSearchQuickCard extends StatelessWidget {
  const _SavedSearchQuickCard({
    required this.snapshot,
    required this.onTap,
    required this.onManage,
  });

  final SavedSearchSnapshot snapshot;
  final VoidCallback onTap;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final preview = snapshot.matches.isEmpty ? null : snapshot.matches.first;
    final description = snapshot.entry.describe();
    final badgeLabel =
        l10n.t('saved_search_new_badge').replaceFirst('%d', snapshot.unseenCount.toString());
    final totalLabel =
        l10n.t('saved_search_total_label').replaceFirst('%d', snapshot.matches.length.toString());
    final latest = snapshot.unseenMatches.isNotEmpty ? snapshot.unseenMatches.first : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: preview != null
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(preview.images.first, fit: BoxFit.cover),
                    )
                  : Container(
                      height: 90,
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                      alignment: Alignment.center,
                      child: Icon(Icons.search, color: theme.colorScheme.primary.withOpacity(0.6)),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    snapshot.entry.label,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onManage,
                  tooltip: l10n.t('saved_search_manage'),
                ),
              ],
            ),
            if (description.isNotEmpty)
              Text(
                description,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (latest != null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.t('saved_search_notification_preview').replaceFirst('%s', latest.title),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (snapshot.unseenCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(totalLabel, style: theme.textTheme.labelSmall),
                const Spacer(),
                Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChips extends StatelessWidget {
  const _FeatureChips({super.key, required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = <String>['all', 'best_offer', 'for_sale', 'for_rent', 'mortgage'];
    return Wrap(
      spacing: 12,
      children: chips
          .map(
            (chip) => ChoiceChip(
              label: Text(l10n.t(chip)),
              selected: selected == chip,
              onSelected: (_) => onChanged(chip),
            ),
          )
          .toList(),
    );
  }
}

Widget _buildBadgeIcon(
  BuildContext context, {
  required IconData icon,
  required int count,
  required String tooltip,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  return Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onTap,
      ),
      if (count > 0)
        Positioned(
          right: 4,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              count > 9 ? '9+' : count.toString(),
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
    ],
  );
}
