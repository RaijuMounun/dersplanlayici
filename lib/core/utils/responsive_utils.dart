import 'package:flutter/material.dart';

/// Farklı ekran boyutları için responsive tasarım yardımcısı.
class ResponsiveUtils {
  /// Ekran genişliğine göre cihaz türünü belirler
  static DeviceType getDeviceType(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Ekran yönünü belirler
  static Orientation getOrientation(BuildContext context) => MediaQuery.of(context).orientation;

  /// Cihaz türüne göre değer döndürür
  static T deviceValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final DeviceType deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Ekran yönüne göre değer döndürür
  static T orientationValue<T>({
    required BuildContext context,
    required T portrait,
    required T landscape,
  }) {
    final Orientation orientation = getOrientation(context);

    return orientation == Orientation.portrait ? portrait : landscape;
  }

  /// Ekran genişliğine göre responsive değer döndürür
  static double responsiveWidth(BuildContext context, double percentage) => MediaQuery.of(context).size.width * percentage;

  /// Ekran yüksekliğine göre responsive değer döndürür
  static double responsiveHeight(BuildContext context, double percentage) => MediaQuery.of(context).size.height * percentage;

  /// Ekranın kısa kenarına göre responsive değer döndürür
  static double responsiveSize(BuildContext context, double percentage) => MediaQuery.of(context).size.shortestSide * percentage;

  /// Ekranın genişliğine göre responsive font boyutu döndürür
  static double responsiveFontSize(BuildContext context, double size) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    // Baz genişlik (referans ekran genişliği)
    const double baseWidth = 375.0; // iPhone 8 genişliği

    // Min ve max font boyutları
    final double minSize = size * 0.8;
    final double maxSize = size * 1.2;

    // Ekran genişliğine göre font boyutu hesapla
    final double calculatedSize = size * (deviceWidth / baseWidth);

    // Font boyutunu sınırla
    return calculatedSize.clamp(minSize, maxSize);
  }

  /// Ekranın güvenli alanını döndürür
  static EdgeInsets safeAreaInsets(BuildContext context) => MediaQuery.of(context).padding;

  /// Güvenli alan olmadan kullanılabilir ekran boyutunu döndürür
  static Size safeScreenSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final screenSize = mediaQuery.size;

    return Size(
      screenSize.width,
      screenSize.height - padding.top - padding.bottom,
    );
  }

  /// Ekran büyüklüğüne göre grid sütun sayısını belirler
  static int getGridColumnCount(BuildContext context) {
    final deviceType = getDeviceType(context);
    final orientation = getOrientation(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return orientation == Orientation.portrait ? 2 : 3;
      case DeviceType.tablet:
        return orientation == Orientation.portrait ? 3 : 4;
      case DeviceType.desktop:
        return 5;
    }
  }
}

/// Cihaz türleri
enum DeviceType { mobile, tablet, desktop }
