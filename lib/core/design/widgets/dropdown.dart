import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

/// A premium generic dropdown selection element.
class AppDropdown<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    this.labelText,
    this.hintText,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTypography.subtitle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: AppTypography.body,
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            hintStyle: AppTypography.caption,
            border: OutlineInputBorder(
              borderRadius: AppRadius.small,
              borderSide: BorderSide(color: AppColors.divider, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.small,
              borderSide: BorderSide(color: AppColors.divider, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.small,
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
