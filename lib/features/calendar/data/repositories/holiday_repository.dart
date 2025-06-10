import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/core/error/app_exception.dart' as app_exception;

class HolidayRepository {
  final DatabaseHelper _databaseHelper;

  HolidayRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Tüm tatil günlerini getirir
  Future<List<Map<String, dynamic>>> getAllHolidays() async {
    try {
      return await _databaseHelper.getHolidays();
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tatil günleri alınamadı',
        code: 'get_holidays_failed',
        details: e.toString(),
      );
    }
  }

  /// Tatil günlerini harita olarak getirir (key: tarih, value: tatil adı)
  Future<Map<String, String>> getHolidaysMap() async {
    try {
      return await _databaseHelper.getHolidaysMap();
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tatil günleri haritası alınamadı',
        code: 'get_holidays_map_failed',
        details: e.toString(),
      );
    }
  }

  /// Yeni bir tatil günü ekler
  Future<bool> addHoliday(
    String date,
    String name, {
    bool isNationalHoliday = false,
  }) async {
    try {
      final holiday = {
        'date': date,
        'name': name,
        'isNationalHoliday': isNationalHoliday,
      };

      final result = await _databaseHelper.insertHoliday(holiday);
      return result > 0;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tatil günü eklenemedi',
        code: 'add_holiday_failed',
        details: e.toString(),
      );
    }
  }

  /// Bir tatil gününü günceller
  Future<bool> updateHoliday(
    String date,
    String name, {
    bool isNationalHoliday = false,
  }) async {
    try {
      final holiday = {
        'date': date,
        'name': name,
        'isNationalHoliday': isNationalHoliday,
      };

      final result = await _databaseHelper.updateHoliday(holiday);
      return result > 0;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tatil günü güncellenemedi',
        code: 'update_holiday_failed',
        details: e.toString(),
      );
    }
  }

  /// Bir tatil gününü siler
  Future<bool> deleteHoliday(String date) async {
    try {
      final result = await _databaseHelper.deleteHoliday(date);
      return result > 0;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tatil günü silinemedi',
        code: 'delete_holiday_failed',
        details: e.toString(),
      );
    }
  }

  /// Birden fazla tatil günü ekler
  Future<bool> addMultipleHolidays(
    Map<String, String> holidays, {
    bool isNationalHoliday = false,
  }) async {
    try {
      for (final entry in holidays.entries) {
        await addHoliday(
          entry.key,
          entry.value,
          isNationalHoliday: isNationalHoliday,
        );
      }
      return true;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tatil günleri eklenemedi',
        code: 'add_multiple_holidays_failed',
        details: e.toString(),
      );
    }
  }

  /// Tüm tatil günlerini siler
  Future<bool> deleteAllHolidays() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('holidays');
      return true;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tüm tatil günleri silinemedi',
        code: 'delete_all_holidays_failed',
        details: e.toString(),
      );
    }
  }
}
