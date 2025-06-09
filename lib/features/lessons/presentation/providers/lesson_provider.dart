import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/lessons/data/repositories/lesson_repository.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson.dart';

class LessonProvider with ChangeNotifier {
  final LessonRepository _repository = LessonRepository();
  List<Lesson> _lessons = [];
  List<Lesson> _dailyLessons = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _error = '';

  List<Lesson> get lessons => _lessons;
  List<Lesson> get dailyLessons => _dailyLessons;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String get error => _error;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadLessonsByDate(date);
  }

  Future<void> loadLessons() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _lessons = await _repository.getAllLessons();
    } catch (e) {
      _error = 'Dersler yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLessonsByDate(DateTime date) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _dailyLessons = await _repository.getLessonsByDate(date);
    } catch (e) {
      _error = 'Günlük dersler yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Lesson>> getLessonsByStudent(String studentId) async {
    try {
      return await _repository.getLessonsByStudent(studentId);
    } catch (e) {
      _error = 'Öğrenci dersleri yüklenirken bir hata oluştu: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> addLesson(Lesson lesson) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.addLesson(lesson);
      await loadLessons();
      await loadLessonsByDate(_selectedDate);
    } catch (e) {
      _error = 'Ders eklenirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLesson(Lesson lesson) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.updateLesson(lesson);
      await loadLessons();
      await loadLessonsByDate(_selectedDate);
    } catch (e) {
      _error = 'Ders güncellenirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLesson(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.deleteLesson(id);
      await loadLessons();
      await loadLessonsByDate(_selectedDate);
    } catch (e) {
      _error = 'Ders silinirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Lesson?> getLesson(String id) async {
    try {
      return await _repository.getLesson(id);
    } catch (e) {
      _error = 'Ders bilgileri alınırken bir hata oluştu: $e';
      notifyListeners();
      return null;
    }
  }
} 