import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// A modal dialog for standard user confirmations (e.g. Yes/No prompts).
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () {
          Navigator.of(context).pop(true);
          onConfirm();
        },
        onCancel: () {
          Navigator.of(context).pop(false);
          if (onCancel != null) onCancel();
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
            Text(
              title,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: cancelLabel,
                    onTap: () {
                      Navigator.of(context).pop(false);
                      if (onCancel != null) onCancel!();
                    },
                    height: 44,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    label: confirmLabel,
                    onTap: () {
                      Navigator.of(context).pop(true);
                      onConfirm();
                    },
                    height: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
