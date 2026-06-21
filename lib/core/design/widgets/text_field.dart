import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';

/// A premium stylized text field supporting validation, obscure text, and custom inputs.
class AppTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          style: AppTypography.body,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
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
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.small,
              borderSide: BorderSide(color: AppColors.error, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.small,
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
