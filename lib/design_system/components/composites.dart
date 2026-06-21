import 'package:flutter/material.dart';
import '../foundations/spacing.dart';
import 'text.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MoneyLens Design System (MLDS) Layer 2 Composite Components.
///
/// These widgets combine Primitive building blocks to form interface modules.

/// Standard Application Header Bar.
class MLAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MLAppBar({required this.title, super.key, this.actions, this.leading});

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: MLText.heading(title),
      actions: actions,
      leading: leading,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Standardized divider/section headers.
class MLSectionHeader extends StatelessWidget {
  const MLSectionHeader({required this.title, super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MLSpacing.listSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [MLText.dotLabel(title), trailing ?? const SizedBox.shrink()],
      ),
    );
  }
}

/// Quick actions horizontal toolbar.
class MLToolbar extends StatelessWidget {
  const MLToolbar({required this.items, super.key});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: item,
          );
        }).toList(),
      ),
    );
  }
}

/// Dynamic Date selector dropdown/trigger.
class MLDateSelector extends StatelessWidget {
  const MLDateSelector({
    required this.selectedDate,
    required this.onTap,
    super.key,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.calendar_today, size: 14),
      label: Text(
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
      ),
      onPressed: onTap,
    );
  }
}

/// Statistical readout display row.
class MLStatistic extends StatelessWidget {
  const MLStatistic({
    required this.label,
    required this.value,
    super.key,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MLText.caption(label),
            const SizedBox(height: 4.0),
            MLText.money(value),
          ],
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

/// Vertical timeline item sequence.
class MLTimeline extends StatelessWidget {
  const MLTimeline({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.map((child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.textMuted.withAlpha(51),
                ),
              ],
            ),
            const SizedBox(width: 12.0),
            Expanded(child: child),
          ],
        );
      }).toList(),
    );
  }
}

/// Informational horizontal progress steps.
class MLStepper extends StatelessWidget {
  const MLStepper({required this.steps, required this.currentStep, super.key});

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final label = entry.value;
        final isActive = idx == currentStep;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: isActive ? Colors.blue : AppColors.textMuted,
                child: Text(
                  '${idx + 1}',
                  style: TextStyle(fontSize: 10, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 4.0),
              Text(label, style: const TextStyle(fontSize: 10)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Horizontal paging slide carousel.
class MLCarousel extends StatelessWidget {
  const MLCarousel({required this.items, super.key});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 150, child: PageView(children: items));
  }
}

/// Bottom Sheet confirmation layout.
class MLConfirmationSheet extends StatelessWidget {
  const MLConfirmationSheet({
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    super.key,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MLText.heading(title),
          const SizedBox(height: 12.0),
          MLText.body(message),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: Text(cancelLabel)),
              const SizedBox(width: 8.0),
              ElevatedButton(onPressed: onConfirm, child: Text(confirmLabel)),
            ],
          ),
        ],
      ),
    );
  }
}
