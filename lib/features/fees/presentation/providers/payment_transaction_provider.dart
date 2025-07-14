import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/fees/data/repositories/payment_transaction_repository.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_transaction_model.dart';

/// Ödeme işlemlerini yöneten provider sınıfı.
class PaymentTransactionProvider extends ChangeNotifier {

  PaymentTransactionProvider(this._repository);
  final PaymentTransactionRepository _repository;

  List<PaymentTransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentTransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalAmount => _transactions.fold(0, (sum, item) => sum + item.amount);

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

  /// Belirli bir ödemeye ait işlemleri yükler.
  Future<void> loadTransactionsByPaymentId(String paymentId) async {
    await _executeAction(() async {
      _transactions = await _repository.getTransactionsByPaymentId(paymentId);
    });
  }

  /// Yeni bir ödeme işlemi ekler.
  Future<void> addTransaction(PaymentTransactionModel transaction) async {
    await _executeAction(() => _repository.addTransaction(transaction));
    await loadTransactionsByPaymentId(transaction.paymentId);
  }

  /// Bir ödeme işlemini günceller.
  Future<void> updateTransaction(PaymentTransactionModel transaction) async {
    await _executeAction(() => _repository.updateTransaction(transaction));
    await loadTransactionsByPaymentId(transaction.paymentId);
  }

  /// Bir ödeme işlemini siler.
  Future<void> deleteTransaction(String transactionId, String paymentId) async {
    await _executeAction(() => _repository.deleteTransaction(transactionId));
    await loadTransactionsByPaymentId(paymentId);
  }
}
