import 'package:flutter/services.dart';

/// MoneyLens Design System (MLDS) Semantic Haptic Feedback framework.
///
/// Under FIL guidelines, haptics should never spam the user. They are reserved
/// for meaningful feedback confirmation:
/// - Light: Component state changes (chips, toggles).
/// - Medium: Successful transactions or page triggers.
/// - Heavy: Destructive actions (wiping local database).
/// - Success: Multi-tap rhythmic vibration confirming operations (exports, imports).
/// - Warning: Rhythmic alert pattern notifying caution.
class MLHaptics {
  MLHaptics._();

  static bool _reducedMotion = false;

  /// Globally toggle haptics off for accessibility options.
  static void setReducedMotion(bool value) {
    _reducedMotion = value;
  }

  /// Light impact feedback (selection, minor toggles).
  static Future<void> light() async {
    if (_reducedMotion) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback (button activations).
  static Future<void> medium() async {
    if (_reducedMotion) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback (destructive steps).
  static Future<void> heavy() async {
    if (_reducedMotion) return;
    await HapticFeedback.heavyImpact();
  }

  /// Click tick feedback (scrollers, item traversals).
  static Future<void> selection() async {
    if (_reducedMotion) return;
    await HapticFeedback.selectionClick();
  }

  /// Success tactile signature (Double light tap).
  static Future<void> success() async {
    if (_reducedMotion) return;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// Warning tactile signature (Medium-Heavy pulse).
  static Future<void> warning() async {
    if (_reducedMotion) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
