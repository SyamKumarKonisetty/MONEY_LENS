import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

/// A card for displaying user notification list items.
class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeLabel;
  final IconData icon;
  final bool isRead;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.icon,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.small,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isRead ? AppColors.card.withValues(alpha: 0.5) : AppColors.card,
            borderRadius: AppRadius.small,
            border: Border.all(
              color: isRead ? AppColors.divider.withValues(alpha: 0.5) : AppColors.divider,
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isRead ? AppColors.textSecondary : AppColors.primary)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isRead ? AppColors.textSecondary : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.body.copyWith(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          timeLabel,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
