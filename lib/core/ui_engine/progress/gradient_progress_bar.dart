import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A premium horizontal progress bar rendered entirely with [CustomPainter].
///
/// Features:
/// - Gradient fill that shifts from green → yellow → red as [value] increases
/// - Smooth 600 ms easeOutCubic animation when [value] changes
/// - Round caps via [StrokeCap.round] semantics (drawn as rounded rect)
/// - Soft glow box-shadow that matches the dominant fill colour
///
/// Example:
/// ```dart
/// GradientProgressBar(
///   value: 0.65,       // 65 % used
///   height: 8,
///   borderRadius: 4,
/// )
/// ```
class GradientProgressBar extends StatelessWidget {
  const GradientProgressBar({
    super.key,
    required this.value,
    this.gradient,
    this.height = 8.0,
    this.borderRadius = 4.0,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = Curves.easeOutCubic,
  }) : assert(value >= 0.0 && value <= 1.0,
            'value must be between 0.0 and 1.0');

  /// Fill ratio between 0.0 and 1.0.
  final double value;

  /// Custom gradient override. When null a green→yellow→red gradient is used.
  final Gradient? gradient;

  /// Bar height in logical pixels. Defaults to 8.
  final double height;

  /// Corner radius in logical pixels. Defaults to 4.
  final double borderRadius;

  /// Background track colour. Defaults to [AppColors.divider].
  final Color? backgroundColor;

  /// Duration of the fill animation. Defaults to 600 ms.
  final Duration animationDuration;

  /// Curve of the fill animation. Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  /// Derives the dominant colour for the glow from the current value.
  Color _dominantColor(double v) {
    if (v < 0.5) {
      return Color.lerp(AppColors.income, AppColors.warning, v * 2)!;
    } else {
      return Color.lerp(AppColors.warning, AppColors.expense, (v - 0.5) * 2)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? AppColors.divider;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: animationDuration,
      curve: animationCurve,
      builder: (BuildContext ctx, double animatedValue, Widget? _) {
        final Color dominant = _dominantColor(animatedValue);

        final Gradient resolvedGradient = gradient ??
            LinearGradient(
              colors: <Color>[
                AppColors.income,
                AppColors.warning,
                AppColors.expense,
              ],
              stops: const <double>[0.0, 0.55, 1.0],
            );

        return RepaintBoundary(
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: dominant.withValues(alpha: 0.0),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                // ── Background track ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                // ── Filled portion with glow ──────────────────────────────
                LayoutBuilder(
                  builder:
                      (BuildContext lCtx, BoxConstraints constraints) {
                    final double totalWidth = constraints.maxWidth;
                    final double fillWidth =
                        (totalWidth * animatedValue).clamp(0.0, totalWidth);

                    return Stack(
                      children: <Widget>[
                        // Glow layer (slightly wider/taller for bloom)
                        if (animatedValue > 0.02)
                          Container(
                            width: math.max(fillWidth, height),
                            height: height,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(borderRadius),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: dominant.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        // Fill bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: SizedBox(
                            width: totalWidth,
                            height: height,
                            child: CustomPaint(
                              painter: _BarPainter(
                                fillFraction: animatedValue,
                                gradient: resolvedGradient,
                                borderRadius: borderRadius,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Paints only the filled portion of the bar with the provided gradient.
class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.fillFraction,
    required this.gradient,
    required this.borderRadius,
  });

  final double fillFraction;
  final Gradient gradient;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillFraction <= 0.0) return;

    final double fillWidth = size.width * fillFraction;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      Radius.circular(borderRadius),
    );

    // Gradient is always drawn over the FULL width so colours stay consistent.
    final Paint paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) =>
      oldDelegate.fillFraction != fillFraction ||
      oldDelegate.gradient != gradient ||
      oldDelegate.borderRadius != borderRadius;
}
