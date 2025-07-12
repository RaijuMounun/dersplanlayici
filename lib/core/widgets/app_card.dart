import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Uygulamada kullanılan standart kart widget'ı.
class AppCard extends StatelessWidget {

  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.borderSide,
    this.hasShadow = true,
    this.boxShadow,
  });
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final BorderSide? borderSide;
  final bool hasShadow;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.cardColor;

    final defaultBorderRadius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radius12);

    final defaultPadding =
        padding ?? const EdgeInsets.all(AppDimensions.spacing16);

    final defaultMargin =
        margin ??
        const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing8,
          horizontal: AppDimensions.spacing16,
        );

    final defaultBoxShadow =
        boxShadow ??
        (hasShadow
            ? [
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : []);

    final card = Container(
      padding: defaultPadding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: defaultBorderRadius,
        border: borderSide != null ? Border.fromBorderSide(borderSide!) : null,
        boxShadow: defaultBoxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: defaultMargin,
        child: InkWell(
          onTap: onTap,
          borderRadius: defaultBorderRadius,
          child: card,
        ),
      );
    }

    return Container(margin: defaultMargin, child: card);
  }
}
