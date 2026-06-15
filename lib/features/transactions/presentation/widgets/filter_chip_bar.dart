import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/transactions_provider.dart';

/// Filter chip bar for the transactions screen.
///
/// Shows All / Income / Expense filter chips.
class FilterChipBar extends ConsumerWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(transactionFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: TransactionFilter.values.map((filter) {
          final isSelected = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _FilterChip(
              label: _label(filter),
              isSelected: isSelected,
              onTap: () => ref
                  .read(transactionFilterProvider.notifier)
                  .setFilter(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(TransactionFilter filter) {
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final selectedBg = context.primaryColor.withValues(alpha: 0.12);
    final unselectedBg = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF2F2F7);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: AppRadius.circularFull,
          border: isSelected
              ? Border.all(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isSelected
                ? context.primaryColor
                : context.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
