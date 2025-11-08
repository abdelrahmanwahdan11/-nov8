import 'package:flutter/material.dart';

class SpinGallery3D extends StatefulWidget {
  const SpinGallery3D({super.key, required this.frames, this.heroTag, this.onTap});

  final List<String> frames;
  final String? heroTag;
  final VoidCallback? onTap;

  @override
  State<SpinGallery3D> createState() => _SpinGallery3DState();
}

class _SpinGallery3DState extends State<SpinGallery3D> with SingleTickerProviderStateMixin {
  late int _index;
  late final int _frameCount;
  late final AnimationController _controller;
  Animation<double>? _animation;
  int _animatedOffset = 0;

  @override
  void initState() {
    super.initState();
    _frameCount = widget.frames.length;
    _index = 0;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _animation?.removeListener(_onAnimate);
    _controller.dispose();
    super.dispose();
  }

  void _applyDelta(int delta) {
    if (_frameCount == 0 || delta == 0) return;
    setState(() {
      _index = (_index - delta) % _frameCount;
      while (_index < 0) {
        _index += _frameCount;
      }
    });
  }

  void _startInertia(double velocity) {
    if (_frameCount == 0) return;
    _animation?.removeListener(_onAnimate);
    _controller.stop();
    final normalized = (velocity / 90).round();
    if (normalized == 0) return;
    _animatedOffset = 0;
    _animation = Tween<double>(begin: 0, end: normalized.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    )..addListener(_onAnimate);
    _controller.forward(from: 0);
  }

  void _onAnimate() {
    if (!mounted) return;
    final value = _animation!.value.round();
    final delta = value - _animatedOffset;
    if (delta != 0) {
      _applyDelta(-delta);
      _animatedOffset = value;
    }
    if (_controller.isCompleted) {
      _animation?.removeListener(_onAnimate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );

    final image = widget.frames.isEmpty
        ? placeholder
        : ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.network(
              widget.frames[_index.clamp(0, _frameCount - 1)],
              fit: BoxFit.cover,
            ),
          );

    final totalFrames = _frameCount == 0 ? 1 : _frameCount;
    final currentFrame = _frameCount == 0 ? 1 : (_index + 1);

    final content = Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: image),
        Positioned(
          bottom: 16,
          left: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.rotate_90_degrees_ccw, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$currentFrame/$totalFrames',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) {
        _applyDelta(details.delta.dx.round());
      },
      onPanEnd: (details) {
        _startInertia(details.velocity.pixelsPerSecond.dx);
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: widget.heroTag != null
            ? Hero(tag: widget.heroTag!, child: content)
            : content,
      ),
    );
  }
}
