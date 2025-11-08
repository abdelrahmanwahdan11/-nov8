import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../localization/app_localizations.dart';
import '../utils/formatters.dart';
import '../../data/models/property.dart';
import 'pressable_scale.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavorite,
    required this.onCompare,
    required this.isFavorite,
    required this.isCompared,
  });

  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onCompare;
  final bool isFavorite;
  final bool isCompared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accent = property.dynamicAccent();
    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      property.images.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        _CircleIconButton(
                          icon: isFavorite ? IconlyBold.heart : IconlyLight.heart,
                          filled: true,
                          color: isFavorite ? accent : Colors.white,
                          onPressed: onFavorite,
                        ),
                        const SizedBox(height: 12),
                        _CircleIconButton(
                          icon: IconlyLight.compare,
                          filled: isCompared,
                          color: accent,
                          onPressed: onCompare,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: theme.colorScheme.primary.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.city,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _FacilityChip(label: '${property.facilities.beds} ${l10n.t('beds_short')}'),
                      _FacilityChip(label: '${property.facilities.baths} ${l10n.t('baths_short')}'),
                      _FacilityChip(label: '${property.area} m²'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppFormatters.currency(property.price),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (property.mortgageEligible)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            l10n.t('mortgage_badge'),
                            style: theme.textTheme.labelMedium?.copyWith(color: accent),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: property.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.filled = false,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color.withOpacity(0.9) : Colors.white.withOpacity(0.8),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: filled ? Colors.white : color, size: 18),
        ),
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
