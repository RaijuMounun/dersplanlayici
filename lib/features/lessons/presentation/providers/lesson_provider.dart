import 'package:flutter/foundation.dart';
import '../../domain/models/lesson_model.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/widgets/app_recurring_picker.dart' as ui;
import 'package:intl/intl.dart';
import 'package:ders_planlayici/features/lessons/domain/models/recurring_pattern_model.dart';

/// Ders verilerini yöneten Provider sınıfı.
class LessonProvider extends ChangeNotifier {
  LessonProvider(this._repository) {
    loadLessons();
  }
  final LessonRepository _repository;

  List<Lesson> _allLessons = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  /// Tüm derslerin önbelleğe alınmış listesi.
  List<Lesson> get allLessons => _allLessons;

  /// Seçili tarihe göre filtrelenmiş dersler.
  List<Lesson> get lessonsForSelectedDate {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _allLessons.where((lesson) => lesson.date == dateStr).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  /// Seçili tarihi günceller ve dinleyicileri bilgilendirir.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Belirli bir asenkron işlemi sarmalayan, yükleme ve hata durumlarını yöneten yardımcı.
  Future<T> _executeAction<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tüm dersleri veritabanından yükler ve `_allLessons` listesini günceller.
  Future<void> loadLessons() async {
    await _executeAction(() async {
      _allLessons = await _repository.getAllLessons();
    });
  }

  /// Yeni bir ders ekler.
  /// Çakışma kontrolü repository katmanında yapılır.
  Future<void> addLesson(Lesson lesson) async {
    final hasConflict = await _repository.checkLessonConflict(
      lesson.date,
      lesson.startTime,
      lesson.endTime,
    );

    if (hasConflict) {
      throw const LessonConflictException(
        message: 'Bu saatlerde başka bir ders zaten planlanmış.',
      );
    }

    await _executeAction(() => _repository.addLesson(lesson));
    await loadLessons(); // Yeni ders eklendikten sonra listeyi yenile
  }

  /// Mevcut bir dersi günceller.
  Future<void> updateLesson(Lesson lesson) async {
    final hasConflict = await _repository.checkLessonConflict(
      lesson.date,
      lesson.startTime,
      lesson.endTime,
      lessonId: lesson.id,
    );

    if (hasConflict) {
      throw const LessonConflictException(
        message: 'Bu saatlerde başka bir ders zaten planlanmış.',
      );
    }

    await _executeAction(() => _repository.updateLesson(lesson));
    await loadLessons(); // Ders güncellendikten sonra listeyi yenile
  }

  /// Bir dersi ID'sine göre siler.
  Future<void> deleteLesson(String id) async {
    await _executeAction(() => _repository.deleteLesson(id));
    await loadLessons(); // Ders silindikten sonra listeyi yenile
  }

  Future<Map<String, int>> deleteRecurringLessons(String patternId) async {
    final result = await _executeAction(
      () => _repository.deleteRecurringLessons(patternId),
    );
    await loadLessons();
    return result;
  }

  Future<RecurringPattern?> getRecurringPattern(String patternId) async => _executeAction(
      () => _repository.getRecurringPattern(patternId),
    );

  /// Tekrarlanan bir ders serisi oluşturur.
  Future<void> createRecurringLessons({
    required Lesson baseLesson,
    required ui.RecurringInfo recurringInfo,
    required int occurrences,
  }) async {
    await _executeAction(
      () => _repository.createRecurringLessons(
        baseLesson: baseLesson,
        recurringInfo: recurringInfo,
        occurrences: occurrences,
      ),
    );
    await loadLessons();
  }

  /// ID'ye göre bir dersi getirir.
  Future<Lesson?> getLessonById(String id) async =>
      _executeAction(() => _repository.getLesson(id));
}
