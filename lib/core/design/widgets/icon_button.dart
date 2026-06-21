import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import 'animated_button.dart';

/// A premium circular/square icon button with soft background ink splashes.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider, width: 1.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textPrimary,
          size: size * 0.5,
        ),
      ),
    );
  }
}
