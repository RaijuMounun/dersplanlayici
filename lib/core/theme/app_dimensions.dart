import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan boyutsal değerleri içeren sınıf.
class AppDimensions {
  AppDimensions._(); // Private constructor

  // Boşluk değerleri
  static const double spacing0 = 0;
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing56 = 56;
  static const double spacing64 = 64;
  static const double spacing80 = 80;
  static const double spacing96 = 96;
  static const double spacing128 = 128;

  // Yuvarlama (Radius) değerleri
  static const double radius0 = 0;
  static const double radius2 = 2;
  static const double radius4 = 4;
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;
  static const double radius32 = 32;
  static const double radiusCircular = 1000; // Tam daire için büyük değer

  // Border (Kenar) kalınlığı
  static const double borderWidth0 = 0;
  static const double borderWidth1 = 1;
  static const double borderWidth2 = 2;
  static const double borderWidth4 = 4;

  // Elevation (Yükseklik) değerleri
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation4 = 4;
  static const double elevation8 = 8;
  static const double elevation12 = 12;
  static const double elevation16 = 16;
  static const double elevation24 = 24;

  // Icon boyutları
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeExtraLarge = 48;

  // Avatar boyutları
  static const double avatarSizeSmall = 32;
  static const double avatarSizeMedium = 40;
  static const double avatarSizeLarge = 56;
  static const double avatarSizeExtraLarge = 80;

  // Button boyutları
  static const double buttonHeightSmall = 32;
  static const double buttonHeightMedium = 40;
  static const double buttonHeightLarge = 48;

  // Form alanları
  static const double inputHeight = 48;
  static const double inputHeightSmall = 40;
  static const double inputHeightLarge = 56;

  // Takvim ve liste öğeleri
  static const double listItemHeight = 64;
  static const double calendarDaySize = 40;
  static const double calendarEventHeight = 32;

  // Sabit aralıklarla boşluk oluşturmak için yardımcı widget'lar
  static SizedBox get verticalSpace4 => const SizedBox(height: spacing4);
  static SizedBox get verticalSpace8 => const SizedBox(height: spacing8);
  static SizedBox get verticalSpace12 => const SizedBox(height: spacing12);
  static SizedBox get verticalSpace16 => const SizedBox(height: spacing16);
  static SizedBox get verticalSpace24 => const SizedBox(height: spacing24);
  static SizedBox get verticalSpace32 => const SizedBox(height: spacing32);
  static SizedBox get verticalSpace48 => const SizedBox(height: spacing48);

  static SizedBox get horizontalSpace4 => const SizedBox(width: spacing4);
  static SizedBox get horizontalSpace8 => const SizedBox(width: spacing8);
  static SizedBox get horizontalSpace12 => const SizedBox(width: spacing12);
  static SizedBox get horizontalSpace16 => const SizedBox(width: spacing16);
  static SizedBox get horizontalSpace24 => const SizedBox(width: spacing24);
  static SizedBox get horizontalSpace32 => const SizedBox(width: spacing32);
  static SizedBox get horizontalSpace48 => const SizedBox(width: spacing48);

  // Önceden tanımlanmış kenar yuvarlamaları
  static BorderRadius get borderRadius2 => BorderRadius.circular(radius2);
  static BorderRadius get borderRadius4 => BorderRadius.circular(radius4);
  static BorderRadius get borderRadius8 => BorderRadius.circular(radius8);
  static BorderRadius get borderRadius12 => BorderRadius.circular(radius12);
  static BorderRadius get borderRadius16 => BorderRadius.circular(radius16);
  static BorderRadius get borderRadius24 => BorderRadius.circular(radius24);
  static BorderRadius get borderRadiusCircular =>
      BorderRadius.circular(radiusCircular);

  // Önceden tanımlanmış padding değerleri
  static EdgeInsetsGeometry get padding4 => const EdgeInsets.all(spacing4);
  static EdgeInsetsGeometry get padding8 => const EdgeInsets.all(spacing8);
  static EdgeInsetsGeometry get padding12 => const EdgeInsets.all(spacing12);
  static EdgeInsetsGeometry get padding16 => const EdgeInsets.all(spacing16);
  static EdgeInsetsGeometry get padding24 => const EdgeInsets.all(spacing24);
  static EdgeInsetsGeometry get padding32 => const EdgeInsets.all(spacing32);

  static EdgeInsetsGeometry get paddingH8 =>
      const EdgeInsets.symmetric(horizontal: spacing8);
  static EdgeInsetsGeometry get paddingH16 =>
      const EdgeInsets.symmetric(horizontal: spacing16);
  static EdgeInsetsGeometry get paddingH24 =>
      const EdgeInsets.symmetric(horizontal: spacing24);

  static EdgeInsetsGeometry get paddingV8 =>
      const EdgeInsets.symmetric(vertical: spacing8);
  static EdgeInsetsGeometry get paddingV16 =>
      const EdgeInsets.symmetric(vertical: spacing16);
  static EdgeInsetsGeometry get paddingV24 =>
      const EdgeInsets.symmetric(vertical: spacing24);
}
