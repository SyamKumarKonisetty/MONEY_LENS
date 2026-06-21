import 'package:flutter/material.dart';
import '../foundations/curves.dart';
import '../foundations/duration.dart';

/// MoneyLens Design System (MLDS) Page and Element Transition curves.
class MLTransitions {
  MLTransitions._();

  static bool _reducedMotion = false;

  /// Globally toggle transitions to fade-only or instant for accessibility options.
  static void setReducedMotion(bool value) {
    _reducedMotion = value;
  }

  /// Page slide-and-fade forward route transition.
  static Route<T> page<T>({required Widget page, RouteSettings? settings}) {
    if (_reducedMotion) {
      return PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: MLDuration.normal,
      reverseTransitionDuration: MLDuration.fast,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0.08, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: MLCurves.pageForward),
            );
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Modal bottom-up slide transition.
  static Route<T> modal<T>({required Widget page, RouteSettings? settings}) {
    if (_reducedMotion) {
      return PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: MLDuration.slow,
      reverseTransitionDuration: MLDuration.normal,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0.0, 0.12),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: MLCurves.springBack),
            );
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
