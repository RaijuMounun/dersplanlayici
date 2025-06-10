import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      developer.log('Veritabanı başlatılıyor...');
      final path = join(await getDatabasesPath(), 'ders_planlayici.db');
      developer.log('Veritabanı yolu: $path');

      // Windows platformunda dosya yolu doğru mu kontrol et
      if (Platform.isWindows) {
        final dbFile = File(path);
        final dbDirectory = Directory(dirname(path));

        if (!dbDirectory.existsSync()) {
          developer.log('Veritabanı dizini oluşturuluyor: ${dbDirectory.path}');
          await dbDirectory.create(recursive: true);
        }

        if (dbFile.existsSync()) {
          developer.log('Veritabanı dosyası zaten var: ${dbFile.path}');
        } else {
          developer.log('Veritabanı dosyası henüz oluşturulmamış');
        }
      }

      // Veritabanını oluştur veya aç
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
        onOpen: (db) {
          developer.log('Veritabanı açıldı: ${db.path}');
        },
      );
    } catch (e) {
      developer.log('Veritabanı başlatma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> _createDb(Database db, int version) async {
    try {
      developer.log('Veritabanı tabloları oluşturuluyor...');

      // Öğrenci tablosu
      await db.execute('''
        CREATE TABLE students(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          grade TEXT NOT NULL,
          parentName TEXT,
          phone TEXT,
          email TEXT,
          subjects TEXT,
          notes TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      developer.log('Öğrenci tablosu oluşturuldu');

      // Tekrarlanan ders desenleri tablosu
      await db.execute('''
        CREATE TABLE recurring_patterns(
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          interval INTEGER NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT,
          daysOfWeek TEXT,
          dayOfMonth INTEGER,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      developer.log('Tekrarlanan ders desenleri tablosu oluşturuldu');

      // Ders tablosu
      await db.execute('''
        CREATE TABLE lessons(
          id TEXT PRIMARY KEY,
          studentId TEXT NOT NULL,
          studentName TEXT NOT NULL,
          subject TEXT NOT NULL,
          topic TEXT,
          date TEXT NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          status TEXT NOT NULL,
          notes TEXT,
          recurringPatternId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
          FOREIGN KEY (recurringPatternId) REFERENCES recurring_patterns (id) ON DELETE SET NULL
        )
      ''');
      developer.log('Ders tablosu oluşturuldu');

      // Ücret tablosu
      await db.execute('''
        CREATE TABLE fees(
          id TEXT PRIMARY KEY,
          studentId TEXT NOT NULL,
          studentName TEXT NOT NULL,
          amount REAL NOT NULL,
          paidAmount REAL,
          date TEXT NOT NULL,
          status TEXT NOT NULL,
          paymentType TEXT,
          paymentDate TEXT,
          notes TEXT,
          month TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE
        )
      ''');
      developer.log('Ücret tablosu oluşturuldu');
    } catch (e) {
      developer.log('Tablo oluşturma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Veritabanı bilgilerini al
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final path = db.path;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables
          .map((table) => table['name'] as String)
          .toList();

      final Map<String, dynamic> tableData = {};
      for (String tableName in tableNames) {
        if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
          final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
          );
          tableData[tableName] = count;
        }
      }

      return {'path': path, 'tables': tableNames, 'counts': tableData};
    } catch (e) {
      developer.log('Veritabanı bilgileri alınırken hata: $e');
      return {'error': e.toString()};
    }
  }

  // Öğrenci işlemleri
  Future<int> insertStudent(Map<String, dynamic> student) async {
    try {
      final db = await database;
      developer.log('Öğrenci ekleniyor: ${student['name']}');

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      student['createdAt'] = now;
      student['updatedAt'] = now;

      developer.log('Öğrenci verisi: $student');

      final result = await db.insert('students', student);
      developer.log('Öğrenci eklendi, ID: ${student['id']}, Sonuç: $result');

      // Veritabanı durumunu kontrol et
      final dbInfo = await getDatabaseInfo();
      developer.log('Güncel veritabanı durumu: $dbInfo');

      return result;
    } catch (e) {
      developer.log('Öğrenci ekleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> updateStudent(Map<String, dynamic> student) async {
    try {
      final db = await database;
      developer.log('Öğrenci güncelleniyor, ID: ${student['id']}');

      // Güncelleme tarihini ekle
      student['updatedAt'] = DateTime.now().toIso8601String();

      return await db.update(
        'students',
        student,
        where: 'id = ?',
        whereArgs: [student['id']],
      );
    } catch (e) {
      developer.log('Öğrenci güncelleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> deleteStudent(String id) async {
    try {
      final db = await database;
      developer.log('Öğrenci siliniyor, ID: $id');
      return await db.delete('students', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Öğrenci silme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final db = await database;
      developer.log('Tüm öğrenciler alınıyor');
      final result = await db.query('students');
      developer.log('${result.length} öğrenci bulundu');

      // Detaylı bilgi
      if (result.isNotEmpty) {
        developer.log('İlk öğrenci: ${result.first}');
      }

      return result;
    } catch (e) {
      developer.log('Öğrenci listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getStudent(String id) async {
    try {
      final db = await database;
      developer.log('Öğrenci alınıyor, ID: $id');
      final List<Map<String, dynamic>> result = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        developer.log('Öğrenci bulundu: ${result.first['name']}');
      } else {
        developer.log('Öğrenci bulunamadı, ID: $id');
      }
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      developer.log('Öğrenci alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Ders işlemleri
  Future<int> insertLesson(Map<String, dynamic> lesson) async {
    try {
      final db = await database;
      developer.log(
        'Ders ekleniyor: ${lesson['subject']} - ${lesson['studentName']}',
      );

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      lesson['createdAt'] = now;
      lesson['updatedAt'] = now;

      developer.log('Ders verisi: $lesson');

      final result = await db.insert('lessons', lesson);
      developer.log('Ders eklendi, ID: ${lesson['id']}, Sonuç: $result');

      // Veritabanı durumunu kontrol et
      final dbInfo = await getDatabaseInfo();
      developer.log('Güncel veritabanı durumu: $dbInfo');

      return result;
    } catch (e) {
      developer.log('Ders ekleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> updateLesson(Map<String, dynamic> lesson) async {
    try {
      final db = await database;
      developer.log('Ders güncelleniyor, ID: ${lesson['id']}');

      // Güncelleme tarihini ekle
      lesson['updatedAt'] = DateTime.now().toIso8601String();

      return await db.update(
        'lessons',
        lesson,
        where: 'id = ?',
        whereArgs: [lesson['id']],
      );
    } catch (e) {
      developer.log('Ders güncelleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> deleteLesson(String id) async {
    try {
      final db = await database;
      developer.log('Ders siliniyor, ID: $id');
      return await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Ders silme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      final db = await database;
      developer.log('Tüm dersler alınıyor');
      final result = await db.query('lessons', orderBy: 'date, startTime');
      developer.log('${result.length} ders bulundu');

      // Detaylı bilgi
      if (result.isNotEmpty) {
        developer.log('İlk ders: ${result.first}');
      }

      return result;
    } catch (e) {
      developer.log('Ders listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLessonsByDate(String dateString) async {
    try {
      final db = await database;
      developer.log('Tarihe göre dersler alınıyor: $dateString');
      final result = await db.query(
        'lessons',
        where: 'date = ?',
        whereArgs: [dateString],
        orderBy: 'startTime',
      );
      developer.log('${result.length} ders bulundu, tarih: $dateString');
      return result;
    } catch (e) {
      developer.log('Tarihe göre ders listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLessonsByStudent(
    String studentId,
  ) async {
    try {
      final db = await database;
      developer.log('Öğrenciye göre dersler alınıyor, Öğrenci ID: $studentId');
      final result = await db.query(
        'lessons',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'date DESC, startTime',
      );
      developer.log('${result.length} ders bulundu, Öğrenci ID: $studentId');
      return result;
    } catch (e) {
      developer.log('Öğrenciye göre ders listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getLesson(String id) async {
    try {
      final db = await database;
      developer.log('Ders alınıyor, ID: $id');
      final List<Map<String, dynamic>> result = await db.query(
        'lessons',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        developer.log('Ders bulundu, ID: $id');
      } else {
        developer.log('Ders bulunamadı, ID: $id');
      }
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      developer.log('Ders alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Veritabanını sıfırlar ve yeniden oluşturur
  Future<void> resetDatabase() async {
    try {
      developer.log('Veritabanı sıfırlanıyor...');
      final db = await database;

      // Tüm tabloları sil
      await db.execute('DROP TABLE IF EXISTS fees');
      await db.execute('DROP TABLE IF EXISTS lessons');
      await db.execute('DROP TABLE IF EXISTS recurring_patterns');
      await db.execute('DROP TABLE IF EXISTS students');

      // Tabloları yeniden oluştur
      await _createDb(db, 1);
      developer.log('Veritabanı başarıyla sıfırlandı');
    } catch (e) {
      developer.log('Veritabanı sıfırlama hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Veritabanını yedekler
  Future<String> backupDatabase() async {
    try {
      developer.log('Veritabanı yedekleniyor...');
      final db = await database;
      final dbPath = db.path;

      // Yedek dosya yolu
      final backupPath = '$dbPath.backup';

      // Veritabanı dosyasını kopyala
      final dbFile = File(dbPath);
      await dbFile.copy(backupPath);

      developer.log('Veritabanı başarıyla yedeklendi: $backupPath');
      return backupPath;
    } catch (e) {
      developer.log('Veritabanı yedekleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Veritabanını yedekten geri yükler
  Future<void> restoreDatabase(String backupPath) async {
    try {
      developer.log('Veritabanı geri yükleniyor...');
      final db = await database;
      await db.close();

      final dbPath = join(await getDatabasesPath(), 'ders_planlayici.db');

      // Yedek dosyasını kopyala
      final backupFile = File(backupPath);
      await backupFile.copy(dbPath);

      // Veritabanını yeniden aç
      _database = null;
      await database;

      developer.log('Veritabanı başarıyla geri yüklendi');
    } catch (e) {
      developer.log('Veritabanı geri yükleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Tekrarlanan ders desenleri işlemleri
  Future<int> insertRecurringPattern(Map<String, dynamic> pattern) async {
    try {
      final db = await database;
      developer.log('Tekrarlanan ders deseni ekleniyor: ${pattern['id']}');

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      pattern['createdAt'] = now;
      pattern['updatedAt'] = now;

      final result = await db.insert('recurring_patterns', pattern);
      developer.log('Tekrarlanan ders deseni eklendi, ID: ${pattern['id']}');
      return result;
    } catch (e) {
      developer.log('Tekrarlanan ders deseni ekleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> updateRecurringPattern(Map<String, dynamic> pattern) async {
    try {
      final db = await database;
      developer.log(
        'Tekrarlanan ders deseni güncelleniyor, ID: ${pattern['id']}',
      );

      // Güncelleme tarihini ekle
      pattern['updatedAt'] = DateTime.now().toIso8601String();

      return await db.update(
        'recurring_patterns',
        pattern,
        where: 'id = ?',
        whereArgs: [pattern['id']],
      );
    } catch (e) {
      developer.log('Tekrarlanan ders deseni güncelleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> deleteRecurringPattern(String id) async {
    try {
      final db = await database;
      developer.log('Tekrarlanan ders deseni siliniyor, ID: $id');
      return await db.delete(
        'recurring_patterns',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Tekrarlanan ders deseni silme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getRecurringPattern(String id) async {
    try {
      final db = await database;
      developer.log('Tekrarlanan ders deseni alınıyor, ID: $id');
      final List<Map<String, dynamic>> result = await db.query(
        'recurring_patterns',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      developer.log('Tekrarlanan ders deseni alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Ücret işlemleri
  Future<int> insertFee(Map<String, dynamic> fee) async {
    try {
      final db = await database;
      developer.log('Ücret ekleniyor: ${fee['id']}');

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      fee['createdAt'] = now;
      fee['updatedAt'] = now;

      final result = await db.insert('fees', fee);
      developer.log('Ücret eklendi, ID: ${fee['id']}');
      return result;
    } catch (e) {
      developer.log('Ücret ekleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> updateFee(Map<String, dynamic> fee) async {
    try {
      final db = await database;
      developer.log('Ücret güncelleniyor, ID: ${fee['id']}');

      // Güncelleme tarihini ekle
      fee['updatedAt'] = DateTime.now().toIso8601String();

      return await db.update(
        'fees',
        fee,
        where: 'id = ?',
        whereArgs: [fee['id']],
      );
    } catch (e) {
      developer.log('Ücret güncelleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> deleteFee(String id) async {
    try {
      final db = await database;
      developer.log('Ücret siliniyor, ID: $id');
      return await db.delete('fees', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      developer.log('Ücret silme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getFee(String id) async {
    try {
      final db = await database;
      developer.log('Ücret alınıyor, ID: $id');
      final List<Map<String, dynamic>> result = await db.query(
        'fees',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      developer.log('Ücret alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFeesByStudent(String studentId) async {
    try {
      final db = await database;
      developer.log('Öğrenciye göre ücretler alınıyor, Öğrenci ID: $studentId');
      final result = await db.query(
        'fees',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'date DESC',
      );
      return result;
    } catch (e) {
      developer.log('Öğrenciye göre ücret listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFeesByStatus(String status) async {
    try {
      final db = await database;
      developer.log('Duruma göre ücretler alınıyor, Durum: $status');
      final result = await db.query(
        'fees',
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'date DESC',
      );
      return result;
    } catch (e) {
      developer.log('Duruma göre ücret listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFeesByMonth(String month) async {
    try {
      final db = await database;
      developer.log('Aya göre ücretler alınıyor, Ay: $month');
      final result = await db.query(
        'fees',
        where: 'month = ?',
        whereArgs: [month],
        orderBy: 'date DESC',
      );
      return result;
    } catch (e) {
      developer.log('Aya göre ücret listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
