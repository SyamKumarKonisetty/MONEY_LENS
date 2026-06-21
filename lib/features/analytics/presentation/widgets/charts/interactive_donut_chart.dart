import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../transactions/domain/models.dart';
import '../../../domain/models.dart';
import '../../providers/analytics_cockpit_provider.dart';

/// Donut chart for category breakdown with segment tapping expansion and dynamic merchant metrics.
class InteractiveDonutChart extends ConsumerStatefulWidget {
  const InteractiveDonutChart({super.key});

  @override
  ConsumerState<InteractiveDonutChart> createState() => _InteractiveDonutChartState();
}

class _InteractiveDonutChartState extends ConsumerState<InteractiveDonutChart>
    with SingleTickerProviderStateMixin {
  int _tappedIndex = -1;
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(cockpitDataProvider);
    final breakdown = data.categorySpendingList;

    if (breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final int activeIdx = _tappedIndex >= 0 ? _tappedIndex : 0;
    final activeCat = breakdown[activeIdx];
    final catColor = AppCategories.findById(activeCat.categoryId).color;
    final catName = AppCategories.findById(activeCat.categoryId).name;

    final catTx = data.transactions
        .where((t) => t.type == TransactionType.expense && t.categoryId == activeCat.categoryId)
        .toList();
    final count = catTx.length;
    final avg = count > 0 ? activeCat.amount / count : 0.0;

    final merchants = <String, double>{};
    for (final t in catTx) {
      merchants[t.title] = (merchants[t.title] ?? 0.0) + t.amount;
    }
    final topMerchant = merchants.isEmpty
        ? 'None'
        : (merchants.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATEGORY BREAKDOWN',
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                // Donut Chart Segment
                SizedBox(
                  width: 120,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _DonutPainter(
                          breakdown: breakdown,
                          animValue: _animCtrl.value,
                          tappedIndex: activeIdx,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),

                // Metrics Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              catName.toUpperCase(),
                              style: AppTypography.labelMedium.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _MetricText(label: 'Total spent', value: CurrencyFormatter.full(activeCat.amount)),
                      _MetricText(label: 'Percentage', value: '${(activeCat.percentage * 100).toStringAsFixed(1)}%'),
                      _MetricText(label: 'Transactions', value: '$count tx'),
                      _MetricText(label: 'Average spent', value: CurrencyFormatter.full(avg)),
                      _MetricText(label: 'Top merchant', value: topMerchant),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            Center(
              child: Text(
                'Tap a category below to expand details',
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Interactive category chips
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: List.generate(breakdown.length, (i) {
                final item = breakdown[i];
                final cat = AppCategories.findById(item.categoryId);
                final isSelected = i == activeIdx;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _tappedIndex = i;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withValues(alpha: 0.2)
                          : context.surfaceColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? cat.color : context.separatorColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.name,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected ? context.textPrimaryColor : context.textSecondaryColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricText extends StatelessWidget {
  const _MetricText({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: context.textSecondaryColor),
          ),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<CategorySpending> breakdown;
  final double animValue;
  final int tappedIndex;

  _DonutPainter({
    required this.breakdown,
    required this.animValue,
    required this.tappedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final strokeWidth = 20.0;
    final innerRadius = outerRadius - strokeWidth;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < breakdown.length; i++) {
      final item = breakdown[i];
      final sweepAngle = item.percentage * 2 * math.pi * animValue;
      final color = AppCategories.findById(item.categoryId).color;

      final isTapped = i == tappedIndex;
      final double offsetRadius = isTapped ? 4.0 : 0.0;
      final midAngle = startAngle + sweepAngle / 2;
      final currentCenter = center + Offset(math.cos(midAngle) * offsetRadius, math.sin(midAngle) * offsetRadius);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: currentCenter, radius: (outerRadius + innerRadius) / 2),
        startAngle + 0.05,
        sweepAngle - 0.1,
        false,
        paint,
      );

      startAngle += item.percentage * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.tappedIndex != tappedIndex ||
        oldDelegate.breakdown != breakdown;
  }
}
