import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/features/lessons/domain/models/recurring_pattern_model.dart';
import 'package:uuid/uuid.dart';

class RecurringPatternRepository {
  RecurringPatternRepository(this._databaseHelper);
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  Future<RecurringPattern?> getPattern(String id) async {
    final patternMap = await _databaseHelper.getRecurringPattern(id);
    return patternMap != null ? RecurringPattern.fromMap(patternMap) : null;
  }

  Future<void> addPattern(RecurringPattern pattern) async {
    final newPattern = pattern.copyWith(id: _uuid.v4());
    await _databaseHelper.insertRecurringPattern(newPattern.toMap());
  }

  Future<void> updatePattern(RecurringPattern pattern) async {
    await _databaseHelper.updateRecurringPattern(pattern.toMap());
  }

  Future<void> deletePattern(String id) async {
    await _databaseHelper.deleteRecurringPattern(id);
  }
} 