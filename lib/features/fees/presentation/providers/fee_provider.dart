import 'package:flutter/foundation.dart';
import '../../domain/models/fee_model.dart';
import '../../data/repositories/fee_repository.dart';

/// Ücret verilerini yöneten Provider sınıfı.
class FeeProvider extends ChangeNotifier {

  FeeProvider(this._repository) {
    loadFees();
  }
  final FeeRepository _repository;

  List<FeeModel> _fees = [];
  bool _isLoading = false;
  String? _error;

  List<FeeModel> get fees => _fees;
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

  /// Tüm ücretleri veritabanından yükler.
  Future<void> loadFees() async {
    await _executeAction(() async {
      _fees = await _repository.getAllFees();
    });
  }

  /// Belirli bir öğrenciye ait ücretleri yükler.
  Future<void> loadFeesByStudent(String studentId) async {
    await _executeAction(() async {
      _fees = await _repository.getFeesByStudent(studentId);
    });
  }

  /// Ücret ekler ve listeyi yeniler.
  Future<void> addFee(FeeModel fee) async {
    await _executeAction(() => _repository.addFee(fee));
    await loadFees();
  }

  /// Ücret günceller ve listeyi yeniler.
  Future<void> updateFee(FeeModel fee) async {
    await _executeAction(() => _repository.updateFee(fee));
    await loadFees();
  }

  /// Ücret siler ve listeyi yeniler.
  Future<void> deleteFee(String id) async {
    await _executeAction(() => _repository.deleteFee(id));
    await loadFees();
  }
}
