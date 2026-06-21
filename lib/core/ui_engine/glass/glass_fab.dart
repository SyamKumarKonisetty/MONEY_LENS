import 'package:flutter/material.dart';
import '../../design/colors/app_colors.dart';
import '../motion/press_scale.dart';
import 'glass_surface.dart';

class GlassFAB extends StatelessWidget {
  const GlassFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Widget? label;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isExtended = label != null;
    final bgColor = backgroundColor ?? AppColors.sapphireBlue;

    return PressScale(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(28),
          opacity: 0.15,
          blur: 24.0,
          gradientTint: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor.withValues(alpha: 0.8),
              bgColor.withValues(alpha: 0.4),
            ],
          ),
          borderColor: Colors.white.withValues(alpha: 0.2),
          showBorder: true,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isExtended ? 20.0 : 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor ?? AppColors.textPrimary,
                  size: 24,
                ),
                if (isExtended) ...[
                  const SizedBox(width: 8),
                  label!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
