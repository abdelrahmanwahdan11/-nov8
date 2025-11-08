import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/state/notifiers/search_notifier.dart';
import '../../core/widgets/property_card.dart';
import '../../core/widgets/search_bar_x.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/models/property.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  bool _initialized = false;

  Future<void> _saveCurrentSearch(BuildContext context, SearchNotifier notifier, AppLocalizations l10n) async {
    if (!notifier.canSaveCurrent) {
      return;
    }
    FocusScope.of(context).unfocus();
    final suggested = notifier.suggestedLabelForCurrent();
    final initial = suggested == 'Search' ? l10n.t('search') : suggested;
    final label = await _promptForLabel(
      context: context,
      title: l10n.t('save_search'),
      initialValue: initial,
      l10n: l10n,
    );
    if (label == null) {
      return;
    }
    final result = notifier.saveCurrent(label: label);
    final messageKey = result.isUpdate ? 'saved_search_updated' : 'saved_search_created';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t(messageKey))),
    );
  }

  Future<String?> _promptForLabel({
    required BuildContext context,
    required String title,
    required String initialValue,
    required AppLocalizations l10n,
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.t('save_search_placeholder'),
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.t('cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isEmpty) {
                      setState(() => errorText = l10n.t('save_search_required'));
                      return;
                    }
                    Navigator.of(context).pop(value);
                  },
                  child: Text(l10n.t('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applySavedSearch(BuildContext context, SearchNotifier notifier, SavedSearchEntry entry, AppLocalizations l10n) {
    notifier.applySavedSearch(entry.id);
    _controller.text = notifier.query;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('saved_search_applied'))),
    );
  }

  Future<void> _renameSavedSearch(
    BuildContext context,
    SearchNotifier notifier,
    SavedSearchEntry entry,
    AppLocalizations l10n,
  ) async {
    final label = await _promptForLabel(
      context: context,
      title: l10n.t('rename_saved_search'),
      initialValue: entry.label,
      l10n: l10n,
    );
    if (label == null) {
      return;
    }
    if (notifier.renameSavedSearch(entry.id, label) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('saved_search_updated'))),
      );
    }
  }

  void _deleteSavedSearch(
    BuildContext context,
    SearchNotifier notifier,
    SavedSearchEntry entry,
    AppLocalizations l10n,
  ) {
    if (notifier.deleteSavedSearch(entry.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('saved_search_deleted'))),
      );
    }
  }

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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: notifier.canSaveCurrent
                    ? Padding(
                        key: const ValueKey('save_search_row'),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.t('save_search_hint'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: () => _saveCurrentSearch(context, notifier, l10n),
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: Text(l10n.t('save_search')),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: notifier.savedSnapshots.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        key: const ValueKey('saved_searches_section'),
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.t('saved_search_highlights'),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ...notifier.savedSnapshots.map(
                              (snapshot) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SavedSearchCard(
                                  snapshot: snapshot,
                                  onApply: () =>
                                      _applySavedSearch(context, notifier, snapshot.entry, l10n),
                                  onRename: () =>
                                      _renameSavedSearch(context, notifier, snapshot.entry, l10n),
                                  onDelete: () =>
                                      _deleteSavedSearch(context, notifier, snapshot.entry, l10n),
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _SavedSearchCard extends StatelessWidget {
  const _SavedSearchCard({
    required this.snapshot,
    required this.onApply,
    required this.onRename,
    required this.onDelete,
  });

  final SavedSearchSnapshot snapshot;
  final VoidCallback onApply;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final entry = snapshot.entry;
    final preview = snapshot.matches.take(3).toList();
    final description = entry.describe();
    final totalLabel =
        l10n.t('saved_search_total_label').replaceFirst('%d', snapshot.matches.length.toString());
    final badgeLabel =
        l10n.t('saved_search_new_badge').replaceFirst('%d', snapshot.unseenCount.toString());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.label, style: theme.textTheme.titleMedium),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(description, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<_SavedSearchMenu>(
                  tooltip: l10n.t('saved_search_manage'),
                  onSelected: (value) {
                    switch (value) {
                      case _SavedSearchMenu.apply:
                        onApply();
                        break;
                      case _SavedSearchMenu.rename:
                        onRename();
                        break;
                      case _SavedSearchMenu.delete:
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _SavedSearchMenu.apply,
                      child: Text(l10n.t('apply_saved_search')),
                    ),
                    PopupMenuItem(
                      value: _SavedSearchMenu.rename,
                      child: Text(l10n.t('rename_saved_search')),
                    ),
                    PopupMenuItem(
                      value: _SavedSearchMenu.delete,
                      child: Text(l10n.t('delete_saved_search')),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (preview.isEmpty)
              Container(
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.t('saved_search_preview_empty'),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            else
              _SavedSearchPreviewStrip(matches: preview),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(totalLabel, style: theme.textTheme.labelLarge),
                if (snapshot.unseenCount > 0) ...[
                  const SizedBox(width: 12),
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
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.t('saved_search_preview_button')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedSearchPreviewStrip extends StatelessWidget {
  const _SavedSearchPreviewStrip({required this.matches});

  final List<Property> matches;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(matches.length, (index) {
          final property = matches[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == matches.length - 1 ? 0 : 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  property.images.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
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

enum _SavedSearchMenu { apply, rename, delete }
