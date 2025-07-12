import 'package:flutter/foundation.dart';
import '../../domain/models/student_model.dart';
import '../../../../services/database/database_service.dart';
import '../../../../core/error/app_exception.dart';
import 'package:collection/collection.dart';

/// Öğrenci verilerini yöneten Provider sınıfı.
class StudentProvider extends ChangeNotifier {
  StudentProvider(this._databaseService);
  final DatabaseService _databaseService;

  List<Student> _students = [];
  bool _isLoading = false;
  AppException? _error;

  /// Öğrenci listesini döndürür.
  List<Student> get students => _students;

  /// Yükleme durumunu döndürür.
  bool get isLoading => _isLoading;

  /// Hata durumunu döndürür.
  AppException? get error => _error;

  /// Tüm öğrencileri veritabanından yükler.
  Future<void> loadStudents({bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      final studentsData = await _databaseService.getStudents();
      _students = studentsData.map(Student.fromMap).toList();
      if (notify) notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Öğrenciler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Öğrenci ekler.
  Future<void> addStudent(Student student, {bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      await _databaseService.insertStudent(student.toMap());
      await loadStudents(notify: notify);
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci eklenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Öğrenci günceller.
  Future<void> updateStudent(Student student, {bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      await _databaseService.updateStudent(student.toMap());
      await loadStudents(notify: notify);
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci güncellenirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Öğrenci siler.
  Future<void> deleteStudent(String id, {bool notify = true}) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      await _databaseService.deleteStudent(id);
      await loadStudents(notify: notify);
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci silinirken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// ID'ye göre öğrenci arar.
  Student? getStudentById(String id) => _students.firstWhereOrNull((student) => student.id == id);

  /// Adına göre öğrenci arar.
  List<Student> searchStudentsByName(String query) {
    if (query.isEmpty) return _students;

    final lowercaseQuery = query.toLowerCase();
    return _students
        .where((student) => student.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Öğrencileri çeşitli kriterlere göre arar.
  /// [query] parametresi öğrenci adı, veli adı, sınıf, notlar ve dersler gibi alanlarda arama yapar.
  /// Bu metot veritabanı seviyesinde arama yapar, bu nedenle daha verimlidir.
  Future<List<Student>> searchStudents(
    String query, {
    bool notify = true,
  }) async {
    _setLoading(true, notify: notify);
    _error = null;

    try {
      if (query.trim().isEmpty) {
        return _students;
      }

      final studentsData = await _databaseService.searchStudents(query);
      final searchResults = studentsData.map(Student.fromMap).toList();

      return searchResults;
    } on AppException catch (e) {
      _error = e;
      if (notify) notifyListeners();
      return [];
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci araması yapılırken bir hata oluştu: ${e.toString()}',
      );
      if (notify) notifyListeners();
      return [];
    } finally {
      _setLoading(false, notify: notify);
    }
  }

  /// Sınıfa göre öğrencileri filtreler.
  List<Student> filterByGrade(String grade) {
    if (grade.isEmpty) return _students;

    return _students.where((student) => student.grade == grade).toList();
  }

  /// Yükleme durumunu günceller.
  void _setLoading(bool loading, {bool notify = true}) {
    _isLoading = loading;
    if (notify) {
      notifyListeners();
    }
  }

  /// State değişikliklerini dinleyenlere bildirir. Bu metodu sadece build dışında ve
  /// Future.microtask içinde çağırın.
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
