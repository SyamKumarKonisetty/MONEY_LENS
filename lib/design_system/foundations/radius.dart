import 'package:flutter/material.dart';

/// Corner Radius tokens for MoneyLens Design System (MLDS).
///
/// Under MLDS, raw BorderRadius.circular() values must never be hardcoded.
/// Use these tokens to ensure consistent rounded geometry across elements.
class MLRadius {
  MLRadius._();

  // ─── Double Constants ─────────────────────────────────────────────────────
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
  static const double circle = 999.0;

  // ─── BorderRadius Wrappers ────────────────────────────────────────────────
  static final BorderRadius smallBorderRadius = BorderRadius.circular(small);
  static final BorderRadius mediumBorderRadius = BorderRadius.circular(medium);
  static final BorderRadius largeBorderRadius = BorderRadius.circular(large);
  static final BorderRadius xlBorderRadius = BorderRadius.circular(xl);
  static final BorderRadius pillBorderRadius = BorderRadius.circular(pill);
  static final BorderRadius circleBorderRadius = BorderRadius.circular(circle);
}
