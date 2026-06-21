import 'package:flutter/material.dart';
import '../foundations/colors.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';
import '../animations/haptics.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MoneyLens Design System (MLDS) Chip Component interface.
///
/// Under MLDS, chips are used for category tags, filter triggers, and selections.
abstract class MLChip extends StatelessWidget {
  const MLChip({super.key});

  /// Standard static tag chip.
  const factory MLChip.tag({
    required String label,
    Key? key,
    IconData? icon,
    Color? color,
  }) = _MLTagChip;

  /// Choice/Filter selectable chip.
  const factory MLChip.choice({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
    Key? key,
    IconData? icon,
  }) = _MLChoiceChip;
}

class _MLTagChip extends MLChip {
  const _MLTagChip({
    required this.label,
    super.key,
    this.icon,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? MLColors.primary(context).withValues(alpha: 0.1);
    final textColor = color != null ? AppColors.textPrimary : MLColors.primary(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MLSpacing.md,
        vertical: MLSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: MLRadius.pillBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: MLSpacing.xs),
          ],
          Text(
            label,
            style: MLTypography.chip.copyWith(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MLChoiceChip extends MLChip {
  const _MLChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    super.key,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final primaryColor = MLColors.primary(context);
    final activeBg = primaryColor.withValues(alpha: 0.15);
    final inactiveBg = Theme.of(context).brightness == Brightness.dark
        ? MLColors.surfaceVariant(context)
        : const Color(0xFFF2F2F7);

    final activeText = primaryColor;
    final inactiveText = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondary
        : Colors.black87;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          MLHaptics.selection();
          onSelected(!isSelected);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: MLSpacing.lg,
            vertical: MLSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: MLRadius.pillBorderRadius,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? activeText : inactiveText,
                ),
                const SizedBox(width: MLSpacing.xs),
              ],
              Text(
                label,
                style: MLTypography.chip.copyWith(
                  color: isSelected ? activeText : inactiveText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
