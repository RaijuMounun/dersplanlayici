import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:ders_planlayici/core/error/app_exception.dart'
    as app_exception
    show DatabaseException;
import 'package:ders_planlayici/core/error/error_handler.dart';
import 'dart:convert';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

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
        version: 6,
        onCreate: _createDb,
        onUpgrade: _onUpgradeDb,
        onOpen: (db) {
          developer.log('Veritabanı açıldı: ${db.path}');
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Veritabanı başlatma hatası: $e';
      ErrorHandler.logError(e, stackTrace: stackTrace, hint: errorMessage);
      throw app_exception.DatabaseException(
        message: 'Veritabanı başlatılamadı',
        code: 'db_init_error',
        details: e.toString(),
      );
    }
  }

  /// Veritabanı sürüm yükseltme işlemini gerçekleştirir
  Future<void> _onUpgradeDb(Database db, int oldVersion, int newVersion) async {
    try {
      developer.log('Veritabanı güncelleniyor... $oldVersion -> $newVersion');

      if (oldVersion < 2) {
        // Versiyon 1'den 2'ye geçiş
        // Takvim tabloları
        await db.execute('''
          CREATE TABLE calendar_events(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            type TEXT NOT NULL,
            color TEXT,
            isAllDay INTEGER NOT NULL DEFAULT 0,
            metadata TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        developer.log('Takvim etkinlikleri tablosu oluşturuldu');

        // Ayarlar tablosu
        await db.execute('''
          CREATE TABLE app_settings(
            id TEXT PRIMARY KEY,
            themeMode TEXT NOT NULL,
            lessonNotificationTime TEXT NOT NULL,
            showWeekends INTEGER NOT NULL DEFAULT 1,
            defaultLessonDuration INTEGER NOT NULL DEFAULT 90,
            defaultLessonFee REAL NOT NULL DEFAULT 0,
            currency TEXT,
            defaultSubject TEXT,
            confirmBeforeDelete INTEGER NOT NULL DEFAULT 1,
            showLessonColors INTEGER NOT NULL DEFAULT 1,
            lessonRemindersEnabled INTEGER NOT NULL DEFAULT 1,
            reminderMinutes INTEGER NOT NULL DEFAULT 15,
            paymentRemindersEnabled INTEGER NOT NULL DEFAULT 1,
            birthdayRemindersEnabled INTEGER NOT NULL DEFAULT 1,
            additionalSettings TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        developer.log('Ayarlar tablosu oluşturuldu');

        // Veritabanı yedekleri tablosu
        await db.execute('''
          CREATE TABLE database_backups(
            id TEXT PRIMARY KEY,
            path TEXT NOT NULL,
            fileName TEXT NOT NULL,
            fileSize INTEGER NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        developer.log('Veritabanı yedekleri tablosu oluşturuldu');

        // Holidays tablosu (tatiller)
        await db.execute('''
          CREATE TABLE holidays(
            date TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            isNationalHoliday INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
        developer.log('Tatiller tablosu oluşturuldu');
      }

      if (oldVersion < 3) {
        // Versiyon 2'den 3'e geçiş - Ödemeler tablosunu ekle
        // Ders tablosuna fee (ücret) kolonu ekle
        await db.execute('ALTER TABLE lessons ADD COLUMN fee REAL DEFAULT 0');
        developer.log('Ders tablosuna fee kolonu eklendi');

        // Ödemeler tablosu
        await db.execute('''
          CREATE TABLE payments(
            id TEXT PRIMARY KEY,
            studentId TEXT NOT NULL,
            studentName TEXT NOT NULL,
            description TEXT NOT NULL,
            amount REAL NOT NULL,
            paidAmount REAL DEFAULT 0,
            date TEXT NOT NULL,
            dueDate TEXT,
            status TEXT NOT NULL,
            method TEXT,
            notes TEXT,
            lessonIds TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
        developer.log('Ödemeler tablosu oluşturuldu');

        // Ödeme işlemleri tablosu
        await db.execute('''
          CREATE TABLE payment_transactions(
            id TEXT PRIMARY KEY,
            paymentId TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            method TEXT NOT NULL,
            notes TEXT,
            receiptNo TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (paymentId) REFERENCES payments (id) ON DELETE CASCADE
          )
        ''');
        developer.log('Ödeme işlemleri tablosu oluşturuldu');
      }

      if (oldVersion < 4) {
        // Versiyon 3'ten 4'e geçiş - Ödeme işlemleri tablosunu ekle
        await db.execute('''
          CREATE TABLE payment_transactions(
            id TEXT PRIMARY KEY,
            paymentId TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            method TEXT NOT NULL,
            notes TEXT,
            receiptNo TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (paymentId) REFERENCES payments (id) ON DELETE CASCADE
          )
        ''');
        developer.log('Ödeme işlemleri tablosu oluşturuldu');
      }

      if (oldVersion < 5) {
        // Versiyon 4'ten 5'e geçiş - Notification alanlarını ekle
        try {
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN lessonRemindersEnabled INTEGER NOT NULL DEFAULT 1',
          );
          developer.log('lessonRemindersEnabled kolonu eklendi');
        } on Exception catch (e) {
          developer.log('lessonRemindersEnabled kolonu zaten var: $e');
        }

        try {
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN reminderMinutes INTEGER NOT NULL DEFAULT 15',
          );
          developer.log('reminderMinutes kolonu eklendi');
        } on Exception catch (e) {
          developer.log('reminderMinutes kolonu zaten var: $e');
        }

        try {
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN paymentRemindersEnabled INTEGER NOT NULL DEFAULT 1',
          );
          developer.log('paymentRemindersEnabled kolonu eklendi');
        } on Exception catch (e) {
          developer.log('paymentRemindersEnabled kolonu zaten var: $e');
        }

        try {
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN birthdayRemindersEnabled INTEGER NOT NULL DEFAULT 1',
          );
          developer.log('birthdayRemindersEnabled kolonu eklendi');
        } on Exception catch (e) {
          developer.log('birthdayRemindersEnabled kolonu zaten var: $e');
        }
      }

      if (oldVersion < 6) {
        // Versiyon 5'ten 6'ya geçiş - Eksik tabloları oluştur
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS app_settings(
              id TEXT PRIMARY KEY,
              themeMode TEXT NOT NULL,
              lessonNotificationTime TEXT NOT NULL,
              showWeekends INTEGER NOT NULL DEFAULT 1,
              defaultLessonDuration INTEGER NOT NULL DEFAULT 90,
              defaultLessonFee REAL NOT NULL DEFAULT 0,
              currency TEXT,
              defaultSubject TEXT,
              confirmBeforeDelete INTEGER NOT NULL DEFAULT 1,
              showLessonColors INTEGER NOT NULL DEFAULT 1,
              lessonRemindersEnabled INTEGER NOT NULL DEFAULT 1,
              reminderMinutes INTEGER NOT NULL DEFAULT 15,
              paymentRemindersEnabled INTEGER NOT NULL DEFAULT 1,
              birthdayRemindersEnabled INTEGER NOT NULL DEFAULT 1,
              additionalSettings TEXT,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL
            )
          ''');
          developer.log('app_settings tablosu oluşturuldu (versiyon 6)');
        } on Exception catch (e) {
          developer.log('app_settings tablosu zaten var: $e');
        }

        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS calendar_events(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              date TEXT NOT NULL,
              startTime TEXT NOT NULL,
              endTime TEXT NOT NULL,
              type TEXT NOT NULL,
              color TEXT,
              isAllDay INTEGER NOT NULL DEFAULT 0,
              metadata TEXT,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL
            )
          ''');
          developer.log('calendar_events tablosu oluşturuldu (versiyon 6)');
        } on Exception catch (e) {
          developer.log('calendar_events tablosu zaten var: $e');
        }

        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS database_backups(
              id TEXT PRIMARY KEY,
              path TEXT NOT NULL,
              fileName TEXT NOT NULL,
              fileSize INTEGER NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
          developer.log('database_backups tablosu oluşturuldu (versiyon 6)');
        } on Exception catch (e) {
          developer.log('database_backups tablosu zaten var: $e');
        }

        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS holidays(
              date TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              isNationalHoliday INTEGER NOT NULL DEFAULT 0,
              createdAt TEXT NOT NULL,
              updatedAt TEXT NOT NULL
            )
          ''');
          developer.log('holidays tablosu oluşturuldu (versiyon 6)');
        } on Exception catch (e) {
          developer.log('holidays tablosu zaten var: $e');
        }
      }

      developer.log('Veritabanı başarıyla güncellendi.');
    } catch (e) {
      developer.log('Veritabanı güncelleme hatası: $e');
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
          fee REAL DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
          FOREIGN KEY (recurringPatternId) REFERENCES recurring_patterns (id) ON DELETE SET NULL
        )
      ''');
      developer.log('Ders tablosu oluşturuldu');

      // Ödemeler tablosu
      await db.execute('''
        CREATE TABLE payments(
          id TEXT PRIMARY KEY,
          studentId TEXT NOT NULL,
          studentName TEXT NOT NULL,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          paidAmount REAL DEFAULT 0,
          date TEXT NOT NULL,
          dueDate TEXT,
          status TEXT NOT NULL,
          method TEXT,
          notes TEXT,
          lessonIds TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE
        )
      ''');
      developer.log('Ödemeler tablosu oluşturuldu');

      // Ödeme işlemleri tablosu
      await db.execute('''
        CREATE TABLE payment_transactions(
          id TEXT PRIMARY KEY,
          paymentId TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          method TEXT NOT NULL,
          notes TEXT,
          receiptNo TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (paymentId) REFERENCES payments (id) ON DELETE CASCADE
        )
      ''');
      developer.log('Ödeme işlemleri tablosu oluşturuldu');

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

      // Ayarlar tablosu
      await db.execute('''
        CREATE TABLE app_settings(
          id TEXT PRIMARY KEY,
          themeMode TEXT NOT NULL,
          lessonNotificationTime TEXT NOT NULL,
          showWeekends INTEGER NOT NULL DEFAULT 1,
          defaultLessonDuration INTEGER NOT NULL DEFAULT 90,
          defaultLessonFee REAL NOT NULL DEFAULT 0,
          currency TEXT,
          defaultSubject TEXT,
          confirmBeforeDelete INTEGER NOT NULL DEFAULT 1,
          showLessonColors INTEGER NOT NULL DEFAULT 1,
          lessonRemindersEnabled INTEGER NOT NULL DEFAULT 1,
          reminderMinutes INTEGER NOT NULL DEFAULT 15,
          paymentRemindersEnabled INTEGER NOT NULL DEFAULT 1,
          birthdayRemindersEnabled INTEGER NOT NULL DEFAULT 1,
          additionalSettings TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      developer.log('Ayarlar tablosu oluşturuldu');

      // Takvim etkinlikleri tablosu
      await db.execute('''
        CREATE TABLE calendar_events(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL,
          type TEXT NOT NULL,
          color TEXT,
          isAllDay INTEGER NOT NULL DEFAULT 0,
          metadata TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      developer.log('Takvim etkinlikleri tablosu oluşturuldu');

      // Veritabanı yedekleri tablosu
      await db.execute('''
        CREATE TABLE database_backups(
          id TEXT PRIMARY KEY,
          path TEXT NOT NULL,
          fileName TEXT NOT NULL,
          fileSize INTEGER NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
      developer.log('Veritabanı yedekleri tablosu oluşturuldu');

      // Holidays tablosu (tatiller)
      await db.execute('''
        CREATE TABLE holidays(
          date TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          isNationalHoliday INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      developer.log('Tatiller tablosu oluşturuldu');
    } catch (e) {
      developer.log('Tablo oluşturma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Veritabanı bilgilerini al
  Future<Map<String, dynamic>> getDatabaseInfo() async =>
      ErrorHandler.handleError<Map<String, dynamic>>(() async {
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
          if (tableName != 'android_metadata' &&
              tableName != 'sqlite_sequence') {
            final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
            );
            tableData[tableName] = count;
          }
        }

        return {'path': path, 'tables': tableNames, 'counts': tableData};
      }, errorMessage: 'Veritabanı bilgileri alınamadı');

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

  /// Öğrencileri arama kriterlerine göre arar
  /// [searchTerm] arama terimi
  /// Öğrenci adı, veli adı, sınıf ve notlarda arama yapar
  Future<List<Map<String, dynamic>>> searchStudents(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) {
        return getStudents();
      }

      final db = await database;
      developer.log('Öğrenciler aranıyor, Arama terimi: $searchTerm');

      final query = '%${searchTerm.toLowerCase()}%';

      final result = await db.rawQuery(
        '''
        SELECT * FROM students 
        WHERE lower(name) LIKE ? 
        OR lower(parentName) LIKE ? 
        OR lower(grade) LIKE ? 
        OR lower(notes) LIKE ?
        OR (
          subjects IS NOT NULL AND lower(subjects) LIKE ?
        )
      ''',
        [query, query, query, query, query],
      );

      developer.log(
        '${result.length} öğrenci bulundu, Arama terimi: $searchTerm',
      );
      return result;
    } catch (e) {
      developer.log('Öğrenci arama hatası: $e');
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

      // Gerekli alanları kontrol et
      developer.log('🔍 [DatabaseHelper] Ders verisi detayları:');
      developer.log('  - ID: ${lesson['id']}');
      developer.log('  - StudentID: ${lesson['studentId']}');
      developer.log('  - StudentName: ${lesson['studentName']}');
      developer.log('  - Subject: ${lesson['subject']}');
      developer.log('  - Date: ${lesson['date']}');
      developer.log('  - StartTime: ${lesson['startTime']}');
      developer.log('  - EndTime: ${lesson['endTime']}');
      developer.log('  - Status: ${lesson['status']}');

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
      developer.log('❌ [DatabaseHelper] Ders ekleme hatası: $e');
      developer.log(
        '❌ [DatabaseHelper] Hata stack trace: ${StackTrace.current}',
      );
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
  Future<void> resetDatabase() async => ErrorHandler.handleError<void>(
    () async {
      developer.log('Veritabanı sıfırlanıyor...');
      final db = await database;

      // Tüm tabloları sil
      await db.execute('DROP TABLE IF EXISTS payment_transactions');
      await db.execute('DROP TABLE IF EXISTS payments');
      await db.execute('DROP TABLE IF EXISTS holidays');
      await db.execute('DROP TABLE IF EXISTS database_backups');
      await db.execute('DROP TABLE IF EXISTS app_settings');
      await db.execute('DROP TABLE IF EXISTS calendar_events');
      await db.execute('DROP TABLE IF EXISTS lessons');
      await db.execute('DROP TABLE IF EXISTS recurring_patterns');
      await db.execute('DROP TABLE IF EXISTS students');

      // Veritabanını kapat ve yeniden aç
      await db.close();
      _database = null;
      
      // Yeni veritabanı oluştur
      await database;
      developer.log('Veritabanı başarıyla sıfırlandı');
    },
    errorMessage: 'Veritabanı sıfırlanamadı',
    shouldRethrow: true,
  );

  // Veritabanını yedekler
  Future<String> backupDatabase() async => ErrorHandler.handleError<String>(
    () async {
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
    },
    errorMessage: 'Veritabanı yedeklenemedi',
    shouldRethrow: true,
  );

  // Veritabanını yedekten geri yükler
  Future<void> restoreDatabase(String backupPath) async =>
      ErrorHandler.handleError<void>(
        () async {
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
        },
        errorMessage: 'Veritabanı geri yüklenemedi',
        shouldRethrow: true,
      );

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

  // Takvim etkinlikleri işlemleri
  Future<int> insertCalendarEvent(Map<String, dynamic> event) async {
    try {
      final db = await database;
      developer.log('Takvim etkinliği ekleniyor: ${event['title']}');

      // JSON verilerini string'e dönüştür
      if (event['metadata'] != null && event['metadata'] is Map) {
        event['metadata'] = jsonEncode(event['metadata']);
      }

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      event['createdAt'] = now;
      event['updatedAt'] = now;

      // Boolean değerleri 0/1'e dönüştür
      if (event['isAllDay'] is bool) {
        event['isAllDay'] = event['isAllDay'] ? 1 : 0;
      }

      final result = await db.insert('calendar_events', event);
      developer.log(
        'Takvim etkinliği eklendi, ID: ${event['id']}, Sonuç: $result',
      );
      return result;
    } catch (e) {
      developer.log('Takvim etkinliği ekleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> updateCalendarEvent(Map<String, dynamic> event) async {
    try {
      final db = await database;
      developer.log('Takvim etkinliği güncelleniyor, ID: ${event['id']}');

      // JSON verilerini string'e dönüştür
      if (event['metadata'] != null && event['metadata'] is Map) {
        event['metadata'] = jsonEncode(event['metadata']);
      }

      // Güncelleme tarihini ekle
      event['updatedAt'] = DateTime.now().toIso8601String();

      // Boolean değerleri 0/1'e dönüştür
      if (event['isAllDay'] is bool) {
        event['isAllDay'] = event['isAllDay'] ? 1 : 0;
      }

      return await db.update(
        'calendar_events',
        event,
        where: 'id = ?',
        whereArgs: [event['id']],
      );
    } catch (e) {
      developer.log('Takvim etkinliği güncelleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> deleteCalendarEvent(String id) async {
    try {
      final db = await database;
      developer.log('Takvim etkinliği siliniyor, ID: $id');
      return await db.delete(
        'calendar_events',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Takvim etkinliği silme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCalendarEvents() async {
    try {
      final db = await database;
      developer.log('Tüm takvim etkinlikleri alınıyor');
      final result = await db.query(
        'calendar_events',
        orderBy: 'date, startTime',
      );

      // JSON verilerini Map'e dönüştür
      final processedResult = result.map((event) {
        final Map<String, dynamic> processedEvent = Map.from(event);
        if (processedEvent['metadata'] != null &&
            processedEvent['metadata'] is String) {
          try {
            final metadataString = processedEvent['metadata'] as String;
            if (metadataString.isNotEmpty) {
              processedEvent['metadata'] = jsonDecode(metadataString);
            } else {
              processedEvent['metadata'] = <String, dynamic>{};
            }
          } on FormatException catch (e) {
            developer.log('Metadata JSON dönüştürme hatası: $e');
            processedEvent['metadata'] = <String, dynamic>{};
          }
        } else if (processedEvent['metadata'] == null) {
          processedEvent['metadata'] = <String, dynamic>{};
        }
        // Boolean değerleri dönüştür
        processedEvent['isAllDay'] = processedEvent['isAllDay'] == 1;
        return processedEvent;
      }).toList();

      developer.log('${processedResult.length} takvim etkinliği bulundu');
      return processedResult;
    } on Exception catch (e) {
      developer.log('Takvim etkinlikleri listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCalendarEventsByDate(
    String dateString,
  ) async {
    try {
      final db = await database;
      developer.log('Tarihe göre takvim etkinlikleri alınıyor: $dateString');
      final result = await db.query(
        'calendar_events',
        where: 'date = ?',
        whereArgs: [dateString],
        orderBy: 'startTime',
      );

      // JSON verilerini Map'e dönüştür
      final processedResult = result.map((event) {
        final Map<String, dynamic> processedEvent = Map.from(event);
        if (processedEvent['metadata'] != null) {
          try {
            processedEvent['metadata'] = jsonDecode(
              processedEvent['metadata'] as String,
            );
          } on Exception catch (e) {
            developer.log('Metadata JSON dönüştürme hatası: $e');
          }
        }
        // Boolean değerleri dönüştür
        processedEvent['isAllDay'] = processedEvent['isAllDay'] == 1;
        return processedEvent;
      }).toList();

      developer.log(
        '${processedResult.length} takvim etkinliği bulundu, tarih: $dateString',
      );
      return processedResult;
    } catch (e) {
      developer.log('Tarihe göre takvim etkinlikleri listesi alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCalendarEvent(String id) async {
    try {
      final db = await database;
      developer.log('Takvim etkinliği alınıyor, ID: $id');
      final List<Map<String, dynamic>> result = await db.query(
        'calendar_events',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        final Map<String, dynamic> processedEvent = Map.from(result.first);
        if (processedEvent['metadata'] != null) {
          try {
            processedEvent['metadata'] = jsonDecode(
              processedEvent['metadata'] as String,
            );
          } on Exception catch (e) {
            developer.log('Metadata JSON dönüştürme hatası: $e');
          }
        }
        // Boolean değerleri dönüştür
        processedEvent['isAllDay'] = processedEvent['isAllDay'] == 1;

        developer.log('Takvim etkinliği bulundu, ID: $id');
        return processedEvent;
      } else {
        developer.log('Takvim etkinliği bulunamadı, ID: $id');
        return null;
      }
    } catch (e) {
      developer.log('Takvim etkinliği alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Ayarlar işlemleri
  Future<int> insertOrUpdateAppSettings(Map<String, dynamic> settings) async {
    try {
      final db = await database;
      developer.log('Ayarlar güncelleniyor');

      // JSON verilerini string'e dönüştür
      if (settings['additionalSettings'] != null &&
          settings['additionalSettings'] is Map) {
        settings['additionalSettings'] = jsonEncode(
          settings['additionalSettings'],
        );
      }

      // Boolean değerleri 0/1'e dönüştür
      final boolFields = [
        'showWeekends',
        'confirmBeforeDelete',
        'showLessonColors',
        'lessonRemindersEnabled',
        'paymentRemindersEnabled',
        'birthdayRemindersEnabled',
      ];
      for (final field in boolFields) {
        if (settings[field] is bool) {
          settings[field] = settings[field] ? 1 : 0;
        }
      }

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      settings['updatedAt'] = now;

      // Önce ayarların var olup olmadığını kontrol et
      final List<Map<String, dynamic>> existingSettings = await db.query(
        'app_settings',
      );

      if (existingSettings.isEmpty) {
        // Yeni ayarlar oluştur
        settings['id'] = 'app_settings';
        settings['createdAt'] = now;

        final result = await db.insert('app_settings', settings);
        developer.log('Yeni ayarlar oluşturuldu, Sonuç: $result');
        return result;
      } else {
        // Mevcut ayarları güncelle
        final result = await db.update(
          'app_settings',
          settings,
          where: 'id = ?',
          whereArgs: ['app_settings'],
        );
        developer.log('Ayarlar güncellendi, Sonuç: $result');
        return result;
      }
    } catch (e) {
      developer.log('Ayarlar güncelleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final db = await database;
      developer.log('Ayarlar alınıyor');
      final List<Map<String, dynamic>> result = await db.query('app_settings');

      if (result.isNotEmpty) {
        final Map<String, dynamic> processedSettings = Map.from(result.first);

        // JSON verilerini Map'e dönüştür
        if (processedSettings['additionalSettings'] != null) {
          try {
            processedSettings['additionalSettings'] = jsonDecode(
              processedSettings['additionalSettings'] as String,
            );
          } on Exception catch (e) {
            developer.log('additionalSettings JSON dönüştürme hatası: $e');
          }
        }

        // Boolean değerleri dönüştür
        final boolFields = [
          'showWeekends',
          'confirmBeforeDelete',
          'showLessonColors',
          'lessonRemindersEnabled',
          'paymentRemindersEnabled',
          'birthdayRemindersEnabled',
        ];
        for (final field in boolFields) {
          processedSettings[field] = processedSettings[field] == 1;
        }

        developer.log('Ayarlar bulundu');
        return processedSettings;
      } else {
        developer.log('Ayarlar bulunamadı, varsayılan ayarlar döndürülecek');

        // Varsayılan ayarları döndür
        return {
          'id': 'app_settings',
          'themeMode': 'system',
          'lessonNotificationTime': 'fifteenMinutes',
          'showWeekends': true,
          'defaultLessonDuration': 90,
          'defaultLessonFee': 0.0,
          'currency': 'TL',
          'defaultSubject': null,
          'confirmBeforeDelete': true,
          'showLessonColors': true,
          'lessonRemindersEnabled': true,
          'reminderMinutes': 15,
          'paymentRemindersEnabled': true,
          'birthdayRemindersEnabled': true,
          'additionalSettings': null,
        };
      }
    } catch (e) {
      developer.log('Ayarlar alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Veritabanı yedekleri işlemleri
  Future<int> insertDatabaseBackup(Map<String, dynamic> backup) async {
    try {
      final db = await database;
      developer.log('Veritabanı yedeği kaydediliyor: ${backup['fileName']}');

      // Otomatik id oluştur
      backup['id'] = 'backup_${DateTime.now().millisecondsSinceEpoch}';

      final result = await db.insert('database_backups', backup);
      developer.log(
        'Veritabanı yedeği kaydedildi, ID: ${backup['id']}, Sonuç: $result',
      );
      return result;
    } catch (e) {
      developer.log('Veritabanı yedeği kaydetme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> deleteDatabaseBackup(String id) async {
    try {
      final db = await database;
      developer.log('Veritabanı yedeği siliniyor, ID: $id');
      return await db.delete(
        'database_backups',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Veritabanı yedeği silme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDatabaseBackups() async {
    try {
      final db = await database;
      developer.log('Veritabanı yedekleri alınıyor');
      final result = await db.query(
        'database_backups',
        orderBy: 'createdAt DESC',
      );

      developer.log('${result.length} veritabanı yedeği bulundu');
      return result;
    } catch (e) {
      developer.log('Veritabanı yedekleri alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Tatil günleri işlemleri
  Future<int> insertHoliday(Map<String, dynamic> holiday) async {
    try {
      final db = await database;
      developer.log('Tatil günü ekleniyor: ${holiday['name']}');

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      holiday['createdAt'] = now;
      holiday['updatedAt'] = now;

      // Boolean değerleri 0/1'e dönüştür
      if (holiday['isNationalHoliday'] is bool) {
        holiday['isNationalHoliday'] = holiday['isNationalHoliday'] ? 1 : 0;
      }

      final result = await db.insert('holidays', holiday);
      developer.log(
        'Tatil günü eklendi, Tarih: ${holiday['date']}, Sonuç: $result',
      );
      return result;
    } catch (e) {
      developer.log('Tatil günü ekleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> updateHoliday(Map<String, dynamic> holiday) async {
    try {
      final db = await database;
      developer.log('Tatil günü güncelleniyor, Tarih: ${holiday['date']}');

      // Güncelleme tarihini ekle
      holiday['updatedAt'] = DateTime.now().toIso8601String();

      // Boolean değerleri 0/1'e dönüştür
      if (holiday['isNationalHoliday'] is bool) {
        holiday['isNationalHoliday'] = holiday['isNationalHoliday'] ? 1 : 0;
      }

      return await db.update(
        'holidays',
        holiday,
        where: 'date = ?',
        whereArgs: [holiday['date']],
      );
    } catch (e) {
      developer.log('Tatil günü güncelleme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> deleteHoliday(String date) async {
    try {
      final db = await database;
      developer.log('Tatil günü siliniyor, Tarih: $date');
      return await db.delete('holidays', where: 'date = ?', whereArgs: [date]);
    } catch (e) {
      developer.log('Tatil günü silme hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHolidays() async {
    try {
      final db = await database;
      developer.log('Tüm tatil günleri alınıyor');
      final result = await db.query('holidays', orderBy: 'date');

      // Boolean değerleri dönüştür
      final processedResult = result.map((holiday) {
        final Map<String, dynamic> processedHoliday = Map.from(holiday);
        processedHoliday['isNationalHoliday'] =
            processedHoliday['isNationalHoliday'] == 1;
        return processedHoliday;
      }).toList();

      developer.log('${processedResult.length} tatil günü bulundu');
      return processedResult;
    } catch (e) {
      developer.log('Tatil günleri alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<Map<String, String>> getHolidaysMap() async {
    try {
      final db = await database;
      developer.log('Tatil günleri haritası alınıyor');
      final List<Map<String, dynamic>> holidays = await db.query('holidays');

      final Map<String, String> holidaysMap = {};
      for (final holiday in holidays) {
        holidaysMap[holiday['date'] as String] = holiday['name'] as String;
      }

      developer.log('${holidaysMap.length} tatil günü haritası oluşturuldu');
      return holidaysMap;
    } catch (e) {
      developer.log('Tatil günleri haritası alma hatası: $e');
      developer.log('Hata stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
