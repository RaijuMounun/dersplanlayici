import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_card.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Geri Bildirim')),
    body: ListView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      children: [
        _buildSection(
          title: 'Hata Bildir',
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Hata açıklaması veya öneriniz',
                        hintText:
                            'Karşılaştığınız sorunu veya önerinizi detaylı bir şekilde yazın...',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitFeedback,
                        child: const Text('Gönder'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing16),
        _buildSection(
          title: 'İletişim',
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text('E-posta'),
              subtitle: const Text('erenkeskinoglu@outlook.com'),
              trailing: const Icon(Icons.open_in_new),
              onTap: _launchEmail,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: const Text('GitHub'),
              subtitle: const Text('Proje sayfası'),
              trailing: const Icon(Icons.open_in_new),
              onTap: _launchGitHub,
            ),
          ],
        ),
      ],
    ),
  );

  void _submitFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geri bildiriminizi yazın'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Gerçek uygulamada burada e-posta gönderme veya API çağrısı yapılır
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geri bildiriminiz için teşekkürler!'),
        backgroundColor: AppColors.success,
      ),
    );

    _feedbackController.clear();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'erenkeskinoglu@outlook.com',
      query: 'subject=Ders Planlayıcı - Geri Bildirim',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/raijumounun/ders-planlayici');
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
