import 'package:uuid/uuid.dart';

/// Ödeme durumunu temsil eden enum.
enum PaymentStatus {
  pending, // Beklemede
  paid, // Ödenmiş
  partiallyPaid, // Kısmen ödenmiş
  overdue, // Gecikmiş
  cancelled, // İptal edilmiş
}

/// Ödeme yöntemini temsil eden enum.
enum PaymentMethod {
  cash, // Nakit
  creditCard, // Kredi kartı
  bankTransfer, // Banka havalesi
  other, // Diğer
}

/// Ödeme bilgilerini temsil eden model sınıfı.
class PaymentModel { // İlişkili ders ID'leri

  PaymentModel({
    String? id,
    required this.studentId,
    required this.studentName,
    required this.description,
    required this.amount,
    this.paidAmount = 0,
    required this.date,
    this.dueDate,
    this.status = PaymentStatus.pending,
    this.method,
    this.notes,
    this.lessonIds,
  }) : id = id ?? const Uuid().v4();

  /// Map objesinden PaymentModel nesnesine dönüştürür.
  factory PaymentModel.fromMap(Map<String, dynamic> map) => PaymentModel(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      studentName: map['studentName'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0,
      date: map['date'] as String,
      dueDate: map['dueDate'] as String?,
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${map['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      method: map['method'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${map['method']}',
              orElse: () => PaymentMethod.cash,
            )
          : null,
      notes: map['notes'] as String?,
      lessonIds: map['lessonIds'] != null
          ? List<String>.from(map['lessonIds'])
          : null,
    );
  final String id;
  final String studentId;
  final String studentName;
  final String description;
  final double amount;
  final double paidAmount;
  final String date;
  final String? dueDate;
  final PaymentStatus status;
  final PaymentMethod? method;
  final String? notes;
  final List<String>? lessonIds;

  /// Payment nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'description': description,
      'amount': amount,
      'paidAmount': paidAmount,
      'date': date,
      'dueDate': dueDate,
      'status': status.toString().split('.').last,
      'method': method?.toString().split('.').last,
      'notes': notes,
      'lessonIds': lessonIds,
    };

  /// Güncellenmiş bir ödeme nesnesi oluşturur.
  PaymentModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? description,
    double? amount,
    double? paidAmount,
    String? date,
    String? dueDate,
    PaymentStatus? status,
    PaymentMethod? method,
    String? notes,
    List<String>? lessonIds,
  }) => PaymentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      lessonIds: lessonIds ?? this.lessonIds,
    );

  /// Ödeme durumunu hesaplar
  PaymentStatus calculateStatus() {
    if (paidAmount >= amount) {
      return PaymentStatus.paid;
    } else if (paidAmount > 0) {
      return PaymentStatus.partiallyPaid;
    } else if (dueDate != null) {
      final due = DateTime.parse(dueDate!);
      final now = DateTime.now();
      if (now.isAfter(due)) {
        return PaymentStatus.overdue;
      }
    }
    return PaymentStatus.pending;
  }

  /// Kalan ödeme miktarını hesaplar
  double get remainingAmount => amount - paidAmount;

  /// Ödemenin tamamlanıp tamamlanmadığını kontrol eder
  bool get isPaid => paidAmount >= amount;

  /// Ödemenin gecikmeli olup olmadığını kontrol eder
  bool get isOverdue {
    if (dueDate == null || isPaid) return false;
    final due = DateTime.parse(dueDate!);
    final now = DateTime.now();
    return now.isAfter(due);
  }

  @override
  String toString() => 'Payment(id: $id, studentName: $studentName, amount: $amount, paidAmount: $paidAmount, status: $status)';
}
