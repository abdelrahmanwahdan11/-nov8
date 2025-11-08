import 'package:flutter/material.dart';

class CompareTray extends StatelessWidget {
  const CompareTray({
    super.key,
    required this.items,
    required this.onRemove,
    required this.onOpen,
  });

  final List<String> items;
  final ValueChanged<String> onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
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
            Text('Compare (${items.length})', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: items
                  .map(
                    (id) => Chip(
                      label: Text(id),
                      onDeleted: () => onRemove(id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOpen,
                child: const Text('Compare now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
