import 'package:ders_planlayici/features/calendar/domain/models/calendar_event_model.dart';

/// Takvimde gösterilen günü temsil eden model sınıfı.
class CalendarDay {
  final DateTime date;
  final List<CalendarEvent> events;
  final bool isToday;
  final bool isWeekend;
  final bool isSelectedMonth;
  final String? holidayName;

  CalendarDay({
    required this.date,
    required this.events,
    required this.isToday,
    required this.isWeekend,
    required this.isSelectedMonth,
    this.holidayName,
  });

  /// Tarihten CalendarDay nesnesi oluşturur.
  factory CalendarDay.fromDate(
    DateTime date, {
    List<CalendarEvent> events = const [],
    DateTime? today,
    DateTime? selectedMonth,
    Map<String, String>? holidays,
  }) {
    final now = today ?? DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final isWeekend =
        date.weekday == 6 || date.weekday == 7; // 6: Cumartesi, 7: Pazar

    final currentMonth = selectedMonth ?? DateTime(now.year, now.month, 1);
    final isSelectedMonth =
        date.year == currentMonth.year && date.month == currentMonth.month;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final holidayName = holidays != null ? holidays[dateStr] : null;

    return CalendarDay(
      date: date,
      events: events.where((event) => event.date == dateStr).toList(),
      isToday: isToday,
      isWeekend: isWeekend,
      isSelectedMonth: isSelectedMonth,
      holidayName: holidayName,
    );
  }

  /// Bu günün toplam etkinlik sayısını döndürür.
  int get eventCount => events.length;

  /// Bu günün ders etkinliklerini döndürür.
  List<CalendarEvent> get lessonEvents =>
      events.where((event) => event.type == CalendarEventType.lesson).toList();

  /// Bu günün sınav etkinliklerini döndürür.
  List<CalendarEvent> get examEvents =>
      events.where((event) => event.type == CalendarEventType.exam).toList();

  /// Bu günün tatil olup olmadığını döndürür.
  bool get isHoliday => holidayName != null;

  /// Bu günün tarihini string olarak döndürür (yyyy-MM-dd).
  String get formattedDate =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Bu günün haftanın kaçıncı günü olduğunu döndürür.
  int get weekday => date.weekday;

  /// Günün sadece gün kısmını döndürür.
  int get day => date.day;

  /// Etkinlik eklenmiş yeni bir CalendarDay nesnesi oluşturur.
  CalendarDay addEvent(CalendarEvent event) {
    return CalendarDay(
      date: date,
      events: [...events, event],
      isToday: isToday,
      isWeekend: isWeekend,
      isSelectedMonth: isSelectedMonth,
      holidayName: holidayName,
    );
  }

  /// Çoklu etkinlik eklenmiş yeni bir CalendarDay nesnesi oluşturur.
  CalendarDay addEvents(List<CalendarEvent> newEvents) {
    return CalendarDay(
      date: date,
      events: [...events, ...newEvents],
      isToday: isToday,
      isWeekend: isWeekend,
      isSelectedMonth: isSelectedMonth,
      holidayName: holidayName,
    );
  }

  @override
  String toString() {
    return 'CalendarDay(date: $formattedDate, events: $eventCount, isToday: $isToday)';
  }
}
