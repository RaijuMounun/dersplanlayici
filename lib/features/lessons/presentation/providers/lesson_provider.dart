import 'package:flutter/foundation.dart';
import '../../domain/models/lesson_model.dart';
import '../../domain/models/recurring_pattern_model.dart';
import '../../domain/services/recurring_lesson_service.dart';
import '../../../../core/widgets/app_recurring_picker.dart' as ui;
import '../../../../services/database/database_service.dart';
import '../../../../core/error/app_exception.dart';
import 'package:intl/intl.dart';

/// Ders verilerini yöneten Provider sınıfı.
class LessonProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final RecurringLessonService _recurringLessonService =
      RecurringLessonService();

  List<Lesson> _lessons = [];
  bool _isLoading = false;
  AppException? _error;
  DateTime _selectedDate = DateTime.now();

  /// Ders listesini döndürür.
  List<Lesson> get lessons => _lessons;

  /// Seçili tarihteki dersleri döndürür.
  List<Lesson> get dailyLessons {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _lessons.where((lesson) => lesson.date == dateStr).toList();
  }

  /// Yükleme durumunu döndürür.
  bool get isLoading => _isLoading;

  /// Hata durumunu döndürür.
  AppException? get error => _error;

  /// Seçili tarihi döndürür.
  DateTime get selectedDate => _selectedDate;

  LessonProvider(this._databaseService);

  /// Seçili tarihi ayarlar ve o tarihteki dersleri yükler.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    loadLessonsByDate(dateStr);
    notifyListeners();
  }

  /// Tüm dersleri veritabanından yükler.
  Future<void> loadLessons() async {
    _setLoading(true);
    _error = null;

    try {
      print('🔍 [LessonProvider] Dersler yükleniyor...');
      final lessonsData = await _databaseService.getLessons();
      print(
        '🔍 [LessonProvider] Veritabanından ${lessonsData.length} ders alındı',
      );

      if (lessonsData.isNotEmpty) {
        print('🔍 [LessonProvider] İlk ders verisi: ${lessonsData.first}');
      }

      _lessons = lessonsData.map((data) {
        try {
          final lesson = Lesson.fromMap(data);
          print('🔍 [LessonProvider] Ders oluşturuldu: ${lesson.toString()}');
          return lesson;
        } catch (e) {
          print('❌ [LessonProvider] Ders oluşturma hatası: $e');
          print('❌ [LessonProvider] Hatalı veri: $data');
          rethrow;
        }
      }).toList();

      print('🔍 [LessonProvider] Toplam ${_lessons.length} ders yüklendi');
      notifyListeners();
    } on AppException catch (e) {
      print('❌ [LessonProvider] AppException: $e');
      _error = e;
      notifyListeners();
    } catch (e) {
      print('❌ [LessonProvider] Genel hata: $e');
      _error = DatabaseException(
        message: 'Dersler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Tarih aralığına göre dersleri yükler.
  Future<void> loadLessonsByDateRange(String startDate, String endDate) async {
    _setLoading(true);
    _error = null;

    try {
      final lessonsData = await _databaseService.getLessonsByDateRange(
        startDate,
        endDate,
      );
      _lessons = lessonsData.map((data) => Lesson.fromMap(data)).toList();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Tarih aralığındaki dersler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Belirli bir tarihe göre dersleri yükler.
  Future<void> loadLessonsByDate(String date) async {
    _setLoading(true);
    _error = null;

    try {
      final lessonsData = await _databaseService.getLessonsByDate(date);
      _lessons = lessonsData.map((data) => Lesson.fromMap(data)).toList();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Belirli tarihteki dersler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Öğrenciye göre dersleri yükler.
  Future<void> loadLessonsByStudent(String studentId) async {
    _setLoading(true);
    _error = null;

    try {
      final lessonsData = await _databaseService.getLessonsByStudent(studentId);
      _lessons = lessonsData.map((data) => Lesson.fromMap(data)).toList();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Öğrenciye ait dersler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ders ekler.
  Future<void> addLesson(Lesson lesson) async {
    _setLoading(true);
    _error = null;

    try {
      print('➕ [LessonProvider] Ders ekleniyor: ${lesson.toString()}');

      // Ders çakışması kontrolü
      final hasConflict = await _databaseService.checkLessonConflict(
        date: lesson.date,
        startTime: lesson.startTime,
        endTime: lesson.endTime,
      );

      if (hasConflict) {
        print('⚠️ [LessonProvider] Ders çakışması tespit edildi');
        throw const LessonConflictException(
          message: 'Bu saatlerde başka bir ders zaten planlanmış.',
        );
      }

      print('💾 [LessonProvider] Veritabanına ders kaydediliyor...');
      await _databaseService.insertLesson(lesson.toMap());
      print('✅ [LessonProvider] Ders başarıyla kaydedildi');

      // Dersler listesini yeniden yükle
      print('🔄 [LessonProvider] Dersler listesi yeniden yükleniyor...');
      await loadLessons();
      print('✅ [LessonProvider] Dersler listesi güncellendi');
    } on AppException catch (e) {
      print('❌ [LessonProvider] AppException: $e');
      _error = e;
      notifyListeners();
    } catch (e) {
      print('❌ [LessonProvider] Genel hata: $e');
      _error = DatabaseException(
        message: 'Ders eklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ders günceller.
  Future<void> updateLesson(Lesson lesson) async {
    _setLoading(true);
    _error = null;

    try {
      // Ders çakışması kontrolü (kendi dışındaki derslerle)
      final hasConflict = await _databaseService.checkLessonConflict(
        date: lesson.date,
        startTime: lesson.startTime,
        endTime: lesson.endTime,
        lessonId: lesson.id,
      );

      if (hasConflict) {
        throw const LessonConflictException(
          message: 'Bu saatlerde başka bir ders zaten planlanmış.',
        );
      }

      await _databaseService.updateLesson(lesson.toMap());
      await loadLessons();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ders güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ders siler.
  Future<void> deleteLesson(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.deleteLesson(id);
      await loadLessons();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Ders silinirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Birden fazla dersi siler.
  ///
  /// [ids] - Silinecek derslerin id listesi
  /// Başarılı ve başarısız silme sayılarını içeren bir Map döndürür.
  Future<Map<String, int>> deleteLessons(List<String> ids) async {
    _setLoading(true);
    _error = null;

    int successCount = 0;
    int errorCount = 0;

    try {
      for (var id in ids) {
        try {
          await _databaseService.deleteLesson(id);
          successCount++;
        } catch (e) {
          errorCount++;
        }
      }

      await loadLessons();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Dersler silinirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }

    return {'success': successCount, 'error': errorCount};
  }

  /// Tekrarlanan derslerin tümünü siler.
  ///
  /// [recurringPatternId] - Silinecek tekrarlanan derslerin pattern ID'si
  Future<Map<String, int>> deleteRecurringLessons(
    String recurringPatternId,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      // Tekrarlanan dersleri bul
      final db = await _databaseService.query(
        table: 'lessons',
        where: 'recurringPatternId = ?',
        whereArgs: [recurringPatternId],
      );

      final lessonIds = db.map((e) => e['id'] as String).toList();

      // Tüm dersleri sil
      final result = await deleteLessons(lessonIds);

      // Tekrarlama desenini sil
      await _databaseService.delete(
        table: 'recurring_patterns',
        where: 'id = ?',
        whereArgs: [recurringPatternId],
      );

      return result;
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
      return {'success': 0, 'error': 0};
    } catch (e) {
      _error = DatabaseException(
        message:
            'Tekrarlanan dersler silinirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
      return {'success': 0, 'error': 0};
    } finally {
      _setLoading(false);
    }
  }

  /// Tekrarlanan ders serisi oluşturur.
  ///
  /// [baseLesson] - Temel ders bilgilerini içeren ders nesnesi
  /// [recurringInfo] - Tekrarlama bilgilerini içeren RecurringInfo nesnesi
  /// [occurrences] - Oluşturulacak ders sayısı (mevcut ders dahil değil)
  Future<void> createRecurringLessons({
    required Lesson baseLesson,
    required ui.RecurringInfo recurringInfo,
    required int occurrences,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      if (recurringInfo.type == ui.RecurringType.none) {
        // Tekrarlanmayan ders
        await addLesson(baseLesson);
        return;
      }

      // RecurringPattern oluştur
      final pattern = _recurringLessonService.convertToRecurringPattern(
        recurringInfo: recurringInfo,
        startDate: baseLesson.date,
      );

      // Deseni veritabanına kaydet
      await _databaseService.insert(
        table: 'recurring_patterns',
        data: pattern.toMap(),
      );

      // İlk dersi oluştur ve ID'yi ata
      final firstLesson = baseLesson.copyWith(recurringPatternId: pattern.id);
      await addLesson(firstLesson);

      // Tekrarlanan dersleri oluştur
      final lessons = _recurringLessonService.generateRecurringLessons(
        baseLesson: firstLesson,
        pattern: pattern,
        occurrences: occurrences,
      );

      // Ders çakışma kontrolü
      for (var lesson in lessons) {
        final hasConflict = await _databaseService.checkLessonConflict(
          date: lesson.date,
          startTime: lesson.startTime,
          endTime: lesson.endTime,
        );

        if (hasConflict) {
          throw LessonConflictException(
            message:
                'Çakışma: ${lesson.date} tarihinde ${lesson.startTime} saatinde başka bir ders var.',
          );
        }
      }

      // Tüm dersleri kaydet
      for (var lesson in lessons) {
        await _databaseService.insertLesson(lesson.toMap());
      }

      await loadLessons();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message:
            'Tekrarlanan dersler oluşturulurken hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Tekrarlanan ders desenini getirir.
  Future<RecurringPattern?> getRecurringPattern(String patternId) async {
    try {
      final data = await _databaseService.query(
        table: 'recurring_patterns',
        where: 'id = ?',
        whereArgs: [patternId],
      );

      if (data.isNotEmpty) {
        return RecurringPattern.fromMap(data.first);
      }
      return null;
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
      return null;
    } catch (e) {
      _error = DatabaseException(
        message: 'Tekrarlama deseni alınırken hata oluştu: ${e.toString()}',
      );
      notifyListeners();
      return null;
    }
  }

  /// ID'ye göre ders arar.
  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Belirli bir tarihteki ders sayısını döndürür.
  int getLessonCountForDate(String date) {
    return _lessons.where((lesson) => lesson.date == date).length;
  }

  /// Duruma göre dersleri filtreler.
  List<Lesson> filterByStatus(LessonStatus status) {
    return _lessons.where((lesson) => lesson.status == status).toList();
  }

  /// Yükleme durumunu günceller.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
