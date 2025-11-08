import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/state/app_scope.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/ai_explain_button.dart';
import '../../core/widgets/flip_info_card.dart';
import '../../core/widgets/spin_gallery_3d.dart';
import '../../data/mocks/mock_data.dart';
import '../../data/models/property.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  Property _findProperty(String? id) {
    return MockData.properties.firstWhere((element) => element.id == id, orElse: () => MockData.properties.first);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final String? id = ModalRoute.of(context)?.settings.arguments as String?;
    final property = _findProperty(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        actions: [
          IconButton(
            icon: Icon(scope.favoritesNotifier.isFavorite(property.id) ? IconlyBold.heart : IconlyLight.heart),
            onPressed: () => scope.favoritesNotifier.toggle(property.id),
          ),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: 320,
            child: GestureDetector(
              onTap: () => _openGallery(context, property.images),
              child: SpinGallery3D(frames: property.spinFrames),
            ),
          ),
          const SizedBox(height: 24),
          FlipInfoCard(
            front: _InfoFront(property: property),
            back: _InfoBack(property: property),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/booking'),
                  child: Text(l10n.t('book_now')),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed('/mortgage'),
                child: Text(l10n.t('mortgage')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AIExplainButton(),
        ],
      ),
    );
  }

  void _openGallery(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    child: Image.network(images[index], fit: BoxFit.contain),
                  );
                },
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoFront extends StatelessWidget {
  const _InfoFront({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18),
              const SizedBox(width: 6),
              Text(property.city, style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              Chip(label: Text('${property.facilities.beds} ${AppLocalizations.of(context).t('beds')}')),
              Chip(label: Text('${property.facilities.baths} ${AppLocalizations.of(context).t('baths')}')),
              Chip(label: Text('${property.area} m²')),
              Chip(label: Text(AppFormatters.currency(property.price))),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBack extends StatelessWidget {
  const _InfoBack({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).t('description'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(property.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).t('facilities'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _Facility(label: AppLocalizations.of(context).t('parking'), value: property.facilities.parking.toString()),
              _Facility(label: AppLocalizations.of(context).t('garden'), value: property.facilities.garden.toString()),
              _Facility(label: 'Rating', value: property.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Facility extends StatelessWidget {
  const _Facility({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
