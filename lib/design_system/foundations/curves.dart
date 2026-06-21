import 'package:flutter/animation.dart';

/// Animation curve tokens for MoneyLens Design System (MLDS).
///
/// Under MLDS, all transitions should follow natural, physical-feeling curves.
class MLCurves {
  MLCurves._();

  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.fastOutSlowIn;
  static const Curve spring = Cubic(0.175, 0.885, 0.32, 1.1);
  static const Curve easeOut = Curves.easeOutQuad;
  static const Curve easeIn = Curves.easeInQuad;
  static const Curve bounce = Curves.bounceOut;

  // ─── Financial Interaction Language (FIL) Curves ──────────────────────────

  /// Tactile button spring-back compression.
  static const Curve springBack = Cubic(0.175, 0.885, 0.32, 1.275);

  /// Premium coin landing bounce.
  static const Curve coinDropBounce = Cubic(0.25, 1.35, 0.45, 1.0);

  /// Acceleration for folding transitions (Receipt fold).
  static const Curve receiptFoldCurve = Cubic(0.77, 0.0, 0.175, 1.0);

  /// Breathing active budget loops.
  static const Curve livingRingEase = Curves.easeInOutSine;

  /// Direct forward translating page movement.
  static const Curve pageForward = Cubic(0.2, 0.8, 0.2, 1.0);

  /// Direct backward translating page movement.
  static const Curve pageBackward = Cubic(0.2, 0.8, 0.2, 1.0);
}
