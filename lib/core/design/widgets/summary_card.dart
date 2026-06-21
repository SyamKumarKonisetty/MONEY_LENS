import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';

/// A general summary card wrapper with consistent border, background and padding.
class SummaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.divider, width: 1.0),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.medium,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
