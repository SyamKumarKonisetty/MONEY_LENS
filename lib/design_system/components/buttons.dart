import 'package:flutter/material.dart';
import '../foundations/colors.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';
import '../animations/haptics.dart';
import 'primitives.dart';
import 'package:money_lens/core/design/design_system.dart' hide OutlinedButton;

/// MoneyLens Design System (MLDS) Button Component interface.
///
/// Developers should use semantic constructors instead of configuring raw button
/// paddings, colors, and border shapes.
///
/// Example:
/// ```dart
/// MLButton.primary(
///   label: 'Confirm Restore',
///   onPressed: () => _restoreBackup(),
/// )
/// ```
abstract class MLButton extends StatelessWidget {
  const MLButton({super.key});

  /// Primary action button. Solid brand color fill.
  const factory MLButton.primary({
    required String label,
    required VoidCallback onPressed,
    Key? key,
    IconData? icon,
    bool isLoading,
    bool isDisabled,
  }) = _MLPrimaryButton;

  /// Secondary action button. Outlined brand border.
  const factory MLButton.secondary({
    required String label,
    required VoidCallback onPressed,
    Key? key,
    IconData? icon,
    bool isDisabled,
  }) = _MLSecondaryButton;

  /// Subtle text action button. Borderless, matches text style.
  const factory MLButton.text({
    required String label,
    required VoidCallback onPressed,
    Key? key,
    IconData? icon,
    bool isDisabled,
  }) = _MLTextButton;
}

class _MLPrimaryButton extends MLButton {
  const _MLPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final activeColor = MLColors.primary(context);
    final textStyle = MLTypography.button.copyWith(color: AppColors.textPrimary);

    return MouseRegion(
      cursor: isDisabled || isLoading ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => MLHaptics.light(),
        child: ElevatedButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: activeColor,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: activeColor.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: MLRadius.largeBorderRadius,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: MLSpacing.xxl,
              vertical: MLSpacing.lg,
            ),
            minimumSize: const Size.fromHeight(52),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: MLCircularProgress(
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: MLSpacing.sm),
                    ],
                    Text(label, style: textStyle),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MLSecondaryButton extends MLButton {
  const _MLSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final activeColor = MLColors.primary(context);
    final textStyle = MLTypography.button.copyWith(color: activeColor);

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => MLHaptics.light(),
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: activeColor,
            side: BorderSide(
              color: activeColor.withValues(alpha: isDisabled ? 0.3 : 1.0),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: MLRadius.largeBorderRadius,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: MLSpacing.xxl,
              vertical: MLSpacing.lg,
            ),
            minimumSize: const Size.fromHeight(52),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: MLSpacing.sm),
              ],
              Text(label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}

class _MLTextButton extends MLButton {
  const _MLTextButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final activeColor = MLColors.primary(context);
    final textStyle = MLTypography.button.copyWith(
      color: activeColor.withValues(alpha: isDisabled ? 0.5 : 1.0),
    );

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => MLHaptics.light(),
        child: TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: activeColor,
            shape: RoundedRectangleBorder(
              borderRadius: MLRadius.mediumBorderRadius,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: MLSpacing.md,
              vertical: MLSpacing.sm,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: MLSpacing.sm),
              ],
              Text(label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
