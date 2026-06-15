import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models.dart';
import '../../../transactions/domain/models.dart';

/// Category breakdown donut chart using fl_chart.
class CategoryDonutChart extends StatefulWidget {
  const CategoryDonutChart({super.key, required this.breakdown});

  final List<CategorySpending> breakdown;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.breakdown.isEmpty) {
      return const SizedBox(height: 200);
    }

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
          Text(
            'By Category',
            style: AppTypography.titleLarge.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: _buildSections(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 64,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                  ),
                ),
                // Center label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: AppTypography.labelSmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.compact(
                        widget.breakdown.fold(0.0, (s, e) => s + e.amount),
                      ),
                      style: AppTypography.titleLarge.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.breakdown.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedIndex;
      final category = AppCategories.findById(item.categoryId);
      final radius = isTouched ? 56.0 : 48.0;

      return PieChartSectionData(
        value: item.amount,
        color: category.color,
        radius: radius,
        title: '${(item.percentage * 100).toStringAsFixed(0)}%',
        titleStyle: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: isTouched ? 13 : 11,
        ),
        titlePositionPercentageOffset: 0.65,
      );
    }).toList();
  }
}
