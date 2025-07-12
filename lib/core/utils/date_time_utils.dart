import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Tarih ve saat işlemleri için yardımcı fonksiyonlar içerir.
class DateTimeUtils {
  DateTimeUtils._();

  /// Verilen DateTime nesnesini 'dd/MM/yyyy' formatında string'e dönüştürür.
  static String formatDate(DateTime date) => DateFormat(AppConstants.dateFormat).format(date);

  /// Verilen TimeOfDay nesnesini 'HH:mm' formatında string'e dönüştürür.
  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat(AppConstants.timeFormat).format(dt);
  }

  /// String formatındaki tarihi DateTime nesnesine dönüştürür.
  static DateTime parseDate(String date) => DateFormat(AppConstants.dateFormat).parse(date);

  /// String formatındaki saati TimeOfDay nesnesine dönüştürür.
  static TimeOfDay parseTime(String time) {
    final dt = DateFormat(AppConstants.timeFormat).parse(time);
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  /// İki tarih arasındaki gün farkını hesaplar.
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// İki zaman arasındaki dakika farkını hesaplar.
  static int minutesBetween(TimeOfDay from, TimeOfDay to) => (to.hour * 60 + to.minute) - (from.hour * 60 + from.minute);

  /// Verilen dakika sayısını saat:dakika formatına dönüştürür.
  static String minutesToHourMinuteFormat(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '$hours saat ${remainingMinutes > 0 ? '$remainingMinutes dakika' : ''}';
    } else {
      return '$minutes dakika';
    }
  }

  /// Haftanın günlerini Türkçe olarak döndürür.
  static String getDayName(int weekday) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[weekday - 1];
  }

  /// Ayın adını Türkçe olarak döndürür.
  static String getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  /// Verilen tarihin aynı gün olup olmadığını kontrol eder.
  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Verilen tarih aralığını ve tekrarlama desenine göre belirli bir tarih için ders olup olmadığını kontrol eder.
  static bool isLessonDay(
    DateTime date,
    DateTime startDate,
    int recurringType,
    int interval,
  ) {
    // Başlangıç tarihinden önce ise ders günü değildir
    if (date.isBefore(startDate)) return false;

    // Başlangıç günü ile aynı ise ders günüdür
    if (isSameDay(date, startDate)) return true;

    // Haftalık tekrarlamada
    if (recurringType == 1) {
      // Haftalık
      final daysBetween = DateTimeUtils.daysBetween(startDate, date);
      return daysBetween % (7 * interval) == 0;
    }

    // Aylık tekrarlamada (ayın aynı günü)
    if (recurringType == 2) {
      // Aylık
      if (date.day != startDate.day) return false;

      final monthDiff =
          (date.year - startDate.year) * 12 + date.month - startDate.month;
      return monthDiff % interval == 0;
    }

    return false;
  }

  /// Tarih seçme dialog'unu gösterir ve seçilen tarihi döndürür.
  static Future<DateTime?> showDatePickerDialog(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    initialDate ??= DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
    );
  }

  /// Saat seçme dialog'unu gösterir ve seçilen saati döndürür.
  static Future<TimeOfDay?> showTimePickerDialog(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    initialTime ??= TimeOfDay.now();

    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
    );
  }
}
