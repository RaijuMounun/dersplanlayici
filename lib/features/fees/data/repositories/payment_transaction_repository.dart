import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_transaction_model.dart';

/// Ödeme işlemleri ile ilgili veri işlemlerini yöneten repository sınıfı.
class PaymentTransactionRepository {

  PaymentTransactionRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  /// Belirli bir ödemeye ait tüm işlemleri getirir.
  Future<List<PaymentTransactionModel>> getTransactionsByPaymentId(
    String paymentId,
  ) async {
    try {
      final transactions = await _databaseHelper
          .getPaymentTransactionsByPaymentId(paymentId);
      return transactions
          .map(PaymentTransactionModel.fromMap)
          .toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemleri yüklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Belirli bir işlemi ID'ye göre getirir.
  Future<PaymentTransactionModel?> getTransactionById(String id) async {
    try {
      final transaction = await _databaseHelper.getPaymentTransactionById(id);
      if (transaction != null) {
        return PaymentTransactionModel.fromMap(transaction);
      }
      return null;
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi yüklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Yeni bir ödeme işlemi ekler.
  Future<void> addTransaction(PaymentTransactionModel transaction) async {
    try {
      await _databaseHelper.insertPaymentTransaction(transaction.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi eklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Bir ödeme işlemini günceller.
  Future<void> updateTransaction(PaymentTransactionModel transaction) async {
    try {
      await _databaseHelper.updatePaymentTransaction(transaction.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi güncellenirken bir hata oluştu: $e',
      );
    }
  }

  /// Bir ödeme işlemini siler.
  Future<void> deleteTransaction(String id) async {
    try {
      await _databaseHelper.deletePaymentTransaction(id);
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi silinirken bir hata oluştu: $e',
      );
    }
  }
}
