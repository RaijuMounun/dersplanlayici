import 'package:intl/intl.dart';

/// Tarih işlemleri için yardımcı metotlar içeren sınıf.
class DateUtils {
  /// "yyyy-MM-dd" formatındaki string tarihi "1 Ocak 2023" formatına dönüştürür.
  static String formatDate(String dateStr) {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
  }

  /// "yyyy-MM-dd" formatındaki string tarihi "1 Ocak 2023, Pazartesi" formatına dönüştürür.
  static String formatDateWithDay(String dateStr) {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date);
  }

  /// "yyyy-MM-dd" formatındaki string tarihi "01.01.2023" formatına dönüştürür.
  static String formatDateShort(String dateStr) {
    final date = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('dd.MM.yyyy').format(date);
  }

  /// DateTime nesnesini "yyyy-MM-dd" formatında string'e dönüştürür.
  static String toIsoDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// İki tarih arasındaki gün farkını döndürür.
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Verilen tarihin bugün olup olmadığını kontrol eder.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Verilen tarihin hafta sonu olup olmadığını kontrol eder.
  static bool isWeekend(DateTime date) => date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  /// Verilen ayın ilk gününü döndürür.
  static DateTime firstDayOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  /// Verilen ayın son gününü döndürür.
  static DateTime lastDayOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

  /// Verilen haftanın ilk gününü (Pazartesi) döndürür.
  static DateTime firstDayOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));

  /// Verilen haftanın son gününü (Pazar) döndürür.
  static DateTime lastDayOfWeek(DateTime date) => date.add(Duration(days: 7 - date.weekday));
}
