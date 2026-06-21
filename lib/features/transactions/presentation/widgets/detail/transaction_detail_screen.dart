library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design/design_system.dart';
import '../../../../../core/ui_engine/glass/glass_button.dart';
import '../../../../../core/ui_engine/glass/glass_surface.dart';
import '../../../domain/models.dart';
import '../animations/transaction_animations.dart';

/// Premium Transaction Detail Screen displaying full properties and actions.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cat = AppCategories.findById(transaction.categoryId);
    final dateStr = DateFormat.yMMMMd().format(transaction.date);
    final timeStr = DateFormat.jm().format(transaction.date);
    final isIncome = transaction.type.isIncome;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Transaction Details',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Hero Category Icon
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cat.color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    cat.icon,
                    color: cat.color,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Merchant/Title
              Center(
                child: Text(
                  transaction.title,
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Large Animated Amount
              Center(
                child: AnimatedAmountText(
                  amount: transaction.amount,
                  isIncome: isIncome,
                  style: AppTypography.displayLarge.copyWith(
                    letterSpacing: -1.0,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Detailed Properties Card
              GlassSurface(
                borderRadius: BorderRadius.circular(20),
                borderColor: AppColors.divider.withValues(alpha: 0.2),
                opacity: 0.05,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      _buildDetailRow('Date', dateStr),
                      _buildDetailRow('Time', timeStr),
                      _buildDetailRow('Category', cat.name),
                      _buildDetailRow('Type', isIncome ? 'Income' : 'Expense'),
                      _buildDetailRow(
                        'Source',
                        transaction.note?.contains('SMS') ?? false
                            ? 'Auto-parsed SMS'
                            : 'Manually logged',
                      ),
                      _buildDetailRow('Notes', transaction.note ?? 'None', isLast: true),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Edit',
                      icon: Icons.edit_rounded,
                      opacity: 0.08,
                      onTap: () {
                        Navigator.of(context).pop();
                        onEdit();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GlassButton(
                      label: 'Delete',
                      icon: Icons.delete_rounded,
                      foregroundColor: AppColors.expense,
                      opacity: 0.08,
                      onTap: () {
                        Navigator.of(context).pop();
                        onDelete();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.divider.withValues(alpha: 0.3), height: 1),
          ],
        ],
      ),
    );
  }
}
