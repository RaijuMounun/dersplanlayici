import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/lessons/presentation/widgets/lesson_card.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/core/widgets/app_calendar.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Provider erişimini build sonrasına ertele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final lessonProvider = Provider.of<LessonProvider>(
          context,
          listen: false,
        );
        lessonProvider.loadLessons();
        lessonProvider.setSelectedDate(_selectedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) => ResponsiveLayout(
    // Mobil görünüm - Calendar üstte, dersler altta
    mobile: Column(
      children: [
        // Takvim görünümü
        _buildCalendarView(),

        // Günlük ders listesi
        Expanded(child: _buildDailyLessonsList()),
      ],
    ),

    // Tablet görünüm - Daha geniş alanlı düşey layout
    tablet: Column(
      children: [
        // Takvim görünümü
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: _buildCalendarView(),
        ),

        // Günlük ders listesi
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing24,
            ),
            child: _buildDailyLessonsList(),
          ),
        ),
      ],
    ),

    // Desktop görünüm - Yatay layout (Takvim solda, dersler sağda)
    desktop: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Takvim görünümü - sabit genişlik
        Container(
          width: 400,
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: _buildCalendarView(),
        ),

        // Dikey çizgi ayırıcı
        Container(width: 1, height: double.infinity, color: AppColors.border),

        // Günlük ders listesi - kalan alanı doldur
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarih başlığı
                Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing16),
                // Ders listesi
                Expanded(child: _buildDailyLessonsList()),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildCalendarView() => Consumer<LessonProvider>(
    builder: (context, lessonProvider, child) {
      final events = _buildEventsMap(lessonProvider);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
        child: AppCalendar(
          initialDate: _selectedDate,
          events: events,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
            lessonProvider.setSelectedDate(_selectedDate);
          },
        ),
      );
    },
  );

  Map<DateTime, List<dynamic>> _buildEventsMap(LessonProvider lessonProvider) {
    final Map<DateTime, List<dynamic>> eventsMap = {};

    for (final lesson in lessonProvider.lessons) {
      final date = _parseDate(lesson.date);
      if (eventsMap.containsKey(date)) {
        eventsMap[date]!.add(lesson.subject);
      } else {
        eventsMap[date] = [lesson.subject];
      }
    }

    return eventsMap;
  }

  DateTime _parseDate(String date) => DateTime(
    int.parse(date.split('-')[0]), // yıl
    int.parse(date.split('-')[1]), // ay
    int.parse(date.split('-')[2]), // gün
  );

  Widget _buildDailyLessonsList() => Consumer<LessonProvider>(
    builder: (context, lessonProvider, child) {
      if (lessonProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (lessonProvider.error != null &&
          lessonProvider.error.toString().isNotEmpty) {
        return Center(child: Text('Hata: ${lessonProvider.error}'));
      }

      if (lessonProvider.dailyLessons.isEmpty) {
        return _buildEmptyState();
      }

      // Ekran boyutuna göre farklı padding ve tasarım kullan
      final padding = ResponsiveUtils.deviceValue<EdgeInsets>(
        context: context,
        mobile: const EdgeInsets.all(AppDimensions.spacing8),
        tablet: const EdgeInsets.all(AppDimensions.spacing16),
        desktop: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
      );

      return ListView.builder(
        padding: padding,
        itemCount: lessonProvider.dailyLessons.length,
        itemBuilder: (context, index) {
          final lesson = lessonProvider.dailyLessons[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
            child: LessonCard(
              studentName: lesson.studentName,
              subject: lesson.subject,
              startTime: lesson.startTime,
              endTime: lesson.endTime,
              onTap: () {
                // Ders detay sayfasına yönlendir
                context.push('/lesson/${lesson.id}');
              },
            ),
          );
        },
      );
    },
  );

  Widget _buildEmptyState() {
    final dateStr = DateFormat('dd MMMM yyyy').format(_selectedDate);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: ResponsiveUtils.deviceValue(
              context: context,
              mobile: 64.0,
              tablet: 80.0,
              desktop: 96.0,
            ),
            color: Colors.grey.withAlpha(128),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            '$dateStr tarihinde ders bulunmuyor',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          SizedBox(
            width: ResponsiveUtils.deviceValue(
              context: context,
              mobile: 160.0,
              tablet: 200.0,
              desktop: 220.0,
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                // Ders ekleme sayfasına yönlendir
                await context.push('/new-lesson');

                if (mounted) {
                  final lessonProvider = Provider.of<LessonProvider>(
                    context,
                    listen: false,
                  );
                  await lessonProvider.loadLessons();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Ders Ekle'),
            ),
          ),
        ],
      ),
    );
  }
}
