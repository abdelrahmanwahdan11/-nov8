import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/widgets/coach_marks.dart';
import '../../core/widgets/compare_tray.dart';
import '../../core/widgets/property_card.dart';
import '../../core/widgets/search_bar_x.dart';
import '../../core/widgets/spin_gallery_3d.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scope = AppScope.of(context);
      if (scope.coachMarksNotifier.shouldShow) {
        final l10n = AppLocalizations.of(context);
        final overlay = CoachMarksOverlay(
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
          },
        );
        overlay.show();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Property> _filteredProperties() {
    final all = MockData.properties;
    switch (_selectedChip) {
      case 'best_offer':
        return all.where((p) => p.price < 2000000).toList();
      case 'for_sale':
        return all;
      case 'for_rent':
        return all.where((p) => p.tags.contains('deal')).toList();
      case 'mortgage':
        return all.where((p) => p.mortgageEligible).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final properties = _filteredProperties();
    final heroProperty = properties.isNotEmpty ? properties.first : MockData.properties.first;
    final modernList = MockData.properties.where((p) => p.tags.contains('modern')).toList();
    final cityList = MockData.properties
        .where((p) => p.tags.contains('cityscape') || p.tags.contains('skyline'))
        .toList();
    final curatedModern = modernList.isEmpty ? MockData.properties : modernList;
    final curatedCity = cityList.isEmpty ? MockData.properties : cityList;

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
      body: RefreshIndicator(
        onRefresh: () async {
          await scope.catalogNotifier.refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              key: _searchKey,
              child: SearchBarX(
                controller: _searchController,
                onChanged: (value) => scope.searchNotifier.updateQuery(value),
                onSubmitted: (value) {
                  scope.searchNotifier.updateQuery(value);
                  scope.searchNotifier.commitQuery(value);
                  Navigator.of(context).pushNamed('/search');
                },
                onFilters: () => Navigator.of(context).pushNamed('/catalog'),
                suggestionsBuilder: (query) => scope.searchNotifier.suggestions(query),
              ),
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
                  onTap: () => Navigator.of(context)
                      .pushNamed('/details', arguments: heroProperty.id),
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
                itemCount: curatedModern.length,
                itemBuilder: (context, index) {
                  final property = curatedModern[index];
                  return SizedBox(
                    width: 280,
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
                itemCount: curatedCity.length,
                itemBuilder: (context, index) {
                  final property = curatedCity[index];
                  return GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed('/details', arguments: property.id),
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
