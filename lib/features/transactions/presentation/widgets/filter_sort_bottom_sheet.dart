import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/models.dart';
import '../providers/transactions_provider.dart';
import '../../../../design_system/components/chips.dart';
import '../../../../design_system/components/buttons.dart';
import '../../../../core/ui_engine/ui_engine.dart';

class FilterSortBottomSheet extends ConsumerWidget {
  const FilterSortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSort = ref.watch(transactionSortProvider);
    final activeDate = ref.watch(transactionDateFilterProvider);
    final activeCategory = ref.watch(transactionCategoryFilterProvider);

    final allCategories = [...AppCategories.all, ...AppCategories.income];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: GlassSurface(
        borderRadius: AppRadius.bottomSheet,
        blur: 24,
        opacity: 0.0,
        showBorder: true,
        child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: AppTypography.titleLarge.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(transactionSortProvider.notifier).state =
                          TransactionSort.newest;
                      ref.read(transactionDateFilterProvider.notifier).state =
                          TransactionDateFilter.all;
                      ref
                              .read(transactionCategoryFilterProvider.notifier)
                              .state =
                          null;
                    },
                    child: Text(
                      'Reset All',
                      style: AppTypography.labelLarge.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.md),

              // Sort Section
              Text(
                'SORT BY',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _SortChip(
                    label: 'Newest First',
                    value: TransactionSort.newest,
                    activeValue: activeSort,
                  ),
                  _SortChip(
                    label: 'Oldest First',
                    value: TransactionSort.oldest,
                    activeValue: activeSort,
                  ),
                  _SortChip(
                    label: 'Amount: High to Low',
                    value: TransactionSort.amountHighToLow,
                    activeValue: activeSort,
                  ),
                  _SortChip(
                    label: 'Amount: Low to High',
                    value: TransactionSort.amountLowToHigh,
                    activeValue: activeSort,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date Filter Section
              Text(
                'DATE RANGE',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _DateChip(
                    label: 'All Time',
                    value: TransactionDateFilter.all,
                    activeValue: activeDate,
                  ),
                  _DateChip(
                    label: 'Today',
                    value: TransactionDateFilter.today,
                    activeValue: activeDate,
                  ),
                  _DateChip(
                    label: 'This Week',
                    value: TransactionDateFilter.week,
                    activeValue: activeDate,
                  ),
                  _DateChip(
                    label: 'This Month',
                    value: TransactionDateFilter.month,
                    activeValue: activeDate,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category Filter Section
              Text(
                'CATEGORY',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  MLChip.choice(
                    label: 'All Categories',
                    isSelected: activeCategory == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                                .read(
                                  transactionCategoryFilterProvider.notifier,
                                )
                                .state =
                            null;
                      }
                    },
                  ),
                  ...allCategories.map((cat) {
                    final isSelected =
                        activeCategory?.toLowerCase() == cat.id.toLowerCase();
                    return MLChip.choice(
                      icon: cat.icon,
                      label: cat.name,
                      isSelected: isSelected,
                      onSelected: (selected) {
                        ref
                            .read(transactionCategoryFilterProvider.notifier)
                            .state = selected
                            ? cat.id
                            : null;
                      },
                    );
                  }),
                ],
              ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Close / Apply Button
            MLButton.primary(
              label: 'Apply Filters',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}

class _SortChip extends ConsumerWidget {
  const _SortChip({
    required this.label,
    required this.value,
    required this.activeValue,
  });

  final String label;
  final TransactionSort value;
  final TransactionSort activeValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = activeValue == value;
    return MLChip.choice(
      label: label,
      isSelected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(transactionSortProvider.notifier).state = value;
        }
      },
    );
  }
}

class _DateChip extends ConsumerWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.activeValue,
  });

  final String label;
  final TransactionDateFilter value;
  final TransactionDateFilter activeValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = activeValue == value;
    return MLChip.choice(
      label: label,
      isSelected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(transactionDateFilterProvider.notifier).state = value;
        }
      },
    );
  }
}
