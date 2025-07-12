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

  /// Verilen tablo ve kolon adlarıyla sorgu yapar.
  ///
  /// [table]: Sorgulanacak tablo adı.
  /// [columns]: Getirilecek kolonlar (null ise tüm kolonlar).
  /// [where]: WHERE koşulu.
  /// [whereArgs]: WHERE koşulu için argümanlar.
  /// [orderBy]: ORDER BY koşulu.
  /// [limit]: Maksimum satır sayısı.
  Future<List<Map<String, dynamic>>> query({
    required String table,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Veri sorgularken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Verilen tabloya bir satır ekler.
  ///
  /// [table]: Veri eklenecek tablo adı.
  /// [data]: Eklenecek veri.
  Future<int> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert(table, data);
    } catch (e) {
      throw DatabaseException(
        message: 'Veri eklerken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Verilen tablodaki bir satırı günceller.
  ///
  /// [table]: Güncelleme yapılacak tablo adı.
  /// [data]: Güncellenecek veri.
  /// [where]: WHERE koşulu.
  /// [whereArgs]: WHERE koşulu için argümanlar.
  Future<int> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(table, data, where: where, whereArgs: whereArgs);
    } catch (e) {
      throw DatabaseException(
        message: 'Veri güncellerken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Verilen tablodaki bir satırı siler.
  ///
  /// [table]: Silme işlemi yapılacak tablo adı.
  /// [where]: WHERE koşulu.
  /// [whereArgs]: WHERE koşulu için argümanlar.
  Future<int> delete({
    required String table,
    required String where,
    required List<Object?> whereArgs,
  }) async {
    try {
      final db = await _databaseHelper.database;
      return await db.delete(table, where: where, whereArgs: whereArgs);
    } catch (e) {
      throw DatabaseException(
        message: 'Veri silerken hata oluştu: ${e.toString()}',
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

  /// Arama kriterlerine göre öğrencileri arar.
  Future<List<Map<String, dynamic>>> searchStudents(String searchTerm) async {
    try {
      return await _databaseHelper.searchStudents(searchTerm);
    } catch (e) {
      throw DatabaseException(
        message: 'Öğrenci araması yapılırken hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Ders Operasyonları

  /// Yeni ders ekler.
  Future<int> insertLesson(Map<String, dynamic> lesson) async {
    try {
      print('🔍 [DatabaseService] insertLesson çağrıldı');
      print('🔍 [DatabaseService] Ders verisi: $lesson');

      final db = await _databaseHelper.database;
      print('🔍 [DatabaseService] Veritabanı bağlantısı alındı');

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      lesson['createdAt'] = now;
      lesson['updatedAt'] = now;

      print(
        '🔍 [DatabaseService] Tarih alanları eklendi: createdAt=$now, updatedAt=$now',
      );

      final result = await db.insert('lessons', lesson);
      print('🔍 [DatabaseService] Ders başarıyla eklendi, sonuç: $result');

      return result;
    } catch (e) {
      print('❌ [DatabaseService] Ders ekleme hatası: $e');
      print('❌ [DatabaseService] Hata stack trace: ${StackTrace.current}');
      throw const DatabaseException(message: 'Ders eklenirken hata oluştu');
    }
  }

  /// Ders bilgilerini günceller.
  Future<int> updateLesson(Map<String, dynamic> lesson) async {
    try {
      final db = await _databaseHelper.database;

      // Güncelleme tarihini ekle
      lesson['updatedAt'] = DateTime.now().toIso8601String();

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

  /// Ödeme Operasyonları

  /// Yeni ödeme ekler.
  Future<int> insertPayment(Map<String, dynamic> payment) async {
    try {
      final db = await _databaseHelper.database;
      return await db.insert('payments', payment);
    } catch (e) {
      throw const DatabaseException(message: 'Ödeme eklenirken hata oluştu');
    }
  }

  /// Ödeme bilgilerini günceller.
  Future<int> updatePayment(Map<String, dynamic> payment) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        'payments',
        payment,
        where: 'id = ?',
        whereArgs: [payment['id']],
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Ödeme güncellenirken hata oluştu',
      );
    }
  }

  /// Ödemeyi siler.
  Future<int> deletePayment(String id) async {
    try {
      final db = await _databaseHelper.database;
      return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw const DatabaseException(message: 'Ödeme silinirken hata oluştu');
    }
  }

  /// Tüm ödemeleri getirir.
  Future<List<Map<String, dynamic>>> getPayments() async {
    try {
      final db = await _databaseHelper.database;
      return await db.query('payments', orderBy: 'date DESC');
    } catch (e) {
      throw const DatabaseException(message: 'Ödemeler alınırken hata oluştu');
    }
  }

  /// Belirli bir ödemeyi getirir.
  Future<Map<String, dynamic>?> getPaymentById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        'payments',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw const DatabaseException(message: 'Ödeme alınırken hata oluştu');
    }
  }

  /// Belirli bir öğrencinin ödemelerini getirir.
  Future<List<Map<String, dynamic>>> getPaymentsByStudent(
    String studentId,
  ) async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        'payments',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'date DESC',
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Öğrenci ödemeleri alınırken hata oluştu',
      );
    }
  }

  /// Belirli bir tarih aralığındaki ödemeleri getirir.
  Future<List<Map<String, dynamic>>> getPaymentsByDateRange(
    String startDate,
    String endDate,
  ) async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        'payments',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date DESC',
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Tarih aralığındaki ödemeler alınırken hata oluştu',
      );
    }
  }

  /// Belirli bir ödeme durumuna göre ödemeleri getirir.
  Future<List<Map<String, dynamic>>> getPaymentsByStatus(String status) async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        'payments',
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'date DESC',
      );
    } catch (e) {
      throw const DatabaseException(
        message: 'Ödeme durumuna göre ödemeler alınırken hata oluştu',
      );
    }
  }

  /// Belirli bir öğrencinin ID'sine göre öğrenciyi getirir.
  Future<Map<String, dynamic>?> getStudentById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw const DatabaseException(message: 'Öğrenci alınırken hata oluştu');
    }
  }

  /// Ödeme işlemi ekler.
  Future<int> insertPaymentTransaction(Map<String, dynamic> transaction) async {
    try {
      final db = await _databaseHelper.database;

      // Tarih alanlarını ekle
      final now = DateTime.now().toIso8601String();
      transaction['createdAt'] = now;
      transaction['updatedAt'] = now;

      // İşlemi ekle
      final result = await db.insert('payment_transactions', transaction);

      // İlgili ödeme kaydının paidAmount alanını güncelle
      final paymentId = transaction['paymentId'];
      final amount = transaction['amount'] as double;

      // Mevcut ödeme kaydını al
      final List<Map<String, dynamic>> payments = await db.query(
        'payments',
        where: 'id = ?',
        whereArgs: [paymentId],
      );

      if (payments.isNotEmpty) {
        final payment = payments.first;
        final currentPaidAmount = (payment['paidAmount'] as num).toDouble();
        final totalAmount = (payment['amount'] as num).toDouble();
        final newPaidAmount = currentPaidAmount + amount;

        // Ödeme durumunu belirle
        String status;
        if (newPaidAmount >= totalAmount) {
          status = 'paid';
        } else if (newPaidAmount > 0) {
          status = 'partiallyPaid';
        } else {
          status = 'pending';
        }

        // Ödeme kaydını güncelle
        await db.update(
          'payments',
          {'paidAmount': newPaidAmount, 'status': status, 'updatedAt': now},
          where: 'id = ?',
          whereArgs: [paymentId],
        );
      }

      return result;
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi eklenirken hata oluştu: $e',
      );
    }
  }

  /// Ödeme işlemini günceller.
  Future<int> updatePaymentTransaction(Map<String, dynamic> transaction) async {
    try {
      final db = await _databaseHelper.database;

      // Güncelleme tarihini ekle
      transaction['updatedAt'] = DateTime.now().toIso8601String();

      // Mevcut işlemi al
      final List<Map<String, dynamic>> oldTransactions = await db.query(
        'payment_transactions',
        where: 'id = ?',
        whereArgs: [transaction['id']],
      );

      if (oldTransactions.isEmpty) {
        throw Exception('Güncellenecek ödeme işlemi bulunamadı');
      }

      final oldTransaction = oldTransactions.first;
      final oldAmount = (oldTransaction['amount'] as num).toDouble();
      final newAmount = (transaction['amount'] as num).toDouble();
      final paymentId = transaction['paymentId'] as String;

      // Ödeme kaydını güncelle
      if (oldAmount != newAmount) {
        // Mevcut ödemeyi al
        final List<Map<String, dynamic>> payments = await db.query(
          'payments',
          where: 'id = ?',
          whereArgs: [paymentId],
        );

        if (payments.isNotEmpty) {
          final payment = payments.first;
          final currentPaidAmount = (payment['paidAmount'] as num).toDouble();
          final totalAmount = (payment['amount'] as num).toDouble();

          // Eski miktarı çıkar, yeni miktarı ekle
          final newPaidAmount = currentPaidAmount - oldAmount + newAmount;

          // Ödeme durumunu belirle
          String status;
          if (newPaidAmount >= totalAmount) {
            status = 'paid';
          } else if (newPaidAmount > 0) {
            status = 'partiallyPaid';
          } else {
            status = 'pending';
          }

          // Ödeme kaydını güncelle
          await db.update(
            'payments',
            {
              'paidAmount': newPaidAmount,
              'status': status,
              'updatedAt': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [paymentId],
          );
        }
      }

      return await db.update(
        'payment_transactions',
        transaction,
        where: 'id = ?',
        whereArgs: [transaction['id']],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi güncellenirken hata oluştu: $e',
      );
    }
  }

  /// Ödeme işlemini siler.
  Future<int> deletePaymentTransaction(String id) async {
    try {
      final db = await _databaseHelper.database;

      // İşlem bilgilerini al
      final List<Map<String, dynamic>> transactions = await db.query(
        'payment_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (transactions.isEmpty) {
        throw Exception('Silinecek ödeme işlemi bulunamadı');
      }

      final transaction = transactions.first;
      final amount = (transaction['amount'] as num).toDouble();
      final paymentId = transaction['paymentId'] as String;

      // İlgili ödeme kaydını güncelle
      final List<Map<String, dynamic>> payments = await db.query(
        'payments',
        where: 'id = ?',
        whereArgs: [paymentId],
      );

      if (payments.isNotEmpty) {
        final payment = payments.first;
        final currentPaidAmount = (payment['paidAmount'] as num).toDouble();
        final totalAmount = (payment['amount'] as num).toDouble();
        final newPaidAmount = currentPaidAmount - amount;

        // Ödeme durumunu belirle
        String status;
        if (newPaidAmount >= totalAmount) {
          status = 'paid';
        } else if (newPaidAmount > 0) {
          status = 'partiallyPaid';
        } else {
          status = 'pending';
        }

        // Ödeme kaydını güncelle
        await db.update(
          'payments',
          {
            'paidAmount': newPaidAmount,
            'status': status,
            'updatedAt': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [paymentId],
        );
      }

      return await db.delete(
        'payment_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi silinirken hata oluştu: $e',
      );
    }
  }

  /// Belirli bir ödemeye ait işlemleri getirir.
  Future<List<Map<String, dynamic>>> getPaymentTransactionsByPaymentId(
    String paymentId,
  ) async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        'payment_transactions',
        where: 'paymentId = ?',
        whereArgs: [paymentId],
        orderBy: 'date DESC',
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemleri alınırken hata oluştu: $e',
      );
    }
  }

  /// Belirli bir ödeme işlemini getirir.
  Future<Map<String, dynamic>?> getPaymentTransactionById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        'payment_transactions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      throw DatabaseException(
        message: 'Ödeme işlemi alınırken hata oluştu: $e',
      );
    }
  }
}
