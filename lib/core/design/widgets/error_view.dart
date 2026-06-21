import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import 'primary_button.dart';

/// A clean error fallback screen displaying an error indicator, details, and retry trigger.
class ErrorView extends StatelessWidget {
  final String title;
  final String description;
  final String retryLabel;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.description,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 32,
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
              description,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: retryLabel,
                onTap: onRetry,
                width: 140,
                height: 40,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
