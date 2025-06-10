import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/lessons/presentation/widgets/lesson_card.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/core/widgets/app_calendar.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';

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
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Takvim görünümü
        _buildCalendarView(),

        // Günlük ders listesi
        Expanded(child: _buildDailyLessonsList()),
      ],
    );
  }

  Widget _buildCalendarView() {
    return Consumer<LessonProvider>(
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
  }

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

  DateTime _parseDate(String date) {
    final components = date.split('-');
    return DateTime(
      int.parse(components[0]), // yıl
      int.parse(components[1]), // ay
      int.parse(components[2]), // gün
    );
  }

  Widget _buildDailyLessonsList() {
    return Consumer<LessonProvider>(
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

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          itemCount: lessonProvider.dailyLessons.length,
          itemBuilder: (context, index) {
            final lesson = lessonProvider.dailyLessons[index];
            return LessonCard(
              studentName: lesson.studentName,
              subject: lesson.subject,
              startTime: lesson.startTime,
              endTime: lesson.endTime,
              onTap: () async {
                // TODO: Ders detay sayfasına yönlendir
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final dateStr = DateFormat('dd MMMM yyyy').format(_selectedDate);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey.withAlpha(128),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            '$dateStr tarihinde ders bulunmuyor',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton.icon(
            onPressed: () async {
              // Ders ekleme sayfasına yönlendir
              await context.push('/add-lesson');

              if (mounted) {
                final lessonProvider = Provider.of<LessonProvider>(
                  context,
                  listen: false,
                );
                lessonProvider.loadLessons();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Ders Ekle'),
          ),
        ],
      ),
    );
  }
}
