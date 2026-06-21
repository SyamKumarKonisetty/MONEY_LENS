import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../domain/models.dart';
import '../../../../design_system/components/buttons.dart';

/// Bottom sheet for editing an existing expense.
class EditExpenseBottomSheet extends ConsumerStatefulWidget {
  final ExpenseEntity expense;

  const EditExpenseBottomSheet({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseBottomSheet> createState() =>
      _EditExpenseBottomSheetState();
}

class _EditExpenseBottomSheetState
    extends ConsumerState<EditExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late String _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    _notesController = TextEditingController(text: widget.expense.notes ?? '');

    // Ensure category dropdown value matches a valid category name exactly
    final matches = AppCategories.all.where(
      (cat) => cat.name.toLowerCase() == widget.expense.category.toLowerCase(),
    );
    _selectedCategory = matches.isNotEmpty ? matches.first.name : 'Other';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && widget.expense.id != null) {
      setState(() => _isSaving = true);

      final String title;
      if (_titleController.text.trim().isEmpty) {
        title = widget.expense.transactionType == 'income'
            ? '$_selectedCategory Income'
            : '$_selectedCategory Expense';
      } else {
        title = _titleController.text.trim();
      }

      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final notes = _notesController.text.trim();

      ref
          .read(expenseNotifierProvider.notifier)
          .updateExpense(
            id: widget.expense.id!,
            title: title,
            amount: amount,
            category: _selectedCategory,
            notes: notes.isEmpty ? null : notes,
            transactionType: widget.expense.transactionType,
          );

      Navigator.of(context).pop();
    }
  }

  void _confirmDelete(BuildContext context) {
    // Capture navigator before the async gap.
    final navigator = Navigator.of(context);
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text(
          'Delete Expense',
          style: AppTypography.titleLarge.copyWith(
            color: context.textPrimaryColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.expense.title}"? This cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(
                color: context.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && widget.expense.id != null && mounted) {
        ref
            .read(expenseNotifierProvider.notifier)
            .deleteExpense(widget.expense.id!);
        navigator.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
        child: Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handlebar
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.separatorColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Scrollable form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      0,
                      AppSpacing.pagePadding,
                      bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          'Edit Expense',
                          style: AppTypography.headlineLarge.copyWith(
                            color: context.textPrimaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Title Field
                        TextFormField(
                          controller: _titleController,
                          style: AppTypography.bodyLarge.copyWith(
                            color: context.textPrimaryColor,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            filled: true,
                            fillColor: context.surfaceVariantColor,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.circularMd,
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.lg,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Title cannot be empty';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Amount Field
                        TextFormField(
                          controller: _amountController,
                          style: AppTypography.bodyLarge.copyWith(
                            color: context.textPrimaryColor,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Amount (₹)',
                            labelStyle: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            filled: true,
                            fillColor: context.surfaceVariantColor,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.circularMd,
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.lg,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Amount cannot be empty';
                            }
                            final num = double.tryParse(val.trim());
                            if (num == null) {
                              return 'Please enter a valid number';
                            }
                            if (num <= 0) {
                              return 'Amount must be greater than zero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          style: AppTypography.bodyLarge.copyWith(
                            color: context.textPrimaryColor,
                          ),
                          dropdownColor: context.surfaceColor,
                          borderRadius: AppRadius.card,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            filled: true,
                            fillColor: context.surfaceVariantColor,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.circularMd,
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.lg,
                            ),
                          ),
                          items: AppCategories.all.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.name,
                              child: Row(
                                children: [
                                  Icon(cat.icon, color: cat.color, size: 20),
                                  const SizedBox(width: AppSpacing.md),
                                  Text(cat.name),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Notes Field
                        TextFormField(
                          controller: _notesController,
                          style: AppTypography.bodyLarge.copyWith(
                            color: context.textPrimaryColor,
                          ),
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Notes (optional)',
                            labelStyle: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            filled: true,
                            fillColor: context.surfaceVariantColor,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.circularMd,
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.lg,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),

                // ─── Action Buttons (always visible, outside scroll) ───
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    0,
                    AppSpacing.pagePadding,
                    AppSpacing.xl + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.lg),

                      // Update button (full width)
                      MLButton.primary(
                        label: 'Update Expense',
                        onPressed: _submit,
                        isLoading: _isSaving,
                        isDisabled: _isSaving,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Delete & Cancel row
                      Row(
                        children: [
                          Expanded(
                            child: MLButton.secondary(
                              label: 'Delete',
                              icon: Icons.delete_outline_rounded,
                              onPressed: () => _confirmDelete(context),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: MLButton.text(
                              label: 'Cancel',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
