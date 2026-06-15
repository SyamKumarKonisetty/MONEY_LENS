import 'package:flutter/material.dart';

/// MoneyLens animation constants.
///
/// Centralized timing and curve values for consistent motion
/// throughout the app. Apple-inspired: subtle, fluid, purposeful.
class AppAnimations {
  AppAnimations._();

  // ─── Durations ────────────────────────────────────────────────────────────

  /// For immediate state changes — no perceived delay
  static const Duration instant = Duration(milliseconds: 100);

  /// Micro-interactions: icon swaps, color changes
  static const Duration fast = Duration(milliseconds: 200);

  /// Standard UI transitions: content fades, slide-ins
  static const Duration medium = Duration(milliseconds: 300);

  /// Page transitions and large element movements
  static const Duration slow = Duration(milliseconds: 450);

  /// Spring/elastic effects — FAB appearance, etc.
  static const Duration spring = Duration(milliseconds: 600);

  // ─── Curves ───────────────────────────────────────────────────────────────

  /// Standard ease — entering and exiting
  static const Curve standard = Curves.easeInOut;

  /// Decelerate — elements entering the screen
  static const Curve decelerate = Curves.easeOut;

  /// Accelerate — elements leaving the screen
  static const Curve accelerate = Curves.easeIn;

  /// Apple-style spring feel for bouncy interactions
  static const Curve springCurve = Curves.elasticOut;

  /// Smooth ease for most UI transitions
  static const Curve smooth = Curves.fastOutSlowIn;

  // ─── Stagger delays ───────────────────────────────────────────────────────

  /// Delay between staggered list items
  static const Duration staggerDelay = Duration(milliseconds: 60);

  /// Initial delay for entrance animations
  static const Duration entranceDelay = Duration(milliseconds: 150);
}
