import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light =>
      _build(brightness: Brightness.light, colors: AppColorScheme.light);
  static ThemeData get dark =>
      _build(brightness: Brightness.dark, colors: AppColorScheme.dark);

  static ThemeData _build({
    required Brightness brightness,
    required AppColorScheme colors,
  }) {
    final base =
        brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: colors.surfacePrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.goldPrimary,
        brightness: brightness,
        surface: colors.surfacePrimary,
      ).copyWith(
        primary: colors.goldPrimary,
        secondary: colors.navyDeep,
        error: colors.error,
        surface: colors.surfacePrimary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayXl.copyWith(color: colors.ink900),
        displayMedium: AppTypography.displayLg.copyWith(color: colors.ink900),
        displaySmall: AppTypography.displayMd.copyWith(color: colors.ink900),
        titleLarge: AppTypography.heading.copyWith(color: colors.ink900),
        bodyLarge: AppTypography.body.copyWith(color: colors.ink600),
        bodyMedium: AppTypography.body.copyWith(color: colors.ink600),
        labelLarge: AppTypography.label.copyWith(color: colors.ink900),
        labelSmall: AppTypography.caption.copyWith(color: colors.ink400),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfacePrimary,
        foregroundColor: colors.ink900,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surfaceCard,
        selectedItemColor: colors.goldPrimary,
        unselectedItemColor: colors.ink400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: colors.lineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: colors.goldPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        labelStyle: AppTypography.body.copyWith(color: colors.ink600),
        hintStyle: AppTypography.body.copyWith(color: colors.ink400),
        errorStyle: AppTypography.caption.copyWith(color: colors.error),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.goldPrimary,
          foregroundColor: AppColors.navyDeep,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.goldPrimary,
          textStyle: AppTypography.label,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.lineSoft,
        thickness: 1,
        space: 0,
      ),
      extensions: [colors],
    );
  }
}
