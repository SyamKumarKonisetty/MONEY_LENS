/// Animation duration tokens for MoneyLens Design System (MLDS).
///
/// Under MLDS, raw Duration constructors must never be hardcoded.
/// Use these tokens to maintain timing harmony across the application.
class MLDuration {
  MLDuration._();

  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration extraSlow = Duration(milliseconds: 500);

  // ─── Financial Interaction Language (FIL) Durations ───────────────────────
  static const Duration coinDrop = Duration(milliseconds: 600);
  static const Duration receiptFold = Duration(milliseconds: 500);
  static const Duration livingRingBreath = Duration(seconds: 2);
  static const Duration staggerStep = Duration(milliseconds: 50);
  static const Duration searchExpand = Duration(milliseconds: 300);
  static const Duration skeletonShimmer = Duration(milliseconds: 1500);
}
