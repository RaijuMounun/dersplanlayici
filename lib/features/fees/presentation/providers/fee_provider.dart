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
  String? _currentStudentId; // Mevcut öğrenci filtresini takip eder

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
      _currentStudentId = null;
      _fees = await _repository.getAllFees();
    });
  }

  /// Belirli bir öğrenciye ait ücretleri yükler.
  Future<void> loadFeesByStudent(String studentId) async {
    await _executeAction(() async {
      _currentStudentId = studentId;
      _fees = await _repository.getFeesByStudent(studentId);
    });
  }

  Future<void> _reloadData() async {
    if (_currentStudentId != null) {
      await loadFeesByStudent(_currentStudentId!);
    } else {
      await loadFees();
    }
  }

  /// Ücret ekler ve listeyi yeniler.
  Future<void> addFee(FeeModel fee) async {
    await _executeAction(() => _repository.addFee(fee));
    await _reloadData();
  }

  /// Ücret günceller ve listeyi yeniler.
  Future<void> updateFee(FeeModel fee) async {
    await _executeAction(() => _repository.updateFee(fee));
    await _reloadData();
  }

  /// Ücret siler ve listeyi yeniler.
  Future<void> deleteFee(String id) async {
    await _executeAction(() => _repository.deleteFee(id));
    await _reloadData();
  }
}
