import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';

/// Uygulama genelinde kullanılan widget stillerini içeren sınıf.
class AppStyles {
  AppStyles._(); // Private constructor

  // Kart stilleri
  static CardTheme get cardTheme => CardTheme(
    elevation: AppDimensions.elevation2,
    shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadius12),
    margin: const EdgeInsets.symmetric(
      vertical: AppDimensions.spacing8,
      horizontal: AppDimensions.spacing16,
    ),
    color: AppColors.surface,
  );

  static CardTheme get darkCardTheme =>
      cardTheme.copyWith(color: AppColors.surfaceDark);

  // AppBar stilleri
  static AppBarTheme get appBarTheme => AppBarTheme(
    elevation: AppDimensions.elevation0,
    centerTitle: true,
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textLight,
    iconTheme: IconThemeData(color: AppColors.textLight),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textLight,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(AppDimensions.radius16),
      ),
    ),
  );

  static AppBarTheme get darkAppBarTheme =>
      appBarTheme.copyWith(backgroundColor: AppColors.primaryDark);

  // Button stilleri
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primary.withAlpha(128);
            }
            return AppColors.primary;
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.textLight),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppDimensions.borderRadius8),
          ),
          elevation: WidgetStateProperty.all(AppDimensions.elevation2),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              vertical: AppDimensions.spacing12,
              horizontal: AppDimensions.spacing24,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );

  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          side: WidgetStateProperty.all(
            BorderSide(
              color: AppColors.primary,
              width: AppDimensions.borderWidth1,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppDimensions.borderRadius8),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              vertical: AppDimensions.spacing12,
              horizontal: AppDimensions.spacing24,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.primary),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: AppDimensions.borderRadius8),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing8,
          horizontal: AppDimensions.spacing16,
        ),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );

  // Input stilleri
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      vertical: AppDimensions.spacing16,
      horizontal: AppDimensions.spacing16,
    ),
    border: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadius8,
      borderSide: BorderSide(
        color: AppColors.border,
        width: AppDimensions.borderWidth1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadius8,
      borderSide: BorderSide(
        color: AppColors.border,
        width: AppDimensions.borderWidth1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadius8,
      borderSide: BorderSide(
        color: AppColors.primary,
        width: AppDimensions.borderWidth2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadius8,
      borderSide: BorderSide(
        color: AppColors.error,
        width: AppDimensions.borderWidth1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppDimensions.borderRadius8,
      borderSide: BorderSide(
        color: AppColors.error,
        width: AppDimensions.borderWidth2,
      ),
    ),
    hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16),
    labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 16),
    errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
  );

  static InputDecorationTheme get darkInputDecorationTheme =>
      inputDecorationTheme.copyWith(
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadius8,
          borderSide: BorderSide(
            color: AppColors.borderDark,
            width: AppDimensions.borderWidth1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadius8,
          borderSide: BorderSide(
            color: AppColors.borderDark,
            width: AppDimensions.borderWidth1,
          ),
        ),
      );

  // Bottom Navigation Bar stilleri
  static BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: AppDimensions.elevation8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      );

  static BottomNavigationBarThemeData get darkBottomNavigationBarTheme =>
      bottomNavigationBarTheme.copyWith(backgroundColor: AppColors.surfaceDark);

  // ListTile stilleri
  static ListTileThemeData get listTileTheme => ListTileThemeData(
    tileColor: AppColors.surface,
    selectedTileColor: AppColors.primary.withAlpha(26),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacing16,
      vertical: AppDimensions.spacing8,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadius8),
    dense: false,
    minLeadingWidth: 40,
    iconColor: AppColors.primary,
    textColor: AppColors.textPrimary,
  );

  static ListTileThemeData get darkListTileTheme => listTileTheme.copyWith(
    tileColor: AppColors.surfaceDark,
    textColor: AppColors.textLight,
  );

  // TabBar stilleri
  static TabBarTheme get tabBarTheme => TabBarTheme(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    indicatorColor: AppColors.primary,
    labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    unselectedLabelStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    indicatorSize: TabBarIndicatorSize.tab,
  );

  // Divider stilleri
  static DividerThemeData get dividerTheme => DividerThemeData(
    color: AppColors.divider,
    thickness: AppDimensions.borderWidth1,
    space: AppDimensions.spacing16,
  );

  static DividerThemeData get darkDividerTheme =>
      dividerTheme.copyWith(color: AppColors.dividerDark);
}
