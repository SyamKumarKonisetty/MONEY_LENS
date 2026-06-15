import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MoneyLens typography system.
///
/// Font family: Inter (Google Fonts)
/// Inspired by Apple Human Interface Guidelines typography scale.
///
/// Usage: Apply [AppTypography.textTheme] to [ThemeData.textTheme].
/// Access individual styles via [AppTypography.displayLarge], etc.
class AppTypography {
  AppTypography._();

  // ─── Font family ──────────────────────────────────────────────────────────
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  // ─── Light theme text styles ──────────────────────────────────────────────

  /// 34sp Bold — hero numbers, balance displays
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );

  /// 28sp SemiBold — large dashboard numbers
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );

  /// 22sp SemiBold — screen titles, section headings
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );

  /// 17sp SemiBold — card headers, nav titles
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  /// 15sp SemiBold — list tile titles, tab labels
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  /// 13sp Medium — small titles, chip labels
  static TextStyle get titleSmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  /// 17sp Regular — primary body content
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimaryLight,
  );

  /// 15sp Regular — secondary body, descriptions
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textPrimaryLight,
  );

  /// 13sp Regular — tertiary text, metadata
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textSecondaryLight,
  );

  /// 13sp Medium — button labels, tags
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  /// 12sp Medium — standard labels, minor elements
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  /// 11sp Regular — captions, footnotes, nav labels
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
    color: AppColors.textSecondaryLight,
  );

  // ─── Semantic aliases ─────────────────────────────────────────────────────
  static TextStyle get caption => labelSmall;
  static TextStyle get balanceHero => displayLarge;
  static TextStyle get sectionTitle => titleLarge;
  static TextStyle get navLabel => labelSmall;

  // ─── Full text theme ──────────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.3,
    ),
    headlineLarge: headlineLarge,
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      height: 1.4,
    ),
    labelSmall: labelSmall,
  );
}
