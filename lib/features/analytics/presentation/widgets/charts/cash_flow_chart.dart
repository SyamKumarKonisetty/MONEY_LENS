import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../transactions/domain/models.dart';

/// Interactive Cash Flow Area chart showing Income vs Expenses with drag scrubbing.
class CashFlowChart extends StatefulWidget {
  const CashFlowChart({
    super.key,
    required this.transactions,
    required this.dateRange,
  });

  final List<Transaction> transactions;
  final DateTimeRange dateRange;

  @override
  State<CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends State<CashFlowChart> {
  int _selectedIndex = -1; // -1 means not dragging

  @override
  Widget build(BuildContext context) {
    // 1. Calculate 7 points
    final start = widget.dateRange.start;
    final end = widget.dateRange.end;
    final totalDays = end.difference(start).inDays.clamp(1, 1000);
    final stepDays = (totalDays / 6.0);

    final incomePoints = List<double>.filled(7, 0.0);
    final expensePoints = List<double>.filled(7, 0.0);
    final labels = List<String>.filled(7, '');

    for (int i = 0; i < 7; i++) {
      final pStart = start.add(Duration(days: (i * stepDays).round()));
      final pEnd = start.add(Duration(days: ((i + 1) * stepDays).round()));
      labels[i] = '${pStart.day}/${pStart.month}';

      for (final t in widget.transactions) {
        if (t.date.isAfter(pStart.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(pEnd.add(const Duration(seconds: 1)))) {
          if (t.type == TransactionType.income) {
            incomePoints[i] += t.amount;
          } else {
            expensePoints[i] += t.amount;
          }
        }
      }
    }

    final maxVal = [
      ...incomePoints,
      ...expensePoints,
      5000.0 // Min ceiling
    ].reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CASH FLOW',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                // Legend
                Row(
                  children: [
                    _LegendDot(color: context.primaryColor, label: 'Income'),
                    const SizedBox(width: AppSpacing.md),
                    _LegendDot(color: Colors.redAccent, label: 'Expense'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Interactive Painter Area
            GestureDetector(
              onPanStart: (details) => _updateSelection(details.localPosition, context.mounted),
              onPanUpdate: (details) => _updateSelection(details.localPosition, context.mounted),
              onPanEnd: (_) => setState(() => _selectedIndex = -1),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _CashFlowPainter(
                    income: incomePoints,
                    expense: expensePoints,
                    maxVal: maxVal,
                    selectedIndex: _selectedIndex,
                    primaryColor: context.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Labels or scrubber tooltip
            _selectedIndex >= 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${labels[_selectedIndex]}',
                        style: AppTypography.labelMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                      Text(
                        'In: ${CurrencyFormatter.full(incomePoints[_selectedIndex])}  •  Out: ${CurrencyFormatter.full(expensePoints[_selectedIndex])}',
                        style: AppTypography.labelMedium.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: labels.map((l) {
                      return Text(
                        l,
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  void _updateSelection(Offset local, bool mounted) {
    if (!mounted) return;
    final width = context.size?.width ?? 300.0;
    final drawWidth = width - (AppSpacing.xl * 2) - 40.0;
    final double x = local.dx.clamp(0.0, drawWidth);
    final idx = ((x / drawWidth) * 6).round().clamp(0, 6);
    if (idx != _selectedIndex) {
      setState(() => _selectedIndex = idx);
    }
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _CashFlowPainter extends CustomPainter {
  final List<double> income;
  final List<double> expense;
  final double maxVal;
  final int selectedIndex;
  final Color primaryColor;

  _CashFlowPainter({
    required this.income,
    required this.expense,
    required this.maxVal,
    required this.selectedIndex,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (income.isEmpty) return;

    final double stepX = size.width / 6.0;

    final inPoints = <Offset>[];
    final exPoints = <Offset>[];

    for (int i = 0; i < 7; i++) {
      final x = i * stepX;
      final yIn = size.height - (income[i] / maxVal) * size.height;
      final yEx = size.height - (expense[i] / maxVal) * size.height;
      inPoints.add(Offset(x, yIn));
      exPoints.add(Offset(x, yEx));
    }

    _drawFlowLine(canvas, size, inPoints, primaryColor, true);
    _drawFlowLine(canvas, size, exPoints, Colors.redAccent, false);

    // Draw scrubbing vertical guide line
    if (selectedIndex >= 0 && selectedIndex < 7) {
      final double selectX = selectedIndex * stepX;
      final guidePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(selectX, 0), Offset(selectX, size.height), guidePaint);

      final dotPaint = Paint()..style = PaintingStyle.fill;

      dotPaint.color = primaryColor;
      canvas.drawCircle(inPoints[selectedIndex], 5.0, dotPaint);

      dotPaint.color = Colors.redAccent;
      canvas.drawCircle(exPoints[selectedIndex], 5.0, dotPaint);
    }
  }

  void _drawFlowLine(Canvas canvas, Size size, List<Offset> pts, Color color, bool fillUnder) {
    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2.0;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2.0;
      final controlY2 = p1.dy;
      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);

    if (fillUnder) {
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.15), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(_CashFlowPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.income != income ||
        oldDelegate.expense != expense;
  }
}
