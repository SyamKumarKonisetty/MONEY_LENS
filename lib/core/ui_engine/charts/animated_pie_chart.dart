import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

/// Represents a single segment in [AnimatedPieChart].
class PieSegment {
  /// Creates a [PieSegment] with a [color], numeric [value], and display [label].
  const PieSegment({
    required this.color,
    required this.value,
    required this.label,
  });

  /// Fill color of this segment.
  final Color color;

  /// Numeric value used to compute the segment's angular size.
  final double value;

  /// Human-readable label displayed in the legend.
  final String label;
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// A fully custom animated pie chart that renders segments clockwise, one by
/// one, with a configurable stagger delay.
///
/// Usage:
/// ```dart
/// AnimatedPieChart(
///   segments: [
///     PieSegment(color: AppColors.categoryFood, value: 420, label: 'Food'),
///     PieSegment(color: AppColors.categoryTransport, value: 180, label: 'Transport'),
///   ],
///   centerLabel: '₹600',
///   onSegmentTap: (index) => debugPrint('tapped $index'),
/// )
/// ```
class AnimatedPieChart extends StatefulWidget {
  /// Creates an [AnimatedPieChart].
  const AnimatedPieChart({
    super.key,
    required this.segments,
    this.size = 220.0,
    this.centerLabel,
    this.onSegmentTap,
    this.strokeWidth = 52.0,
    this.segmentGap = 2.0,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.staggerDelay = const Duration(milliseconds: 120),
  });

  /// Segments to render. Must not be empty.
  final List<PieSegment> segments;

  /// Outer diameter of the chart.
  final double size;

  /// Text shown in the center hole (e.g. total amount).
  final String? centerLabel;

  /// Called with the tapped segment index.
  final ValueChanged<int>? onSegmentTap;

  /// Width of each donut ring stroke.
  final double strokeWidth;

  /// Gap in logical pixels between adjacent segments.
  final double segmentGap;

  /// Total animation duration (all segments combined).
  final Duration animationDuration;

  /// Additional delay per segment for the stagger effect.
  final Duration staggerDelay;

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _sweepAnims;
  int _tappedIndex = -1;

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    _startStagger();
  }

  void _buildAnimations() {
    final n = widget.segments.length;
    _controllers = List.generate(
      n,
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

  /// Computes the tap-hit-test for each segment.
  int _hitTestSegment(Offset localPos) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final outerR = widget.size / 2 - 4;
    final innerR = outerR - widget.strokeWidth;
    if (dist < innerR || dist > outerR) return -1;

    double angle = math.atan2(dy, dx) + math.pi / 2; // start from top
    if (angle < 0) angle += 2 * math.pi;

    final total = widget.segments.fold<double>(0, (s, e) => s + e.value);
    double cursor = 0;
    for (int i = 0; i < widget.segments.length; i++) {
      final sweep = (widget.segments[i].value / total) * 2 * math.pi;
      if (angle >= cursor && angle <= cursor + sweep) return i;
      cursor += sweep;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (details) {
          final idx = _hitTestSegment(details.localPosition);
          setState(() => _tappedIndex = idx);
          if (idx >= 0) widget.onSegmentTap?.call(idx);
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge(_controllers),
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _PieChartPainter(
                  segments: widget.segments,
                  sweepValues:
                      _sweepAnims.map((a) => a.value).toList(),
                  strokeWidth: widget.strokeWidth,
                  gap: widget.segmentGap,
                  centerLabel: widget.centerLabel,
                  tappedIndex: _tappedIndex,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.segments,
    required this.sweepValues,
    required this.strokeWidth,
    required this.gap,
    required this.tappedIndex,
    this.centerLabel,
  });

  final List<PieSegment> segments;
  final List<double> sweepValues;
  final double strokeWidth;
  final double gap;
  final String? centerLabel;
  final int tappedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: outerRadius);

    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total == 0) return;

    // Convert gap from pixels to radians
    final gapRad = gap / outerRadius;

    double startAngle = -math.pi / 2; // top

    for (int i = 0; i < segments.length; i++) {
      final fraction = segments[i].value / total;
      final fullSweep = fraction * 2 * math.pi - gapRad;
      final animatedSweep = fullSweep * sweepValues[i];

      if (animatedSweep <= 0) {
        startAngle += fullSweep + gapRad;
        continue;
      }

      final isTapped = tappedIndex == i;
      final paint = Paint()
        ..color = segments[i].color.withValues(alpha: isTapped ? 1.0 : 0.88)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isTapped ? strokeWidth + 6 : strokeWidth
        ..strokeCap = StrokeCap.round;

      // Glow effect for tapped segment
      if (isTapped) {
        final glowPaint = Paint()
          ..color = segments[i].color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 16
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawArc(rect, startAngle, animatedSweep, false, glowPaint);
      }

      canvas.drawArc(rect, startAngle, animatedSweep, false, paint);
      startAngle += fullSweep + gapRad;
    }

    _drawCenter(canvas, center);
  }

  void _drawCenter(Canvas canvas, Offset center) {
    if (centerLabel == null) return;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 52, bgPaint);

    // Label
    final tp = TextPainter(
      text: TextSpan(
        text: centerLabel,
        style: AppTypography.title.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      old.sweepValues != sweepValues ||
      old.tappedIndex != tappedIndex ||
      old.centerLabel != centerLabel;
}
