import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../foundations/colors.dart';
import '../../foundations/typography.dart';
import '../../foundations/radius.dart';
import '../../foundations/spacing.dart';
import '../metrics/metrics.dart';
import '../comparison/comparison.dart';
import '../forecast/forecast.dart';
import '../insights/insights.dart';
import '../stories/stories.dart';
import '../../components/primitives.dart';
import 'package:money_lens/core/design/design_system.dart';


/// Data representation model for coordinate points.
class MLDataPoint {
  const MLDataPoint(this.x, this.y);
  final double x;
  final double y;
}

/// Aggregates and downsamples up to 100k data points into targetSize points.
/// This prevents rendering performance bottlenecks and frame drops.
class MLDataDownsampler {
  MLDataDownsampler._();

  static List<MLDataPoint> downsample(List<MLDataPoint> data, int targetSize) {
    if (data.length <= targetSize || targetSize <= 2) {
      return data;
    }

    final List<MLDataPoint> sampled = [];
    sampled.add(data.first);

    final double bucketSize = (data.length - 2) / (targetSize - 2);

    for (int i = 0; i < targetSize - 2; i++) {
      final int start = ((i * bucketSize) + 1).floor();
      final int end = (((i + 1) * bucketSize) + 1).floor().clamp(
        0,
        data.length,
      );

      if (start >= end) {
        if (start < data.length) {
          sampled.add(data[start]);
        }
        continue;
      }

      double sumX = 0;
      double sumY = 0;
      for (int j = start; j < end; j++) {
        sumX += data[j].x;
        sumY += data[j].y;
      }
      sampled.add(MLDataPoint(sumX / (end - start), sumY / (end - start)));
    }

    sampled.add(data.last);
    return sampled;
  }
}

// -------------------------------------------------------------
// 1. MLLineChart
// -------------------------------------------------------------
class MLLineChart extends StatelessWidget {
  const MLLineChart({
    required this.data,
    super.key,
    this.lineColor,
    this.strokeWidth = 2.0,
    this.downsampleLimit = 50,
  });

  final List<MLDataPoint> data;
  final Color? lineColor;
  final double strokeWidth;
  final int downsampleLimit;

  @override
  Widget build(BuildContext context) {
    final processedData = MLDataDownsampler.downsample(data, downsampleLimit);
    final color = lineColor ?? MLColors.primary(context);

    return AspectRatio(
      aspectRatio: 1.7,
      child: CustomPaint(
        painter: _LineChartPainter(
          data: processedData,
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });
  final List<MLDataPoint> data;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double minX = data.map((p) => p.x).reduce(math.min);
    final double maxX = data.map((p) => p.x).reduce(math.max);
    final double minY = data.map((p) => p.y).reduce(math.min);
    final double maxY = data.map((p) => p.y).reduce(math.max);

    final double rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;
    final double rangeY = maxY - minY == 0 ? 1.0 : maxY - minY;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = size.width * (data[i].x - minX) / rangeX;
      final double y = size.height * (1.0 - (data[i].y - minY) / rangeY);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

// -------------------------------------------------------------
// 2. MLAreaChart
// -------------------------------------------------------------
class MLAreaChart extends StatelessWidget {
  const MLAreaChart({
    required this.data,
    super.key,
    this.areaColor,
    this.downsampleLimit = 50,
  });

  final List<MLDataPoint> data;
  final Color? areaColor;
  final int downsampleLimit;

  @override
  Widget build(BuildContext context) {
    final processedData = MLDataDownsampler.downsample(data, downsampleLimit);
    final baseColor = areaColor ?? MLColors.primary(context);

    return AspectRatio(
      aspectRatio: 1.7,
      child: CustomPaint(
        painter: _AreaChartPainter(data: processedData, color: baseColor),
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({required this.data, required this.color});
  final List<MLDataPoint> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double minX = data.map((p) => p.x).reduce(math.min);
    final double maxX = data.map((p) => p.x).reduce(math.max);
    final double minY = data.map((p) => p.y).reduce(math.min);
    final double maxY = data.map((p) => p.y).reduce(math.max);

    final double rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;
    final double rangeY = maxY - minY == 0 ? 1.0 : maxY - minY;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final double x = size.width * (data[i].x - minX) / rangeX;
      final double y = size.height * (1.0 - (data[i].y - minY) / rangeY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == data.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

// -------------------------------------------------------------
// 3. MLBarChart
// -------------------------------------------------------------
class MLBarChart extends StatelessWidget {
  const MLBarChart({
    required this.values,
    super.key,
    this.barColor,
    this.spacing = 8.0,
  });

  final List<double> values;
  final Color? barColor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final maxVal = values.isEmpty ? 1.0 : values.reduce(math.max);
    final color = barColor ?? MLColors.primary(context);

    return AspectRatio(
      aspectRatio: 1.7,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((val) {
          final heightRatio = maxVal == 0
              ? 0.0
              : (val / maxVal).clamp(0.05, 1.0);
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: constraints.maxHeight * heightRatio,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(MLRadius.small),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// -------------------------------------------------------------
// 4. MLStackedBarChart
// -------------------------------------------------------------
class MLStackedBarChart extends StatelessWidget {
  const MLStackedBarChart({required this.groups, super.key, this.colors});

  final List<List<double>> groups;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      MLColors.primary(context),
      MLColors.secondary(context),
      MLColors.warning(context),
    ];

    double maxGroupSum = 0;
    for (final group in groups) {
      final sum = group.fold(0.0, (a, b) => a + b);
      if (sum > maxGroupSum) maxGroupSum = sum;
    }
    if (maxGroupSum == 0) maxGroupSum = 1.0;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: groups.map((group) {
          final groupSum = group.fold(0.0, (a, b) => a + b);
          final heightRatio = (groupSum / maxGroupSum).clamp(0.05, 1.0);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalHeight = constraints.maxHeight * heightRatio;
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(MLRadius.small),
                      ),
                      child: SizedBox(
                        height: totalHeight,
                        child: Column(
                          verticalDirection: VerticalDirection.up,
                          children: List.generate(group.length, (idx) {
                            final double val = group[idx];
                            final double itemHeight = groupSum == 0
                                ? 0.0
                                : totalHeight * (val / groupSum);
                            final itemColor =
                                (colors != null && idx < colors!.length)
                                ? colors![idx]
                                : defaultColors[idx % defaultColors.length];
                            return Container(
                              height: itemHeight,
                              color: itemColor,
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// -------------------------------------------------------------
// 5. MLDonutChart
// -------------------------------------------------------------
class MLDonutChart extends StatelessWidget {
  const MLDonutChart({
    required this.shares,
    super.key,
    this.colors,
    this.thickness = 14.0,
  });

  final List<double> shares;
  final List<Color>? colors;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      MLColors.primary(context),
      MLColors.secondary(context),
      MLColors.warning(context),
      MLColors.error(context),
      MLColors.success(context),
    ];
    final resolvedColors = colors ?? defaultColors;

    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: CustomPaint(
          painter: _PieOrDonutPainter(
            shares: shares,
            colors: resolvedColors,
            isDonut: true,
            thickness: thickness,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 6. MLPieChart
// -------------------------------------------------------------
class MLPieChart extends StatelessWidget {
  const MLPieChart({required this.shares, super.key, this.colors});

  final List<double> shares;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      MLColors.primary(context),
      MLColors.secondary(context),
      MLColors.warning(context),
      MLColors.error(context),
      MLColors.success(context),
    ];
    final resolvedColors = colors ?? defaultColors;

    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: CustomPaint(
          painter: _PieOrDonutPainter(
            shares: shares,
            colors: resolvedColors,
            isDonut: false,
          ),
        ),
      ),
    );
  }
}

class _PieOrDonutPainter extends CustomPainter {
  _PieOrDonutPainter({
    required this.shares,
    required this.colors,
    required this.isDonut,
    this.thickness = 12.0,
  });

  final List<double> shares;
  final List<Color> colors;
  final bool isDonut;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final sum = shares.fold(0.0, (a, b) => a + b);
    if (sum == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -math.pi / 2;

    for (int i = 0; i < shares.length; i++) {
      final double sweepAngle = 2 * math.pi * (shares[i] / sum);
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = isDonut ? PaintingStyle.stroke : PaintingStyle.fill;

      if (isDonut) {
        paint.strokeWidth = thickness;
        final insetRect = rect.deflate(thickness / 2);
        canvas.drawArc(insetRect, startAngle, sweepAngle, false, paint);
      } else {
        canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieOrDonutPainter oldDelegate) =>
      oldDelegate.shares != shares ||
      oldDelegate.colors != colors ||
      oldDelegate.isDonut != isDonut;
}

// -------------------------------------------------------------
// 7. MLHeatMap
// -------------------------------------------------------------
class MLHeatMap extends StatelessWidget {
  const MLHeatMap({required this.matrix, super.key, this.baseColor});

  final List<List<double>> matrix;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final color = baseColor ?? MLColors.primary(context);

    return Column(
      children: matrix.map((row) {
        return Row(
          children: row.map((cell) {
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: cell.clamp(0.0, 1.0)),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// -------------------------------------------------------------
// 8. MLCalendarHeatMap
// -------------------------------------------------------------
class MLCalendarHeatMap extends StatelessWidget {
  const MLCalendarHeatMap({required this.days, super.key, this.baseColor});

  final List<double> days;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final color = baseColor ?? MLColors.primary(context);
    final columnsCount = (days.length / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnsCount,
        crossAxisSpacing: 3.0,
        mainAxisSpacing: 3.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final val = days[index].clamp(0.0, 1.0);
        return Container(
          decoration: BoxDecoration(
            color: val == 0
                ? AppColors.textMuted.withValues(alpha: 0.1)
                : color.withValues(alpha: val),
            borderRadius: BorderRadius.circular(2.0),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// 9. MLBudgetRing
// -------------------------------------------------------------
class MLBudgetRing extends StatelessWidget {
  const MLBudgetRing({required this.spent, required this.limit, super.key});

  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final double pct = limit > 0 ? (spent / limit) : 0.0;
    final Color color = MLColors.budgetScaleColor(context, pct);

    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            MLCircularProgress(
              size: 100.0,
              color: color,
            ),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: MLTypography.headingMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 10. MLGoalRing
// -------------------------------------------------------------
class MLGoalRing extends StatelessWidget {
  const MLGoalRing({required this.saved, required this.goal, super.key});

  final double saved;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final Color color = MLColors.success(context);

    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            MLCircularProgress(
              size: 100.0,
              color: color,
            ),
            Icon(Icons.stars_rounded, color: color, size: 28.0),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 11. MLTimelineChart
// -------------------------------------------------------------
class MLTimelineChart extends StatelessWidget {
  const MLTimelineChart({required this.events, super.key});

  final List<Map<String, dynamic>> events;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final ev = events[index];
        final isLast = index == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: MLColors.primary(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.0,
                        color: MLColors.primary(context).withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: MLSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: MLSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ev['label'] ?? '',
                        style: MLTypography.titleSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ev['timestamp'] ?? '',
                        style: MLTypography.caption.copyWith(
                          color: MLColors.secondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                ev['value'] ?? '',
                style: MLTypography.moneySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// 12. MLCashFlowChart
// -------------------------------------------------------------
class MLCashFlowChart extends StatelessWidget {
  const MLCashFlowChart({
    required this.income,
    required this.expenses,
    super.key,
  });

  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    final maxVal = math.max(income, expenses);
    final ratioIncome = maxVal == 0 ? 0.0 : income / maxVal;
    final ratioExpenses = maxVal == 0 ? 0.0 : expenses / maxVal;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '₹${income.toStringAsFixed(0)}',
                style: MLTypography.chartValue.copyWith(
                  color: MLColors.income(context),
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                width: 40.0,
                height: 120.0 * ratioIncome,
                decoration: BoxDecoration(
                  color: MLColors.income(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(MLRadius.small),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Income',
                style: MLTypography.caption.copyWith(
                  color: MLColors.secondary(context),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '₹${expenses.toStringAsFixed(0)}',
                style: MLTypography.chartValue.copyWith(
                  color: MLColors.expense(context),
                ),
              ),
              const SizedBox(height: 4.0),
              Container(
                width: 40.0,
                height: 120.0 * ratioExpenses,
                decoration: BoxDecoration(
                  color: MLColors.expense(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(MLRadius.small),
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Expenses',
                style: MLTypography.caption.copyWith(
                  color: MLColors.secondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 13. MLForecastChart
// -------------------------------------------------------------
class MLForecastChart extends StatelessWidget {
  const MLForecastChart({
    required this.forecast,
    required this.historicalPoints,
    super.key,
  });

  final MLForecast forecast;
  final List<MLDataPoint> historicalPoints;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: CustomPaint(
        painter: _ForecastChartPainter(
          historicalPoints: historicalPoints,
          forecast: forecast,
          primaryColor: MLColors.primary(context),
          forecastColor: MLColors.warning(context),
        ),
      ),
    );
  }
}

class _ForecastChartPainter extends CustomPainter {
  _ForecastChartPainter({
    required this.historicalPoints,
    required this.forecast,
    required this.primaryColor,
    required this.forecastColor,
  });

  final List<MLDataPoint> historicalPoints;
  final MLForecast forecast;
  final Color primaryColor;
  final Color forecastColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (historicalPoints.isEmpty) return;

    final double maxX = historicalPoints.last.x + forecast.daysRemaining;
    final double minX = historicalPoints.first.x;
    final double maxY =
        math.max(forecast.projectedSpend, forecast.budgetLimit) * 1.1;

    final rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;
    final rangeY = maxY == 0 ? 1.0 : maxY;

    final budgetPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double budgetY =
        size.height * (1.0 - (forecast.budgetLimit / rangeY));
    canvas.drawLine(
      Offset(0, budgetY),
      Offset(size.width, budgetY),
      budgetPaint,
    );

    final histPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < historicalPoints.length; i++) {
      final double x = size.width * (historicalPoints[i].x - minX) / rangeX;
      final double y = size.height * (1.0 - (historicalPoints[i].y / rangeY));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, histPaint);

    final double lastX = size.width * (historicalPoints.last.x - minX) / rangeX;
    final double lastY =
        size.height * (1.0 - (historicalPoints.last.y / rangeY));
    final double forecastEndX = size.width;
    final double forecastEndY =
        size.height * (1.0 - (forecast.projectedSpend / rangeY));

    final dashPaint = Paint()
      ..color = forecastColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const int dashCount = 8;
    for (int i = 0; i < dashCount; i++) {
      final t1 = i / dashCount;
      final t2 = (i + 0.5) / dashCount;
      final double x1 = lastX + (forecastEndX - lastX) * t1;
      final double y1 = lastY + (forecastEndY - lastY) * t1;
      final double x2 = lastX + (forecastEndX - lastX) * t2;
      final double y2 = lastY + (forecastEndY - lastY) * t2;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ForecastChartPainter oldDelegate) => true;
}

// -------------------------------------------------------------
// 14. MLComparisonChart
// -------------------------------------------------------------
class MLComparisonChart extends StatelessWidget {
  const MLComparisonChart({required this.metrics, super.key});

  final MLComparisonMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final double maxVal = math.max(
      metrics.currentPeriodTotal,
      metrics.previousPeriodTotal,
    );
    final ratioCurrent = maxVal == 0
        ? 0.0
        : metrics.currentPeriodTotal / maxVal;
    final ratioPrevious = maxVal == 0
        ? 0.0
        : metrics.previousPeriodTotal / maxVal;

    final activeColor = metrics.isPositiveChange
        ? MLColors.success(context)
        : MLColors.error(context);

    return Container(
      padding: const EdgeInsets.all(MLSpacing.cardPadding),
      decoration: BoxDecoration(
        color: MLColors.surfaceCard(context),
        borderRadius: MLRadius.largeBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metrics.toStoryString(),
            style: MLTypography.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: MLSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₹${metrics.previousPeriodTotal.toStringAsFixed(0)}',
                      style: MLTypography.moneySmall.copyWith(
                        color: MLColors.secondary(context),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      height: 80.0 * ratioPrevious,
                      decoration: BoxDecoration(
                        color: MLColors.secondary(context).withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(MLRadius.small),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Previous',
                      style: MLTypography.caption.copyWith(
                        color: MLColors.secondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: MLSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₹${metrics.currentPeriodTotal.toStringAsFixed(0)}',
                      style: MLTypography.moneySmall.copyWith(
                        color: activeColor,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      height: 80.0 * ratioCurrent,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(MLRadius.small),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Current',
                      style: MLTypography.caption.copyWith(color: activeColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 15. MLMerchantChart
// -------------------------------------------------------------
class MLMerchantChart extends StatelessWidget {
  const MLMerchantChart({required this.merchants, super.key});

  final List<Map<String, dynamic>> merchants;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        final merch = merchants[index];
        final name = merch['name'] as String? ?? '';
        final value = merch['value'] as String? ?? '';
        final percentage = (merch['percentage'] as num? ?? 0.0).toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: MLTypography.titleSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    value,
                    style: MLTypography.moneySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Stack(
                children: [
                  Container(
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage.clamp(0.0, 1.0),
                    child: Container(
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: MLColors.primary(context),
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// 16. MLCategoryChart
// -------------------------------------------------------------
class MLCategoryChart extends StatelessWidget {
  const MLCategoryChart({required this.categories, super.key});

  final List<Map<String, dynamic>> categories;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final name = cat['name'] as String? ?? '';
        final value = cat['value'] as String? ?? '';
        final percentage = (cat['percentage'] as num? ?? 0.0).toDouble();
        final color = cat['color'] as Color? ?? MLColors.primary(context);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  name,
                  style: MLTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}% ($value)',
                style: MLTypography.chartValue.copyWith(
                  color: MLColors.secondary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// 17. MLTrendChart
// -------------------------------------------------------------
class MLTrendChart extends StatelessWidget {
  const MLTrendChart({
    required this.trendType,
    required this.values,
    super.key,
  });

  final MLTrendType trendType;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final tr = MLTrendRegistry.resolve(trendType);
    final color = tr.resolveColor(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tr.icon, color: color, size: 18.0),
          const SizedBox(width: 6.0),
          Text(tr.label, style: MLTypography.badge.copyWith(color: color)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 18. MLInsightCard
// -------------------------------------------------------------
class MLInsightCard extends StatelessWidget {
  const MLInsightCard({required this.insight, super.key, this.onTap});

  final MLInsight insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color border = Colors.transparent;
    IconData icon = Icons.info_outline_rounded;
    Color iconColor = MLColors.secondary(context);

    switch (insight.severity) {
      case MLInsightSeverity.info:
        border = MLColors.secondary(context).withValues(alpha: 0.3);
        icon = Icons.info_outline_rounded;
        iconColor = MLColors.secondary(context);
        break;
      case MLInsightSeverity.success:
        border = MLColors.success(context).withValues(alpha: 0.3);
        icon = Icons.check_circle_outline_rounded;
        iconColor = MLColors.success(context);
        break;
      case MLInsightSeverity.warning:
        border = MLColors.warning(context).withValues(alpha: 0.3);
        icon = Icons.warning_amber_rounded;
        iconColor = MLColors.warning(context);
        break;
      case MLInsightSeverity.critical:
        border = MLColors.error(context).withValues(alpha: 0.3);
        icon = Icons.error_outline_rounded;
        iconColor = MLColors.error(context);
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: MLRadius.largeBorderRadius,
      child: Container(
        padding: const EdgeInsets.all(MLSpacing.cardPadding),
        decoration: BoxDecoration(
          color: MLColors.surfaceCard(context),
          borderRadius: MLRadius.largeBorderRadius,
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24.0),
            const SizedBox(width: MLSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: MLTypography.titleSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    insight.message,
                    style: MLTypography.bodySmall.copyWith(
                      color: MLColors.secondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 19. MLStoryCard
// -------------------------------------------------------------
class MLStoryCard extends StatelessWidget {
  const MLStoryCard({required this.story, super.key, this.onAction});

  final MLStory story;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final borderCol = story.isPositive
        ? MLColors.success(context).withValues(alpha: 0.3)
        : MLColors.warning(context).withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.all(MLSpacing.cardPadding),
      decoration: BoxDecoration(
        color: MLColors.surfaceCard(context),
        borderRadius: MLRadius.largeBorderRadius,
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                story.isPositive
                    ? Icons.sentiment_satisfied_alt_rounded
                    : Icons.sentiment_neutral_rounded,
                color: story.isPositive
                    ? MLColors.success(context)
                    : MLColors.warning(context),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  story.headline,
                  style: MLTypography.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            story.summary,
            style: MLTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            story.context,
            style: MLTypography.bodySmall.copyWith(
              color: MLColors.secondary(context),
            ),
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: MLRadius.mediumBorderRadius,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: MLColors.primary(context),
                  size: 16.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    story.recommendation,
                    style: MLTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                child: Text(
                  'Inspect Details',
                  style: MLTypography.button.copyWith(
                    color: MLColors.primary(context),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 20. MLMetricGrid
// -------------------------------------------------------------
class MLMetricGrid extends StatelessWidget {
  const MLMetricGrid({required this.metrics, super.key});

  final List<MLMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: MLSpacing.gridSpacing,
        mainAxisSpacing: MLSpacing.gridSpacing,
        childAspectRatio: 1.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];

        return Container(
          padding: const EdgeInsets.all(MLSpacing.cardPadding),
          decoration: BoxDecoration(
            color: MLColors.surfaceCard(context),
            borderRadius: MLRadius.largeBorderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      metric.label,
                      style: MLTypography.caption.copyWith(
                        color: MLColors.secondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (metric.icon != null)
                    Icon(
                      metric.icon,
                      size: 16.0,
                      color: MLColors.secondary(context),
                    ),
                ],
              ),
              Text(
                metric.formattedValue,
                style: MLTypography.moneyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
