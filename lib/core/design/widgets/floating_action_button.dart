import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../theme/app_shadows.dart';
import 'animated_button.dart';

/// A premium floating action button using system gradients and soft glow shadows.
class AppFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? iconColor;
  final Color? backgroundColor;

  const AppFloatingActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: AppShadows.primaryGlowList,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor ?? AppColors.textPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
