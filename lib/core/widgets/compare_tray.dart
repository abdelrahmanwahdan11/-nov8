import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class CompareTrayItem {
  const CompareTrayItem({required this.id, required this.label});

  final String id;
  final String label;
}

class CompareTray extends StatelessWidget {
  const CompareTray({
    super.key,
    required this.items,
    required this.onRemove,
    required this.onOpen,
  });

  final List<CompareTrayItem> items;
  final ValueChanged<String> onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      minimum: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('compare_count').replaceFirst('%d', items.length.toString()),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: items
                  .map(
                    (item) => Chip(
                      label: Text(item.label, overflow: TextOverflow.ellipsis),
                      onDeleted: () => onRemove(item.id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOpen,
                child: Text(l10n.t('compare_cta')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
