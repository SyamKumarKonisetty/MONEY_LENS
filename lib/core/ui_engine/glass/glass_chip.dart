import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import 'glass_surface.dart';

class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.sapphireBlue;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: AppRadius.pill,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.28),
                    blurRadius: 18,
                    spreadRadius: 0,
                  )
                ]
              : [],
        ),
        child: GlassSurface(
          borderRadius: AppRadius.pill,
          opacity: isSelected ? 0.34 : 0.18,
          blur: 14.0,
          borderColor: isSelected
              ? baseColor.withValues(alpha: 0.72)
              : AppColors.cyanHighlight.withValues(alpha: 0.14),
          gradientTint: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.midnightSapphire.withValues(alpha: 0.96),
                    baseColor.withValues(alpha: 0.42),
                    AppColors.cyanHighlight.withValues(alpha: 0.18),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface2.withValues(alpha: 0.90),
                    AppColors.surface3.withValues(alpha: 0.80),
                  ],
                ),
          showBorder: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? AppColors.cyanHighlight : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
