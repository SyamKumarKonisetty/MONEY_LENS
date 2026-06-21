import 'package:flutter/material.dart';
import '../../foundations/breakpoints.dart';
import '../../foundations/spacing.dart';

/// MoneyLens Design System (MLDS) Responsive Layout Container.
///
/// Automatically swaps child representations based on design system breakpoints.
class MLResponsiveContainer extends StatelessWidget {
  const MLResponsiveContainer({
    required this.phone,
    super.key,
    this.foldable,
    this.tablet,
    this.desktop,
  });

  /// Default mobile layout representation (required).
  final Widget phone;

  /// Foldable screen layout representation (optional).
  final Widget? foldable;

  /// Tablet screen layout representation (optional).
  final Widget? tablet;

  /// Desktop layout representation (optional).
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= MLBreakpoints.desktop && desktop != null) {
          return desktop!;
        } else if (width >= MLBreakpoints.tablet && tablet != null) {
          return tablet!;
        } else if (width >= MLBreakpoints.foldable && foldable != null) {
          return foldable!;
        } else {
          return phone;
        }
      },
    );
  }
}

/// MoneyLens Design System (MLDS) Semantic Grid.
///
/// Formats child components into multi-column, adaptive grid formats.
class MLGrid extends StatelessWidget {
  const MLGrid({
    required this.children,
    super.key,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = MLSpacing.gridSpacing,
    this.crossAxisSpacing = MLSpacing.gridSpacing,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}
