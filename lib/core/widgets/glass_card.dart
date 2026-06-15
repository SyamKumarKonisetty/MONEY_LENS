import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_radius.dart';

/// A frosted glass card using [BackdropFilter].
///
/// Creates a premium glass effect popular in Apple's design language.
/// Best used over colorful or gradient backgrounds.
///
/// Example:
/// ```dart
/// GlassCard(
///   child: Text('Hello'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 20.0,
    this.opacity = 0.15,
    this.border = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  /// Blur sigma for the frosted glass effect.
  final double blur;

  /// Opacity of the white/surface overlay.
  final double opacity;

  /// Whether to show a subtle border.
  final bool border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.card;
    final baseColor = isDark ? Colors.white : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.6);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: opacity),
              borderRadius: radius,
              border: border ? Border.all(color: borderColor, width: 1) : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
