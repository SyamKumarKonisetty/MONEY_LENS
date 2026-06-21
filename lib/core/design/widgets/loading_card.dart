import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import 'skeleton_loader.dart';

/// A card displaying shimmer skeleton loaders for cards loading states.
class LoadingCard extends StatelessWidget {
  final double height;

  const LoadingCard({
    super.key,
    this.height = 120.0,
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
          const SkeletonLoader(width: 120, height: 16),
          const SizedBox(height: AppSpacing.sm),
          SkeletonLoader(width: double.infinity, height: height - 60),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 80, height: 12),
              SkeletonLoader(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
