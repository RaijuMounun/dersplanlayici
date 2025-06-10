import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_button.dart';
import 'package:ders_planlayici/core/widgets/app_card.dart';
import 'package:ders_planlayici/core/widgets/app_text_field.dart';
import 'package:ders_planlayici/core/widgets/app_calendar.dart';
import 'package:ders_planlayici/core/widgets/app_bottom_navigation.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_card.dart';
import 'package:ders_planlayici/features/lessons/presentation/widgets/lesson_list_item.dart';

/// Widget'ları göstermek için örnek sayfa.
class WidgetShowcasePage extends StatefulWidget {
  const WidgetShowcasePage({Key? key}) : super(key: key);

  @override
  State<WidgetShowcasePage> createState() => _WidgetShowcasePageState();
}

class _WidgetShowcasePageState extends State<WidgetShowcasePage> {
  int _currentNavIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Butonlar'),
            _buildButtonsSection(),

            _buildSectionTitle('Metin Alanları'),
            _buildTextFieldsSection(),

            _buildSectionTitle('Kartlar'),
            _buildCardsSection(),

            _buildSectionTitle('Takvim'),
            _buildCalendarSection(),

            _buildSectionTitle('Öğrenci Kartı'),
            _buildStudentCardSection(),

            _buildSectionTitle('Ders Listesi Öğesi'),
            _buildLessonListItemSection(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          AppBottomNavigationItem(label: 'Ana Sayfa', icon: Icons.home),
          AppBottomNavigationItem(label: 'Takvim', icon: Icons.calendar_today),
          AppBottomNavigationItem(label: 'Dersler', icon: Icons.book),
          AppBottomNavigationItem(label: 'Öğrenciler', icon: Icons.people),
          AppBottomNavigationItem(label: 'Ayarlar', icon: Icons.settings),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacing24,
        bottom: AppDimensions.spacing16,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildButtonsSection() {
    return Wrap(
      spacing: AppDimensions.spacing8,
      runSpacing: AppDimensions.spacing8,
      children: [
        AppButton(
          text: 'Primary Button',
          onPressed: () {},
          type: AppButtonType.primary,
        ),
        AppButton(
          text: 'Secondary Button',
          onPressed: () {},
          type: AppButtonType.secondary,
        ),
        AppButton(
          text: 'Outline Button',
          onPressed: () {},
          type: AppButtonType.outline,
        ),
        AppButton(
          text: 'Text Button',
          onPressed: () {},
          type: AppButtonType.text,
        ),
        AppButton(text: 'Icon Button', onPressed: () {}, icon: Icons.add),
        AppButton(text: 'Loading', onPressed: () {}, isLoading: true),
        AppButton(text: 'Disabled', onPressed: null),
      ],
    );
  }

  Widget _buildTextFieldsSection() {
    return Column(
      children: [
        const AppTextField(
          label: 'Standart Metin Alanı',
          hint: 'Bir şeyler yazın...',
        ),
        SizedBox(height: AppDimensions.spacing16),
        const AppTextField(
          label: 'Prefix Icon',
          hint: 'Arama...',
          prefixIcon: Icon(Icons.search),
        ),
        SizedBox(height: AppDimensions.spacing16),
        const AppTextField(
          label: 'Suffix Icon',
          hint: 'Şifre',
          obscureText: true,
          suffixIcon: Icon(Icons.visibility),
        ),
        SizedBox(height: AppDimensions.spacing16),
        const AppTextField(
          label: 'Hata Durumu',
          hint: 'Bir şeyler yazın...',
          errorText: 'Bu alan boş bırakılamaz',
        ),
        SizedBox(height: AppDimensions.spacing16),
        const AppTextField(
          label: 'Çok Satırlı',
          hint: 'Bir şeyler yazın...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    final theme = Theme.of(context);

    return Column(
      children: [
        AppCard(
          child: Text('Basit Kart İçeriği', style: theme.textTheme.bodyLarge),
        ),
        SizedBox(height: AppDimensions.spacing16),
        AppCard(
          onTap: () {},
          child: Column(
            children: [
              Text('Tıklanabilir Kart', style: theme.textTheme.titleMedium),
              SizedBox(height: AppDimensions.spacing8),
              Text(
                'Bu karta tıklayabilirsiniz.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacing16),
        AppCard(
          hasShadow: false,
          borderSide: BorderSide(color: AppColors.primary),
          child: Text(
            'Gölgesiz, Kenarlıklı Kart',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return AppCalendar(
      initialDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
      events: {
        DateTime(_selectedDate.year, _selectedDate.month, 15): ['Matematik'],
        DateTime(_selectedDate.year, _selectedDate.month, 20): ['Fizik'],
        DateTime(_selectedDate.year, _selectedDate.month, 25): [
          'Kimya',
          'Biyoloji',
        ],
      },
    );
  }

  Widget _buildStudentCardSection() {
    return Column(
      children: [
        StudentCard(
          studentName: 'Ahmet Yılmaz',
          studentGrade: '10. Sınıf',
          phoneNumber: '0532 123 4567',
          email: 'ahmet.yilmaz@example.com',
          totalLessons: 12,
          totalFee: 1200,
          onTap: () {},
          onEditPressed: () {},
          onDeletePressed: () {},
        ),
        SizedBox(height: AppDimensions.spacing16),
        StudentCard(
          studentName: 'Ayşe Demir',
          studentGrade: '11. Sınıf',
          phoneNumber: '0533 765 4321',
          totalLessons: 8,
          totalFee: 800,
          onTap: () {},
          onEditPressed: () {},
          onDeletePressed: () {},
          avatarBackgroundColor: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildLessonListItemSection() {
    return Column(
      children: [
        LessonListItem(
          lessonTitle: 'Matematik',
          studentName: 'Ahmet Yılmaz',
          startTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
          endTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
          fee: 100,
          onTap: () {},
          onEditPressed: () {},
          onDeletePressed: () {},
        ),
        SizedBox(height: AppDimensions.spacing8),
        LessonListItem(
          lessonTitle: 'Fizik',
          studentName: 'Ayşe Demir',
          startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
          fee: 120,
          isRecurring: true,
          onTap: () {},
          onEditPressed: () {},
          onDeletePressed: () {},
        ),
        SizedBox(height: AppDimensions.spacing8),
        LessonListItem(
          lessonTitle: 'Kimya',
          studentName: 'Mehmet Kaya',
          startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          endTime: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
          fee: 90,
          isCompleted: true,
          onTap: () {},
          onEditPressed: () {},
          onDeletePressed: () {},
        ),
      ],
    );
  }
}
