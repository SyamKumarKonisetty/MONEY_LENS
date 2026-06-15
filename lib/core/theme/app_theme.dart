import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// MoneyLens theme system.
///
/// Provides [lightTheme] and [darkTheme] — both built on Material 3
/// with Apple-inspired color overrides and custom component themes.
/// No Material defaults leak through.
class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE1F0FF),
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE1F0FF),
      onSecondaryContainer: AppColors.primaryLight,
      tertiary: AppColors.successLight,
      onTertiary: Colors.white,
      error: AppColors.errorLight,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.separatorLight,
      outlineVariant: AppColors.separatorOpaqueLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      surfaceContainerHigh: AppColors.surfaceVariantLight,
      surfaceContainer: AppColors.surfaceVariantLight,
      surfaceContainerLow: AppColors.backgroundLight,
      surfaceContainerLowest: AppColors.backgroundLight,
      inverseSurface: AppColors.textPrimaryLight,
      onInverseSurface: AppColors.surfaceLight,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.textTheme,
      appBarTheme: _appBarTheme(colorScheme, Brightness.light),
      cardTheme: _cardTheme(colorScheme, Brightness.light),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(
        colorScheme,
        Brightness.light,
      ),
      chipTheme: _chipTheme(colorScheme, Brightness.light),
      dividerTheme: DividerThemeData(
        color: AppColors.separatorLight,
        thickness: 0.5,
        space: 0,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 24),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTypography.titleMedium,
        subtitleTextStyle: AppTypography.bodySmall,
        leadingAndTrailingTextStyle: AppTypography.bodySmall,
        tileColor: Colors.transparent,
        selectedColor: AppColors.primaryLight,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()},
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF003059),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primaryDark,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF003059),
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.successDark,
      onTertiary: Colors.black,
      error: AppColors.errorDark,
      onError: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.separatorDark,
      outlineVariant: AppColors.separatorOpaqueDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      surfaceContainerHigh: AppColors.surfaceVariantDark,
      surfaceContainer: AppColors.surfaceVariantDark,
      surfaceContainerLow: AppColors.backgroundDark,
      surfaceContainerLowest: AppColors.backgroundDark,
      inverseSurface: AppColors.textPrimaryDark,
      onInverseSurface: AppColors.surfaceDark,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      appBarTheme: _appBarTheme(colorScheme, Brightness.dark),
      cardTheme: _cardTheme(colorScheme, Brightness.dark),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme, Brightness.dark),
      chipTheme: _chipTheme(colorScheme, Brightness.dark),
      dividerTheme: DividerThemeData(
        color: AppColors.separatorDark,
        thickness: 0.5,
        space: 0,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimaryDark, size: 24),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        tileColor: Colors.transparent,
        selectedColor: AppColors.primaryDark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()},
      ),
    );
  }

  // ─── Component theme builders ─────────────────────────────────────────────

  static AppBarTheme _appBarTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.headlineLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  static CardThemeData _cardTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    return CardThemeData(
      color: brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        textStyle: AppTypography.titleMedium,
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularSm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    final fillColor = brightness == Brightness.dark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: AppRadius.circularXl,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.circularXl,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.circularXl,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
    );
  }

  static ChipThemeData _chipTheme(
    ColorScheme colorScheme,
    Brightness brightness,
  ) {
    final backgroundColor = brightness == Brightness.dark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;

    return ChipThemeData(
      backgroundColor: backgroundColor,
      selectedColor: colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: AppTypography.labelLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.circularFull),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );
  }

  // ─── System UI overlay ────────────────────────────────────────────────────

  static SystemUiOverlayStyle lightOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static SystemUiOverlayStyle darkOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
