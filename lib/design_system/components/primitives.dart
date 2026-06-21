import 'package:flutter/material.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/colors.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MoneyLens Design System (MLDS) Layer 1 Primitive Components.
///
/// These are the atomic building blocks of the application, consuming
/// MLDS foundations directly and encapsulating base Material widgets.

/// Semantic Icon Button.
class MLIconButton extends StatelessWidget {
  const MLIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.isDisabled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: isDisabled ? null : onPressed,
      tooltip: tooltip,
    );
  }
}

/// Generic surface container for depth stacking.
class MLSurface extends StatelessWidget {
  const MLSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(MLSpacing.cardPadding),
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? MLColors.surfaceCard(context),
        borderRadius: borderRadius ?? MLRadius.largeBorderRadius,
      ),
      child: child,
    );
  }
}

/// Core divider keyline.
class MLDivider extends StatelessWidget {
  const MLDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AppColors.textMuted.withAlpha(51));
  }
}

/// Numerical/Status Badge tag.
class MLBadge extends StatelessWidget {
  const MLBadge({required this.label, super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// User profile Avatar.
class MLAvatar extends StatelessWidget {
  const MLAvatar({
    required this.initials,
    super.key,
    this.imageUrl,
    this.radius = 20.0,
  });

  final String initials;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null ? Text(initials) : null,
    );
  }
}

/// Floating Action Button.
class MLFAB extends StatelessWidget {
  const MLFAB({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}

/// Circular progress spinner.
class MLCircularProgress extends StatefulWidget {
  const MLCircularProgress({
    super.key,
    this.color,
    this.size = 24.0,
  });

  final Color? color;
  final double size;

  @override
  State<MLCircularProgress> createState() => _MLCircularProgressState();
}

class _MLCircularProgressState extends State<MLCircularProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RotationTransition(
        turns: _controller,
        child: Icon(
          Icons.donut_large_rounded,
          color: widget.color ?? MLColors.primary(context),
          size: widget.size,
        ),
      ),
    );
  }
}

/// Linear progress loading bar.
class MLLinearProgress extends StatelessWidget {
  const MLLinearProgress({required this.value, super.key, this.color});

  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textMuted.withAlpha(51),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: constraints.maxWidth * value.clamp(0.0, 1.0),
            height: 8,
            decoration: BoxDecoration(
              color: color ?? MLColors.primary(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }
}

/// Switch toggle.
class MLSwitch extends StatelessWidget {
  const MLSwitch({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(value: value, onChanged: onChanged);
  }
}

/// Checkbox toggle.
class MLCheckbox extends StatelessWidget {
  const MLCheckbox({required this.value, required this.onChanged, super.key});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(value: value, onChanged: onChanged);
  }
}

class MLRadio<T> extends StatelessWidget {
  const MLRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : AppColors.textMuted,
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Segmented horizontal selector.
class MLSegmentedControl<T> extends StatelessWidget {
  const MLSegmentedControl({
    required this.children,
    required this.selectedValue,
    required this.onSelected,
    super.key,
  });

  final Map<T, Widget> children;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    // Basic wrapper mockup
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children.entries.map((entry) {
        final isSelected = entry.key == selectedValue;
        return GestureDetector(
          onTap: () => onSelected(entry.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.textMuted.withAlpha(51)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: entry.value,
          ),
        );
      }).toList(),
    );
  }
}

/// Continuous slider selector.
class MLSlider extends StatelessWidget {
  const MLSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 0.0,
    this.max = 1.0,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Slider(value: value, onChanged: onChanged, min: min, max: max);
  }
}

/// Informational tooltip overlay.
class MLTooltip extends StatelessWidget {
  const MLTooltip({required this.message, required this.child, super.key});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(message: message, child: child);
  }
}

/// Reusable layout spacer block.
class MLSpacer extends StatelessWidget {
  const MLSpacer({super.key, this.width = 0.0, this.height = 0.0});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}

/// Gestural action zone wrapper.
class MLGestureArea extends StatelessWidget {
  const MLGestureArea({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: child);
  }
}
