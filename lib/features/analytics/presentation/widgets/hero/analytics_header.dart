import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/motion/press_scale.dart';
import '../../providers/analytics_cockpit_provider.dart';
import 'package:money_lens/core/design/design_system.dart';

/// Premium Analytics Header with period switcher and custom date picker.
class AnalyticsHeader extends ConsumerWidget {
  const AnalyticsHeader({super.key});

  Future<void> _selectCustomRange(BuildContext context, WidgetRef ref) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: ref.read(cockpitCustomRangeProvider),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.primaryColor,
              onPrimary: AppColors.textPrimary,
              surface: context.surfaceColor,
              onSurface: context.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(cockpitCustomRangeProvider.notifier).state = picked;
      ref.read(cockpitPeriodProvider.notifier).state = CockpitPeriod.custom;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(cockpitPeriodProvider);
    final customRange = ref.watch(cockpitCustomRangeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.giant),
          Text(
            'Analytics',
            style: AppTypography.displayMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your financial story',
            style: AppTypography.bodyLarge.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Period Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: CockpitPeriod.values.map((p) {
                final isSelected = p == active;
                final label = _label(p, customRange);

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: PressScale(
                    onTap: () {
                      if (p == CockpitPeriod.custom) {
                        _selectCustomRange(context, ref);
                      } else {
                        ref.read(cockpitPeriodProvider.notifier).state = p;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.primaryColor
                            : context.surfaceColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? context.primaryColor
                              : context.separatorColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        label,
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : context.textSecondaryColor,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _label(CockpitPeriod p, DateTimeRange? customRange) {
    switch (p) {
      case CockpitPeriod.week:
        return 'Week';
      case CockpitPeriod.month:
        return 'Month';
      case CockpitPeriod.quarter:
        return 'Quarter';
      case CockpitPeriod.year:
        return 'Year';
      case CockpitPeriod.custom:
        if (customRange != null) {
          final startStr = '${customRange.start.day}/${customRange.start.month}';
          final endStr = '${customRange.end.day}/${customRange.end.month}';
          return '$startStr - $endStr';
        }
        return 'Custom...';
    }
  }
}
