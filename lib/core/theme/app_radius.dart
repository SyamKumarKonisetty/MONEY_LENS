import 'package:flutter/widgets.dart';

/// MoneyLens border radius system.
///
/// Consistent radius tokens across the design system.
/// Avoid using raw [BorderRadius.circular] values directly.
class AppRadius {
  AppRadius._();

  // ─── Size tokens ──────────────────────────────────────────────────────────
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 999.0;

  // ─── BorderRadius shortcuts ───────────────────────────────────────────────
  static const BorderRadius circularNone = BorderRadius.zero;

  static const BorderRadius circularXs = BorderRadius.all(Radius.circular(xs));

  static const BorderRadius circularSm = BorderRadius.all(Radius.circular(sm));

  static const BorderRadius circularMd = BorderRadius.all(Radius.circular(md));

  static const BorderRadius circularLg = BorderRadius.all(Radius.circular(lg));

  static const BorderRadius circularXl = BorderRadius.all(Radius.circular(xl));

  static const BorderRadius circularXxl = BorderRadius.all(
    Radius.circular(xxl),
  );

  static const BorderRadius circularFull = BorderRadius.all(
    Radius.circular(full),
  );

  // ─── Semantic shortcuts ───────────────────────────────────────────────────
  /// Standard card border radius
  static const BorderRadius card = circularXxl;

  /// Button border radius
  static const BorderRadius button = circularFull;

  /// Search bar border radius
  static const BorderRadius searchBar = circularXl;

  /// Chip / badge border radius
  static const BorderRadius chip = circularFull;

  /// Bottom sheet border radius (top corners only)
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}
