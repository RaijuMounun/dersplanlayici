import 'package:uuid/uuid.dart';

/// Öğrenci bilgilerini temsil eden model sınıfı.
class Student {

  Student({
    String? id,
    required this.name,
    required this.grade,
    this.parentName,
    this.phone,
    this.email,
    this.subjects,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  /// Map objesinden Student nesnesine dönüştürür.
  factory Student.fromMap(Map<String, dynamic> map) => Student(
      id: map['id'] as String,
      name: map['name'] as String,
      grade: map['grade'] as String,
      parentName: map['parentName'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      subjects: map['subjects'] != null
          ? (map['subjects'] as String).split(',')
          : null,
      notes: map['notes'] as String?,
    );
  final String id;
  final String name;
  final String grade;
  final String? parentName;
  final String? phone;
  final String? email;
  final List<String>? subjects;
  final String? notes;

  /// Student nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'grade': grade,
      'parentName': parentName,
      'phone': phone,
      'email': email,
      'subjects': subjects?.join(','),
      'notes': notes,
    };

  /// Güncellenmiş bir öğrenci nesnesi oluşturur.
  Student copyWith({
    String? id,
    String? name,
    String? grade,
    String? parentName,
    String? phone,
    String? email,
    List<String>? subjects,
    String? notes,
  }) => Student(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subjects: subjects ?? this.subjects,
      notes: notes ?? this.notes,
    );

  @override
  String toString() => 'Student(id: $id, name: $name, grade: $grade)';
}
