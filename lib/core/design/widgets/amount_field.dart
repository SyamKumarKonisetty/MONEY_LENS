import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';

/// A transaction amount input field with large typography and currency symbol indicators.
class AppAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool autoFocus;

  const AppAmountField({
    super.key,
    required this.controller,
    this.currencySymbol = '₹',
    this.onChanged,
    this.validator,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      autofocus: autoFocus,
      style: AppTypography.displayLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        prefixText: '$currencySymbol ',
        prefixStyle: AppTypography.displayMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintText: '0.00',
        hintStyle: AppTypography.displayLarge.copyWith(
          color: AppColors.textHint.withValues(alpha: 0.3),
        ),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
    );
  }
}
