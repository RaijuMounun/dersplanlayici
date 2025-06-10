import 'package:uuid/uuid.dart';

/// Ders durumunu temsil eden enum.
enum LessonStatus {
  scheduled, // Planlanmış
  completed, // Tamamlanmış
  cancelled, // İptal edilmiş
  postponed, // Ertelenmiş
}

/// Ders bilgilerini temsil eden model sınıfı.
class Lesson {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final String? topic;
  final String date;
  final String startTime;
  final String endTime;
  final LessonStatus status;
  final String? notes;
  final String? recurringPatternId;
  final double fee;

  Lesson({
    String? id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    this.topic,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = LessonStatus.scheduled,
    this.notes,
    this.recurringPatternId,
    this.fee = 0,
  }) : id = id ?? const Uuid().v4();

  /// Map objesinden Lesson nesnesine dönüştürür.
  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      studentName: map['studentName'] as String,
      subject: map['subject'] as String,
      topic: map['topic'] as String?,
      date: map['date'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      status: LessonStatus.values.firstWhere(
        (e) => e.toString() == 'LessonStatus.${map['status']}',
        orElse: () => LessonStatus.scheduled,
      ),
      notes: map['notes'] as String?,
      recurringPatternId: map['recurringPatternId'] as String?,
      fee: (map['fee'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Lesson nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'subject': subject,
      'topic': topic,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status.toString().split('.').last,
      'notes': notes,
      'recurringPatternId': recurringPatternId,
      'fee': fee,
    };
  }

  /// Güncellenmiş bir ders nesnesi oluşturur.
  Lesson copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? subject,
    String? topic,
    String? date,
    String? startTime,
    String? endTime,
    LessonStatus? status,
    String? notes,
    String? recurringPatternId,
    double? fee,
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
      recurringPatternId: recurringPatternId ?? this.recurringPatternId,
      fee: fee ?? this.fee,
    );
  }

  @override
  String toString() {
    return 'Lesson(id: $id, studentName: $studentName, subject: $subject, date: $date, startTime: $startTime)';
  }
}
