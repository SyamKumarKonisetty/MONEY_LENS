import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';

/// A premium, standardized modal Bottom Sheet wrapper with a top drag handle.
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.padding,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.mVal),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AppBottomSheet(
          title: title,
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 36,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Optional Title
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.divider),
          ],

          // Content
          Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}
