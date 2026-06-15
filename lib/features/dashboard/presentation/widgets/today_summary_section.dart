import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/dashboard_provider.dart';

class TodaySummarySection extends ConsumerWidget {
  const TodaySummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spentToday = ref.watch(spentTodayProvider);
    final txCountToday = ref.watch(transactionsCountTodayProvider);
    final topCategoryToday = ref.watch(topCategoryTodayProvider);
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Text(
            'Today',
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Row(
            children: [
              Expanded(
                child: _TodayStatCard(
                  label: 'Spent Today',
                  value: CurrencyFormatter.compact(spentToday),
                  icon: Icons.today_rounded,
                  color: context.errorColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _TodayStatCard(
                  label: 'Txs Today',
                  value: '$txCountToday',
                  icon: Icons.tag_rounded,
                  color: context.successColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _TodayStatCard(
                  label: 'Top Category',
                  value: topCategoryToday,
                  icon: Icons.stars_rounded,
                  color: context.primaryColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayStatCard extends StatelessWidget {
  const _TodayStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color.withValues(alpha: 0.8), size: 18),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
