import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class LessonRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<List<Lesson>> getAllLessons() async {
    final lessonMaps = await _databaseHelper.getLessons();
    return lessonMaps.map((map) => Lesson.fromMap(map)).toList();
  }

  Future<List<Lesson>> getLessonsByDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final lessonMaps = await _databaseHelper.getLessonsByDate(dateStr);
    return lessonMaps.map((map) => Lesson.fromMap(map)).toList();
  }

  Future<List<Lesson>> getLessonsByStudent(String studentId) async {
    final lessonMaps = await _databaseHelper.getLessonsByStudent(studentId);
    return lessonMaps.map((map) => Lesson.fromMap(map)).toList();
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
}
