import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import '../icons/app_icons.dart';

/// A search input field with a prefix magnifier icon.
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? hint; // Added for backwards compatibility
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.body,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText ?? hint ?? 'Search transactions...',
        prefixIcon: Icon(
          AppIcons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller!.clear();
                  if (onClear != null) onClear!();
                  if (onChanged != null) onChanged!('');
                },
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
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
    );
  }
}
