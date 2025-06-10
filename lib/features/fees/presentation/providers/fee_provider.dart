import 'package:flutter/foundation.dart';
import '../../domain/models/fee_model.dart';
import '../../../../services/database/database_service.dart';
import '../../../../core/error/app_exception.dart';

/// Ücret verilerini yöneten Provider sınıfı.
class FeeProvider extends ChangeNotifier {
  final DatabaseService _databaseService;

  List<Fee> _fees = [];
  bool _isLoading = false;
  AppException? _error;

  /// Ücret listesini döndürür.
  List<Fee> get fees => _fees;

  /// Yükleme durumunu döndürür.
  bool get isLoading => _isLoading;

  /// Hata durumunu döndürür.
  AppException? get error => _error;

  FeeProvider(this._databaseService);

  /// Tüm ücretleri veritabanından yükler.
  Future<void> loadFees() async {
    _setLoading(true);
    _error = null;

    try {
      final feesData = await _databaseService.query(
        table: 'fees',
        orderBy: 'date DESC',
      );
      _fees = feesData.map((data) => Fee.fromMap(data)).toList();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ücretler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Belirli bir öğrenciye ait ücretleri yükler.
  Future<void> loadFeesByStudent(String studentId) async {
    _setLoading(true);
    _error = null;

    try {
      final feesData = await _databaseService.query(
        table: 'fees',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'date DESC',
      );
      _fees = feesData.map((data) => Fee.fromMap(data)).toList();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Öğrenci ücretleri yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ödeme durumuna göre ücretleri filtreler.
  Future<void> loadFeesByStatus(PaymentStatus status) async {
    _setLoading(true);
    _error = null;

    try {
      final feesData = await _databaseService.query(
        table: 'fees',
        where: 'status = ?',
        whereArgs: [status.toString().split('.').last],
        orderBy: 'date DESC',
      );
      _fees = feesData.map((data) => Fee.fromMap(data)).toList();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Ödeme durumuna göre ücretler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ücret ekler.
  Future<void> addFee(Fee fee) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.insert(table: 'fees', data: fee.toMap());
      await loadFees();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ücret eklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ücret günceller.
  Future<void> updateFee(Fee fee) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.update(
        table: 'fees',
        data: fee.toMap(),
        where: 'id = ?',
        whereArgs: [fee.id],
      );
      await loadFees();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ücret güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ücret siler.
  Future<void> deleteFee(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.delete(
        table: 'fees',
        where: 'id = ?',
        whereArgs: [id],
      );
      await loadFees();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ücret silinirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// ID'ye göre ücret arar.
  Fee? getFeeById(String id) {
    try {
      return _fees.firstWhere((fee) => fee.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Öğrenci ID'sine göre ödenmemiş ücretlerin toplamını hesaplar.
  double getUnpaidTotalForStudent(String studentId) {
    final unpaidFees = _fees.where(
      (fee) => fee.studentId == studentId && fee.status == PaymentStatus.unpaid,
    );

    return unpaidFees.fold(0, (total, fee) => total + fee.amount);
  }

  /// Ödeme durumuna göre ücretleri filtreler.
  List<Fee> filterByStatus(PaymentStatus status) {
    return _fees.where((fee) => fee.status == status).toList();
  }

  /// Belirli bir aya ait ücretleri döndürür.
  List<Fee> getFeesByMonth(String month) {
    return _fees.where((fee) => fee.month == month).toList();
  }

  /// Yükleme durumunu günceller.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
