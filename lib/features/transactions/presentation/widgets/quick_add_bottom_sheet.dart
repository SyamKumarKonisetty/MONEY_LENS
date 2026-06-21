import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../domain/models.dart';
import '../../../../design_system/components/buttons.dart';

/// Shows the lightweight Quick Add sheet for a pre-selected category.
void showQuickAddSheet(BuildContext context, Category category) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: false,
    useRootNavigator: true,
    builder: (_) => QuickAddBottomSheet(category: category),
  );
}

class QuickAddBottomSheet extends ConsumerStatefulWidget {
  const QuickAddBottomSheet({super.key, required this.category});

  final Category category;

  @override
  ConsumerState<QuickAddBottomSheet> createState() =>
      _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> {
  String _amountInput = '0';
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _showDetails = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _amount {
    if (_amountInput.isEmpty || _amountInput == '0') return 0.0;
    return double.tryParse(_amountInput) ?? 0.0;
  }

  String get _amountDisplay {
    if (_amountInput.isEmpty || _amountInput == '0') return '0';
    if (_amountInput.contains('.')) {
      final parts = _amountInput.split('.');
      final whole = parts[0];
      final formattedWhole = _formatIndianRupees(whole);
      if (parts.length > 1) {
        return '$formattedWhole.${parts[1]}';
      } else {
        return '$formattedWhole.';
      }
    } else {
      return _formatIndianRupees(_amountInput);
    }
  }

  String _formatIndianRupees(String wholeNumberStr) {
    if (wholeNumberStr.isEmpty || wholeNumberStr == '0') return '0';
    final cleanStr = wholeNumberStr.replaceAll(',', '');
    if (cleanStr.length <= 3) return cleanStr;
    final last3 = cleanStr.substring(cleanStr.length - 3);
    final rest = cleanStr.substring(0, cleanStr.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    buffer.write(',');
    buffer.write(last3);
    return buffer.toString();
  }

  void _onDigit(String d) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput == '0') {
        if (d == '.') {
          _amountInput = '0.';
        } else {
          _amountInput = d;
        }
        return;
      }

      if (d == '.') {
        if (!_amountInput.contains('.')) {
          _amountInput += '.';
        }
        return;
      }

      if (_amountInput.contains('.')) {
        final parts = _amountInput.split('.');
        if (parts.length > 1 && parts[1].length >= 2) {
          return; // Max 2 decimal places
        }
      }

      if (_amountInput.replaceAll(',', '').replaceAll('.', '').length >= 9) {
        return; // Limit length
      }

      _amountInput += d;
    });
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_amountInput.length <= 1) {
        _amountInput = '0';
      } else {
        _amountInput = _amountInput.substring(0, _amountInput.length - 1);
      }
    });
  }

  Future<void> _submit() async {
    if (_amount <= 0 || _isSaving) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final title = _titleController.text.trim().isEmpty
        ? '${widget.category.name} Expense'
        : _titleController.text.trim();
    final notes = _notesController.text.trim();

    try {
      await ref
          .read(expenseNotifierProvider.notifier)
          .addExpense(
            title: title,
            amount: _amount,
            category: widget.category.name,
            notes: notes.isEmpty ? null : notes,
            transactionType: 'expense',
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${widget.category.name} Expense of ${CurrencyFormatter.full(_amount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: context.separatorColor.withValues(alpha: isDark ? 0.3 : 0.6),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        safeBottom + bottomInset + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Header Pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: widget.category.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.circularFull,
                border: Border.all(
                  color: widget.category.color.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.category.icon,
                    color: widget.category.color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Add: ${widget.category.name}',
                    style: AppTypography.labelLarge.copyWith(
                      color: widget.category.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Large Wallet Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹',
                  style: AppTypography.displayLarge.copyWith(
                    color: widget.category.color,
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _amountDisplay,
                  style: AppTypography.displayLarge.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Toggle Optional Details
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showDetails = !_showDetails);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showDetails
                        ? Icons.remove_circle_outline_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 16,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showDetails
                        ? 'Hide Details'
                        : 'Add Title & Notes (Optional)',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Optional Details Inputs
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _showDetails
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textPrimaryColor,
                            ),
                            decoration: InputDecoration(
                              labelText: 'What was this for?',
                              labelStyle: TextStyle(
                                color: context.textSecondaryColor,
                              ),
                              filled: true,
                              fillColor: context.surfaceVariantColor,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.circularMd,
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _notesController,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textPrimaryColor,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              labelStyle: TextStyle(
                                color: context.textSecondaryColor,
                              ),
                              filled: true,
                              fillColor: context.surfaceVariantColor,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.circularMd,
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Keypad Layout
            Column(
              children: [
                _buildRow(['1', '2', '3']),
                const SizedBox(height: AppSpacing.sm),
                _buildRow(['4', '5', '6']),
                const SizedBox(height: AppSpacing.sm),
                _buildRow(['7', '8', '9']),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _buildDigitButton('.')),
                    Expanded(child: _buildDigitButton('0')),
                    Expanded(
                      child: IconButton(
                        onPressed: _onBackspace,
                        icon: const Icon(Icons.backspace_outlined),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            MLButton.primary(
              label: 'Save Transaction',
              onPressed: _submit,
              isLoading: _isSaving,
              isDisabled: _amount <= 0 || _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: digits
          .map((d) => Expanded(child: _buildDigitButton(d)))
          .toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    return InkWell(
      onTap: () => _onDigit(digit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: AppTypography.displayLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
      ),
    );
  }
}
