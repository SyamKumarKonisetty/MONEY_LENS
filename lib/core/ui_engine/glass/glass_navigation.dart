import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../../theme/app_typography.dart';
import '../motion/press_scale.dart';
import 'glass_surface.dart';

class GlassNavigation extends StatelessWidget {
  const GlassNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<GlassNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: BorderRadius.circular(40),
      opacity: 0.22,
      blur: 30.0,
      borderColor: AppColors.cyanHighlight.withValues(alpha: 0.14),
      gradientTint: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface2.withValues(alpha: 0.94),
          AppColors.surface3.withValues(alpha: 0.84),
        ],
      ),
      showBorder: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];

            return PressScale(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.24)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? AppColors.cyanHighlight : AppColors.textMuted,
                      size: 24,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class GlassNavigationItem {
  final IconData icon;
  final String label;

  const GlassNavigationItem({
    required this.icon,
    required this.label,
  });
}
