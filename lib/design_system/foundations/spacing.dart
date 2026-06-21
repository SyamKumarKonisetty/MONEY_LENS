/// Spacing tokens for MoneyLens Design System (MLDS).
///
/// Built on a strict 8dp rhythm to preserve spatial clarity and layout alignment.
class MLSpacing {
  MLSpacing._();

  // ─── Base Grid Scale ──────────────────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double giant = 48.0;
  static const double massive = 64.0;

  // ─── Semantic Padding Tokens ──────────────────────────────────────────────
  static const double pagePadding = xl;
  static const double cardPadding = lg;
  static const double bottomSheetPadding = xxl;
  static const double dialogPadding = xxl;
  static const double navigationPadding = lg;
  static const double formSpacing = xl;
  static const double listSpacing = md;
  static const double gridSpacing = lg;

  // Safe area helper spacing offsets
  static const double safeAreaBottomMin = lg;
  static const double safeAreaTopMin = xxl;
}
