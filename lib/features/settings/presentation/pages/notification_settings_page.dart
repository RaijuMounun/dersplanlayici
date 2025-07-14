import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_card.dart';
import 'package:ders_planlayici/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Bildirim Ayarları')),
    body: ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        _buildSection(
          title: 'Ders Hatırlatmaları',
          children: [
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) {
                if (settingsProvider.isLoading) {
                  return const ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: AppColors.primary,
                    ),
                    title: Text('Ders Hatırlatmaları'),
                    trailing: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                  ),
                  title: const Text('Ders Hatırlatmaları'),
                  subtitle: const Text('Ders başlamadan önce bildirim al'),
                  value: settingsProvider.lessonRemindersEnabled,
                  onChanged: (bool value) {
                    settingsProvider.updateLessonRemindersEnabled(value);
                  },
                );
              },
            ),
            const Divider(height: 1),
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) {
                if (!settingsProvider.lessonRemindersEnabled) {
                  return const ListTile(
                    leading: Icon(Icons.timer, color: AppColors.primary),
                    title: Text('Hatırlatma Süresi'),
                    subtitle: Text('15 dakika önce'),
                    enabled: false,
                  );
                }

                return ListTile(
                  leading: const Icon(Icons.timer, color: AppColors.primary),
                  title: const Text('Hatırlatma Süresi'),
                  subtitle: Text(
                    '${settingsProvider.reminderMinutes} dakika önce',
                  ),
                  trailing: DropdownButton<int>(
                    value: settingsProvider.reminderMinutes,
                    underline: const SizedBox(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        settingsProvider.updateReminderMinutes(newValue);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 dk')),
                      DropdownMenuItem(value: 10, child: Text('10 dk')),
                      DropdownMenuItem(value: 15, child: Text('15 dk')),
                      DropdownMenuItem(value: 30, child: Text('30 dk')),
                      DropdownMenuItem(value: 60, child: Text('1 saat')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing16),
        _buildSection(
          title: 'Diğer Bildirimler',
          children: [
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) => SwitchListTile(
                  secondary: const Icon(
                    Icons.payment,
                    color: AppColors.primary,
                  ),
                  title: const Text('Ödeme Hatırlatmaları'),
                  subtitle: const Text('Gecikmiş ödemeler için bildirim al'),
                  value: settingsProvider.paymentRemindersEnabled,
                  onChanged: (bool value) {
                    settingsProvider.updatePaymentRemindersEnabled(value);
                  },
                ),
            ),
            const Divider(height: 1),
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) => SwitchListTile(
                  secondary: const Icon(Icons.school, color: AppColors.primary),
                  title: const Text('Öğrenci Doğum Günü'),
                  subtitle: const Text('Öğrenci doğum günlerinde bildirim al'),
                  value: settingsProvider.birthdayRemindersEnabled,
                  onChanged: (bool value) {
                    settingsProvider.updateBirthdayRemindersEnabled(value);
                  },
                ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing8,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: children),
      ),
    ],
  );
}
