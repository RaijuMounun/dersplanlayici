import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';
import 'package:ders_planlayici/features/fees/data/repositories/payment_repository.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:intl/intl.dart';

/// Ödeme işlemlerini yöneten Provider sınıfı.
class PaymentProvider extends ChangeNotifier {

  PaymentProvider(this._repository) {
    loadPayments();
  }
  final PaymentRepository _repository;

  List<PaymentModel> _payments = [];
  List<FeeSummary> _summaries = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentModel> get payments => _payments;
  List<FeeSummary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<T> _executeAction<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tüm ödemeleri yükler.
  Future<void> loadPayments() async {
    await _executeAction(() async {
      _payments = await _repository.getAllPayments();
    });
  }

  /// Öğrenciye ait ödemeleri yükler.
  Future<void> loadPaymentsByStudent(String studentId) async {
    await _executeAction(() async {
      _payments = await _repository.getPaymentsByStudent(studentId);
    });
  }

  /// Tüm öğrencilerin ücret özetlerini yükler.
  Future<void> loadAllStudentFeeSummaries() async {
    await _executeAction(() async {
      _summaries = await _repository.getAllStudentFeeSummaries();
    });
  }

  /// Tek bir öğrencinin ücret özetini yükler.
  Future<FeeSummary?> loadStudentFeeSummary(String studentId) async => _executeAction(() => _repository.getStudentFeeSummary(studentId));

  /// Ödeme ekler.
  Future<void> addPayment(PaymentModel payment) async {
    if (payment.amount <= 0) {
      throw const ValidationException(message: 'Ödeme miktarı sıfırdan büyük olmalıdır');
    }
    await _executeAction(() => _repository.addPayment(payment));
    await loadPayments();
  }

  /// Ödeme günceller.
  Future<void> updatePayment(PaymentModel payment) async {
    if (payment.amount <= 0) {
      throw const ValidationException(message: 'Ödeme miktarı sıfırdan büyük olmalıdır');
    }
    await _executeAction(() => _repository.updatePayment(payment));
    await loadPayments();
  }

  /// Ödeme siler.
  Future<void> deletePayment(String id) async {
    await _executeAction(() => _repository.deletePayment(id));
    await loadPayments();
  }

  /// Ödeme oluşturma helper metodu
  PaymentModel createPayment({
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

    return PaymentModel(
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

  /// Belirli bir ID'ye sahip ödemeyi döndürür.
  PaymentModel? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } on Exception {
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
