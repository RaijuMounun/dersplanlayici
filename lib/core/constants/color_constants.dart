import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk değerlerini içerir.
class ColorConstants {
  ColorConstants._();

  // Ana Renkler
  static const Color primaryColor = Color(0xFF6750A4); // Mor tonu
  static const Color primaryLight = Color(0xFFEADDFF);
  static const Color primaryDark = Color(0xFF381E72);

  static const Color secondaryColor = Color(0xFF625B71); // Mor-gri tonu
  static const Color secondaryLight = Color(0xFFE8DEF8);
  static const Color secondaryDark = Color(0xFF332D41);

  static const Color accentColor = Color(0xFF7D5260); // Bordo tonu
  static const Color accentLight = Color(0xFFFFD8E4);
  static const Color accentDark = Color(0xFF4A3036);

  // Fonksiyonel Renkler
  static const Color success = Color(0xFF4CAF50); // Yeşil
  static const Color error = Color(0xFFC62828); // Kırmızı
  static const Color warning = Color(0xFFFFA000); // Sarı
  static const Color info = Color(0xFF2196F3); // Mavi

  // Gri Tonları
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF9E9E9E);
  static const Color black = Color(0xFF1C1B1F);
  static const Color white = Color(0xFFFFFFFF);

  // Arka Plan Renkleri
  static const Color scaffoldBackground = Color(0xFFFFFBFE);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color dialogBackground = Color(0xFFFFFFFF);

  // Bileşen Renkleri
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x1A000000);
  static const Color overlayColor = Color(0x0A000000);

  // Takvim Renkleri
  static const Color todayColor = primaryLight;
  static const Color selectedDayColor = primaryColor;
  static const Color weekendColor = lightGrey;

  // Ders Durum Renkleri
  static const Color completedLessonColor = success;
  static const Color pendingLessonColor = warning;
  static const Color cancelledLessonColor = error;

  // Ücret Durum Renkleri
  static const Color paidFeeColor = success;
  static const Color unpaidFeeColor = error;

  // Gradyanlar
  static const List<Color> primaryGradient = [
    primaryLight,
    primaryColor,
    primaryDark,
  ];
}
