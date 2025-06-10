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
  Future<void> loadPayments({bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      _payments = await _paymentRepository.getAllPayments();
      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödemeler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Öğrenci ödemelerini yükler.
  Future<void> loadPaymentsByStudent(
    String studentId, {
    bool notify = true,
  }) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      _payments = await _paymentRepository.getPaymentsByStudent(studentId);
      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Öğrenci ödemeleri yüklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Öğrenci ücret özetini yükler.
  Future<FeeSummary?> loadStudentFeeSummary(
    String studentId, {
    bool notify = true,
  }) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      final summary = await _paymentRepository.getStudentFeeSummary(studentId);
      _summaries = [summary];
      if (notify) notifyListeners();
      return summary;
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
      return null;
    } catch (e) {
      _error = DatabaseException(
        message:
            'Öğrenci ücret özeti yüklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
      return null;
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Tüm öğrencilerin ücret özetlerini yükler.
  Future<void> loadAllStudentFeeSummaries({bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      _summaries = await _paymentRepository.getAllStudentFeeSummaries();
      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ücret özetleri yüklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Ödeme durumuna göre ödemeleri filtreler.
  void filterByStatus(String status, {bool notify = true}) {
    _filterStatus = status;
    if (notify) {
      notifyListeners();
    }
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
  Future<void> addPayment(Payment payment, {bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      // Doğrulama: Ödeme miktarı pozitif olmalı
      if (payment.amount <= 0) {
        throw const ValidationException(
          message: 'Ödeme miktarı sıfırdan büyük olmalıdır',
        );
      }

      await _paymentRepository.addPayment(payment);
      await loadPayments(notify: notify);
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödeme eklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Ödeme günceller.
  Future<void> updatePayment(Payment payment, {bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      // Doğrulama: Ödeme miktarı pozitif olmalı
      if (payment.amount <= 0) {
        throw const ValidationException(
          message: 'Ödeme miktarı sıfırdan büyük olmalıdır',
        );
      }

      await _paymentRepository.updatePayment(payment);
      await loadPayments(notify: notify);
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödeme güncellenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Ödeme siler.
  Future<void> deletePayment(String id, {bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      await _paymentRepository.deletePayment(id);
      await loadPayments(notify: notify);
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ödeme silinirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
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

  void _setLoading(bool loading, {bool notify = true}) {
    _isLoading = loading;
    if (notify) {
      notifyListeners();
    }
  }

  /// Belirli bir ID'ye sahip ödemeyi döndürür.
  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  /// State değişikliklerini dinleyenlere bildirir. Bu metodu sadece build dışında ve
  /// Future.microtask içinde çağırın.
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
