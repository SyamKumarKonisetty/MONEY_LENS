import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A circular progress ring that animates from 0 to [progress] (0.0–1.0).
///
/// Features:
/// - Gradient stroke from [AppColors.primary] → [AppColors.primaryLight]
/// - Background track ring in [AppColors.divider]
/// - Smooth 800 ms easeOutCubic animation on [progress] changes
/// - Accepts an arbitrary [child] widget rendered in the centre
///
/// Example:
/// ```dart
/// LiquidProgressRing(
///   progress: 0.72,
///   size: 120,
///   strokeWidth: 8,
///   child: Text('72%'),
/// )
/// ```
class LiquidProgressRing extends StatelessWidget {
  const LiquidProgressRing({
    super.key,
    required this.progress,
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.child,
    this.gradientStart,
    this.gradientEnd,
    this.trackColor,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutCubic,
  }) : assert(progress >= 0.0 && progress <= 1.0,
            'progress must be between 0.0 and 1.0');

  /// Progress value between 0.0 and 1.0.
  final double progress;

  /// Outer diameter of the ring in logical pixels. Defaults to 120.
  final double size;

  /// Width of the arc stroke in logical pixels. Defaults to 8.
  final double strokeWidth;

  /// Optional widget rendered in the centre of the ring.
  final Widget? child;

  /// Start color of the arc gradient. Defaults to [AppColors.primary].
  final Color? gradientStart;

  /// End color of the arc gradient. Defaults to [AppColors.primaryLight].
  final Color? gradientEnd;

  /// Color of the background track ring. Defaults to [AppColors.divider].
  final Color? trackColor;

  /// Duration of the progress animation. Defaults to 800 ms.
  final Duration animationDuration;

  /// Curve of the progress animation. Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    final Color start = gradientStart ?? AppColors.primary;
    final Color end = gradientEnd ?? AppColors.primaryLight;
    final Color track = trackColor ?? AppColors.divider;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: animationDuration,
      curve: animationCurve,
      builder: (BuildContext ctx, double animatedProgress, Widget? _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring painter
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _RingPainter(
                    progress: animatedProgress,
                    strokeWidth: strokeWidth,
                    gradientStart: start,
                    gradientEnd: end,
                    trackColor: track,
                  ),
                ),
              ),
              // Centre content
              if (child != null)
                SizedBox(
                  width: size - strokeWidth * 2 - AppSpacing.xs,
                  height: size - strokeWidth * 2 - AppSpacing.xs,
                  child: Center(child: child),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// [CustomPainter] that draws the background track and the progress arc.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientStart,
    required this.gradientEnd,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color gradientStart;
  final Color gradientEnd;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    // ── Background track ──────────────────────────────────────────────────
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // ── Gradient arc ─────────────────────────────────────────────────────
    if (progress <= 0.0) return;

    final double sweepAngle = 2 * math.pi * progress;
    const double startAngle = -math.pi / 2; // 12 o'clock

    // Build a SweepGradient as a shader across the bounding rect.
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final SweepGradient gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: <Color>[gradientStart, gradientEnd],
      stops: const <double>[0.0, 1.0],
      tileMode: TileMode.clamp,
    );

    final Paint arcPaint = Paint()
      ..shader = gradient.createShader(arcRect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);

    // ── Glowing tip dot ──────────────────────────────────────────────────
    final double tipX =
        center.dx + radius * math.cos(startAngle + sweepAngle);
    final double tipY =
        center.dy + radius * math.sin(startAngle + sweepAngle);
    final Offset tipOffset = Offset(tipX, tipY);

    final Paint glowPaint = Paint()
      ..color = gradientEnd.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(tipOffset, strokeWidth / 2 + 2, glowPaint);

    final Paint tipPaint = Paint()
      ..color = gradientEnd
      ..style = PaintingStyle.fill;

    canvas.drawCircle(tipOffset, strokeWidth / 2, tipPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gradientStart != gradientStart ||
      oldDelegate.gradientEnd != gradientEnd ||
      oldDelegate.trackColor != trackColor;
}
