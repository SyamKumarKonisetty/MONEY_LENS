import 'package:flutter/material.dart';
import '../spacing/app_spacing.dart';
import 'skeleton_loader.dart';
import 'loading_card.dart';

/// A dashboard view shimmer placeholder to render while primary accounts are loading.
class LoadingDashboard extends StatelessWidget {
  const LoadingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Greeting Header Skeleton
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 140, height: 16),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonLoader(width: 200, height: 28),
                ],
              ),
              SkeletonLoader(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Balance Card Skeleton
          const LoadingCard(height: 160),
          const SizedBox(height: AppSpacing.xl),

          // Quick Actions Grid Skeleton
          Row(
            children: [
              Expanded(child: Container(height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Container(height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Container(height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)))),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Recent Activity Header
          const SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: AppSpacing.md),

          // List item blocks
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                const SkeletonLoader(width: 44, height: 44),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: 120, height: 14),
                      SizedBox(height: 4),
                      SkeletonLoader(width: 80, height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(width: 60, height: 14, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
