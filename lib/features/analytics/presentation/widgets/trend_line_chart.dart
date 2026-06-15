import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/models.dart';

/// 6-month trend line chart using fl_chart.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key, required this.trends});

  final List<MonthlyTrend> trends;

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) return const SizedBox.shrink();

    final isDark = context.isDark;
    final primaryColor = context.primaryColor;
    final expenseColor = context.errorColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '6-Month Trend',
                style: AppTypography.titleLarge.copyWith(
                  color: context.textPrimaryColor,
                ),
              ),
              const Spacer(),
              // Legend
              _LegendDot(color: primaryColor, label: 'Income'),
              const SizedBox(width: AppSpacing.lg),
              _LegendDot(color: expenseColor, label: 'Spent'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 30000,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.separatorColor.withValues(alpha: 0.5),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trends.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            trends[index].label,
                            style: AppTypography.labelSmall.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Income line
                  _buildLine(
                    spots: trends
                        .map((t) => FlSpot(t.month.toDouble(), t.income))
                        .toList(),
                    color: primaryColor,
                    isDark: isDark,
                  ),
                  // Expense line
                  _buildLine(
                    spots: trends
                        .map((t) => FlSpot(t.month.toDouble(), t.expenses))
                        .toList(),
                    color: expenseColor,
                    isDark: isDark,
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '₹${(spot.y / 1000).toStringAsFixed(0)}K',
                          AppTypography.labelLarge.copyWith(
                            color: spot.bar.color,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine({
    required List<FlSpot> spots,
    required Color color,
    required bool isDark,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: isDark ? 0.2 : 0.1),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
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
