import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../providers/analytics_cockpit_provider.dart';

/// Gamified finance achievements grid screen block.
class AchievementsGrid extends StatelessWidget {
  const AchievementsGrid({
    super.key,
    required this.achievements,
  });

  final List<AchievementItem> achievements;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINANCIAL MILESTONES & ACHIEVEMENTS',
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondaryColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final item = achievements[index];
              return _AchievementTile(item: item);
            },
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.item});
  final AchievementItem item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isInteractive: item.isUnlocked,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Opacity(
        opacity: item.isUnlocked ? 1.0 : 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: item.isUnlocked
                        ? context.primaryColor.withValues(alpha: 0.15)
                        : context.separatorColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isUnlocked ? context.primaryColor : context.textSecondaryColor,
                    size: 18,
                  ),
                ),
                if (!item.isUnlocked)
                  Icon(
                    Icons.lock_rounded,
                    color: context.textSecondaryColor.withValues(alpha: 0.6),
                    size: 14,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondaryColor,
                fontSize: 10,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
