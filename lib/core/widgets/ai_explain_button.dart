import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AIExplainButton extends StatelessWidget {
  const AIExplainButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ElevatedButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 24),
                      const SizedBox(width: 12),
                      Text(l10n.t('ai_explain'), style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.t('ai_placeholder'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.t('close')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.auto_awesome),
      label: Text(l10n.t('ai_explain')),
    );
  }
}
