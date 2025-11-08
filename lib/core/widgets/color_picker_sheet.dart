import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class ColorPickerSheet extends StatefulWidget {
  const ColorPickerSheet({super.key, required this.initialColor, required this.onChanged});

  final Color initialColor;
  final ValueChanged<Color> onChanged;

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late double _hue;
  late double _saturation;
  late double _lightness;

  @override
  void initState() {
    super.initState();
    final hsl = HSLColor.fromColor(widget.initialColor);
    _hue = hsl.hue;
    _saturation = hsl.saturation;
    _lightness = hsl.lightness;
  }

  Color get _color => HSLColor.fromAHSL(1, _hue, _saturation, _lightness).toColor();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _color.withOpacity(0.4), blurRadius: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSlider(l10n.t('hue'), _hue, 0, 360, (value) => setState(() => _hue = value)),
          _buildSlider(l10n.t('saturation'), _saturation, 0, 1, (value) => setState(() => _saturation = value)),
          _buildSlider(l10n.t('lightness'), _lightness, 0, 1, (value) => setState(() => _lightness = value)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              for (final preset in _presets)
                ChoiceChip(
                  label: const Text(''),
                  selected: false,
                  backgroundColor: preset,
                  onSelected: (_) {
                    final hsl = HSLColor.fromColor(preset);
                    setState(() {
                      _hue = hsl.hue;
                      _saturation = hsl.saturation;
                      _lightness = hsl.lightness;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onChanged(_color);
                Navigator.of(context).pop();
              },
              child: Text(l10n.t('apply_accent')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: (v) {
            onChanged(v);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Color> get _presets => const [
        Color(0xFFFF8A00),
        Color(0xFFFFD400),
        Color(0xFF4ECDC4),
        Color(0xFF8E44AD),
        Color(0xFF2ECC71),
        Color(0xFFEF5777),
      ];
}
