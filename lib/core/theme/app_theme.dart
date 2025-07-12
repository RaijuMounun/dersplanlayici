import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_typography.dart';

/// Uygulama temalarını içeren sınıf
class AppTheme {
  AppTheme._(); // Private constructor

  /// Açık tema
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardColor: AppColors.surface,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.headlineLarge,
      displayMedium: AppTypography.headlineMedium,
      displaySmall: AppTypography.headlineSmall,
      headlineLarge: AppTypography.titleLarge,
      headlineMedium: AppTypography.titleMedium,
      headlineSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  /// Koyu tema
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardColor: AppColors.surfaceDark,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.withColor(
        AppTypography.headlineLarge,
        AppColors.textLight,
      ),
      displayMedium: AppTypography.withColor(
        AppTypography.headlineMedium,
        AppColors.textLight,
      ),
      displaySmall: AppTypography.withColor(
        AppTypography.headlineSmall,
        AppColors.textLight,
      ),
      headlineLarge: AppTypography.withColor(
        AppTypography.titleLarge,
        AppColors.textLight,
      ),
      headlineMedium: AppTypography.withColor(
        AppTypography.titleMedium,
        AppColors.textLight,
      ),
      headlineSmall: AppTypography.withColor(
        AppTypography.titleSmall,
        AppColors.textLight,
      ),
      bodyLarge: AppTypography.withColor(
        AppTypography.bodyLarge,
        AppColors.textLight,
      ),
      bodyMedium: AppTypography.withColor(
        AppTypography.bodyMedium,
        AppColors.textLight,
      ),
      bodySmall: AppTypography.withColor(
        AppTypography.bodySmall,
        AppColors.textLight,
      ),
      labelLarge: AppTypography.withColor(
        AppTypography.labelLarge,
        AppColors.textLight,
      ),
      labelMedium: AppTypography.withColor(
        AppTypography.labelMedium,
        AppColors.textLight,
      ),
      labelSmall: AppTypography.withColor(
        AppTypography.labelSmall,
        AppColors.textLight,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight.withAlpha(178),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  /// Tema modunu algılar ve uygun temayı döndürür
  static ThemeData resolveTheme(ThemeMode themeMode, BuildContext context) {
    switch (themeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.light ? lightTheme : darkTheme;
    }
  }
}
