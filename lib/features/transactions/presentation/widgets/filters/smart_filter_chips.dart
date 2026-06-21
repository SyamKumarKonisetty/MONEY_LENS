library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/ui_engine.dart';
import '../../../domain/models.dart';
import '../../providers/transactions_provider.dart';

/// Premium glass chip bar featuring search type and category options.
class SmartFilterChips extends ConsumerWidget {
  const SmartFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(transactionFilterProvider);
    final activeCategory = ref.watch(transactionCategoryFilterProvider);

    final categories = [
      AppCategories.food,
      AppCategories.shopping,
      AppCategories.travel,
      AppCategories.bills,
      AppCategories.salary,
      AppCategories.freelance,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 1. Transaction Types (All, Income, Expense)
          ...TransactionFilter.values.map((filter) {
            final isSelected = activeFilter == filter && activeCategory == null;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GlassChip(
                label: _typeLabel(filter),
                isSelected: isSelected,
                color: AppColors.primary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(transactionFilterProvider.notifier).setFilter(filter);
                  ref.read(transactionCategoryFilterProvider.notifier).state = null;
                },
              ),
            );
          }),

          // Vertical Separator
          Container(
            height: 24,
            width: 1.2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: AppColors.divider.withValues(alpha: 0.5),
          ),

          // 2. Predefined high-frequency categories
          ...categories.map((cat) {
            final isSelected = activeCategory?.toLowerCase() == cat.id.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GlassChip(
                label: cat.name,
                icon: cat.icon,
                color: cat.color,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (isSelected) {
                    ref.read(transactionCategoryFilterProvider.notifier).state = null;
                  } else {
                    ref.read(transactionCategoryFilterProvider.notifier).state = cat.id;
                    final isIncCat = AppCategories.income.any((c) => c.id == cat.id);
                    ref.read(transactionFilterProvider.notifier).setFilter(
                      isIncCat ? TransactionFilter.income : TransactionFilter.expense,
                    );
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _typeLabel(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return 'All';
      case TransactionFilter.income:
        return 'Income';
      case TransactionFilter.expense:
        return 'Expenses';
    }
  }
}
