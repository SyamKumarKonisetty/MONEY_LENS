import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../providers/analytics_cockpit_provider.dart';

/// Horizontal scrolling milestone financial events timeline.
class SpendingTimeline extends StatelessWidget {
  const SpendingTimeline({
    super.key,
    required this.milestones,
  });

  final List<TimelineMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Text(
            'MILESTONES TIMELINE',
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: milestones.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: GlassCard(
                    isInteractive: false,
                    child: Center(
                      child: Text(
                        'No significant financial milestones in this period.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
                  child: Row(
                    children: List.generate(milestones.length, (index) {
                      final item = milestones[index];
                      final isLast = index == milestones.length - 1;

                      return Row(
                        children: [
                          _TimelineEventNode(item: item),
                          if (!isLast)
                            Container(
                              width: 32,
                              height: 2,
                              color: context.separatorColor.withValues(alpha: 0.15),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
        ),
      ],
    );
  }
}

class _TimelineEventNode extends StatelessWidget {
  const _TimelineEventNode({required this.item});
  final TimelineMilestone item;

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor(item.type);
    final dateStr = '${item.date.day}/${item.date.month}';

    return GlassCard(
      isInteractive: true,
      width: 170,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: color, size: 14),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateStr,
                style: AppTypography.labelSmall.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyFormatter.full(item.amount),
            style: AppTypography.labelSmall.copyWith(
              color: item.type == 'salary' ? Colors.greenAccent : context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'salary':
        return const Color(0xFF34C759); // Green
      case 'bill':
        return const Color(0xFFFF9500); // Orange
      case 'large_purchase':
        return const Color(0xFFFF3B30); // Red
      default:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
}
