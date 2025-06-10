import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../../core/data/database_helper.dart';
import '../../core/error/app_exception.dart';

/// Veritabanı işlemlerini yönetmek için kullanılan servis sınıfı.
///
/// Bu sınıf, veritabanı işlemlerini DatabaseHelper üzerinden yaparak
/// daha üst seviye bir API sağlar ve hata yönetimi yapar.
class DatabaseService {
  final DatabaseHelper _databaseHelper;

  /// DatabaseService sınıfı için constructor.
  ///
  /// [_databaseHelper]: Veritabanı işlemlerini gerçekleştiren helper.
  DatabaseService(this._databaseHelper);

  /// Veritabanı bağlantısını başlatır.
  Future<void> initDatabase() async {
    try {
      await _databaseHelper.database;
    } catch (e) {
      throw const DatabaseException(
        message: 'Veritabanı başlatılırken hata oluştu',
      );
    }
  }

  /// Veritabanı bilgilerini alır.
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      return await _databaseHelper.getDatabaseInfo();
    } catch (e) {
      throw const DatabaseException(
        message: 'Veritabanı bilgileri alınırken hata oluştu',
      );
    }
  }

  /// Öğrenci Operasyonları

  /// Yeni öğrenci ekler.
  Future<int> insertStudent(Map<String, dynamic> student) async {
    try {
      return await _databaseHelper.insertStudent(student);
    } catch (e) {
      throw const DatabaseException(message: 'Öğrenci eklenirken hata oluştu');
    }
  }

  /// Öğrenci bilgilerini günceller.
  Future<int> updateStudent(Map<String, dynamic> student) async {
    try {
      return await _databaseHelper.updateStudent(student);
    } catch (e) {
      throw const DatabaseException(
        message: 'Öğrenci güncellenirken hata oluştu',
      );
    }
  }

  /// Öğrenciyi siler.
  Future<int> deleteStudent(String id) async {
    try {
      return await _databaseHelper.deleteStudent(id);
    } catch (e) {
      throw const DatabaseException(message: 'Öğrenci silinirken hata oluştu');
    }
  }

  /// Tüm öğrencileri getirir.
  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      return await _databaseHelper.getStudents();
    } catch (e) {
      throw const DatabaseException(
        message: 'Öğrenciler alınırken hata oluştu',
      );
    }
  }

  /// Ders Operasyonları

  /// Yeni ders ekler.
  Future<int> insertLesson(Map<String, dynamic> lesson) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert('lessons', lesson);
    } catch (e) {
      throw const DatabaseException(message: 'Ders eklenirken hata oluştu');
    }
  }

  /// Ders bilgilerini günceller.
  Future<int> updateLesson(Map<String, dynamic> lesson) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        'lessons',
        lesson,
        where: 'id = ?',
        whereArgs: [lesson['id']],
      );
    } catch (e) {
      throw const DatabaseException(message: 'Ders güncellenirken hata oluştu');
    }
  }

  /// Dersi siler.
  Future<int> deleteLesson(String id) async {
    try {
      final db = await _databaseHelper.database;
      return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw const DatabaseException(message: 'Ders silinirken hata oluştu');
    }
  }

  /// Tüm dersleri getirir.
  Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      final db = await _databaseHelper.database;
      return await db.query('lessons');
    } catch (e) {
      throw const DatabaseException(message: 'Dersler alınırken hata oluştu');
    }
  }

  /// Belirli bir tarihteki dersleri getirir.
  Future<List<Map<String, dynamic>>> getLessonsByDate(String date) async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        'lessons',
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'startTime ASC',
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Tarihe göre dersler alınırken hata oluştu',
      );
    }
  }

  /// Belirli bir öğrencinin derslerini getirir.
  Future<List<Map<String, dynamic>>> getLessonsByStudent(
    String studentId,
  ) async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        'lessons',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'date DESC, startTime ASC',
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Öğrenci dersleri alınırken hata oluştu',
      );
    }
  }

  /// İki tarih arasındaki dersleri getirir.
  Future<List<Map<String, dynamic>>> getLessonsByDateRange(
    String startDate,
    String endDate,
  ) async {
    try {
      final db = await _databaseHelper.database;
      return await db.rawQuery(
        '''
        SELECT l.*, s.name as studentName
        FROM lessons l
        INNER JOIN students s ON l.studentId = s.id
        WHERE l.date BETWEEN ? AND ?
        ORDER BY l.date, l.startTime
        ''',
        [startDate, endDate],
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Tarih aralığındaki dersler alınırken hata oluştu',
      );
    }
  }

  /// Dersin çakışma kontrolünü yapar.
  Future<bool> checkLessonConflict({
    required String date,
    required String startTime,
    required String endTime,
    String? lessonId,
  }) async {
    try {
      final db = await _databaseHelper.database;
      String sql = '''
        SELECT COUNT(*) as count
        FROM lessons
        WHERE date = ?
        AND (
          (startTime <= ? AND endTime > ?) OR
          (startTime < ? AND endTime >= ?) OR
          (startTime >= ? AND endTime <= ?)
        )
      ''';

      List<Object?> args = [
        date,
        endTime,
        startTime,
        endTime,
        startTime,
        startTime,
        endTime,
      ];

      if (lessonId != null) {
        sql += ' AND id != ?';
        args.add(lessonId);
      }

      final result = await db.rawQuery(sql, args);
      final count = Sqflite.firstIntValue(result);
      return count != null && count > 0;
    } catch (e) {
      throw const DatabaseException(
        message: 'Ders çakışması kontrolü yapılırken hata oluştu',
      );
    }
  }
}
