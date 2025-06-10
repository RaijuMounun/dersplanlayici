import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Uygulamada kullanılan liste öğesi widget'ı.
class AppListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool hasBorder;
  final bool hasRoundedCorners;
  final EdgeInsetsGeometry? contentPadding;

  const AppListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.hasBorder = true,
    this.hasRoundedCorners = true,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPadding =
        contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        );

    final borderRadius = hasRoundedCorners
        ? BorderRadius.circular(AppDimensions.radius8)
        : null;

    final border = hasBorder
        ? Border.all(color: AppColors.border, width: 1)
        : null;

    final backgroundColor = selected
        ? AppColors.primary.withAlpha(20)
        : theme.cardColor;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing4,
        horizontal: AppDimensions.spacing16,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: border,
          ),
          child: Padding(
            padding: defaultPadding,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: AppDimensions.spacing12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppDimensions.spacing4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: AppDimensions.spacing12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
