import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// Farklı ekran boyutları için responsive layout widget'ı.
/// Cihaz türüne göre farklı içerikler gösterir.
class ResponsiveLayout extends StatelessWidget {

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Ekran yönüne göre farklı içerikler gösteren widget.
class OrientationLayout extends StatelessWidget {

  const OrientationLayout({
    super.key,
    required this.portrait,
    required this.landscape,
  });
  final Widget portrait;
  final Widget landscape;

  @override
  Widget build(BuildContext context) => MediaQuery.of(context).orientation == Orientation.portrait
        ? portrait
        : landscape;
}

/// Ekran genişliğine göre içerik gösteren widget.
/// Belirtilen genişlik değerinden küçük ekranlarda mobile widget'ını gösterir.
class AdaptiveLayout extends StatelessWidget {

  const AdaptiveLayout({
    super.key,
    required this.mobile,
    required this.wider,
    this.breakpoint = 600,
  });
  final Widget mobile;
  final Widget wider;
  final double breakpoint;

  @override
  Widget build(BuildContext context) => MediaQuery.of(context).size.width < breakpoint ? mobile : wider;
}
