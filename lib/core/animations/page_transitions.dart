import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../animations/animation_constants.dart';

/// Custom page transitions for MoneyLens.
///
/// Apple-inspired smooth transitions — fade + slide for page pushes,
/// fade for tab switches.
class AppPageTransitions {
  AppPageTransitions._();

  /// Fade + slight upward slide — used for modal/push routes.
  static Widget fadeSlide({
    required Animation<double> animation,
    required Widget child,
  }) {
    final curvedAnim = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.smooth,
    );

    return FadeTransition(
      opacity: curvedAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curvedAnim),
        child: child,
      ),
    );
  }

  /// Pure fade — used for tab switches.
  static Widget fade({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: AppAnimations.standard,
      ),
      child: child,
    );
  }
}

/// Fade + slide page route builder — for GoRouter's [pageBuilder].
CustomTransitionPage<void> buildFadeSlidePage({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: AppAnimations.medium,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return AppPageTransitions.fadeSlide(animation: animation, child: child);
    },
  );
}

/// Animated tab switcher using [AnimatedSwitcher].
///
/// Wraps screen content with a fade transition when switching tabs.
class AnimatedTabSwitcher extends StatelessWidget {
  final Widget child;
  final int tabIndex;

  const AnimatedTabSwitcher({
    super.key,
    required this.child,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimations.fast,
      switchInCurve: AppAnimations.decelerate,
      switchOutCurve: AppAnimations.accelerate,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: KeyedSubtree(key: ValueKey<int>(tabIndex), child: child),
    );
  }
}
