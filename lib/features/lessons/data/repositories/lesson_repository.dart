import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/lessons/domain/models/recurring_pattern_model.dart';
import 'package:ders_planlayici/features/lessons/domain/services/recurring_lesson_service.dart';
import 'package:ders_planlayici/features/lessons/data/repositories/recurring_pattern_repository.dart';
import 'package:ders_planlayici/core/widgets/app_recurring_picker.dart' as ui;
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class LessonRepository {

  LessonRepository(
    this._databaseHelper,
    this._recurringLessonService,
    this._recurringPatternRepository,
  );
  final DatabaseHelper _databaseHelper;
  final RecurringLessonService _recurringLessonService;
  final RecurringPatternRepository _recurringPatternRepository;
  final Uuid _uuid = const Uuid();

  Future<List<Lesson>> getAllLessons() async {
    final lessonMaps = await _databaseHelper.getLessons();
    return lessonMaps.map(Lesson.fromMap).toList();
  }

  Future<List<Lesson>> getLessonsByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final lessonMaps = await _databaseHelper.getLessonsByDate(dateStr);
    return lessonMaps.map(Lesson.fromMap).toList();
  }

  Future<List<Lesson>> getLessonsByStudent(String studentId) async {
    final lessonMaps = await _databaseHelper.getLessonsByStudent(studentId);
    return lessonMaps.map(Lesson.fromMap).toList();
  }

  Future<List<Lesson>> getLessonsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final lessonMaps = await _databaseHelper.getLessonsByDateRange(
      startDate,
      endDate,
    );
    return lessonMaps.map(Lesson.fromMap).toList();
  }

  Future<Lesson?> getLesson(String id) async {
    final lessonMap = await _databaseHelper.getLesson(id);
    return lessonMap != null ? Lesson.fromMap(lessonMap) : null;
  }

  Future<void> addLesson(Lesson lesson) async {
    final newLesson = lesson.copyWith(id: _uuid.v4());
    await _databaseHelper.insertLesson(newLesson.toMap());
  }

  Future<void> updateLesson(Lesson lesson) async {
    await _databaseHelper.updateLesson(lesson.toMap());
  }

  Future<void> deleteLesson(String id) async {
    await _databaseHelper.deleteLesson(id);
  }

  Future<Map<String, int>> deleteRecurringLessons(String patternId) async {
    int successCount = 0;
    int errorCount = 0;
    try {
      successCount = await _databaseHelper.deleteLessonsByRecurringPatternId(patternId);
      await _recurringPatternRepository.deletePattern(patternId);
    } on Exception {
      errorCount = successCount; // Assume if pattern fails, lessons might be orphaned
      successCount = 0;
    }
    return {'success': successCount, 'error': errorCount};
  }

  Future<RecurringPattern?> getRecurringPattern(String patternId) async {
    final patternMap = await _databaseHelper.getRecurringPattern(patternId);
    return patternMap != null ? RecurringPattern.fromMap(patternMap) : null;
  }

  Future<void> createRecurringLessons({
    required Lesson baseLesson,
    required ui.RecurringInfo recurringInfo,
    required int occurrences,
  }) async {
    if (recurringInfo.type == ui.RecurringType.none) {
      await addLesson(baseLesson);
      return;
    }

    final pattern = _recurringLessonService.convertToRecurringPattern(
      recurringInfo: recurringInfo,
      startDate: baseLesson.date,
    );

    await _recurringPatternRepository.addPattern(pattern);

    final firstLesson = baseLesson.copyWith(recurringPatternId: pattern.id);
    await addLesson(firstLesson);

    final newLessons = _recurringLessonService.generateRecurringLessons(
      baseLesson: firstLesson,
      pattern: pattern,
      occurrences: occurrences,
    );

    for (var lesson in newLessons) {
      final hasConflict = await checkLessonConflict(
        lesson.date,
        lesson.startTime,
        lesson.endTime,
      );
      if (hasConflict) {
        throw Exception('Lesson conflict detected');
      }
    }

    // Batch insert
    await _databaseHelper.batchInsertLessons(newLessons);
  }

  Future<bool> checkLessonConflict(
    String date,
    String startTime,
    String endTime, {
    String? lessonId,
  }) async => _databaseHelper.checkLessonConflict(
      date: date,
      startTime: startTime,
      endTime: endTime,
      lessonId: lessonId,
    );
}
