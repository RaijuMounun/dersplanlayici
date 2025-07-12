import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_button.dart';
import 'package:ders_planlayici/core/widgets/app_card.dart';
import 'package:ders_planlayici/core/widgets/app_text_field.dart';
import 'package:ders_planlayici/core/widgets/app_calendar.dart';
import 'package:ders_planlayici/core/widgets/app_bottom_navigation.dart';
import 'package:ders_planlayici/core/widgets/app_date_time_picker.dart';
import 'package:ders_planlayici/core/widgets/app_recurring_picker.dart';
import 'package:ders_planlayici/core/widgets/app_student_picker.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_card.dart';
import 'package:ders_planlayici/features/lessons/presentation/widgets/lesson_list_item.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

/// Widget'ları göstermek için örnek sayfa.
class WidgetShowcasePage extends StatefulWidget {
  const WidgetShowcasePage({super.key});

  @override
  State<WidgetShowcasePage> createState() => _WidgetShowcasePageState();
}

class _WidgetShowcasePageState extends State<WidgetShowcasePage> {
  int _currentNavIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) => Scaffold(
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

            _buildSectionTitle('Tarih ve Saat Seçici'),
            _buildDateTimePickerSection(),

            _buildSectionTitle('Tekrar Seçici'),
            _buildRecurringPickerSection(),

            _buildSectionTitle('Öğrenci Seçici'),
            _buildStudentPickerSection(),

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

  Widget _buildSectionTitle(String title) => Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacing24,
        bottom: AppDimensions.spacing16,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );

  Widget _buildButtonsSection() => Wrap(
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
        const AppButton(text: 'Disabled', onPressed: null),
      ],
    );

  Widget _buildTextFieldsSection() => const Column(
      children: [
        AppTextField(
          label: 'Standart Metin Alanı',
          hint: 'Bir şeyler yazın...',
        ),
        SizedBox(height: AppDimensions.spacing16),
        AppTextField(
          label: 'Prefix Icon',
          hint: 'Arama...',
          prefixIcon: Icon(Icons.search),
        ),
        SizedBox(height: AppDimensions.spacing16),
        AppTextField(
          label: 'Suffix Icon',
          hint: 'Şifre',
          obscureText: true,
          suffixIcon: Icon(Icons.visibility),
        ),
        SizedBox(height: AppDimensions.spacing16),
        AppTextField(
          label: 'Hata Durumu',
          hint: 'Bir şeyler yazın...',
          errorText: 'Bu alan boş bırakılamaz',
        ),
        SizedBox(height: AppDimensions.spacing16),
        AppTextField(
          label: 'Çok Satırlı',
          hint: 'Bir şeyler yazın...',
          maxLines: 3,
        ),
      ],
    );

  Widget _buildDateTimePickerSection() => Column(
      children: [
        AppDateTimePicker(
          initialDateTime: _selectedDate,
          onDateTimeChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          label: 'Ders Tarihi ve Saati',
          required: true,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        AppDateTimePicker(
          initialDateTime: DateTime.now().add(const Duration(days: 7)),
          dateHint: 'İleri tarih seçin',
          timeHint: 'Saat seçin',
          enabled: false,
        ),
      ],
    );

  Widget _buildRecurringPickerSection() => Column(
      children: [
        AppRecurringPicker(
          initialValue: const RecurringInfo(
            type: RecurringType.weekly,
            weekdays: [1, 3, 5],
          ),
          onChanged: (recurringInfo) {
            // Handle recurring info change
          },
          label: 'Ders Tekrarı',
          required: true,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        const AppRecurringPicker(
          initialValue: RecurringInfo(
            type: RecurringType.monthly,
            dayOfMonth: 15,
          ),
          label: 'Aylık Tekrar',
          enabled: false,
        ),
      ],
    );

  Widget _buildStudentPickerSection() {
    // Örnek öğrenci listesi
    final demoStudents = [
      Student(
        id: '1',
        name: 'Ahmet Yılmaz',
        grade: '10. Sınıf',
        phone: '0532 123 4567',
        email: 'ahmet@example.com',
      ),
      Student(
        id: '2',
        name: 'Ayşe Demir',
        grade: '11. Sınıf',
        phone: '0533 765 4321',
      ),
      Student(
        id: '3',
        name: 'Mehmet Kaya',
        grade: '9. Sınıf',
        parentName: 'Ali Kaya',
      ),
    ];

    return Column(
      children: [
        AppStudentPicker(
          students: demoStudents,
          onStudentSelected: (studentId) {
            // Handle student selection
          },
          label: 'Öğrenci',
          required: true,
        ),
        const SizedBox(height: AppDimensions.spacing16),
        AppStudentPicker(
          students: demoStudents,
          initialSelectedId: '2',
          onStudentSelected: (studentId) {
            // Handle student selection
          },
          label: 'Seçili Öğrenci',
          showAddButton: true,
          onAddPressed: () {
            // Handle add button press
          },
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
        const SizedBox(height: AppDimensions.spacing16),
        AppCard(
          onTap: () {},
          child: Column(
            children: [
              Text('Tıklanabilir Kart', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Bu karta tıklayabilirsiniz.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        AppCard(
          hasShadow: false,
          borderSide: const BorderSide(color: AppColors.primary),
          child: Text(
            'Gölgesiz, Kenarlıklı Kart',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() => AppCalendar(
      initialDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
      events: {
        DateTime(_selectedDate.year, _selectedDate.month, 15): const ['Matematik'],
        DateTime(_selectedDate.year, _selectedDate.month, 20): const ['Fizik'],
        DateTime(_selectedDate.year, _selectedDate.month, 25): const [
          'Kimya',
          'Biyoloji',
        ],
      },
    );

  Widget _buildStudentCardSection() => Column(
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
        const SizedBox(height: AppDimensions.spacing16),
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

  Widget _buildLessonListItemSection() => Column(
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
        const SizedBox(height: AppDimensions.spacing8),
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
        const SizedBox(height: AppDimensions.spacing8),
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
