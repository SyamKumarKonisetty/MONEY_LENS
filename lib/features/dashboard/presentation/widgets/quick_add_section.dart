import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../transactions/domain/models.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/presentation/widgets/quick_add_bottom_sheet.dart';

/// Provider that returns the default 6 categories sorted by frequency of use.
final quickAddCategoriesProvider = Provider<List<Category>>((ref) {
  final recentlyUsed = ref.watch(recentlyUsedCategoriesProvider);
  
  // The default 6 categories requested
  final defaultIds = ['food', 'fuel', 'groceries', 'transport', 'entertainment', 'bills'];
  
  // Sort the defaultIds based on their index in recentlyUsed list.
  final sortedIds = List<String>.from(defaultIds);
  sortedIds.sort((a, b) {
    final indexA = recentlyUsed.indexWhere((c) => c.id == a);
    final indexB = recentlyUsed.indexWhere((c) => c.id == b);
    
    if (indexA != -1 && indexB != -1) {
      return indexA.compareTo(indexB);
    }
    if (indexA != -1) return -1;
    if (indexB != -1) return 1;
    return defaultIds.indexOf(a).compareTo(defaultIds.indexOf(b));
  });

  return sortedIds.map((id) => AppCategories.findById(id)).toList();
});

class QuickAddSection extends ConsumerWidget {
  const QuickAddSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(quickAddCategoriesProvider);
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Text(
            'Quick Add',
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  showQuickAddSheet(context, cat);
                },
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, color: cat.color, size: 24),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        cat.name,
                        style: AppTypography.labelLarge.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
