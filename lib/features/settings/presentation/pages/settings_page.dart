import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/settings/presentation/pages/database_management_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Genel Ayarlar',
            children: [
              ListTile(
                title: const Text('Tema'),
                subtitle: const Text('Açık / Koyu / Sistem'),
                trailing: const Icon(Icons.brightness_4),
                onTap: () {
                  // Tema ayarları
                },
              ),
              ListTile(
                title: const Text('Bildirimler'),
                subtitle: const Text('Ders başlangıcı için hatırlatmalar'),
                trailing: const Icon(Icons.notifications),
                onTap: () {
                  // Bildirim ayarları
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Ders Ayarları',
            children: [
              ListTile(
                title: const Text('Varsayılan Ders Süresi'),
                subtitle: const Text('90 dakika'),
                trailing: const Icon(Icons.timer),
                onTap: () {
                  // Ders süresi ayarları
                },
              ),
              ListTile(
                title: const Text('Ders Ücretleri'),
                subtitle: const Text('Ders başına ücret ayarları'),
                trailing: const Icon(Icons.attach_money),
                onTap: () {
                  // Ücret ayarları
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Veri Yönetimi',
            children: [
              ListTile(
                title: const Text('Veritabanı Yönetimi'),
                subtitle: const Text('Yedekleme, geri yükleme ve sıfırlama'),
                trailing: const Icon(Icons.storage),
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
          const SizedBox(height: 16),
          _buildSection(
            title: 'Uygulama Hakkında',
            children: [
              ListTile(
                title: const Text('Sürüm'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.info),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}
