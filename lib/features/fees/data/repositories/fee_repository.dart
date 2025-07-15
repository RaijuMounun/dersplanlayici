import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_model.dart';
import 'package:uuid/uuid.dart';

class FeeRepository {

  FeeRepository(this._databaseHelper);
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  Future<List<FeeModel>> getAllFees() async {
    final feeMaps = await _databaseHelper.getFees();
    return feeMaps.map(FeeModel.fromMap).toList();
  }

  Future<List<FeeModel>> getFeesByStudent(String studentId) async {
    final feeMaps = await _databaseHelper.getFeesByStudent(studentId);
    return feeMaps.map(FeeModel.fromMap).toList();
  }

  Future<List<FeeModel>> getFeesByStatus(PaymentStatus status) async {
    final statusString = status.toString().split('.').last;
    final feeMaps = await _databaseHelper.getFeesByStatus(statusString);
    return feeMaps.map(FeeModel.fromMap).toList();
  }

  Future<FeeModel?> getFee(String id) async {
    final feeMap = await _databaseHelper.getFee(id);
    return feeMap != null ? FeeModel.fromMap(feeMap) : null;
  }

  Future<void> addFee(FeeModel fee) async {
    final newFee = fee.copyWith(id: _uuid.v4());
    await _databaseHelper.insertFee(newFee.toMap());
  }

  Future<void> updateFee(FeeModel fee) async {
    await _databaseHelper.updateFee(fee.toMap());
  }

  Future<void> deleteFee(String id) async {
    await _databaseHelper.deleteFee(id);
  }
}
