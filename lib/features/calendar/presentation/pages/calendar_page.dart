import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/add_lesson_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/widgets/lesson_card.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

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
        lessonProvider.setSelectedDate(_selectedDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Takvimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              Provider.of<LessonProvider>(
                context,
                listen: false,
              ).setSelectedDate(_selectedDay);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Takvim görünümü
          _buildCalendarView(),

          // Günlük ders listesi
          Expanded(child: _buildDailyLessonsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final lessonProvider = Provider.of<LessonProvider>(
            context,
            listen: false,
          );
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLessonPage()),
          );

          if (mounted) {
            lessonProvider.loadLessons();
            final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
            lessonProvider.loadLessonsByDate(dateStr);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarView() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        Provider.of<LessonProvider>(
          context,
          listen: false,
        ).setSelectedDate(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(128),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
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
          return const Center(
            child: Text('Bu gün için planlanmış ders bulunmamaktadır.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessonProvider.dailyLessons.length,
          itemBuilder: (context, index) {
            final lesson = lessonProvider.dailyLessons[index];
            return LessonCard(
              studentName: lesson.studentName,
              subject: lesson.subject,
              startTime: lesson.startTime,
              endTime: lesson.endTime,
            );
          },
        );
      },
    );
  }
}
