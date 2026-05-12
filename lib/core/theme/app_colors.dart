import 'package:flutter/material.dart';

abstract final class AppColors {
  // — Light surface —
  static const Color surfacePrimary = Color(0xFFFAF8F3);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceTertiary = Color(0xFFEFEDE6);

  // Gold — ONLY for: primary CTA, active tab underline, active nav icon,
  //        featured price, one premium badge per screen.
  static const Color goldPrimary = Color(0xFFC9A84C);
  static const Color goldAccent = Color(0xFFE8D08A);

  // — Ink (light mode) —
  static const Color ink900 = Color(0xFF1A1A1A);
  static const Color ink600 = Color(0xFF5E5E5E);
  static const Color ink400 = Color(0xFF9E9E9E);

  // — Accent (light mode) —
  static const Color navyDeep = Color(0xFF0D1B2A);
  static const Color lineSoft = Color(0xFFE8E5DC);

  // — Semantic (same in both modes) —
  static const Color success = Color(0xFF2D7A4F);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFC0392B);

  // — Dark surface —
  static const Color darkSurfacePrimary = Color(0xFF0D1117);
  static const Color darkSurfaceCard = Color(0xFF161B22);
  static const Color darkSurfaceTertiary = Color(0xFF21262D);

  // Gold brighter on dark backgrounds for contrast
  static const Color darkGoldPrimary = Color(0xFFD4AF37);
  static const Color darkGoldAccent = Color(0xFFE8D08A);

  // — Ink (dark mode) —
  static const Color darkInk900 = Color(0xFFF0F6FC);
  static const Color darkInk600 = Color(0xFF8B949E);
  static const Color darkInk400 = Color(0xFF484F58);

  // — Accent (dark mode) —
  static const Color darkNavyDeep = Color(0xFF0D1B2A);
  static const Color darkLineSoft = Color(0xFF30363D);
}

/// ThemeExtension so widgets resolve colors automatically for light/dark.
/// Access via: `Theme.of(context).extension<AppColorScheme>()!.goldPrimary`
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.surfacePrimary,
    required this.surfaceCard,
    required this.surfaceTertiary,
    required this.goldPrimary,
    required this.goldAccent,
    required this.ink900,
    required this.ink600,
    required this.ink400,
    required this.navyDeep,
    required this.lineSoft,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color surfacePrimary;
  final Color surfaceCard;
  final Color surfaceTertiary;
  final Color goldPrimary;
  final Color goldAccent;
  final Color ink900;
  final Color ink600;
  final Color ink400;
  final Color navyDeep;
  final Color lineSoft;
  final Color success;
  final Color warning;
  final Color error;

  static const light = AppColorScheme(
    surfacePrimary: AppColors.surfacePrimary,
    surfaceCard: AppColors.surfaceCard,
    surfaceTertiary: AppColors.surfaceTertiary,
    goldPrimary: AppColors.goldPrimary,
    goldAccent: AppColors.goldAccent,
    ink900: AppColors.ink900,
    ink600: AppColors.ink600,
    ink400: AppColors.ink400,
    navyDeep: AppColors.navyDeep,
    lineSoft: AppColors.lineSoft,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
  );

  static const dark = AppColorScheme(
    surfacePrimary: AppColors.darkSurfacePrimary,
    surfaceCard: AppColors.darkSurfaceCard,
    surfaceTertiary: AppColors.darkSurfaceTertiary,
    goldPrimary: AppColors.darkGoldPrimary,
    goldAccent: AppColors.darkGoldAccent,
    ink900: AppColors.darkInk900,
    ink600: AppColors.darkInk600,
    ink400: AppColors.darkInk400,
    navyDeep: AppColors.darkNavyDeep,
    lineSoft: AppColors.darkLineSoft,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
  );

  @override
  AppColorScheme copyWith({
    Color? surfacePrimary,
    Color? surfaceCard,
    Color? surfaceTertiary,
    Color? goldPrimary,
    Color? goldAccent,
    Color? ink900,
    Color? ink600,
    Color? ink400,
    Color? navyDeep,
    Color? lineSoft,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColorScheme(
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      goldPrimary: goldPrimary ?? this.goldPrimary,
      goldAccent: goldAccent ?? this.goldAccent,
      ink900: ink900 ?? this.ink900,
      ink600: ink600 ?? this.ink600,
      ink400: ink400 ?? this.ink400,
      navyDeep: navyDeep ?? this.navyDeep,
      lineSoft: lineSoft ?? this.lineSoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      goldPrimary: Color.lerp(goldPrimary, other.goldPrimary, t)!,
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      ink900: Color.lerp(ink900, other.ink900, t)!,
      ink600: Color.lerp(ink600, other.ink600, t)!,
      ink400: Color.lerp(ink400, other.ink400, t)!,
      navyDeep: Color.lerp(navyDeep, other.navyDeep, t)!,
      lineSoft: Color.lerp(lineSoft, other.lineSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
