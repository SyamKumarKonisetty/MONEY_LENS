/// Centralized spacing system for MoneyLens V2.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // Semantic layout aliases (matching the old system for safe migration)
  static const double cardPadding = md;
  static const double pagePadding = md;
  static const double listGap = sm;
  static const double cardGap = md;
  
  static const double giant = xxxl;
  static const double sectionGap = xxl;
}
