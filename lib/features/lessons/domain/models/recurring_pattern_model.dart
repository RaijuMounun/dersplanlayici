import 'package:uuid/uuid.dart';

/// Tekrarlama türünü temsil eden enum.
enum RecurringType {
  weekly, // Haftalık
  monthly, // Aylık
}

/// Tekrarlanan ders desenini temsil eden model sınıfı.
class RecurringPattern { // Ayın günü (1-31)

  RecurringPattern({
    String? id,
    required this.type,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    this.daysOfWeek,
    this.dayOfMonth,
  }) : id = id ?? const Uuid().v4();

  /// Map objesinden RecurringPattern nesnesine dönüştürür.
  factory RecurringPattern.fromMap(Map<String, dynamic> map) => RecurringPattern(
      id: map['id'] as String,
      type: RecurringType.values.firstWhere(
        (e) => e.toString() == 'RecurringType.${map['type']}',
        orElse: () => RecurringType.weekly,
      ),
      interval: map['interval'] as int,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String?,
      daysOfWeek: map['daysOfWeek'] != null
          ? (map['daysOfWeek'] as String)
                .split(',')
                .map(int.parse)
                .toList()
          : null,
      dayOfMonth: map['dayOfMonth'] as int?,
    );
  final String id;
  final RecurringType type;
  final int interval;
  final String startDate;
  final String? endDate;
  final List<int>? daysOfWeek; // Haftanın günleri (1-7, 1: Pazartesi)
  final int? dayOfMonth;

  /// RecurringPattern nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'id': id,
      'type': type.toString().split('.').last,
      'interval': interval,
      'startDate': startDate,
      'endDate': endDate,
      'daysOfWeek': daysOfWeek?.map((e) => e.toString()).join(','),
      'dayOfMonth': dayOfMonth,
    };

  /// Güncellenmiş bir tekrarlama deseni nesnesi oluşturur.
  RecurringPattern copyWith({
    RecurringType? type,
    int? interval,
    String? startDate,
    String? endDate,
    List<int>? daysOfWeek,
    int? dayOfMonth,
  }) => RecurringPattern(
      id: id,
      type: type ?? this.type,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    );

  @override
  String toString() => 'RecurringPattern(id: $id, type: $type, interval: $interval)';
}
