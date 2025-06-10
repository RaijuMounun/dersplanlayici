import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renkleri içeren sınıf.
class AppColors {
  AppColors._(); // Private constructor

  // Temel renkler
  static const Color primary = Color(0xFF2196F3); // Mavi
  static const Color primaryLight = Color(0xFF64B5F6); // Açık Mavi
  static const Color primaryDark = Color(0xFF1565C0); // Koyu Mavi

  static const Color secondary = Color(0xFF4CAF50); // Yeşil
  static const Color secondaryLight = Color(0xFF81C784); // Açık Yeşil
  static const Color secondaryDark = Color(0xFF2E7D32); // Koyu Yeşil

  static const Color accent = Color(0xFFFFC107); // Sarı/Amber
  static const Color accentLight = Color(0xFFFFD54F); // Açık Sarı
  static const Color accentDark = Color(0xFFFFB300); // Koyu Sarı

  // Metin renkleri
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Arkaplan renkleri
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color disabledBackground = Color(
    0xFFF0F0F0,
  ); // Devre dışı bırakılmış bileşenler için arka plan

  // Durum renkleri
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Takvim renkleri
  static const Color lesson = Color(0xFF4CAF50); // Yeşil - Ders
  static const Color exam = Color(0xFFF44336); // Kırmızı - Sınav
  static const Color holiday = Color(0xFF9C27B0); // Mor - Tatil
  static const Color appointment = Color(0xFF2196F3); // Mavi - Randevu
  static const Color other = Color(0xFF757575); // Gri - Diğer

  // Ders durumu renkleri
  static const Color scheduled = Color(0xFF4CAF50); // Yeşil - Planlandı
  static const Color completed = Color(0xFF2196F3); // Mavi - Tamamlandı
  static const Color cancelled = Color(0xFFF44336); // Kırmızı - İptal edildi
  static const Color postponed = Color(0xFFFF9800); // Turuncu - Ertelendi

  // Divider ve Kenar çizgisi
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color borderDark = Color(0xFF616161);

  // Diğer yardımcı renkler
  static const Color shadow = Color(0x33000000); // %20 opak siyah
  static const Color overlay = Color(0x99000000); // %60 opak siyah
  static const Color transparent = Color(0x00000000);

  // Materyal tasarım renk paleti
  static const MaterialColor primarySwatch =
      MaterialColor(0xFF2196F3, <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF2196F3),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      });

  // Form renkleri
  static Color get inputBackground => const Color(0xFFF5F5F5);
  static Color get formBorder => const Color(0xFFE0E0E0);
}
