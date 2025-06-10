import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/widgets/app_recurring_picker.dart' as ui;
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/lessons/domain/models/recurring_pattern_model.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';

/// Tekrarlanan dersler için servis sınıfı.
class RecurringLessonService {
  /// UI'daki RecurringInfo modelini veritabanı için RecurringPattern modeline dönüştürür.
  RecurringPattern convertToRecurringPattern({
    required ui.RecurringInfo recurringInfo,
    required String startDate,
  }) {
    if (recurringInfo.type == ui.RecurringType.none) {
      throw const RecurringLessonException(
        message: 'Tekrarlanmayan ders için tekrar deseni oluşturulamaz',
      );
    }

    // UI RecurringType'ını veritabanı RecurringType'ına dönüştür
    RecurringType dbType;
    switch (recurringInfo.type) {
      case ui.RecurringType.daily:
      case ui.RecurringType.weekly:
      case ui.RecurringType.biweekly:
        dbType = RecurringType.weekly;
        break;
      case ui.RecurringType.monthly:
        dbType = RecurringType.monthly;
        break;
      default:
        throw const RecurringLessonException(
          message: 'Desteklenmeyen tekrar türü',
        );
    }

    // Interval ve haftanın günleri için özel mantık
    int interval = recurringInfo.interval ?? 1;
    if (recurringInfo.type == ui.RecurringType.biweekly) {
      interval = 2;
    }

    // Haftanın günleri
    List<int>? daysOfWeek;
    if (recurringInfo.type == ui.RecurringType.daily) {
      // Günlük tekrarda tüm günler
      daysOfWeek = List.generate(7, (index) => index + 1);
    } else if (recurringInfo.type == ui.RecurringType.weekly ||
        recurringInfo.type == ui.RecurringType.biweekly) {
      // Haftalık ve iki haftalık tekrarda belirtilen günler
      daysOfWeek = recurringInfo.weekdays;
    }

    // Ayın günü (aylık tekrar için)
    int? dayOfMonth;
    if (recurringInfo.type == ui.RecurringType.monthly) {
      dayOfMonth = recurringInfo.dayOfMonth;
    }

    // Bitiş tarihi
    String? endDate;
    if (recurringInfo.endDate != null) {
      endDate = DateFormat('yyyy-MM-dd').format(recurringInfo.endDate!);
    }

    return RecurringPattern(
      type: dbType,
      interval: interval,
      startDate: startDate,
      endDate: endDate,
      daysOfWeek: daysOfWeek,
      dayOfMonth: dayOfMonth,
    );
  }

  /// Tekrarlanan dersler oluşturur.
  List<Lesson> generateRecurringLessons({
    required Lesson baseLesson,
    required RecurringPattern pattern,
    required int occurrences,
  }) {
    // Temel ders dahil olmayacak
    final lessons = <Lesson>[];

    // Başlangıç tarihini parse et
    final startDateStr = pattern.startDate;
    final baseDateFormat = DateFormat('yyyy-MM-dd');
    final baseDate = baseDateFormat.parse(startDateStr);

    // Başlangıç saatlerini ayır
    final startTime = baseLesson.startTime;
    final endTime = baseLesson.endTime;

    // Güncel tarih
    DateTime currentDate = baseDate;

    // Tekrar tipine göre dersleri oluştur
    for (int i = 0; i < occurrences; i++) {
      if (pattern.type == RecurringType.weekly) {
        // Haftalık tekrar
        if (pattern.daysOfWeek == null || pattern.daysOfWeek!.isEmpty) {
          // Haftanın günü belirtilmemişse, sadece interval kullan
          currentDate = currentDate.add(Duration(days: 7 * pattern.interval));
        } else {
          // Haftanın belirli günleri için
          final weekday = currentDate.weekday;
          int daysToAdd = 0;

          // Sonraki uygun günü bul
          bool foundNextDay = false;
          for (int day in pattern.daysOfWeek!.where((d) => d > weekday)) {
            daysToAdd = day - weekday;
            foundNextDay = true;
            break;
          }

          // Eğer bu hafta içinde uygun gün bulunamadıysa, sonraki haftaya geç
          if (!foundNextDay) {
            // Haftanın ilk gününe git ve interval kadar hafta ekle
            final firstDay = pattern.daysOfWeek!.first;
            daysToAdd = 7 - weekday + firstDay + (7 * (pattern.interval - 1));
          }

          currentDate = currentDate.add(Duration(days: daysToAdd));
        }
      } else if (pattern.type == RecurringType.monthly) {
        // Aylık tekrar
        final day = pattern.dayOfMonth ?? currentDate.day;

        // Bir sonraki ay
        DateTime nextMonth = DateTime(
          currentDate.year,
          currentDate.month + pattern.interval,
          1,
        );

        // Ayın son gününü kontrol et
        final lastDayOfMonth = DateTime(
          nextMonth.year,
          nextMonth.month + 1,
          0,
        ).day;

        // Geçerli gün numarası
        final validDay = day > lastDayOfMonth ? lastDayOfMonth : day;

        // Yeni tarih oluştur
        currentDate = DateTime(nextMonth.year, nextMonth.month, validDay);
      }

      // Ders nesnesi oluştur
      final newLesson = Lesson(
        studentId: baseLesson.studentId,
        studentName: baseLesson.studentName,
        subject: baseLesson.subject,
        topic: baseLesson.topic,
        date: baseDateFormat.format(currentDate),
        startTime: startTime,
        endTime: endTime,
        status: LessonStatus.scheduled,
        notes: baseLesson.notes,
        recurringPatternId: pattern.id,
        fee: baseLesson.fee,
      );

      lessons.add(newLesson);
    }

    return lessons;
  }

  /// Tekrarlanan derslerin ne zaman olacağını hesaplayarak metin açıklaması oluşturur.
  String getRecurringDescription(RecurringPattern pattern) {
    String description = '';

    switch (pattern.type) {
      case RecurringType.weekly:
        if (pattern.interval == 1) {
          description = 'Her hafta';
        } else {
          description = 'Her ${pattern.interval} haftada bir';
        }

        if (pattern.daysOfWeek != null && pattern.daysOfWeek!.isNotEmpty) {
          final dayNames = pattern.daysOfWeek!.map(_getDayName).join(', ');
          description += ' ($dayNames)';
        }
        break;

      case RecurringType.monthly:
        if (pattern.interval == 1) {
          description = 'Her ay';
        } else {
          description = 'Her ${pattern.interval} ayda bir';
        }

        if (pattern.dayOfMonth != null) {
          description += ' (Ayın ${pattern.dayOfMonth}. günü)';
        }
        break;
    }

    if (pattern.endDate != null) {
      final endDate = DateFormat(
        'dd.MM.yyyy',
      ).format(DateFormat('yyyy-MM-dd').parse(pattern.endDate!));
      description += ' - $endDate tarihine kadar';
    }

    return description;
  }

  /// Gün numarasına göre gün adını döndürür.
  String _getDayName(int day) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    // 1-7 aralığı (1: Pazartesi, 7: Pazar)
    return days[day - 1];
  }
}
