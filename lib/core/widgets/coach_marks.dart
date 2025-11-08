import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class CoachMarkStep {
  CoachMarkStep({required this.key, required this.title, required this.message});

  final GlobalKey key;
  final String title;
  final String message;
}

class CoachMarksOverlay {
  CoachMarksOverlay({required this.context, required this.steps, required this.onComplete});

  final BuildContext context;
  final List<CoachMarkStep> steps;
  final VoidCallback onComplete;

  OverlayEntry? _entry;
  int _index = 0;

  void show() {
    if (steps.isEmpty || _entry != null) {
      return;
    }
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    _entry = OverlayEntry(builder: (context) {
      return _CoachMarkContent(
        step: steps[_index],
        index: _index,
        total: steps.length,
        onNext: next,
        onSkip: dismiss,
      );
    });
    overlay.insert(_entry!);
  }

  bool _completed = false;

  void next() {
    if (_index >= steps.length - 1) {
      dismiss();
      return;
    }
    _index += 1;
    _entry?.markNeedsBuild();
  }

  void dismiss() {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
    }
    if (!_completed) {
      _completed = true;
      onComplete();
    }
  }
}

class _CoachMarkContent extends StatefulWidget {
  const _CoachMarkContent({required this.step, required this.index, required this.total, required this.onNext, required this.onSkip});

  final CoachMarkStep step;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_CoachMarkContent> createState() => _CoachMarkContentState();
}

class _CoachMarkContentState extends State<_CoachMarkContent> with SingleTickerProviderStateMixin {
  late Rect targetRect;

  @override
  void initState() {
    super.initState();
    targetRect = _findRect();
  }

  @override
  void didUpdateWidget(covariant _CoachMarkContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.key != widget.step.key) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            targetRect = _findRect();
          });
        }
      });
    }
  }

  Rect _findRect() {
    final renderObject = widget.step.key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & renderObject.size;
    }
    return const Rect.fromLTWH(0, 0, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    targetRect = _findRect();
    final media = MediaQuery.of(context);
    const cardHeightEstimate = 220.0;
    final hasTarget = !targetRect.isEmpty;
    final defaultTop = media.size.height * 0.4;
    double top = hasTarget ? targetRect.bottom + 24 : defaultTop;
    if (top + cardHeightEstimate > media.size.height - 24) {
      final fallbackTop = hasTarget ? targetRect.top - cardHeightEstimate - 24 : media.size.height / 2 - cardHeightEstimate / 2;
      top = fallbackTop.clamp(24.0, math.max(24.0, media.size.height - cardHeightEstimate - 24));
    }
    final double rawLeft = hasTarget ? targetRect.left : 24;
    final double clampedLeft = rawLeft.clamp(24.0, math.max(24.0, media.size.width - 340));
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CoachMaskPainter(rect: targetRect),
            ),
          ),
          Positioned(
            top: top,
            left: clampedLeft,
            right: 24,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.step.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Text(widget.step.message, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: widget.onSkip, child: Text(l10n.t('coach_skip'))),
                          FilledButton(
                            onPressed: widget.onNext,
                            child: Text(widget.index == widget.total - 1 ? l10n.t('coach_done') : l10n.t('coach_next')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.total,
                          (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == widget.index ? 14 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == widget.index ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachMaskPainter extends CustomPainter {
  _CoachMaskPainter({required this.rect});

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..blendMode = BlendMode.dstOut;
    final background = Paint()..color = Colors.black54;
    canvas.drawRect(Offset.zero & size, background);
    if (!rect.isEmpty) {
      final rRect = RRect.fromRectAndRadius(rect.inflate(16), const Radius.circular(24));
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoachMaskPainter oldDelegate) => rect != oldDelegate.rect;
}
