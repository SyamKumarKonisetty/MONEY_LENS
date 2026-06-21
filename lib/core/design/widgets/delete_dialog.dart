import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../radius/app_radius.dart';
import '../typography/app_typography.dart';
import 'danger_button.dart';
import 'secondary_button.dart';

/// A confirmation dialog tailored for destructive delete actions.
class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String deleteLabel;
  final String cancelLabel;
  final VoidCallback onDelete;
  final VoidCallback? onCancel;

  const DeleteDialog({
    super.key,
    required this.title,
    required this.message,
    this.deleteLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    required this.onDelete,
    this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String deleteLabel = 'Delete',
    String cancelLabel = 'Cancel',
    required VoidCallback onDelete,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteDialog(
        title: title,
        message: message,
        deleteLabel: deleteLabel,
        cancelLabel: cancelLabel,
        onDelete: () {
          Navigator.of(context).pop(true);
          onDelete();
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
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
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
                  child: DangerButton(
                    label: deleteLabel,
                    onTap: () {
                      Navigator.of(context).pop(true);
                      onDelete();
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
