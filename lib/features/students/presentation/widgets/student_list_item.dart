import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/widgets/app_list_item.dart';

class StudentListItem extends StatelessWidget {
  final String name;
  final String grade;
  final List<String>? subjects;
  final VoidCallback onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final bool isSelected;

  const StudentListItem({
    super.key,
    required this.name,
    required this.grade,
    this.subjects,
    required this.onTap,
    this.onEditPressed,
    this.onDeletePressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppListItem(
      title: name,
      subtitle: _buildSubtitle(),
      leading: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
      trailing: _buildTrailing(),
      onTap: onTap,
      selected: isSelected,
      backgroundColor: isSelected ? AppColors.primary.withAlpha(40) : null,
    );
  }

  String _buildSubtitle() {
    String subtitle = grade;

    if (subjects != null && subjects!.isNotEmpty) {
      final subjectsText = subjects!.length > 3
          ? '${subjects!.take(3).join(', ')}...'
          : subjects!.join(', ');
      subtitle += '\n$subjectsText';
    }

    return subtitle;
  }

  Widget _buildTrailing() {
    if (isSelected) {
      return const SizedBox.shrink(); // Seçim modunda trailing gösterme
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEditPressed != null)
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.textSecondary),
            onPressed: onEditPressed,
            tooltip: 'Düzenle',
          ),
        if (onDeletePressed != null)
          IconButton(
            icon: Icon(Icons.delete, color: AppColors.error),
            onPressed: onDeletePressed,
            tooltip: 'Sil',
          ),
      ],
    );
  }
}
