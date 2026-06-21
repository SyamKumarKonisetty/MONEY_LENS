import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

/// A card designed specifically to wrap analytics and charts with standard padding and headings.
class AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final Widget? actionWidget;
  final Widget? footerWidget;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.chart,
    this.actionWidget,
    this.footerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.divider, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.title,
              ),
              ?actionWidget,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          chart,
          if (footerWidget != null) ...[
            const SizedBox(height: AppSpacing.md),
            footerWidget!,
          ],
        ],
      ),
    );
  }
}
