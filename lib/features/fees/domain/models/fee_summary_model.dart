/// Öğrenci veya dönem bazlı ücret özetini temsil eden model sınıfı.
class FeeSummary {
  final String id; // Öğrenci ID'si veya dönem ID'si olabilir
  final String name; // Öğrenci adı veya dönem adı olabilir
  final double totalAmount; // Toplam ücret
  final double paidAmount; // Ödenen miktar
  final int totalLessons; // Toplam ders sayısı
  final int completedLessons; // Tamamlanan ders sayısı
  final int pendingPayments; // Bekleyen ödeme sayısı
  final int overduePayments; // Gecikmiş ödeme sayısı
  final DateTime lastUpdated; // Son güncelleme tarihi

  FeeSummary({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.paidAmount,
    required this.totalLessons,
    required this.completedLessons,
    required this.pendingPayments,
    required this.overduePayments,
    required this.lastUpdated,
  });

  /// Kalan borç miktarını hesaplar.
  double get remainingAmount => totalAmount - paidAmount;

  /// Ödeme yüzdesini hesaplar.
  double get paymentPercentage =>
      totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;

  /// Ders tamamlanma yüzdesini hesaplar.
  double get completionPercentage =>
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

  /// Map objesinden FeeSummary nesnesine dönüştürür.
  factory FeeSummary.fromMap(Map<String, dynamic> map) {
    return FeeSummary(
      id: map['id'] as String,
      name: map['name'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num).toDouble(),
      totalLessons: map['totalLessons'] as int,
      completedLessons: map['completedLessons'] as int,
      pendingPayments: map['pendingPayments'] as int,
      overduePayments: map['overduePayments'] as int,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  /// FeeSummary nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'pendingPayments': pendingPayments,
      'overduePayments': overduePayments,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Güncellenmiş bir ücret özeti nesnesi oluşturur.
  FeeSummary copyWith({
    String? id,
    String? name,
    double? totalAmount,
    double? paidAmount,
    int? totalLessons,
    int? completedLessons,
    int? pendingPayments,
    int? overduePayments,
    DateTime? lastUpdated,
  }) {
    return FeeSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      overduePayments: overduePayments ?? this.overduePayments,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'FeeSummary(id: $id, name: $name, totalAmount: $totalAmount, paidAmount: $paidAmount, remaining: $remainingAmount)';
  }
}
