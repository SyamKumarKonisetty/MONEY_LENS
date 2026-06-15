import 'package:flutter/material.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../extensions/context_extensions.dart';

/// A reusable section header with optional trailing action.
///
/// Used to label major sections within a scrollable screen.
///
/// Example:
/// ```dart
/// SectionHeader(
///   title: 'Recent Transactions',
///   actionLabel: 'See All',
///   onAction: () {},
/// )
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.headlineLarge.copyWith(
              color: context.textPrimaryColor,
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelLarge.copyWith(
                  color: context.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
