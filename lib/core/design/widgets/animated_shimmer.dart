import 'package:flutter/material.dart';

/// A sliding gradient shimmer effect container for loading state placeholders.
class AnimatedShimmer extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const AnimatedShimmer({
    super.key,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<AnimatedShimmer> createState() => _AnimatedShimmerState();
}

class _AnimatedShimmerState extends State<AnimatedShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFF17191F),
                Color(0xFF2C303B),
                Color(0xFF17191F),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-2.0 + _controller.value * 4.0, -0.3),
              end: Alignment(-1.0 + _controller.value * 4.0, 0.3),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
