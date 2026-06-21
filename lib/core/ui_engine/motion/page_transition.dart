/// {@template page_transition}
/// Custom page-route transitions for the MoneyLens Motion System.
///
/// This file exports three [PageRouteBuilder] subclasses:
///
/// | Class                    | Effect                                      |
/// |--------------------------|---------------------------------------------|
/// | [FadeScaleRoute]         | Fade-in + scale 0.92 → 1.0 (default push)  |
/// | [SlideUpRoute]           | Slide from 30 px below + fade (modal push) |
/// | [SharedAxisRoute]        | Horizontal slide with cross-fade            |
///
/// All transitions use durations and curves from [MotionConstants] so they are
/// consistent with every other animated element in the app.
///
/// ### Usage
/// ```dart
/// // Standard push
/// Navigator.of(context).push(FadeScaleRoute(page: DetailsScreen()));
///
/// // Modal-style push
/// Navigator.of(context).push(SlideUpRoute(page: AddTransactionScreen()));
///
/// // Lateral navigation (shared axis)
/// Navigator.of(context).push(SharedAxisRoute(page: CategoryScreen(), forward: true));
/// ```
/// {@endtemplate}
library;

import 'package:flutter/material.dart';

import 'motion_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FadeScaleRoute
// ─────────────────────────────────────────────────────────────────────────────

/// A [PageRouteBuilder] that transitions with a simultaneous **fade + scale**.
///
/// - **Enter**: opacity 0 → 1, scale 0.92 → 1.0 over [MotionConstants.normalDuration].
/// - **Exit (pop)**: opacity 1 → 0, scale 1.0 → 0.96 over [MotionConstants.fastDuration].
///
/// Best suited for: dashboard-to-detail, settings screens.
class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  /// Creates a [FadeScaleRoute].
  ///
  /// [page] is the widget to navigate to.
  FadeScaleRoute({
    required Widget page,
    super.settings,
    super.opaque = false,
  }) : super(
          transitionDuration: MotionConstants.normalDuration,
          reverseTransitionDuration: MotionConstants.fastDuration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Incoming page: fade + scale up
            final fadeIn = CurvedAnimation(
              parent: animation,
              curve: MotionConstants.smoothCurve,
              reverseCurve: MotionConstants.smoothCurve,
            );
            final scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: MotionConstants.decelerateCurve,
                reverseCurve: MotionConstants.decelerateCurve,
              ),
            );

            // Outgoing page (the old screen): slight scale-down
            final scaleOut = Tween<double>(begin: 1.0, end: 0.96).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: MotionConstants.snappyCurve,
              ),
            );
            final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: MotionConstants.snappyCurve,
              ),
            );

            return FadeTransition(
              opacity: fadeOut,
              child: ScaleTransition(
                scale: scaleOut,
                child: FadeTransition(
                  opacity: fadeIn,
                  child: ScaleTransition(scale: scaleIn, child: child),
                ),
              ),
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// SlideUpRoute
// ─────────────────────────────────────────────────────────────────────────────

/// A [PageRouteBuilder] that slides the new screen **up from 30 px below** while
/// fading in, mimicking a modal presentation.
///
/// - **Enter**: slide Offset(0, ~0.04) → Offset.zero + fade over [MotionConstants.slowDuration].
/// - **Exit (pop)**: slide back down + fade-out over [MotionConstants.normalDuration].
///
/// Best suited for: add-transaction sheets, detail modals.
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  /// Creates a [SlideUpRoute].
  ///
  /// [page] is the widget to navigate to.
  SlideUpRoute({
    required Widget page,
    super.settings,
    super.opaque = false,
    /// Pixel offset from which the page begins its slide-up.
    double slideStartPixels = 30.0,
  }) : super(
          transitionDuration: MotionConstants.slowDuration,
          reverseTransitionDuration: MotionConstants.normalDuration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // We use a fractional offset derived from the screen height. Since
            // PageRouteBuilder doesn't expose MediaQuery here we use a
            // LayoutBuilder / FractionalOffset-based approach.
            final slideIn = Tween<Offset>(
              // 30-pixel slide in a logical-pixel–agnostic way via a fraction.
              // SlideTransition uses fractional offsets so 30px ≈ a small value.
              // We bake 0.04 (≈30/750) which looks correct at most screen sizes.
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: MotionConstants.springCurve,
                reverseCurve: MotionConstants.snappyCurve,
              ),
            );

            final fadeIn = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            );

            return FadeTransition(
              opacity: fadeIn,
              child: SlideTransition(position: slideIn, child: child),
            );
          },
        );
}

// ─────────────────────────────────────────────────────────────────────────────
// SharedAxisRoute
// ─────────────────────────────────────────────────────────────────────────────

/// A [PageRouteBuilder] that transitions with a **horizontal shared-axis** motion.
///
/// Mimics the Material 3 shared-axis pattern:
/// - Outgoing page exits to the left (or right if [forward] is `false`).
/// - Incoming page enters from the right (or left if [forward] is `false`).
/// - Both pages cross-fade during the transition.
///
/// Best suited for: tab-level navigation, wizard steps, category browsing.
class SharedAxisRoute<T> extends PageRouteBuilder<T> {
  /// Creates a [SharedAxisRoute].
  ///
  /// Set [forward] to `false` for a backwards / "previous" navigation.
  SharedAxisRoute({
    required Widget page,
    super.settings,
    super.opaque = false,
    /// Determines slide direction.
    ///
    /// `true` (default) – incoming page enters from right, outgoing exits left.
    /// `false` – incoming page enters from left, outgoing exits right.
    bool forward = true,
  }) : super(
          transitionDuration: MotionConstants.normalDuration,
          reverseTransitionDuration: MotionConstants.normalDuration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final sign = forward ? 1.0 : -1.0;

            // Incoming
            final slideIn = Tween<Offset>(
              begin: Offset(0.08 * sign, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: MotionConstants.snappyCurve,
              ),
            );
            final fadeIn = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
            );

            // Outgoing
            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(-0.06 * sign, 0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: MotionConstants.snappyCurve,
              ),
            );
            final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
              ),
            );

            return SlideTransition(
              position: slideOut,
              child: FadeTransition(
                opacity: fadeOut,
                child: SlideTransition(
                  position: slideIn,
                  child: FadeTransition(opacity: fadeIn, child: child),
                ),
              ),
            );
          },
        );
}
