import 'package:flutter/material.dart';

/// Typography styles for MoneyLens Design System (MLDS).
///
/// Implements the Financial Typography System (FTS) using two primary fonts:
/// - Inter: For readability, data tables, metrics, forms, and financial amounts.
/// - NothingDotMatrix (with Courier fallback): For structural, uppercase labels.
class MLTypography {
  MLTypography._();

  // ─── Font Families ────────────────────────────────────────────────────────
  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilyMono = 'Courier';
  static const String fontFamilyDotMatrix = 'NothingDotMatrix';

  // ─── Typography Scale ─────────────────────────────────────────────────────

  /// Display XL (48sp, Bold, letterSpacing -1.0)
  static const TextStyle displayXL = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 48.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.0,
  );

  /// Display Large (36sp, Bold, letterSpacing -0.8)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.8,
  );

  /// Display Medium (32sp, Bold, letterSpacing -0.5)
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  /// Display Small (28sp, Bold, letterSpacing -0.4)
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.4,
  );

  /// Hero Amount (44sp, Bold, tabularFigures, letterSpacing -1.0)
  static const TextStyle heroAmount = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 44.0,
    fontWeight: FontWeight.bold,
    letterSpacing: -1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Hero Balance (36sp, Semi-Bold, tabularFigures, letterSpacing -0.8)
  static const TextStyle heroBalance = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Heading XL (24sp, Semi-Bold, letterSpacing -0.2)
  static const TextStyle headingXL = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// Heading Large (20sp, Semi-Bold, letterSpacing -0.1)
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// Heading Medium (18sp, Semi-Bold)
  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
  );

  /// Title Large (16sp, Bold)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  /// Title Medium (16sp, Medium)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  /// Title Small (14sp, Medium)
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  /// Body Large (16sp, Regular)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );

  /// Body Medium (14sp, Regular)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
  );

  /// Body Small (12sp, Regular)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
  );

  /// Caption (11sp, Regular)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 11.0,
    fontWeight: FontWeight.normal,
  );

  /// Tiny (9sp, Regular)
  static const TextStyle tiny = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 9.0,
    fontWeight: FontWeight.normal,
  );

  /// Dot Label (11sp, Bold, NothingDotMatrix / Courier, letterSpacing 2.0)
  static const TextStyle dotLabel = TextStyle(
    fontFamily: fontFamilyDotMatrix,
    fontSize: 11.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
  );

  /// Dot Caption (9sp, Bold, NothingDotMatrix / Courier, letterSpacing 1.5)
  static const TextStyle dotCaption = TextStyle(
    fontFamily: fontFamilyDotMatrix,
    fontSize: 9.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  /// Mono Small (10sp, Regular, Courier, letterSpacing 0.0)
  static const TextStyle monoSmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
  );

  /// Mono Label (12sp, Bold, Courier, letterSpacing 1.0)
  static const TextStyle monoLabel = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  // ─── Semantic Role Tokens ─────────────────────────────────────────────────

  /// Money Large (24sp, Bold, tabularFigures)
  static const TextStyle moneyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Money Medium (18sp, Semi-Bold, tabularFigures)
  static const TextStyle moneyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Money Small (14sp, Semi-Bold, tabularFigures)
  static const TextStyle moneySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Money Decimal (12sp, Medium, tabularFigures)
  static const TextStyle moneyDecimal = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Chart Value (12sp, Semi-Bold, tabularFigures)
  static const TextStyle chartValue = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Chart Axis (10sp, Medium, tabularFigures)
  static const TextStyle chartAxis = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Button Label (14sp, Semi-Bold, letterSpacing 0.5)
  static const TextStyle button = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Input Text (16sp, Regular)
  static const TextStyle input = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );

  /// Dialog Content Text (16sp, Semi-Bold)
  static const TextStyle dialog = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );

  /// Bottom Sheet Header (18sp, Semi-Bold)
  static const TextStyle bottomSheet = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
  );

  /// SnackBar Body (14sp, Medium)
  static const TextStyle snackBar = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  /// Badge text (10sp, Bold)
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 10.0,
    fontWeight: FontWeight.bold,
  );

  /// Chip Text (12sp, Medium)
  static const TextStyle chip = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
  );

  /// Table Text (13sp, Regular)
  static const TextStyle table = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
  );

  /// Helper to map Dot Matrix styles with standard Courier fallbacks
  /// if the custom Nothing font is not bundled.
  static TextStyle getDotMatrixStyle(TextStyle base) {
    return base.copyWith(fontFamilyFallback: const [fontFamilyMono]);
  }
}
