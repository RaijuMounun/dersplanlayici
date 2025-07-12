import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';

/// Ücret hesaplama servis sınıfı.
/// Bu sınıf, otomatik ücret hesaplama işlemlerini gerçekleştirir.
class FeeCalculationService {
  /// Öğrencinin belirtilen tarih aralığındaki derslerinin toplam ücretini hesaplar.
  /// [lessons] Öğrencinin dersleri
  /// [startDate] Başlangıç tarihi
  /// [endDate] Bitiş tarihi
  /// [onlyCompleted] Sadece tamamlanmış dersleri dahil et
  static double calculateStudentFeeForDateRange({
    required List<Lesson> lessons,
    required DateTime startDate,
    required DateTime endDate,
    bool onlyCompleted = false,
  }) {
    // Tarih aralığındaki dersleri filtrele
    final filteredLessons = lessons.where((lesson) {
      final lessonDate = DateTime.parse(lesson.date);
      final isInRange =
          (lessonDate.isAfter(startDate) ||
              lessonDate.isAtSameMomentAs(startDate)) &&
          (lessonDate.isBefore(endDate) ||
              lessonDate.isAtSameMomentAs(endDate));

      // Sadece tamamlanmış dersleri dahil et
      if (onlyCompleted) {
        return isInRange && lesson.status == LessonStatus.completed;
      }

      // Tamamlanmış ve planlanmış dersleri dahil et, iptal edilenleri hariç tut
      return isInRange && lesson.status != LessonStatus.cancelled;
    }).toList();

    // Toplam ücret hesaplama
    double totalFee = 0;
    for (var lesson in filteredLessons) {
      totalFee += lesson.fee;
    }

    return totalFee;
  }

  /// Belirli bir ay için öğrencinin ders ücretlerini hesaplar
  /// [lessons] Öğrencinin dersleri
  /// [year] Yıl
  /// [month] Ay (1-12)
  /// [onlyCompleted] Sadece tamamlanmış dersleri dahil et
  static double calculateStudentFeeForMonth({
    required List<Lesson> lessons,
    required int year,
    required int month,
    bool onlyCompleted = false,
  }) {
    final startDate = DateTime(year, month, 1);
    final endDate = month < 12
        ? DateTime(year, month + 1, 1).subtract(const Duration(days: 1))
        : DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));

    return calculateStudentFeeForDateRange(
      lessons: lessons,
      startDate: startDate,
      endDate: endDate,
      onlyCompleted: onlyCompleted,
    );
  }

  /// Henüz ödeme oluşturulmamış tamamlanmış dersler için otomatik ücret hesaplar
  /// [lessons] Öğrencinin tüm dersleri
  /// [payments] Öğrencinin tüm ödemeleri
  static double calculateUnbilledLessonFees({
    required List<Lesson> lessons,
    required List<PaymentModel> payments,
  }) {
    // Tamamlanmış dersleri filtrele
    final completedLessons = lessons
        .where((lesson) => lesson.status == LessonStatus.completed)
        .toList();

    // Ödemelere bağlı tüm ders ID'lerini al
    final Set<String> billedLessonIds = {};
    for (var payment in payments) {
      if (payment.lessonIds != null) {
        billedLessonIds.addAll(payment.lessonIds!);
      }
    }

    // Henüz faturalandırılmamış dersleri bul
    final unbilledLessons = completedLessons
        .where((lesson) => !billedLessonIds.contains(lesson.id))
        .toList();

    // Toplam ücreti hesapla
    double totalFee = 0;
    for (var lesson in unbilledLessons) {
      totalFee += lesson.fee;
    }

    return totalFee;
  }

  /// Öğrencilerin tamamlanmış ve ödenmemiş derslerini tespit eder ve ödeme önerileri oluşturur
  /// [students] Tüm öğrenciler
  /// [allLessons] Tüm dersler
  /// [allPayments] Tüm ödemeler
  static List<Map<String, dynamic>> generatePaymentSuggestions({
    required List<Student> students,
    required List<Lesson> allLessons,
    required List<PaymentModel> allPayments,
  }) {
    final List<Map<String, dynamic>> suggestions = [];

    for (var student in students) {
      // Öğrencinin derslerini ve ödemelerini filtrele
      final studentLessons = allLessons
          .where((lesson) => lesson.studentId == student.id)
          .toList();

      final studentPayments = allPayments
          .where((payment) => payment.studentId == student.id)
          .toList();

      // Ödenmemiş ders ücretlerini hesapla
      final unbilledAmount = calculateUnbilledLessonFees(
        lessons: studentLessons,
        payments: studentPayments,
      );

      // Eğer ödenmemiş ücret varsa öneri oluştur
      if (unbilledAmount > 0) {
        // Ödenmemiş dersleri bul
        final Set<String> billedLessonIds = {};
        for (var payment in studentPayments) {
          if (payment.lessonIds != null) {
            billedLessonIds.addAll(payment.lessonIds!);
          }
        }

        final unbilledLessons = studentLessons
            .where(
              (lesson) =>
                  lesson.status == LessonStatus.completed &&
                  !billedLessonIds.contains(lesson.id),
            )
            .toList();

        suggestions.add({
          'studentId': student.id,
          'studentName': student.name,
          'amount': unbilledAmount,
          'lessonCount': unbilledLessons.length,
          'unbilledLessonIds': unbilledLessons.map((l) => l.id).toList(),
          'description':
              '${student.name} - ${unbilledLessons.length} ders ücreti',
          'lastLessonDate': unbilledLessons.isNotEmpty
              ? unbilledLessons
                    .map((l) => DateTime.parse(l.date))
                    .reduce((a, b) => a.isAfter(b) ? a : b)
                    .toIso8601String()
              : null,
        });
      }
    }

    // Son ders tarihine göre sırala (en yeni en üstte)
    suggestions.sort((a, b) {
      final dateA = a['lastLessonDate'] != null
          ? DateTime.parse(a['lastLessonDate'] as String)
          : DateTime(1900);
      final dateB = b['lastLessonDate'] != null
          ? DateTime.parse(b['lastLessonDate'] as String)
          : DateTime(1900);
      return dateB.compareTo(dateA);
    });

    return suggestions;
  }
}
