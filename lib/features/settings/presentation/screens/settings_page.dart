import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/settings/presentation/screens/database_management_page.dart';
import 'package:ders_planlayici/features/settings/presentation/screens/notification_settings_page.dart';
import 'package:ders_planlayici/features/settings/presentation/screens/lesson_settings_page.dart';
import 'package:ders_planlayici/features/settings/presentation/screens/feedback_page.dart';
import 'package:ders_planlayici/core/widgets/app_card.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/features/settings/presentation/providers/theme_provider.dart';
import 'package:ders_planlayici/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppDimensions.spacing16),
    children: [
      _buildSection(
        title: 'Genel Ayarlar',
        children: [
          ListTile(
            leading: const Icon(Icons.coffee, color: AppColors.primary),
            title: const Text('Buy Me A Coffee'),
            subtitle: const Text('Bana bir kahve ısmarlamak ister misin?'),
            trailing: const Icon(Icons.open_in_new),
            onTap: _launchBuyMeACoffee,
          ),
          const Divider(height: 1),
          _buildThemeSetting(context),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.primary),
            title: const Text('Bildirimler'),
            subtitle: const Text('Ders başlangıcı için hatırlatmalar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.spacing16),
      _buildSection(
        title: 'Ders Ayarları',
        children: [
          ListTile(
            leading: const Icon(Icons.timer, color: AppColors.primary),
            title: const Text('Ders Ayarları'),
            subtitle: const Text('Süre, ücret ve varsayılan ayarlar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LessonSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.spacing16),
      _buildSection(
        title: 'Öğrenci Ayarları',
        children: [_buildConfirmDeleteSetting(context)],
      ),
      const SizedBox(height: AppDimensions.spacing16),
      _buildSection(
        title: 'Veri Yönetimi',
        children: [
          ListTile(
            leading: const Icon(Icons.storage, color: AppColors.primary),
            title: const Text('Veritabanı Yönetimi'),
            subtitle: const Text('Yedekleme, geri yükleme ve sıfırlama'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DatabaseManagementPage(),
                ),
              );
            },
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.spacing16),
      _buildSection(
        title: 'Uygulama Hakkında',
        children: [
          const ListTile(
            leading: Icon(Icons.info, color: AppColors.primary),
            title: Text('Sürüm'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bug_report, color: AppColors.primary),
            title: const Text('Hata Bildir'),
            subtitle: const Text('Geri bildirim gönder'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FeedbackPage()),
              );
            },
          ),
        ],
      ),
    ],
  );

  Widget _buildThemeSetting(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) => ListTile(
      leading: const Icon(Icons.brightness_4, color: AppColors.primary),
      title: const Text('Tema'),
      subtitle: Text(_getThemeText(themeProvider.themeMode)),
      trailing: DropdownButton<ThemeMode>(
        value: themeProvider.themeMode,
        underline: const SizedBox(),
        onChanged: (ThemeMode? newThemeMode) {
          if (newThemeMode != null) {
            themeProvider.setTheme(newThemeMode);
          }
        },
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Açık')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Koyu')),
        ],
      ),
    ),
  );

  Widget _buildConfirmDeleteSetting(BuildContext context) =>
      Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Silme Onayı'),
              trailing: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return SwitchListTile(
            secondary: const Icon(
              Icons.delete_outline,
              color: AppColors.primary,
            ),
            title: const Text('Silme Onayı'),
            subtitle: const Text('Öğrencileri silmeden önce onay iste'),
            value: settingsProvider.settings.confirmBeforeDelete,
            onChanged: (bool value) {
              settingsProvider.updateConfirmBeforeDelete(value);
            },
          );
        },
      );

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Sistem ayarlarını kullan';
      case ThemeMode.light:
        return 'Açık tema';
      case ThemeMode.dark:
        return 'Koyu tema';
    }
  }

  Future<void> _launchBuyMeACoffee() async {
    final Uri url = Uri.parse('https://coff.ee/raijumounun');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

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
