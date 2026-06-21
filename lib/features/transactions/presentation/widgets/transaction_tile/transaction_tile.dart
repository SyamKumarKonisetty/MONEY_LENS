library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/glass/glass_bottom_sheet.dart';
import '../../../../../core/ui_engine/glass/glass_surface.dart';
import '../../../../expenses/presentation/providers/expense_provider.dart';
import '../../../domain/models.dart';
import '../animations/transaction_animations.dart';

/// Premium transaction tile with micro-interactions, category color accents,
/// and long-press action sheets (Edit, Delete, Duplicate, Copy, Share).
class TransactionTile extends ConsumerWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  void _showLongPressSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    final cat = AppCategories.findById(transaction.categoryId);
    final timeStr = DateFormat.jm().format(transaction.date);
    final dateStr = DateFormat.yMMMMd().format(transaction.date);

    GlassBottomSheet.show(
      context,
      title: transaction.title,
      heightFactor: 0.42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              '${cat.name} • $dateStr at $timeStr',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildOption(
            icon: Icons.edit_rounded,
            label: 'Edit Transaction',
            onTap: () {
              Navigator.of(context).pop();
              onEdit();
            },
          ),
          _buildOption(
            icon: Icons.copy_all_rounded,
            label: 'Duplicate',
            onTap: () async {
              Navigator.of(context).pop();
              await ref.read(expenseNotifierProvider.notifier).addExpense(
                    title: '${transaction.title} (Copy)',
                    amount: transaction.amount,
                    category: transaction.categoryId,
                    notes: transaction.note,
                    transactionType: transaction.type.isIncome ? 'income' : 'expense',
                  );
              if (context.mounted) {
                FloatingSnackBar.showSuccess(context, 'Transaction duplicated');
              }
            },
          ),
          _buildOption(
            icon: Icons.copy_rounded,
            label: 'Copy Amount',
            onTap: () {
              Navigator.of(context).pop();
              Clipboard.setData(ClipboardData(text: transaction.amount.toString()));
              FloatingSnackBar.showSuccess(context, 'Amount copied to clipboard');
            },
          ),
          _buildOption(
            icon: Icons.share_rounded,
            label: 'Share Details',
            onTap: () {
              Navigator.of(context).pop();
              final isInc = transaction.type.isIncome;
              SharePlus.instance.share(
                ShareParams(
                  text: '${transaction.title}: ${isInc ? "+" : "-"}₹${transaction.amount} '
                      '(${cat.name} on $dateStr)\nNotes: ${transaction.note ?? "None"}',
                ),
              );
            },
          ),
          _buildOption(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            isDestructive: true,
            onTap: () {
              Navigator.of(context).pop();
              onDelete();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? AppColors.expense : AppColors.textPrimary,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isDestructive ? AppColors.expense : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = AppCategories.findById(transaction.categoryId);
    final timeStr = DateFormat.jm().format(transaction.date);
    final isIncome = transaction.type.isIncome;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.xs,
      ),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(16),
        borderColor: AppColors.divider.withValues(alpha: 0.2),
        opacity: 0.04,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showLongPressSheet(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Category Icon with colored translucent background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat.icon,
                    color: cat.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Transaction Title, Category, and note
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cat.name} • $timeStr',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaction.note!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textHint,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount
                AnimatedAmountText(
                  amount: transaction.amount,
                  isIncome: isIncome,
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
