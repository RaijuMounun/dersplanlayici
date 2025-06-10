import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan metin stillerini içeren sınıf.
class AppTypography {
  AppTypography._(); // Private constructor

  // Yazı tipi aileleri
  static const String primaryFontFamily = 'Roboto';
  static const String secondaryFontFamily = 'Poppins';

  // Yazı tipi ağırlıkları
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Başlık stilleri - Light Theme
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: -0.5,
    color: Color(0xFF212121),
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 28,
    fontWeight: bold,
    letterSpacing: -0.5,
    color: Color(0xFF212121),
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: bold,
    letterSpacing: 0,
    color: Color(0xFF212121),
  );

  // Alt başlık stilleri
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 22,
    fontWeight: semiBold,
    letterSpacing: 0,
    color: Color(0xFF212121),
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: 0.15,
    color: Color(0xFF212121),
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: medium,
    letterSpacing: 0.1,
    color: Color(0xFF212121),
  );

  // Metin gövdesi stilleri
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: regular,
    letterSpacing: 0.5,
    color: Color(0xFF212121),
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.25,
    color: Color(0xFF212121),
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    color: Color(0xFF757575),
  );

  // Etiket stilleri
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    color: Color(0xFF212121),
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: Color(0xFF212121),
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: Color(0xFF616161),
  );

  // Düğme stilleri
  static TextStyle get buttonLarge => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: medium,
    letterSpacing: 0.5,
    color: Color(0xFFFFFFFF),
  );

  static TextStyle get buttonMedium => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.25,
    color: Color(0xFFFFFFFF),
  );

  static TextStyle get buttonSmall => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.4,
    color: Color(0xFFFFFFFF),
  );

  // Özel stiller
  static TextStyle get caption => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    color: Color(0xFF757575),
  );

  static TextStyle get overline => const TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 10,
    fontWeight: regular,
    letterSpacing: 1.5,
    color: Color(0xFF757575),
  );

  // Koyu tema için metin stillerini elde etmek için yardımcı metod
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
}
