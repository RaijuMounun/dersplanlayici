import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_list_item.dart';
import 'package:intl/intl.dart';

/// Ders listesi öğesi widget'ı.
class LessonListItem extends StatelessWidget {
  final String lessonTitle;
  final String? studentName;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final double? fee;
  final bool isRecurring;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onMarkCompleted;

  const LessonListItem({
    Key? key,
    required this.lessonTitle,
    this.studentName,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.fee,
    this.isRecurring = false,
    this.onTap,
    this.onEditPressed,
    this.onDeletePressed,
    this.onMarkCompleted,
  }) : super(key: key);

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
                  child: Icon(
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
      leading: leadingIcon,
      trailing: _buildTrailing(statusColor),
      onTap: onTap,
      selected: isCompleted,
    );
  }

  Widget _buildTrailing(Color statusColor) {
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
        SizedBox(width: AppDimensions.spacing8),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
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
            if (!isCompleted)
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
