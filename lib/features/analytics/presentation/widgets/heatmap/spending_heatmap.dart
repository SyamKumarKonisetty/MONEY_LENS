import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import 'package:money_lens/core/design/design_system.dart';

/// GitHub-style spending heatmap contribution calendar grid.
class SpendingHeatmap extends StatefulWidget {
  const SpendingHeatmap({
    super.key,
    required this.heatmapData,
  });

  final Map<DateTime, double> heatmapData;

  @override
  State<SpendingHeatmap> createState() => _SpendingHeatmapState();
}

class _SpendingHeatmapState extends State<SpendingHeatmap> {
  DateTime? _selectedDate;
  double? _selectedValue;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // 12 weeks of data: 12 * 7 = 84 days
    final startDay = today.subtract(Duration(days: 83 - (today.weekday % 7)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPENDING HEATMAP',
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Heatmap Grid Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(12, (colIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Column(
                      children: List.generate(7, (rowIndex) {
                        final cellDate = startDay.add(Duration(days: colIndex * 7 + rowIndex));
                        final spent = widget.heatmapData[cellDate] ?? 0.0;
                        final color = _getCellColor(spent, context.primaryColor);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = cellDate;
                              _selectedValue = spent;
                            });
                          },
                          child: Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(bottom: 6.0),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                              border: _selectedDate == cellDate
                                  ? Border.all(color: AppColors.textPrimary, width: 1.2)
                                  : null,
                              boxShadow: spent > 3000
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        spreadRadius: 0.5,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tooltip or legend
            _selectedDate != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEE, MMM d').format(_selectedDate!),
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                      Text(
                        'Spent: ${CurrencyFormatter.full(_selectedValue ?? 0.0)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tap cells to view daily details',
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textSecondaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                      // Mini Legend
                      Row(
                        children: [
                          Text('Less  ', style: AppTypography.labelSmall.copyWith(color: context.textSecondaryColor)),
                          _legendBox(context.separatorColor.withValues(alpha: 0.1)),
                          const SizedBox(width: 3),
                          _legendBox(context.primaryColor.withValues(alpha: 0.25)),
                          const SizedBox(width: 3),
                          _legendBox(context.primaryColor.withValues(alpha: 0.55)),
                          const SizedBox(width: 3),
                          _legendBox(context.primaryColor.withValues(alpha: 0.85)),
                          const SizedBox(width: 3),
                          _legendBox(context.primaryColor),
                          Text('  More', style: AppTypography.labelSmall.copyWith(color: context.textSecondaryColor)),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Color _getCellColor(double spent, Color primary) {
    if (spent == 0.0) return Colors.white.withValues(alpha: 0.08);
    if (spent < 1000.0) return primary.withValues(alpha: 0.25);
    if (spent < 3000.0) return primary.withValues(alpha: 0.55);
    if (spent < 6000.0) return primary.withValues(alpha: 0.85);
    return primary;
  }
}
