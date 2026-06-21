import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/design_system.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────

/// Represents a single bar in [AnimatedBarChart].
class BarData {
  /// Creates a [BarData].
  const BarData({
    required this.label,
    required this.value,
    this.color,
  });

  /// X-axis label displayed below the bar.
  final String label;

  /// Numeric value that determines bar height.
  final double value;

  /// Optional override color. Falls back to [AppColors.categoryPalette] cycling.
  final Color? color;
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// A custom animated bar chart that grows bars from the bottom on mount.
///
/// Each bar enters with a 60 ms stagger and uses a vertical gradient fill.
/// Y-axis labels are rendered on the left, X-axis labels below each bar.
///
/// Usage:
/// ```dart
/// AnimatedBarChart(
///   bars: [
///     BarData(label: 'Mon', value: 240),
///     BarData(label: 'Tue', value: 380),
///   ],
///   height: 220,
///   onBarTap: (i) => debugPrint('Bar $i tapped'),
/// )
/// ```
class AnimatedBarChart extends StatefulWidget {
  /// Creates an [AnimatedBarChart].
  const AnimatedBarChart({
    super.key,
    required this.bars,
    this.height = 220.0,
    this.onBarTap,
    this.barRadius = 8.0,
    this.barSpacing = 12.0,
    this.yAxisDivisions = 4,
    this.animationDuration = const Duration(milliseconds: 700),
    this.staggerDelay = const Duration(milliseconds: 60),
  });

  /// Bars to render. Must not be empty.
  final List<BarData> bars;

  /// Height of the chart area (excluding labels).
  final double height;

  /// Called with the tapped bar index.
  final ValueChanged<int>? onBarTap;

  /// Corner radius for the top of each bar.
  final double barRadius;

  /// Horizontal spacing between bars.
  final double barSpacing;

  /// Number of horizontal grid lines.
  final int yAxisDivisions;

  /// Duration for each bar's grow animation.
  final Duration animationDuration;

  /// Stagger delay between consecutive bar animations.
  final Duration staggerDelay;

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _growAnims;
  int _tappedIndex = -1;

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    _startStagger();
  }

  void _buildAnimations() {
    final n = widget.bars.length;
    _controllers = List.generate(
      n,
      (i) => AnimationController(
        vsync: this,
        duration: widget.animationDuration,
      ),
    );
    _growAnims = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOutBack);
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
      child: GestureDetector(
        onTapDown: (details) {
          // Forward localPosition to the painter for hit-testing via layout
          _handleTap(details.localPosition);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge(_controllers),
          builder: (_, child) {
            return CustomPaint(
              size: Size(double.infinity, widget.height + 48),
              painter: _BarChartPainter(
                bars: widget.bars,
                growValues: _growAnims.map((a) => a.value).toList(),
                barRadius: widget.barRadius,
                barSpacing: widget.barSpacing,
                yAxisDivisions: widget.yAxisDivisions,
                chartHeight: widget.height,
                tappedIndex: _tappedIndex,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleTap(Offset local) {
    final n = widget.bars.length;
    if (n == 0) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final width = renderBox.size.width;
    final drawWidth = width - 40.0; // _yAxisWidth = 40.0
    final barWidth = (drawWidth - (widget.barSpacing * (n - 1))) / n;

    final x = local.dx - 40.0;
    if (x < 0 || x > drawWidth) return;

    final tappedIdx = (x / (barWidth + widget.barSpacing)).floor();
    if (tappedIdx >= 0 && tappedIdx < n) {
      setState(() {
        _tappedIndex = tappedIdx;
      });
      if (widget.onBarTap != null) {
        widget.onBarTap!(tappedIdx);
      }
    }
  }
}

// ─────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.bars,
    required this.growValues,
    required this.barRadius,
    required this.barSpacing,
    required this.yAxisDivisions,
    required this.chartHeight,
    required this.tappedIndex,
  });

  final List<BarData> bars;
  final List<double> growValues;
  final double barRadius;
  final double barSpacing;
  final int yAxisDivisions;
  final double chartHeight;
  final int tappedIndex;

  static const double _yAxisWidth = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    final drawWidth = size.width - _yAxisWidth;
    final drawHeight = chartHeight;
    final baseY = drawHeight;

    final maxVal = bars.map((b) => b.value).reduce(math.max);
    if (maxVal == 0) return;

    // ── Y-axis grid + labels ──────────────────
    _drawGrid(canvas, size, drawWidth, drawHeight, maxVal);

    // ── Bars ──────────────────────────────────
    final totalSpacing = barSpacing * (bars.length + 1);
    final barWidth = (drawWidth - totalSpacing) / bars.length;

    for (int i = 0; i < bars.length; i++) {
      final x = _yAxisWidth + barSpacing + i * (barWidth + barSpacing);
      final normalizedH = (bars[i].value / maxVal) * drawHeight;
      final animH = normalizedH * growValues[i].clamp(0.0, 1.0);

      final color = bars[i].color ??
          AppColors.categoryPalette[i % AppColors.categoryPalette.length];
      final isTapped = tappedIndex == i;

      // Glow when tapped
      if (isTapped) {
        final glowRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x - 3, baseY - animH - 3, barWidth + 6, animH + 6),
          topLeft: Radius.circular(barRadius + 2),
          topRight: Radius.circular(barRadius + 2),
        );
        canvas.drawRRect(
          glowRect,
          Paint()
            ..color = color.withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }

      // Gradient fill
      final barRect = Rect.fromLTWH(x, baseY - animH, barWidth, animH);
      final rrect = RRect.fromRectAndCorners(
        barRect,
        topLeft: Radius.circular(barRadius),
        topRight: Radius.circular(barRadius),
      );

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color.withValues(alpha: 0.5),
        ],
      );

      final barPaint = Paint()
        ..shader = gradient.createShader(barRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rrect, barPaint);

      // Shine highlight on top edge
      final shinePaint = Paint()
        ..color = Colors.white.withValues(alpha: isTapped ? 0.25 : 0.12)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, baseY - animH, barWidth, 4),
          topLeft: Radius.circular(barRadius),
          topRight: Radius.circular(barRadius),
        ),
        shinePaint,
      );

      // X-label
      _drawText(
        canvas,
        bars[i].label,
        Offset(x + barWidth / 2, baseY + 8),
        AppTypography.caption.copyWith(color: AppColors.textSecondary),
        maxWidth: barWidth + barSpacing,
      );
    }
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double drawWidth,
    double drawHeight,
    double maxVal,
  ) {
    final gridPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= yAxisDivisions; i++) {
      final y = drawHeight - (drawHeight / yAxisDivisions) * i;

      canvas.drawLine(
        Offset(_yAxisWidth, y),
        Offset(_yAxisWidth + drawWidth, y),
        gridPaint,
      );

      final labelVal = (maxVal / yAxisDivisions) * i;
      _drawText(
        canvas,
        _formatVal(labelVal),
        Offset(_yAxisWidth - 4, y),
        AppTypography.caption.copyWith(color: AppColors.textSecondary),
        textAlign: TextAlign.right,
        maxWidth: _yAxisWidth - 4,
      );
    }
  }

  String _formatVal(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toInt().toString();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    double maxWidth = 80,
    TextAlign textAlign = TextAlign.center,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, position - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.growValues != growValues || old.tappedIndex != tappedIndex;
}
