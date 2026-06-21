import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

/// A premium grid action shortcut card with scale on tap support.
class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.small,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.card,
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.divider, width: 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
