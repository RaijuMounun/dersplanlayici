import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';
import 'package:ders_planlayici/features/fees/data/repositories/payment_repository.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:intl/intl.dart';

/// Ödeme işlemlerini yöneten Provider sınıfı.
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  List<Payment> _payments = [];
  List<FeeSummary> _summaries = [];
  bool _isLoading = false;
  AppException? _error;
  String _filterStatus = '';

  /// Ödemeleri döndürür.
  List<Payment> get payments => _payments;

  /// Ücret özetlerini döndürür.
  List<FeeSummary> get summaries => _summaries;

  /// Yükleme durumunu döndürür.
  bool get isLoading => _isLoading;

  /// Hata durumunu döndürür.
  AppException? get error => _error;

  PaymentProvider(this._paymentRepository);

  /// Tüm ödemeleri yükler.
  Future<void> loadPayments() async {
    _setLoading(true);
    _error = null;

    try {
      _payments = await _paymentRepository.getAllPayments();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödemeler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Öğrenci ödemelerini yükler.
  Future<void> loadPaymentsByStudent(String studentId) async {
    _setLoading(true);
    _error = null;

    try {
      _payments = await _paymentRepository.getPaymentsByStudent(studentId);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Öğrenci ödemeleri yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Öğrenci ücret özetini yükler.
  Future<FeeSummary?> loadStudentFeeSummary(String studentId) async {
    _setLoading(true);
    _error = null;

    try {
      final summary = await _paymentRepository.getStudentFeeSummary(studentId);
      _summaries = [summary];
      notifyListeners();
      return summary;
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
      return null;
    } catch (e) {
      _error = DatabaseException(
        message:
            'Öğrenci ücret özeti yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Tüm öğrencilerin ücret özetlerini yükler.
  Future<void> loadAllStudentFeeSummaries() async {
    _setLoading(true);
    _error = null;

    try {
      _summaries = await _paymentRepository.getAllStudentFeeSummaries();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ücret özetleri yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ödeme durumuna göre ödemeleri filtreler.
  void filterByStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Filtrelenmiş ödemeleri döndürür.
  List<Payment> get filteredPayments {
    if (_filterStatus.isEmpty) {
      return _payments;
    }
    return _payments
        .where(
          (payment) =>
              payment.status.toString().split('.').last == _filterStatus,
        )
        .toList();
  }

  /// Ödeme ekler.
  Future<void> addPayment(Payment payment) async {
    _setLoading(true);
    _error = null;

    try {
      // Doğrulama: Ödeme miktarı pozitif olmalı
      if (payment.amount <= 0) {
        throw const ValidationException(
          message: 'Ödeme miktarı sıfırdan büyük olmalıdır',
        );
      }

      await _paymentRepository.addPayment(payment);
      await loadPayments();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödeme eklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ödeme günceller.
  Future<void> updatePayment(Payment payment) async {
    _setLoading(true);
    _error = null;

    try {
      // Doğrulama: Ödeme miktarı pozitif olmalı
      if (payment.amount <= 0) {
        throw const ValidationException(
          message: 'Ödeme miktarı sıfırdan büyük olmalıdır',
        );
      }

      await _paymentRepository.updatePayment(payment);
      await loadPayments();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödeme güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ödeme siler.
  Future<void> deletePayment(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _paymentRepository.deletePayment(id);
      await loadPayments();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödeme silinirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ödeme oluşturma helper metodu
  Payment createPayment({
    required String studentId,
    required String studentName,
    required String description,
    required double amount,
    double paidAmount = 0,
    String? date,
    String? dueDate,
    List<String>? lessonIds,
    String? notes,
  }) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    return Payment(
      studentId: studentId,
      studentName: studentName,
      description: description,
      amount: amount,
      paidAmount: paidAmount,
      date: date ?? today,
      dueDate: dueDate,
      status: paidAmount >= amount
          ? PaymentStatus.paid
          : paidAmount > 0
          ? PaymentStatus.partiallyPaid
          : PaymentStatus.pending,
      lessonIds: lessonIds,
      notes: notes,
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Belirli bir ID'ye sahip ödemeyi döndürür.
  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }
}
