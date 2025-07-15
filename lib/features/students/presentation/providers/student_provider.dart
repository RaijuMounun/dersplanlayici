import 'package:flutter/foundation.dart';
import '../../domain/models/student_model.dart';
import '../../data/repositories/student_repository.dart';
import 'package:collection/collection.dart';

/// Öğrenci verilerini yöneten Provider sınıfı.
/// Bu sınıf, öğrenci ekleme, silme, güncelleme ve listeleme işlemlerini
/// yönetir ve bu işlemleri `StudentRepository` üzerinden gerçekleştirir.
class StudentProvider extends ChangeNotifier {

  StudentProvider(this._repository) {
    // Provider oluşturulduğunda öğrencileri yükle
    loadStudents();
  }
  final StudentRepository _repository;

  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _error;

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Provider'ı belirli bir aksiyonu çalıştıracak şekilde sarmalayan yardımcı metot.
  /// Yükleme durumunu ve hata yönetimini merkezi olarak ele alır.
  Future<T> _executeAction<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await action();
    } on Exception catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tüm öğrencileri veritabanından yükler.
  Future<void> loadStudents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _students = await _repository.getAllStudents();
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Yeni bir öğrenci ekler ve listeyi günceller.
  Future<void> addStudent(StudentModel student) async {
    await _executeAction(() => _repository.addStudent(student));
    await loadStudents(); // Listeyi yenile
  }

  /// Mevcut bir öğrenciyi günceller ve listeyi günceller.
  Future<void> updateStudent(StudentModel student) async {
    await _executeAction(() => _repository.updateStudent(student));
    await loadStudents(); // Listeyi yenile
  }

  /// Belirtilen ID'ye sahip öğrenciyi siler ve listeyi günceller.
  Future<void> deleteStudent(String id) async {
    await _executeAction(() => _repository.deleteStudent(id));
    await loadStudents(); // Listeyi yenile
  }

  /// ID'ye göre önbellekteki öğrenciler arasından arama yapar.
  StudentModel? getStudentById(String id) => _students.firstWhereOrNull((student) => student.id == id);

  /// Veritabanında arama yapar ve arama sonuçlarını döndürür.
  /// Bu metot, provider'ın ana listesini (`_students`) değiştirmez.
  Future<List<StudentModel>> searchStudents(String query) async {
    if (query.trim().isEmpty) {
      return _students;
    }
    return _executeAction(() => _repository.searchStudents(query));
  }
}
