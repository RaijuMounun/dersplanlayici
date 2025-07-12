import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Uygulama alt gezinme çubuğu widget'ı.
class AppBottomNavigation extends StatelessWidget {

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.elevation,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize = 24,
    this.showLabels = true,
  });
  final int currentIndex;
  final Function(int) onTap;
  final List<AppBottomNavigationItem> items;
  final double? elevation;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double iconSize;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor =
        backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor;
    final defaultSelectedItemColor =
        selectedItemColor ?? theme.bottomNavigationBarTheme.selectedItemColor;
    final defaultUnselectedItemColor =
        unselectedItemColor ??
        theme.bottomNavigationBarTheme.unselectedItemColor;

    return Container(
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: elevation ?? 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing8,
            vertical: AppDimensions.spacing4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavigationItem(
                context,
                items[index],
                index == currentIndex,
                defaultSelectedItemColor ?? AppColors.primary,
                defaultUnselectedItemColor ?? AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    AppBottomNavigationItem item,
    bool isSelected,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final color = isSelected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: () => onTap(items.indexOf(item)),
      borderRadius: BorderRadius.circular(AppDimensions.radius8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: iconSize),
            if (showLabels) ...[
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Alt gezinme çubuğu öğe bilgilerini içeren sınıf.
class AppBottomNavigationItem {

  const AppBottomNavigationItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
  final String label;
  final IconData icon;
  final IconData? activeIcon;
}
