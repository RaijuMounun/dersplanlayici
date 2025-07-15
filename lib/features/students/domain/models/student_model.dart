import 'package:uuid/uuid.dart';

/// Öğrenci bilgilerini temsil eden model sınıfı.
class StudentModel {
  StudentModel({
    String? id,
    required this.name,
    this.grade,
    this.parentName,
    this.phone,
    this.email,
    this.subjects,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Boş bir StudentModel nesnesi oluşturur.
  factory StudentModel.empty() => StudentModel(id: '', name: '', subjects: []);

  /// Map objesinden StudentModel nesnesine dönüştürür.
  factory StudentModel.fromMap(Map<String, dynamic> map) => StudentModel(
        id: map['id'] as String,
        name: map['name'] as String,
        grade: map['grade'] as String?,
        parentName: map['parentName'] as String?,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        subjects: map['subjects'] != null
            ? (map['subjects'] as String).split(',')
            : [],
        notes: map['notes'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
        updatedAt: map['updatedAt'] != null
            ? DateTime.tryParse(map['updatedAt'] as String)
            : null,
      );

  final String id;
  final String name;
  final String? grade;
  final String? parentName;
  final String? phone;
  final String? email;
  final List<String>? subjects;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// StudentModel nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'grade': grade,
    'parentName': parentName,
    'phone': phone,
    'email': email,
    'subjects': subjects?.join(','),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Güncellenmiş bir öğrenci nesnesi oluşturur.
  StudentModel copyWith({
    String? id,
    String? name,
    String? grade,
    String? parentName,
    String? phone,
    String? email,
    List<String>? subjects,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudentModel(
    id: id ?? this.id,
    name: name ?? this.name,
    grade: grade ?? this.grade,
    parentName: parentName ?? this.parentName,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    subjects: subjects ?? this.subjects,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() => 'StudentModel(id: $id, name: $name, grade: $grade)';
}
