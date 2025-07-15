/// Uygulama genelinde kullanılan rota isimleri.
class RouteNames {
  RouteNames._();

  // Ana sayfalar
  static const String home = 'home';
  static const String calendar = 'calendar';
  static const String students = 'students';
  static const String lessons = 'lessons';
  static const String payments = 'payments';
  static const String settings = 'settings';

  // Öğrenci sayfaları
  static const String addStudent = 'add-student';
  static const String editStudent = 'edit-student';
  static const String studentDetails = 'student-details';

  // Ders sayfaları
  static const String addLesson = 'add-lesson';
  static const String editLesson = 'edit-lesson';
  static const String lessonDetails = 'lesson-details';

  // Ücret ve Ödeme sayfaları
  static const String feeManagement = 'fee-management';
  static const String autoFeeCalculation = 'auto-fee-calculation';
  static const String addPayment = 'add-payment';
  static const String editPayment = 'edit-payment';
  static const String feeHistory = 'fee-history';
  static const String paymentTransactions = 'payment-transactions';
  static const String addPaymentTransaction = 'add-payment-transaction';
  static const String editPaymentTransaction = 'edit-payment-transaction';
}
