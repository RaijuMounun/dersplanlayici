import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';

/// Ödeme işlemlerini yöneten repository sınıfı.
class PaymentRepository {

  PaymentRepository(this._databaseHelper);
  final DatabaseHelper _databaseHelper;

  /// Tüm ödemeleri getirir.
  Future<List<PaymentModel>> getAllPayments() async {
    try {
      final payments = await _databaseHelper.getPayments();

      final List<PaymentModel> result = [];
      for (int i = 0; i < payments.length; i++) {
        try {
          final payment = PaymentModel.fromMap(payments[i]);
          result.add(payment);
        } on Exception {
          //
        }
      }

      return result;
    } catch (e) {
      throw DatabaseException(
        message: 'Ödemeler yüklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Öğrenciye ait ödemeleri getirir.
  Future<List<PaymentModel>> getPaymentsByStudent(String studentId) async {
    try {
      final payments = await _databaseHelper.getPaymentsByStudent(studentId);
      return payments.map(PaymentModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Öğrenciye ait ödemeler yüklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Belirli bir ödemeyi getirir.
  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      final payment = await _databaseHelper.getPaymentById(id);
      if (payment != null) {
        return PaymentModel.fromMap(payment);
      }
      return null;
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme bilgisi yüklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Yeni bir ödeme ekler.
  Future<void> addPayment(PaymentModel payment) async {
    try {
      final paymentMap = payment.toMap();
      await _databaseHelper.insertPayment(paymentMap);
    } catch (e) {
      throw DatabaseException(message: 'Ödeme eklenirken bir hata oluştu: $e');
    }
  }

  /// Bir ödemeyi günceller.
  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _databaseHelper.updatePayment(payment.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme güncellenirken bir hata oluştu: $e',
      );
    }
  }

  /// Bir ödemeyi siler.
  Future<void> deletePayment(String id) async {
    try {
      await _databaseHelper.deletePayment(id);
    } catch (e) {
      throw DatabaseException(message: 'Ödeme silinirken bir hata oluştu: $e');
    }
  }

  /// Bir öğrencinin ücret özetini getirir.
  Future<FeeSummary> getStudentFeeSummary(String studentId) async {
    try {
      // Öğrenci bilgilerini al
      final studentData = await _databaseHelper.getStudent(studentId);
      if (studentData == null) {
        throw const NotFoundException(message: 'Öğrenci bulunamadı');
      }

      // Öğrencinin derslerini al
      final lessons = await _databaseHelper.getLessonsByStudent(studentId);

      // Öğrencinin ödemelerini al
      final payments = await _databaseHelper.getPaymentsByStudent(studentId);

      // Toplam ders ücreti
      double totalAmount = 0;
      for (var lesson in lessons) {
        totalAmount += (lesson['fee'] as num?)?.toDouble() ?? 0;
      }

      // Toplam ödenen miktar
      double paidAmount = 0;
      for (var payment in payments) {
        paidAmount += (payment['paidAmount'] as num?)?.toDouble() ?? 0;
      }

      // Toplam ders sayısı
      final totalLessons = lessons.length;

      // Tamamlanan ders sayısı
      final completedLessons = lessons
          .where((lesson) => lesson['status'] == 'completed')
          .length;

      // Bekleyen ödeme sayısı
      final pendingPayments = payments
          .where(
            (payment) =>
                payment['status'] == 'pending' ||
                payment['status'] == 'partiallyPaid',
          )
          .length;

      // Gecikmiş ödeme sayısı
      final overduePayments = payments
          .where((payment) => payment['status'] == 'overdue')
          .length;

      return FeeSummary(
        id: studentId,
        name: studentData['name'] as String,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        totalLessons: totalLessons,
        completedLessons: completedLessons,
        pendingPayments: pendingPayments,
        overduePayments: overduePayments,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Ücret özeti oluşturulurken bir hata oluştu: $e',
      );
    }
  }

  /// Tüm öğrencilerin ücret özetlerini getirir.
  Future<List<FeeSummary>> getAllStudentFeeSummaries() async {
    try {
      // Tüm öğrencileri al
      final students = await _databaseHelper.getStudents();

      final List<FeeSummary> summaries = [];

      // Her öğrenci için ücret özeti oluştur
      for (var student in students) {
        final studentId = student['id'] as String;
        final summary = await getStudentFeeSummary(studentId);
        summaries.add(summary);
      }

      return summaries;
    } catch (e) {
      throw DatabaseException(
        message: 'Ücret özetleri oluşturulurken bir hata oluştu: $e',
      );
    }
  }
}
