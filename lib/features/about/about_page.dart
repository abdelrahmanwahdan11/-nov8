import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('about'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.t('app_name'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(l10n.t('version')),
            const SizedBox(height: 24),
            Text('Credits'),
            const SizedBox(height: 8),
            Text('Design fusion by NeoEstate Team.'),
            const SizedBox(height: 24),
            Text('Licenses'),
            const SizedBox(height: 8),
            Text('Images from picsum.photos seeds as placeholders.'),
          ],
        ),
      ),
    );
  }
}
