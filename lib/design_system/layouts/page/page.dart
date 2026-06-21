import 'package:flutter/material.dart';
import '../../foundations/colors.dart';
import '../../foundations/radius.dart';
import '../../foundations/shadows.dart';
import '../../foundations/spacing.dart';

/// MoneyLens Design System (MLDS) Page Container.
///
/// Wraps standard screen layouts with standard page padding.
class MLPage extends StatelessWidget {
  const MLPage({
    required this.child,
    super.key,
    this.padding,
    this.useSafeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(MLSpacing.pagePadding),
      child: child,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }
    return content;
  }
}

/// A scrollable layout framework for views that exceed a single viewport.
///
/// Enforces consistent spatial rhythm between sections or list elements.
class MLScrollablePage extends StatelessWidget {
  const MLScrollablePage({
    required this.children,
    super.key,
    this.padding,
    this.controller,
    this.physics,
    this.header,
    this.footer,
    this.spacing = MLSpacing.formSpacing,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final Widget? header;
  final Widget? footer;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final listPadding = padding ?? const EdgeInsets.all(MLSpacing.pagePadding);

    Widget scrollable = ListView.separated(
      controller: controller,
      physics: physics,
      padding: listPadding,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => children[index],
    );

    final headerWidget = header;
    final footerWidget = footer;
    if (headerWidget != null || footerWidget != null) {
      scrollable = Column(
        children: [
          ?headerWidget,
          Expanded(child: scrollable),
          ?footerWidget,
        ],
      );
    }

    return scrollable;
  }
}

/// Container that applies margins or standard spacing insets.
class MLInsetContainer extends StatelessWidget {
  const MLInsetContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(MLSpacing.cardPadding),
    this.margin,
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? MLColors.surfaceCard(context),
        borderRadius: borderRadius ?? MLRadius.mediumBorderRadius,
      ),
      child: child,
    );
  }
}

/// Semantic segment layout containing a header title, a body child, and an optional action.
class MLSection extends StatelessWidget {
  const MLSection({
    required this.title,
    required this.child,
    super.key,
    this.trailing,
    this.spacing = MLSpacing.listSpacing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            ?trailingWidget,
          ],
        ),
        SizedBox(height: spacing),
        child,
      ],
    );
  }
}

/// Groups multiple vertical sections ensuring rhythm consistency.
class MLSectionGroup extends StatelessWidget {
  const MLSectionGroup({
    required this.children,
    super.key,
    this.spacing = MLSpacing.xxl,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

/// A thin, theme-aware division line.
class MLSectionDivider extends StatelessWidget {
  const MLSectionDivider({super.key, this.height = 1.0, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: height,
      color: color ?? Theme.of(context).dividerColor.withValues(alpha: 0.08),
    );
  }
}

/// A layered overlay container with rounded corners and distinct elevation.
class MLFloatingContainer extends StatelessWidget {
  const MLFloatingContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(MLSpacing.cardPadding),
    this.color,
    this.borderRadius,
    this.shadows,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? MLColors.surfaceFloating(context),
        borderRadius: borderRadius ?? MLRadius.largeBorderRadius,
        boxShadow: shadows ?? MLShadows.medium,
      ),
      child: child,
    );
  }
}

/// Sticks a widget (e.g. primary call-to-action buttons) to the bottom of the viewport.
class MLStickyFooter extends StatelessWidget {
  const MLStickyFooter({
    required this.child,
    super.key,
    this.backgroundColor,
    this.padding,
    this.border,
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? MLColors.background(context),
        border:
            border ??
            Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(MLSpacing.pagePadding),
          child: child,
        ),
      ),
    );
  }
}

/// Sticks a header widget to the top of the viewport, preserving space for status bars.
class MLStickyHeader extends StatelessWidget {
  const MLStickyHeader({
    required this.child,
    super.key,
    this.backgroundColor,
    this.padding,
    this.border,
  });

  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? MLColors.background(context),
        border:
            border ??
            Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(MLSpacing.pagePadding),
          child: child,
        ),
      ),
    );
  }
}

/// Layout wrapper that simplifies handling notches, gesture insets, and keyboards.
class MLSafeAreaLayout extends StatelessWidget {
  const MLSafeAreaLayout({
    required this.child,
    super.key,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.keyboardPadding = true,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final bool keyboardPadding;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (keyboardPadding) {
      content = Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: content,
      );
    }

    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: content,
    );
  }
}

/// Helper container for applying semantic spacing padding without nesting widgets.
class MLContentPadding extends StatelessWidget {
  const MLContentPadding({
    required this.child,
    super.key,
    this.horizontal = MLSpacing.pagePadding,
    this.vertical = MLSpacing.pagePadding,
  });

  final Widget child;
  final double horizontal;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child,
    );
  }
}
