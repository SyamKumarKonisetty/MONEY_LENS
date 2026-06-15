/// MoneyLens spacing system.
///
/// Based on an 4pt base grid. Use named tokens throughout
/// the app — never hardcode raw pixel values.
class AppSpacing {
  AppSpacing._();

  // ─── Base grid tokens ─────────────────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double giant = 48.0;
  static const double massive = 64.0;

  // ─── Semantic layout tokens ───────────────────────────────────────────────
  /// Standard horizontal page padding
  static const double pagePadding = 20.0;

  /// Padding inside cards
  static const double cardPadding = 20.0;

  /// Gap between cards in a list
  static const double cardGap = 12.0;

  /// Gap between list items
  static const double listItemGap = 1.0;

  /// Section gap between major page sections
  static const double sectionGap = 32.0;

  /// Bottom safe area padding addition
  static const double bottomSafeArea = 16.0;

  /// Top padding under the greeting header
  static const double headerBottomPadding = 24.0;
}
