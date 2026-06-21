import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import '../icons/app_icons.dart';

/// A date selection field that triggers a standard date picker dialog styled to match our design system.
class AppDatePicker extends StatelessWidget {
  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePicker({
    super.key,
    required this.labelText,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelText,
          style: AppTypography.subtitle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: AppRadius.small,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.small,
              border: Border.all(color: AppColors.divider, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: AppTypography.body,
                ),
                Icon(
                  AppIcons.calendar,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
