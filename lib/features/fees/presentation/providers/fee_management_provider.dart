import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';

/// FeeManagementPage için veri ve iş mantığını yöneten Provider.
class FeeManagementProvider extends ChangeNotifier {
  FeeManagementProvider(
    this._studentProvider,
    this._paymentProvider,
    this._lessonProvider,
  ) {
    // İlgili provider'larda değişiklik olduğunda verileri yeniden yükle
    _studentProvider.addListener(_reloadData);
    _paymentProvider.addListener(_reloadData);
    _lessonProvider.addListener(_reloadData);
    // Başlangıç verilerini yükle
    loadInitialData();
  }
  StudentProvider _studentProvider;
  PaymentProvider _paymentProvider;
  LessonProvider _lessonProvider;

  bool _isLoading = false;
  String? _error;
  List<FeeSummary> _feeSummaries = [];
  List<StudentModel> _students = [];
  List<PaymentModel> _payments = [];
  List<Lesson> _lessons = [];

  // İstatistikler
  double _totalAmount = 0;
  double _paidAmount = 0;
  double _remainingAmount = 0;
  int _overdueCount = 0;

  // UI tarafından erişilecek getter'lar
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FeeSummary> get feeSummaries => _feeSummaries;
  List<StudentModel> get students => _students;
  List<PaymentModel> get payments => _payments;
  double get totalAmount => _totalAmount;
  double get paidAmount => _paidAmount;
  double get remainingAmount => _remainingAmount;
  int get overdueCount => _overdueCount;

  @override
  void dispose() {
    _studentProvider.removeListener(_reloadData);
    _paymentProvider.removeListener(_reloadData);
    _lessonProvider.removeListener(_reloadData);
    super.dispose();
  }

  void updateDependencies(
    StudentProvider studentProvider,
    PaymentProvider paymentProvider,
    LessonProvider lessonProvider,
  ) {
    _studentProvider = studentProvider;
    _paymentProvider = paymentProvider;
    _lessonProvider = lessonProvider;
    _reloadData();
  }

  void _reloadData() {
    // Diğer provider'lardan verileri al ve durumu güncelle
    _students = _studentProvider.students;
    _payments = _paymentProvider.payments;
    _lessons = _lessonProvider.allLessons;
    _feeSummaries = _paymentProvider.summaries;
    _calculateStatistics();
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      // Tüm verilerin paralel olarak yüklenmesini bekle
      await Future.wait([
        _studentProvider.loadStudents(),
        _paymentProvider.loadPayments(),
        _paymentProvider.loadAllStudentFeeSummaries(),
        _lessonProvider.loadLessons(),
      ]);
      // Veri yüklendikten sonra durumu senkronize et
      _reloadData();
    } on Exception catch (e) {
      _error = 'Veriler yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _calculateStatistics() {
    _totalAmount = 0;
    _paidAmount = 0;
    _remainingAmount = 0;
    _overdueCount = 0;

    for (var payment in _payments) {
      _totalAmount += payment.amount;
      _paidAmount += payment.paidAmount;

      if (payment.status == PaymentStatus.overdue) {
        _overdueCount++;
      }
    }
    _remainingAmount = _totalAmount - _paidAmount;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<Lesson> getUnpaidLessonsForStudent(String studentId) {
    final studentLessons = _lessons
        .where((lesson) =>
            lesson.studentId == studentId &&
            lesson.status != LessonStatus.cancelled)
        .toList();

    // Dersleri tarihe göre sırala (en eski önce)
    studentLessons.sort((a, b) => a.date.compareTo(b.date));

    final studentPayments =
        _payments.where((p) => p.studentId == studentId).toList();
    final double totalPaid =
        studentPayments.fold(0, (sum, p) => sum + p.paidAmount);

    final List<Lesson> unpaidLessons = [];
    double runningBalance = totalPaid;

    for (final lesson in studentLessons) {
      if (lesson.fee <= 0) continue;

      if (runningBalance >= lesson.fee) {
        // Bu ders tamamen ödenmiş
        runningBalance -= lesson.fee;
      } else {
        // Bu ders ya kısmen ödenmiş ya da hiç ödenmemiş
        // Kalan borcu olan dersi listeye ekle
        unpaidLessons.add(lesson);
      }
    }

    return unpaidLessons;
  }
}
