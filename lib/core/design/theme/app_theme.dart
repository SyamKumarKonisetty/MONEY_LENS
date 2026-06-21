import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors/app_colors.dart';
import '../typography/app_typography.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';

/// AppTheme definition for MoneyLens V2, implementing light/dark ColorScheme and component styles.
class AppTheme {
  AppTheme._();

  static ThemeData get standardTheme {
    final colorScheme = const ColorScheme.dark().copyWith(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.primary.withValues(alpha: 0.15),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryLight,
      onSecondary: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.divider,
      outlineVariant: AppColors.divider.withValues(alpha: 0.5),
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.midnightSapphire,
      textTheme: AppTypography.textTheme,
      cardColor: AppColors.surface1,
      dividerColor: AppColors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headline,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size.fromHeight(52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.small,
          borderSide: BorderSide(color: AppColors.divider, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.small,
          borderSide: BorderSide(color: AppColors.divider, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.small,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: AppTypography.body.copyWith(
          color: AppColors.textHint,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: AppTypography.body.copyWith(
          color: AppColors.textPrimary,
        ),
        side: BorderSide(color: AppColors.divider, width: 1.0),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
        space: 0,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: AppTypography.caption,
        tileColor: Colors.transparent,
        selectedColor: AppColors.primary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
