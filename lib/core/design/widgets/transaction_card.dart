import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

/// A premium list card layout displaying individual transaction logs.
class TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final String category;
  final IconData icon;
  final Color? categoryColor;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.icon,
    this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amtColor = isIncome ? AppColors.income : AppColors.expense;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.small,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.4),
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              // Icon container with background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (categoryColor ?? AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: AppRadius.small,
                ),
                child: Icon(
                  icon,
                  color: categoryColor ?? AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title and category/sub
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: categoryColor ?? AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: AppTypography.caption,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '•',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              const SizedBox(width: AppSpacing.sm),
              Text(
                amount,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: amtColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
