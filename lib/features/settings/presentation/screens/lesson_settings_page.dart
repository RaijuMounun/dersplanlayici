import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_card.dart';
import 'package:ders_planlayici/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:provider/provider.dart';

class LessonSettingsPage extends StatelessWidget {
  const LessonSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ders Ayarları')),
    body: ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        _buildSection(
          title: 'Varsayılan Ayarlar',
          children: [
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) {
                if (settingsProvider.isLoading) {
                  return const ListTile(
                    leading: Icon(Icons.timer, color: AppColors.primary),
                    title: Text('Varsayılan Ders Süresi'),
                    trailing: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return ListTile(
                  leading: const Icon(Icons.timer, color: AppColors.primary),
                  title: const Text('Varsayılan Ders Süresi'),
                  subtitle: Text(
                    '${settingsProvider.settings.defaultLessonDuration} dakika',
                  ),
                  trailing: DropdownButton<int>(
                    value: settingsProvider.settings.defaultLessonDuration,
                    underline: const SizedBox(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        settingsProvider.updateDefaultLessonDuration(newValue);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('30 dk')),
                      DropdownMenuItem(value: 45, child: Text('45 dk')),
                      DropdownMenuItem(value: 60, child: Text('60 dk')),
                      DropdownMenuItem(value: 90, child: Text('90 dk')),
                      DropdownMenuItem(value: 120, child: Text('120 dk')),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 1),
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) {
                if (settingsProvider.isLoading) {
                  return const ListTile(
                    leading: Icon(Icons.attach_money, color: AppColors.primary),
                    title: Text('Varsayılan Ders Ücreti'),
                    trailing: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return ListTile(
                  leading: const Icon(
                    Icons.attach_money,
                    color: AppColors.primary,
                  ),
                  title: const Text('Varsayılan Ders Ücreti'),
                  subtitle: Text(
                    '${settingsProvider.settings.defaultLessonFee} ${settingsProvider.settings.currency}',
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      controller: TextEditingController(
                        text: settingsProvider.settings.defaultLessonFee
                            .toString(),
                      ),
                      onSubmitted: (value) {
                        final fee = double.tryParse(value);
                        if (fee != null) {
                          settingsProvider.updateDefaultLessonFee(fee);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) {
                if (settingsProvider.isLoading) {
                  return const ListTile(
                    leading: Icon(
                      Icons.monetization_on,
                      color: AppColors.primary,
                    ),
                    title: Text('Para Birimi'),
                    trailing: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return ListTile(
                  leading: const Icon(
                    Icons.monetization_on,
                    color: AppColors.primary,
                  ),
                  title: const Text('Para Birimi'),
                  subtitle: Text(settingsProvider.settings.currency ?? 'TL'),
                  trailing: DropdownButton<String>(
                    value: settingsProvider.settings.currency ?? 'TL',
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        settingsProvider.updateCurrency(newValue);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'TL', child: Text('TL')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing16),
        _buildSection(
          title: 'Varsayılan Ders Konusu',
          children: [
            Consumer<AppSettingsProvider>(
              builder: (context, settingsProvider, child) {
                if (settingsProvider.isLoading) {
                  return const ListTile(
                    leading: Icon(Icons.book, color: AppColors.primary),
                    title: Text('Varsayılan Konu'),
                    trailing: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return ListTile(
                  leading: const Icon(Icons.book, color: AppColors.primary),
                  title: const Text('Varsayılan Konu'),
                  subtitle: Text(
                    settingsProvider.settings.defaultSubject ?? 'Belirtilmemiş',
                  ),
                  trailing: SizedBox(
                    width: 150,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        hintText: 'Örn: Matematik',
                      ),
                      controller: TextEditingController(
                        text: settingsProvider.settings.defaultSubject ?? '',
                      ),
                      onSubmitted: (value) {
                        settingsProvider.updateDefaultSubject(
                          value.isEmpty ? null : value,
                        );
                      },
                    ),
                  ),
                );
              },
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
