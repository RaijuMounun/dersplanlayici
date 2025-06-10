import 'package:ders_planlayici/features/calendar/domain/models/calendar_day_model.dart';
import 'package:ders_planlayici/features/calendar/domain/models/calendar_event_model.dart';

/// Takvimde gösterilen ayı temsil eden model sınıfı.
class CalendarMonth {
  final DateTime firstDay;
  final List<CalendarDay> days;
  final List<CalendarEvent> events;
  final Map<String, String>? holidays;

  CalendarMonth({
    required this.firstDay,
    required this.days,
    required this.events,
    this.holidays,
  });

  /// Belirli bir ay için CalendarMonth nesnesi oluşturur.
  factory CalendarMonth.fromMonth(
    int year,
    int month, {
    List<CalendarEvent> events = const [],
    Map<String, String>? holidays,
  }) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0); // Ayın son günü

    // Takvimde gösterilecek tüm günleri içeren liste
    // (önceki ayın son günleri + geçerli ay + sonraki ayın ilk günleri)
    final List<DateTime> calendarDays = [];

    // Takvim haftanın ilk günü ile başlar (Pazartesi = 1)
    int firstWeekday = firstDay.weekday;

    // Önceki ayın gösterilecek günlerini ekle
    if (firstWeekday > 1) {
      final prevMonth = DateTime(year, month - 1);
      final daysInPrevMonth = DateTime(year, month, 0).day;

      for (int i = firstWeekday - 1; i > 0; i--) {
        calendarDays.add(
          DateTime(prevMonth.year, prevMonth.month, daysInPrevMonth - i + 1),
        );
      }
    }

    // Geçerli ayın günlerini ekle
    for (int i = 1; i <= lastDay.day; i++) {
      calendarDays.add(DateTime(year, month, i));
    }

    // Sonraki ayın gösterilecek günlerini ekle
    int remainingDays = 42 - calendarDays.length; // 6 satır x 7 gün
    if (remainingDays > 0) {
      final nextMonth = DateTime(year, month + 1);

      for (int i = 1; i <= remainingDays; i++) {
        calendarDays.add(DateTime(nextMonth.year, nextMonth.month, i));
      }
    }

    // CalendarDay nesnelerini oluştur
    final calendarDaysList = calendarDays.map((date) {
      return CalendarDay.fromDate(
        date,
        events: events,
        selectedMonth: firstDay,
        holidays: holidays,
      );
    }).toList();

    return CalendarMonth(
      firstDay: firstDay,
      days: calendarDaysList,
      events: events,
      holidays: holidays,
    );
  }

  /// Ayın adını döndürür.
  String get monthName {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[firstDay.month - 1];
  }

  /// Ay ve yıl bilgisini döndürür.
  String get monthYear => '$monthName ${firstDay.year}';

  /// Bu aydaki toplam etkinlik sayısını döndürür.
  int get eventCount => events.length;

  /// Bu aydaki günlerin sayısını döndürür.
  int get dayCount => days.length;

  /// Bu aydaki ders etkinlikleri sayısını döndürür.
  int get lessonCount =>
      events.where((event) => event.type == CalendarEventType.lesson).length;

  /// Belirli bir gün için etkinlikleri döndürür.
  List<CalendarEvent> getEventsForDay(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return events.where((event) => event.date == dateStr).toList();
  }

  /// Yeni etkinlikler eklenmiş bir CalendarMonth nesnesi döndürür.
  CalendarMonth addEvents(List<CalendarEvent> newEvents) {
    // Yeni etkinlikleri içeren günleri güncelle
    final updatedDays = days.map((day) {
      final dayEvents = newEvents
          .where((event) => event.date == day.formattedDate)
          .toList();

      if (dayEvents.isNotEmpty) {
        return day.addEvents(dayEvents);
      }

      return day;
    }).toList();

    return CalendarMonth(
      firstDay: firstDay,
      days: updatedDays,
      events: [...events, ...newEvents],
      holidays: holidays,
    );
  }

  @override
  String toString() {
    return 'CalendarMonth(month: $monthYear, events: $eventCount)';
  }
}
