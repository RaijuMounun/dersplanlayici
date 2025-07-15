import 'package:uuid/uuid.dart';

/// Ödeme durumunu temsil eden enum.
enum PaymentStatus {
  paid, // Ödenmiş
  unpaid, // Ödenmemiş
  partialPaid, // Kısmi ödenmiş
}

/// Ödeme türünü temsil eden enum.
enum PaymentType {
  cash, // Nakit
  bank, // Banka transferi
  creditCard, // Kredi kartı
}

/// Ücret bilgilerini temsil eden model sınıfı.
class FeeModel {
  // Hangi aya ait (Ör: "2025-01")

  FeeModel({
    String? id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    this.paidAmount,
    required this.date,
    this.status = PaymentStatus.unpaid,
    this.paymentType,
    this.paymentDate,
    this.notes,
    this.month,
  }) : id = id ?? const Uuid().v4();

  /// Map objesinden FeeModel nesnesine dönüştürür.
  factory FeeModel.fromMap(Map<String, dynamic> map) => FeeModel(
    id: map['id'] as String,
    studentId: map['studentId'] as String,
    studentName: map['studentName'] as String,
    amount: map['amount'] as double,
    paidAmount: map['paidAmount'] as double?,
    date: map['date'] as String,
    status: PaymentStatus.values.firstWhere(
      (e) => e.toString() == 'PaymentStatus.${map['status']}',
      orElse: () => PaymentStatus.unpaid,
    ),
    paymentType: map['paymentType'] != null
        ? PaymentType.values.firstWhere(
            (e) => e.toString() == 'PaymentType.${map['paymentType']}',
            orElse: () => PaymentType.cash,
          )
        : null,
    paymentDate: map['paymentDate'] as String?,
    notes: map['notes'] as String?,
    month: map['month'] as String?,
  );
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final double? paidAmount;
  final String date;
  final PaymentStatus status;
  final PaymentType? paymentType;
  final String? paymentDate;
  final String? notes;
  final String? month;

  /// Fee nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'studentName': studentName,
    'amount': amount,
    'paidAmount': paidAmount,
    'date': date,
    'status': status.toString().split('.').last,
    'paymentType': paymentType?.toString().split('.').last,
    'paymentDate': paymentDate,
    'notes': notes,
    'month': month,
  };

  /// Güncellenmiş bir ücret nesnesi oluşturur.
  FeeModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    double? amount,
    double? paidAmount,
    String? date,
    PaymentStatus? status,
    PaymentType? paymentType,
    String? paymentDate,
    String? notes,
    String? month,
  }) => FeeModel(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    studentName: studentName ?? this.studentName,
    amount: amount ?? this.amount,
    paidAmount: paidAmount ?? this.paidAmount,
    date: date ?? this.date,
    status: status ?? this.status,
    paymentType: paymentType ?? this.paymentType,
    paymentDate: paymentDate ?? this.paymentDate,
    notes: notes ?? this.notes,
    month: month ?? this.month,
  );

  @override
  String toString() =>
      'FeeModel(id: $id, studentName: $studentName, amount: $amount, status: $status)';
}
