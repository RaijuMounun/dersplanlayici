import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_transaction_model.dart';
import 'package:ders_planlayici/services/database/database_service.dart';

/// Ödeme işlemleri ile ilgili veri işlemlerini yöneten repository sınıfı.
class PaymentTransactionRepository {
  final DatabaseService _databaseService;

  PaymentTransactionRepository(this._databaseService);

  /// Belirli bir ödemeye ait tüm işlemleri getirir.
  Future<List<PaymentTransaction>> getTransactionsByPaymentId(
    String paymentId,
  ) async {
    try {
      final transactions = await _databaseService
          .getPaymentTransactionsByPaymentId(paymentId);
      return transactions
          .map((map) => PaymentTransaction.fromMap(map))
          .toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemleri yüklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Belirli bir işlemi ID'ye göre getirir.
  Future<PaymentTransaction?> getTransactionById(String id) async {
    try {
      final transaction = await _databaseService.getPaymentTransactionById(id);
      if (transaction != null) {
        return PaymentTransaction.fromMap(transaction);
      }
      return null;
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi yüklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Yeni bir ödeme işlemi ekler.
  Future<void> addTransaction(PaymentTransaction transaction) async {
    try {
      await _databaseService.insertPaymentTransaction(transaction.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi eklenirken bir hata oluştu: $e',
      );
    }
  }

  /// Bir ödeme işlemini günceller.
  Future<void> updateTransaction(PaymentTransaction transaction) async {
    try {
      await _databaseService.updatePaymentTransaction(transaction.toMap());
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi güncellenirken bir hata oluştu: $e',
      );
    }
  }

  /// Bir ödeme işlemini siler.
  Future<void> deleteTransaction(String id) async {
    try {
      await _databaseService.deletePaymentTransaction(id);
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi silinirken bir hata oluştu: $e',
      );
    }
  }
}
