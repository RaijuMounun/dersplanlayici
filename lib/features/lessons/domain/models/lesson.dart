class Lesson {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final String topic;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final String notes;

  Lesson({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    this.topic = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'Planlandı',
    this.notes = '',
  });

  Lesson copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? subject,
    String? topic,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
    String? notes,
  }) {
    return Lesson(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'subject': subject,
      'topic': topic,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'notes': notes,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      subject: map['subject'] ?? '',
      topic: map['topic'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      status: map['status'] ?? 'Planlandı',
      notes: map['notes'] ?? '',
    );
  }
} 