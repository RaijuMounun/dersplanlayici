import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:ders_planlayici/features/fees/data/repositories/payment_transaction_repository.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_transaction_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';

/// Ödeme işlemlerini yöneten provider sınıfı.
class PaymentTransactionProvider with ChangeNotifier {
  PaymentTransactionProvider(this._transactionRepository);
  final PaymentTransactionRepository _transactionRepository;

  bool _isLoading = false;
  String? _currentPaymentId;
  List<PaymentTransactionModel> _transactions = [];
  AppException? _error;

  /// İşlemler listesi
  List<PaymentTransactionModel> get transactions => _transactions;

  /// Yükleniyor mu?
  bool get isLoading => _isLoading;

  /// Hata
  AppException? get error => _error;

  /// Toplam ödenen tutar
  double get totalAmount => _transactions.fold(
    0,
    (previous, transaction) => previous + transaction.amount,
  );

  /// Belirli bir ödemeye ait işlemleri yükler
  Future<void> loadTransactionsByPaymentId(
    String paymentId, {
    bool notify = true,
  }) async {
    _setLoading(true, notify: notify);
    _error = null;
    _currentPaymentId = paymentId;

    try {
      _transactions = await _transactionRepository.getTransactionsByPaymentId(
        paymentId,
      );
      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Ödeme işlemleri yüklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Ödeme işlemi ekler
  Future<void> addTransaction({
    required String paymentId,
    required double amount,
    required PaymentMethod method,
    String? date,
    String? notes,
    String? receiptNo,
    bool notify = true,
  }) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);

      final transaction = PaymentTransactionModel(
        paymentId: paymentId,
        amount: amount,
        date: date ?? today,
        method: method,
        notes: notes,
        receiptNo: receiptNo,
      );

      await _transactionRepository.addTransaction(transaction);

      // İşlem listesini yenile
      if (_currentPaymentId == paymentId) {
        await loadTransactionsByPaymentId(paymentId, notify: false);
      }

      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Ödeme işlemi eklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Ödeme işlemini günceller
  Future<void> updateTransaction({
    required String id,
    required String paymentId,
    required double amount,
    required PaymentMethod method,
    String? date,
    String? notes,
    String? receiptNo,
    bool notify = true,
  }) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      final transaction = PaymentTransactionModel(
        id: id,
        paymentId: paymentId,
        amount: amount,
        date: date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        method: method,
        notes: notes,
        receiptNo: receiptNo,
      );

      await _transactionRepository.updateTransaction(transaction);

      // İşlem listesini yenile
      if (_currentPaymentId == paymentId) {
        await loadTransactionsByPaymentId(paymentId, notify: false);
      }

      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Ödeme işlemi güncellenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Ödeme işlemini siler
  Future<void> deleteTransaction(
    String id,
    String paymentId, {
    bool notify = true,
  }) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      await _transactionRepository.deleteTransaction(id);

      // İşlem listesini yenile
      if (_currentPaymentId == paymentId) {
        await loadTransactionsByPaymentId(paymentId, notify: false);
      }

      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Ödeme işlemi silinirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  void _setLoading(bool loading, {bool notify = true}) {
    _isLoading = loading;
    if (notify) {
      notifyListeners();
    }
  }
}
