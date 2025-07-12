import 'package:uuid/uuid.dart';

/// Takvim olaylarını temsil eden model sınıfı.
class CalendarEventModel {

  CalendarEventModel({
    String? id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.eventType,
    this.color,
    this.isAllDay = false,
    this.location,
    this.attendees,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Map objesinden CalendarEventModel nesnesine dönüştürür.
  factory CalendarEventModel.fromMap(Map<String, dynamic> map) => CalendarEventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      eventType: map['eventType'] as String,
      color: map['color'] as String?,
      isAllDay: map['isAllDay'] as bool? ?? false,
      location: map['location'] as String?,
      attendees: map['attendees'] != null
          ? (map['attendees'] as String).split(',')
          : null,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String eventType; // 'lesson', 'holiday', 'exam', 'other'
  final String? color;
  final bool isAllDay;
  final String? location;
  final List<String>? attendees;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// CalendarEventModel nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'eventType': eventType,
      'color': color,
      'isAllDay': isAllDay,
      'location': location,
      'attendees': attendees?.join(','),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

  /// Güncellenmiş bir takvim olayı nesnesi oluşturur.
  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? color,
    bool? isAllDay,
    String? location,
    List<String>? attendees,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      eventType: eventType ?? this.eventType,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );

  /// Olayın süresini dakika cinsinden döndürür.
  int get durationInMinutes => endDate.difference(startDate).inMinutes;

  /// Olayın bugün olup olmadığını kontrol eder.
  bool get isToday {
    final now = DateTime.now();
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  /// Olayın geçmişte olup olmadığını kontrol eder.
  bool get isPast => endDate.isBefore(DateTime.now());

  /// Olayın gelecekte olup olmadığını kontrol eder.
  bool get isFuture => startDate.isAfter(DateTime.now());

  /// Olayın şu anda devam edip etmediğini kontrol eder.
  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

  @override
  String toString() => 'CalendarEventModel(id: $id, title: $title, eventType: $eventType, startDate: $startDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
