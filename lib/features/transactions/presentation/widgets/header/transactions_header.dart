library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design/design_system.dart';
import '../../providers/transactions_provider.dart';

/// Premium header for the Transactions Screen.
///
/// Features large typography, dynamic transaction count, and interactive actions.
class TransactionsHeader extends ConsumerWidget {
  const TransactionsHeader({
    super.key,
    required this.onFilterTap,
    required this.hasActiveFilters,
    required this.onSearchTap,
    required this.isSearchActive,
  });

  final VoidCallback onFilterTap;
  final bool hasActiveFilters;
  final VoidCallback onSearchTap;
  final bool isSearchActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(allTransactionsProvider).length;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.giant,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        bottom: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Title and count subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transactions',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$count Transaction${count == 1 ? "" : "s"}',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Search action
          _HeaderActionButton(
            icon: Icons.search_rounded,
            isActive: isSearchActive,
            onTap: onSearchTap,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Filter action
          _HeaderActionButton(
            icon: Icons.tune_rounded,
            isActive: hasActiveFilters,
            onTap: onFilterTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatefulWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  State<_HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<_HeaderActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        transform: Matrix4.diagonal3Values(_isPressed ? 0.92 : 1.0, _isPressed ? 0.92 : 1.0, 1.0),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.card.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Icon(
          widget.icon,
          color: widget.isActive ? AppColors.primary : AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
