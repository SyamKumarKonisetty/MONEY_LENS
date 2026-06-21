import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A pulsing glow container that continuously breathes between low and high
/// opacity, indicating a 'live' or active state.
///
/// The glow opacity cycles:  0.3 → 0.8 → 0.3  over [duration] with a smooth
/// sine-shaped animation produced by [CurvedAnimation] + [AnimationController]
/// running in repeat(reverse: true) mode.
///
/// Example:
/// ```dart
/// BreathingGlow(
///   glowColor: AppColors.income,
///   radius: 16,
///   child: Icon(Icons.circle, size: 10, color: AppColors.income),
/// )
/// ```
class BreathingGlow extends StatefulWidget {
  const BreathingGlow({
    super.key,
    required this.child,
    this.glowColor,
    this.radius = 20.0,
    this.minOpacity = 0.3,
    this.maxOpacity = 0.8,
    this.duration = const Duration(seconds: 2),
    this.spreadRadius = 2.0,
    this.blurRadius = 12.0,
  });

  /// The widget displayed inside the glowing halo.
  final Widget child;

  /// Colour of the glow. Defaults to [AppColors.primaryLight].
  final Color? glowColor;

  /// Border radius of the glow container in logical pixels. Defaults to 20.
  final double radius;

  /// Minimum glow opacity at the dim phase. Defaults to 0.3.
  final double minOpacity;

  /// Maximum glow opacity at the bright phase. Defaults to 0.8.
  final double maxOpacity;

  /// Full cycle duration (dim→bright). Defaults to 2 seconds.
  final Duration duration;

  /// Spread radius of the box shadow. Defaults to 2.
  final double spreadRadius;

  /// Blur radius of the box shadow. Defaults to 12.
  final double blurRadius;

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color glow = widget.glowColor ?? AppColors.primaryLight;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (BuildContext ctx, Widget? child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: glow.withValues(alpha: _opacityAnimation.value),
                  blurRadius: widget.blurRadius,
                  spreadRadius: widget.spreadRadius,
                ),
              ],
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A compact live-indicator dot that combines [BreathingGlow] with a small
/// coloured circle — useful for "live", "syncing", or "active" badges.
///
/// Example:
/// ```dart
/// LiveDot(color: AppColors.income) // green pulsing dot
/// ```
class LiveDot extends StatelessWidget {
  const LiveDot({
    super.key,
    this.color,
    this.dotSize = 8.0,
  });

  /// Colour of the dot and glow. Defaults to [AppColors.income].
  final Color? color;

  /// Diameter of the inner dot. Defaults to 8.
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.income;
    return BreathingGlow(
      glowColor: c,
      radius: dotSize,
      blurRadius: 10,
      spreadRadius: 1,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
