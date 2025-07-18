import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_list_item.dart';
import 'package:intl/intl.dart';

/// Ders listesi öğesi widget'ı.
class LessonListItem extends StatelessWidget {

  const LessonListItem({
    super.key,
    required this.lessonTitle,
    this.studentName,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.fee,
    this.isRecurring = false,
    this.isSelected = false,
    this.onTap,
    this.onEditPressed,
    this.onDeletePressed,
    this.onMarkCompleted,
  });
  final String lessonTitle;
  final String? studentName;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final double? fee;
  final bool isRecurring;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onMarkCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format time
    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('dd MMMM yyyy');

    String timeText = '';
    if (startTime != null) {
      timeText = timeFormatter.format(startTime!);
      if (endTime != null) {
        timeText += ' - ${timeFormatter.format(endTime!)}';
      }
    }

    String dateText = '';
    if (startTime != null) {
      dateText = dateFormatter.format(startTime!);
    }

    final statusColor = isCompleted ? AppColors.success : AppColors.primary;

    // Icons
    final Widget leadingIcon = isRecurring
        ? Stack(
            children: [
              Icon(
                Icons.event,
                color: statusColor,
                size: AppDimensions.iconSizeMedium,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.repeat,
                    color: AppColors.secondary,
                    size: AppDimensions.iconSizeSmall,
                  ),
                ),
              ),
            ],
          )
        : Icon(
            Icons.event,
            color: statusColor,
            size: AppDimensions.iconSizeMedium,
          );

    return AppListItem(
      title: lessonTitle,
      subtitle: studentName != null
          ? '$studentName\n$dateText $timeText'
          : '$dateText $timeText',
      leading: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : leadingIcon,
      trailing: _buildTrailing(statusColor),
      onTap: onTap,
      selected: isSelected || isCompleted,
      backgroundColor: isSelected ? AppColors.primary.withAlpha(40) : null,
    );
  }

  Widget _buildTrailing(Color statusColor) {
    if (isSelected) {
      return const SizedBox.shrink(); // Seçim modunda trailing gösterme
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (fee != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing8,
              vertical: AppDimensions.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(30),
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
            ),
            child: Text(
              '${fee!.toStringAsFixed(2)} ₺',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
        const SizedBox(width: AppDimensions.spacing8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEditPressed?.call();
                break;
              case 'delete':
                onDeletePressed?.call();
                break;
              case 'complete':
                onMarkCompleted?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isCompleted && onMarkCompleted != null)
              const PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: AppDimensions.spacing8),
                    Text('Tamamlandı'),
                  ],
                ),
              ),
            if (onEditPressed != null)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: AppDimensions.spacing8),
                    Text('Düzenle'),
                  ],
                ),
              ),
            if (onDeletePressed != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: AppDimensions.spacing8),
                    Text('Sil'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
