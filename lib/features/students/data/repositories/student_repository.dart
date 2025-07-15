import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:uuid/uuid.dart';

class StudentRepository {
  StudentRepository(this._databaseHelper);
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  Future<List<StudentModel>> getAllStudents() async {
    final studentMaps = await _databaseHelper.getStudents();
    return studentMaps.map(StudentModel.fromMap).toList();
  }

  Future<StudentModel?> getStudent(String id) async {
    final studentMap = await _databaseHelper.getStudent(id);
    return studentMap != null ? StudentModel.fromMap(studentMap) : null;
  }

  Future<void> addStudent(StudentModel student) async {
    final newStudent = student.copyWith(id: _uuid.v4());
    await _databaseHelper.insertStudent(newStudent.toMap());
  }

  Future<void> updateStudent(StudentModel student) async {
    await _databaseHelper.updateStudent(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _databaseHelper.deleteStudent(id);
  }

  Future<List<StudentModel>> searchStudents(String query) async {
    final studentMaps = await _databaseHelper.searchStudents(query);
    return studentMaps.map(StudentModel.fromMap).toList();
  }
}
