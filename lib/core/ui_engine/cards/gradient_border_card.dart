import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

/// A card with a slowly rotating gradient border rendered via [CustomPaint].
///
/// Features:
/// - 1.5 px border swept from [AppColors.primary] → [AppColors.primaryLight]
///   → transparent, composited with [CustomPaint]
/// - Border gradient completes one full rotation every 3 seconds
/// - Background defaults to [AppColors.card]
/// - Fully customisable [borderGradient], [backgroundColor], [borderRadius]
///
/// Example:
/// ```dart
/// GradientBorderCard(
///   child: Text('Premium'),
///   padding: EdgeInsets.all(16),
/// )
/// ```
class GradientBorderCard extends StatefulWidget {
  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.borderGradient,
    this.backgroundColor,
    this.borderRadius,
    this.borderWidth = 1.5,
    this.rotationDuration = const Duration(seconds: 3),
  });

  /// Content of the card.
  final Widget child;

  /// Inner padding. Defaults to [AppSpacing.md] all sides.
  final EdgeInsetsGeometry? padding;

  /// Custom border gradient. Defaults to primary → primaryLight → transparent.
  final Gradient? borderGradient;

  /// Card background colour. Defaults to [AppColors.card].
  final Color? backgroundColor;

  /// Corner radius of both the card and the border. Defaults to [AppRadius.medium].
  final double? borderRadius;

  /// Width of the gradient border stroke in logical pixels. Defaults to 1.5.
  final double borderWidth;

  /// Duration for one full rotation of the border gradient. Defaults to 3 s.
  final Duration rotationDuration;

  @override
  State<GradientBorderCard> createState() => _GradientBorderCardState();
}

class _GradientBorderCardState extends State<GradientBorderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double r = widget.borderRadius ?? AppRadius.mVal;
    final Color bg = widget.backgroundColor ?? AppColors.card;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (BuildContext ctx, Widget? child) {
          return CustomPaint(
            painter: _GradientBorderPainter(
              rotationAngle: _rotationController.value * 2 * math.pi,
              borderRadius: r,
              borderWidth: widget.borderWidth,
              gradient: widget.borderGradient ??
                  SweepGradient(
                    colors: <Color>[
                      AppColors.primary,
                      AppColors.primaryLight,
                      AppColors.primary.withValues(alpha: 0.4),
                      Colors.transparent,
                      AppColors.primary,
                    ],
                    stops: const <double>[0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
            ),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(r),
          ),
          margin: EdgeInsets.all(widget.borderWidth),
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GradientBorderPainter
// ---------------------------------------------------------------------------

/// Paints a rotating gradient border as a rounded-rect stroke.
class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required this.rotationAngle,
    required this.borderRadius,
    required this.borderWidth,
    required this.gradient,
  });

  final double rotationAngle;
  final double borderRadius;
  final double borderWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Rect.fromLTWH(0, 0, size.width, size.height);

    // Rotate the gradient by applying a canvas transform around the centre.
    final Offset centre = bounds.center;

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-centre.dx, -centre.dy);

    final Paint paint = Paint()
      ..shader = gradient.createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;

    final RRect rrect = RRect.fromRectAndRadius(
      bounds.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle ||
      oldDelegate.gradient != gradient ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.borderRadius != borderRadius;
}
