class Student {
  final String id;
  final String name;
  final String grade;
  final String parentName;
  final String phone;
  final String email;
  final List<String> subjects;
  final String notes;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    this.parentName = '',
    this.phone = '',
    this.email = '',
    required this.subjects,
    this.notes = '',
  });

  Student copyWith({
    String? id,
    String? name,
    String? grade,
    String? parentName,
    String? phone,
    String? email,
    List<String>? subjects,
    String? notes,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subjects: subjects ?? this.subjects,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'parentName': parentName,
      'phone': phone,
      'email': email,
      'subjects': subjects.join(','),
      'notes': notes,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      grade: map['grade'] ?? '',
      parentName: map['parentName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      subjects: map['subjects']?.split(',') ?? <String>[],
      notes: map['notes'] ?? '',
    );
  }
} 