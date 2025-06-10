import 'package:flutter/foundation.dart';
import '../../domain/models/student_model.dart';
import '../../../../services/database/database_service.dart';
import '../../../../core/error/app_exception.dart';

/// Öğrenci verilerini yöneten Provider sınıfı.
class StudentProvider extends ChangeNotifier {
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

  StudentProvider(this._databaseService);

  /// Tüm öğrencileri veritabanından yükler.
  Future<void> loadStudents() async {
    _setLoading(true);
    _error = null;

    try {
      final studentsData = await _databaseService.getStudents();
      _students = studentsData.map((data) => Student.fromMap(data)).toList();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Öğrenciler yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Öğrenci ekler.
  Future<void> addStudent(Student student) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.insertStudent(student.toMap());
      await loadStudents();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci eklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Öğrenci günceller.
  Future<void> updateStudent(Student student) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.updateStudent(student.toMap());
      await loadStudents();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Öğrenci siler.
  Future<void> deleteStudent(String id) async {
    _setLoading(true);
    _error = null;

    try {
      await _databaseService.deleteStudent(id);
      await loadStudents();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci silinirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// ID'ye göre öğrenci arar.
  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }

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
  Future<List<Student>> searchStudents(String query) async {
    _setLoading(true);
    _error = null;

    try {
      if (query.trim().isEmpty) {
        return _students;
      }

      final studentsData = await _databaseService.searchStudents(query);
      final searchResults = studentsData
          .map((data) => Student.fromMap(data))
          .toList();

      return searchResults;
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
      return [];
    } catch (e) {
      _error = DatabaseException(
        message: 'Öğrenci araması yapılırken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Sınıfa göre öğrencileri filtreler.
  List<Student> filterByGrade(String grade) {
    if (grade.isEmpty) return _students;

    return _students.where((student) => student.grade == grade).toList();
  }

  /// Yükleme durumunu günceller.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
