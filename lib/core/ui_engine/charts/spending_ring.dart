import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

/// Represents a single concentric ring in [SpendingRing].
class RingData {
  /// Creates a [RingData].
  const RingData({
    required this.label,
    required this.progress,
    required this.color,
  });

  /// Category name shown in the legend.
  final String label;

  /// Value between 0 and 1 representing percentage used.
  final double progress;

  /// Fill color of this ring's arc.
  final Color color;
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// A multi-ring budget spending visual.
///
/// Each ring represents a spending category and shows how much of the
/// budget has been consumed. Rings animate in with an 80 ms stagger.
///
/// Usage:
/// ```dart
/// SpendingRing(
///   rings: [
///     RingData(label: 'Food', progress: 0.7, color: AppColors.categoryFood),
///     RingData(label: 'Transport', progress: 0.4, color: AppColors.categoryTransport),
///   ],
///   centerLabel: '₹3,200',
/// )
/// ```
class SpendingRing extends StatefulWidget {
  /// Creates a [SpendingRing].
  const SpendingRing({
    super.key,
    required this.rings,
    this.size = 220.0,
    this.centerLabel,
    this.ringStrokeWidth = 14.0,
    this.ringGap = 6.0,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.animationDuration = const Duration(milliseconds: 900),
  });

  /// Ring data list, outermost first.
  final List<RingData> rings;

  /// Outer diameter of the chart.
  final double size;

  /// Text shown in the center.
  final String? centerLabel;

  /// Stroke width for each ring.
  final double ringStrokeWidth;

  /// Gap between consecutive rings.
  final double ringGap;

  /// Stagger delay between ring animations.
  final Duration staggerDelay;

  /// Duration for each ring's fill animation.
  final Duration animationDuration;

  @override
  State<SpendingRing> createState() => _SpendingRingState();
}

class _SpendingRingState extends State<SpendingRing>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _sweepAnims;

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    _startStagger();
  }

  void _buildAnimations() {
    _controllers = List.generate(
      widget.rings.length,
      (i) => AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      ),
    );
    _sweepAnims = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOutCubic);
    }).toList();
  }

  Future<void> _startStagger() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.staggerDelay);
      if (mounted) _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: Listenable.merge(_controllers),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _SpendingRingPainter(
                    rings: widget.rings,
                    sweepValues: _sweepAnims.map((a) => a.value).toList(),
                    strokeWidth: widget.ringStrokeWidth,
                    ringGap: widget.ringGap,
                    centerLabel: widget.centerLabel,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Legend
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: widget.rings.map((r) {
              return _LegendChip(label: r.label, color: r.color);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Legend chip
// ─────────────────────────────────────────────

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────

class _SpendingRingPainter extends CustomPainter {
  _SpendingRingPainter({
    required this.rings,
    required this.sweepValues,
    required this.strokeWidth,
    required this.ringGap,
    this.centerLabel,
  });

  final List<RingData> rings;
  final List<double> sweepValues;
  final double strokeWidth;
  final double ringGap;
  final String? centerLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - strokeWidth / 2 - 4;
    const startAngle = -math.pi / 2;

    for (int i = 0; i < rings.length; i++) {
      final radius = maxRadius - i * (strokeWidth + ringGap);
      if (radius <= 0) break;

      final rect = Rect.fromCircle(center: center, radius: radius);
      final ring = rings[i];
      final sweep = 2 * math.pi * ring.progress * sweepValues[i];

      // Track (background arc)
      final trackPaint = Paint()
        ..color = ring.color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, trackPaint);

      if (sweep > 0.01) {
        // Glow
        final glowPaint = Paint()
          ..color = ring.color.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawArc(rect, startAngle, sweep, false, glowPaint);

        // Filled arc
        final fillPaint = Paint()
          ..color = ring.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(rect, startAngle, sweep, false, fillPaint);
      }
    }

    _drawCenter(canvas, center);
  }

  void _drawCenter(Canvas canvas, Offset center) {
    if (centerLabel == null) return;

    // Label
    final tp = TextPainter(
      text: TextSpan(
        text: centerLabel,
        style: AppTypography.title.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final subtitleTp = TextPainter(
      text: TextSpan(
        text: 'Total Spent',
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final totalH = tp.height + 4 + subtitleTp.height;
    tp.paint(canvas, center - Offset(tp.width / 2, totalH / 2));
    subtitleTp.paint(
      canvas,
      center -
          Offset(subtitleTp.width / 2, totalH / 2 - tp.height - 4),
    );
  }

  @override
  bool shouldRepaint(_SpendingRingPainter old) =>
      old.sweepValues != sweepValues || old.centerLabel != centerLabel;
}
