import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Date section header for grouped transaction lists.
///
/// Shows 'Today', 'Yesterday', or formatted date.
class DateSectionHeader extends StatelessWidget {
  const DateSectionHeader({super.key, required this.dateLabel});

  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        top: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        dateLabel,
        style: AppTypography.titleSmall.copyWith(
          color: context.textSecondaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
