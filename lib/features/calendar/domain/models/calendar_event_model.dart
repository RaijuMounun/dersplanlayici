import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';

/// Takvimde gösterilecek etkinlik türlerini temsil eden enum.
enum CalendarEventType {
  lesson, // Ders
  exam, // Sınav
  holiday, // Tatil
  appointment, // Randevu
  other, // Diğer
}

/// Takvim etkinliğini temsil eden model sınıfı.
class CalendarEvent {
  final String id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final CalendarEventType type;
  final Map<String, dynamic>? metadata;
  final String? color;
  final bool isAllDay;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.type = CalendarEventType.other,
    this.metadata,
    this.color,
    this.isAllDay = false,
  });

  /// Lesson nesnesinden CalendarEvent nesnesi oluşturur.
  factory CalendarEvent.fromLesson(Lesson lesson) {
    String title = '${lesson.subject} - ${lesson.studentName}';
    if (lesson.topic != null && lesson.topic!.isNotEmpty) {
      title += ' (${lesson.topic})';
    }

    return CalendarEvent(
      id: lesson.id,
      title: title,
      date: lesson.date,
      startTime: lesson.startTime,
      endTime: lesson.endTime,
      type: CalendarEventType.lesson,
      metadata: {
        'lessonId': lesson.id,
        'studentId': lesson.studentId,
        'subject': lesson.subject,
        'status': lesson.status.toString(),
      },
      color: _getColorForLessonStatus(lesson.status),
      isAllDay: false,
    );
  }

  /// Ders durumuna göre renk döndürür.
  static String? _getColorForLessonStatus(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return '#4CAF50'; // Yeşil
      case LessonStatus.completed:
        return '#2196F3'; // Mavi
      case LessonStatus.cancelled:
        return '#F44336'; // Kırmızı
      case LessonStatus.postponed:
        return '#FF9800'; // Turuncu
    }
  }

  /// Map objesinden CalendarEvent nesnesine dönüştürür.
  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      type: CalendarEventType.values.firstWhere(
        (e) => e.toString() == 'CalendarEventType.${map['type']}',
        orElse: () => CalendarEventType.other,
      ),
      metadata: map['metadata'] as Map<String, dynamic>?,
      color: map['color'] as String?,
      isAllDay: map['isAllDay'] as bool? ?? false,
    );
  }

  /// CalendarEvent nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'type': type.toString().split('.').last,
      'metadata': metadata,
      'color': color,
      'isAllDay': isAllDay,
    };
  }

  /// Güncellenmiş bir takvim etkinliği nesnesi oluşturur.
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? date,
    String? startTime,
    String? endTime,
    CalendarEventType? type,
    Map<String, dynamic>? metadata,
    String? color,
    bool? isAllDay,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }

  @override
  String toString() {
    return 'CalendarEvent(id: $id, title: $title, date: $date, type: $type)';
  }
}
