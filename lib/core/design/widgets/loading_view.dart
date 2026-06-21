import 'package:flutter/material.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import '../../ui_engine/ui_engine.dart';

/// A premium full-page or overlay loading indicator with custom text.
class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: MLSpinner(size: 32),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
