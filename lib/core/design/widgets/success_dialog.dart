import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import '../icons/app_icons.dart';
import 'primary_button.dart';

/// A premium modal dialog representing successful transactions or state changes.
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel = 'Great',
    this.onAction,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String actionLabel = 'Great',
    VoidCallback? onAction,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: () {
          Navigator.of(context).pop();
          if (onAction != null) onAction();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.check,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: actionLabel,
              onTap: () {
                Navigator.of(context).pop();
                if (onAction != null) onAction!();
              },
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}
