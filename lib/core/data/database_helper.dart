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
          notes TEXT
        )
      ''');
      developer.log('Öğrenci tablosu oluşturuldu');

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
          FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE
        )
      ''');
      developer.log('Ders tablosu oluşturuldu');
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
}
