import 'package:flutter/material.dart';
import '../../foundations/colors.dart';
import '../../foundations/spacing.dart';

/// MoneyLens Design System (MLDS) Navigation Rail Layout.
///
/// Places a navigation sidebar to the left of the core page workspace on tablet/desktop.
class MLNavigationRailLayout extends StatelessWidget {
  const MLNavigationRailLayout({
    required this.rail,
    required this.body,
    super.key,
  });

  final Widget rail;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        rail,
        VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
        Expanded(child: body),
      ],
    );
  }
}

/// MoneyLens Design System (MLDS) Bottom Navigation Layout.
///
/// Places navigation buttons anchored at the bottom (standard mobile setup).
class MLBottomNavigationLayout extends StatelessWidget {
  const MLBottomNavigationLayout({
    required this.body,
    required this.bottomBar,
    super.key,
  });

  final Widget body;
  final Widget bottomBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: body),
        bottomBar,
      ],
    );
  }
}

/// MoneyLens Design System (MLDS) Context Navigation Header.
///
/// Provides top bar contextual information, back actions, and page options.
class MLContextNavigationHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const MLContextNavigationHeader({
    required this.title,
    super.key,
    this.leading,
    this.actions,
    this.onBack,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MLColors.background(context),
      elevation: 0.0,
      centerTitle: false,
      leading:
          leading ??
          (onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
                  onPressed: onBack,
                )
              : null),
      title: title,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}

/// MoneyLens Design System (MLDS) Floating Navigation capsule wrapper.
class MLFloatingNavigation extends StatelessWidget {
  const MLFloatingNavigation({
    required this.child,
    super.key,
    this.margin = const EdgeInsets.all(MLSpacing.pagePadding),
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(padding: margin, child: child),
    );
  }
}
