import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_typography.dart';
import 'bottom_sheet.dart';

/// A premium option selection list sheet.
class AppActionSheet extends StatelessWidget {
  final String? title;
  final List<String> options;
  final List<IconData>? icons;
  final ValueChanged<int> onOptionSelected;

  const AppActionSheet({
    super.key,
    this.title,
    required this.options,
    this.icons,
    required this.onOptionSelected,
  });

  static Future<int?> show(
    BuildContext context, {
    String? title,
    required List<String> options,
    List<IconData>? icons,
  }) {
    int? selectedIndex;
    return AppBottomSheet.show<int>(
      context,
      title: title,
      padding: EdgeInsets.zero,
      child: AppActionSheet(
        options: options,
        icons: icons,
        onOptionSelected: (index) {
          selectedIndex = index;
          Navigator.of(context).pop(index);
        },
      ),
    ).then((_) => selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(options.length, (index) {
        final label = options[index];
        final icon = icons != null && icons!.length > index ? icons![index] : null;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onOptionSelected(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Text(
                    label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
