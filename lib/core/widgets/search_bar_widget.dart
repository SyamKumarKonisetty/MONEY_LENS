import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../extensions/context_extensions.dart';

/// Premium search bar — non-functional placeholder for Phase 1.
///
/// Uses Apple-style rounded fill design, no border, subtle icon.
///
/// Example:
/// ```dart
/// SearchBarWidget(
///   hint: 'Search transactions...',
///   onChanged: (value) {},
/// )
/// ```
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.padding,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final fillColor = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;
    final iconColor = context.textSecondaryColor;

    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: AppRadius.searchBar,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            Icon(Icons.search_rounded, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimaryColor,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: iconColor,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
