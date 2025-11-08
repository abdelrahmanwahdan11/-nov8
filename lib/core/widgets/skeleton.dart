import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.height, this.width, this.borderRadius = 16});

  final double? height;
  final double? width;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1, -0.3),
              end: Alignment(1, 0.3),
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
              stops: [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SkeletonBox(height: 200),
        SizedBox(height: 12),
        SkeletonBox(height: 16, width: 160),
        SizedBox(height: 8),
        SkeletonBox(height: 14, width: 120),
      ],
    );
  }
}

class SkeletonGridCard extends StatelessWidget {
  const SkeletonGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SkeletonBox(height: 180),
        SizedBox(height: 12),
        SkeletonBox(height: 16, width: 100),
        SizedBox(height: 8),
        SkeletonBox(height: 14, width: 140),
      ],
    );
  }
}

class SkeletonHero extends StatelessWidget {
  const SkeletonHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(height: 320, borderRadius: 32);
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0, 0);
  }
}
