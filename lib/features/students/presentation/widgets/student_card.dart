import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_card.dart';

/// Öğrenci bilgilerini gösteren kart widget'ı.
class StudentCard extends StatelessWidget {

  const StudentCard({
    super.key,
    required this.studentName,
    this.studentGrade,
    this.phoneNumber,
    this.email,
    this.totalLessons,
    this.totalFee,
    this.onTap,
    this.onEditPressed,
    this.onDeletePressed,
    this.avatarUrl,
    this.avatarBackgroundColor,
  });
  final String studentName;
  final String? studentGrade;
  final String? phoneNumber;
  final String? email;
  final int? totalLessons;
  final double? totalFee;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final String? avatarUrl;
  final Color? avatarBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials(studentName);

    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: AppDimensions.avatarSizeMedium,
                height: AppDimensions.avatarSizeMedium,
                decoration: BoxDecoration(
                  color: avatarBackgroundColor ?? AppColors.primary,
                  shape: BoxShape.circle,
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null
                    ? Center(
                        child: Text(
                          initials,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.spacing16),

              // İsim ve Sınıf
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (studentGrade != null) ...[
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        studentGrade!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Düzenle/Sil butonları
              Row(
                children: [
                  if (onEditPressed != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: onEditPressed,
                      tooltip: 'Düzenle',
                      constraints: BoxConstraints.tight(
                        const Size(
                          AppDimensions.iconSizeMedium,
                          AppDimensions.iconSizeMedium,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                    ),
                  if (onDeletePressed != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: onDeletePressed,
                      tooltip: 'Sil',
                      constraints: BoxConstraints.tight(
                        const Size(
                          AppDimensions.iconSizeMedium,
                          AppDimensions.iconSizeMedium,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing16),

          // İletişim bilgileri
          if (phoneNumber != null || email != null) ...[
            Row(
              children: [
                if (phoneNumber != null) ...[
                  const Icon(
                    Icons.phone,
                    size: AppDimensions.iconSizeSmall,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Text(phoneNumber!, style: theme.textTheme.bodyMedium),
                  const SizedBox(width: AppDimensions.spacing16),
                ],
                if (email != null) ...[
                  const Icon(
                    Icons.email,
                    size: AppDimensions.iconSizeSmall,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Expanded(
                    child: Text(
                      email!,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.spacing12),
          ],

          // Ders ve ücret bilgisi
          if (totalLessons != null || totalFee != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (totalLessons != null)
                  _buildInfoItem(
                    context,
                    Icons.book,
                    '$totalLessons Ders',
                    AppColors.primary,
                  ),
                if (totalFee != null)
                  _buildInfoItem(
                    context,
                    Icons.attach_money,
                    '${totalFee!.toStringAsFixed(2)} ₺',
                    AppColors.secondary,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppDimensions.spacing4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'
        .toUpperCase();
  }
}
