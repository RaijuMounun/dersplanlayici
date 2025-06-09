import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/students/data/repositories/student_repository.dart';
import 'package:ders_planlayici/features/students/domain/models/student.dart';

class StudentProvider with ChangeNotifier {
  final StudentRepository _repository = StudentRepository();
  List<Student> _students = [];
  bool _isLoading = false;
  String _error = '';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadStudents() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _students = await _repository.getAllStudents();
    } catch (e) {
      _error = 'Öğrenciler yüklenirken bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudent(Student student) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.addStudent(student);
      await loadStudents();
    } catch (e) {
      _error = 'Öğrenci eklenirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.updateStudent(student);
      await loadStudents();
    } catch (e) {
      _error = 'Öğrenci güncellenirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _repository.deleteStudent(id);
      await loadStudents();
    } catch (e) {
      _error = 'Öğrenci silinirken bir hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Student?> getStudent(String id) async {
    try {
      return await _repository.getStudent(id);
    } catch (e) {
      _error = 'Öğrenci bilgileri alınırken bir hata oluştu: $e';
      notifyListeners();
      return null;
    }
  }
} 