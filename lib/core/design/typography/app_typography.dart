import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors/app_colors.dart';

/// Centralized typography system for MoneyLens V2, utilizing Google Fonts (Outfit).
class AppTypography {
  AppTypography._();

  static String get fontFamily => GoogleFonts.outfit().fontFamily ?? 'Outfit';

  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get headline => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get title => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitle => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.4,
        color: AppColors.textHint,
      );

  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headline,
        titleLarge: title,
        titleMedium: subtitle,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button,
      );

  // Backward compatibility mappings (matching old system)
  static TextStyle get headlineLarge => headline;
  static TextStyle get titleLarge => title;
  static TextStyle get titleMedium => subtitle;
  static TextStyle get titleSmall => subtitle.copyWith(fontSize: 13);
  static TextStyle get bodyLarge => body.copyWith(fontSize: 17);
  static TextStyle get bodyMedium => body;
  static TextStyle get bodySmall => caption.copyWith(fontSize: 13);
  static TextStyle get labelLarge => button.copyWith(fontSize: 13);
  static TextStyle get labelMedium => button.copyWith(fontSize: 12);
  static TextStyle get labelSmall => caption.copyWith(fontSize: 11);
  static TextStyle get navLabel => labelSmall;
}
