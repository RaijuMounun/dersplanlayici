import 'package:uuid/uuid.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';

/// Bir ödeme işlemini temsil eden model sınıfı.
/// Bu model, bir ödemenin taksitli olarak yapılması durumunda
/// her bir işlemi ayrı ayrı kaydetmek için kullanılır.
class PaymentTransactionModel { // Makbuz/fiş/dekont numarası

  PaymentTransactionModel({
    String? id,
    required this.paymentId,
    required this.amount,
    required this.date,
    required this.method,
    this.notes,
    this.receiptNo,
  }) : id = id ?? const Uuid().v4();

  /// Map objesinden PaymentTransactionModel nesnesine dönüştürür.
  factory PaymentTransactionModel.fromMap(Map<String, dynamic> map) => PaymentTransactionModel(
      id: map['id'] as String,
      paymentId: map['paymentId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${map['method']}',
        orElse: () => PaymentMethod.cash,
      ),
      notes: map['notes'] as String?,
      receiptNo: map['receiptNo'] as String?,
    );
  final String id;
  final String paymentId; // Bağlı olduğu ödeme kaydının ID'si
  final double amount; // İşlem tutarı
  final String date; // İşlem tarihi
  final PaymentMethod method; // Ödeme yöntemi
  final String? notes; // İşleme ait notlar
  final String? receiptNo;

  /// PaymentTransaction nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'id': id,
      'paymentId': paymentId,
      'amount': amount,
      'date': date,
      'method': method.toString().split('.').last,
      'notes': notes,
      'receiptNo': receiptNo,
    };

  /// Güncellenmiş bir ödeme işlemi nesnesi oluşturur.
  PaymentTransactionModel copyWith({
    String? id,
    String? paymentId,
    double? amount,
    String? date,
    PaymentMethod? method,
    String? notes,
    String? receiptNo,
  }) => PaymentTransactionModel(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      receiptNo: receiptNo ?? this.receiptNo,
    );

  @override
  String toString() => 'PaymentTransaction(id: $id, paymentId: $paymentId, amount: $amount, date: $date, method: $method)';
}
