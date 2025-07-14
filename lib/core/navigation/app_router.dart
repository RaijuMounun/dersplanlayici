import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/home/presentation/pages/home_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/add_student_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/student_details_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/lesson_details_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/add_edit_lesson_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/payment_list_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/add_payment_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/fee_history_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/fee_management_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/auto_fee_calculation_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/payment_transactions_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/payment_transaction_page.dart';
import 'route_names.dart';

/// Uygulama genelinde navigasyon için kullanılan router sınıfı.
class AppRouter {
  /// Router'ı oluşturur
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Ana sayfa rotası
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
        routes: [
          // Öğrenci ekleme sayfası
          GoRoute(
            path: 'add-student',
            name: RouteNames.addStudent,
            builder: (context, state) => const AddStudentPage(),
          ),

          // Öğrenci detay sayfası
          GoRoute(
            path: 'student/:id',
            name: RouteNames.studentDetails,
            builder: (context, state) {
              final studentId = state.pathParameters['id']!;
              return StudentDetailsPage(studentId: studentId);
            },
          ),

          // Öğrenci düzenleme sayfası
          GoRoute(
            path: 'edit-student/:id',
            name: 'editStudent',
            builder: (context, state) {
              final studentId = state.pathParameters['id']!;
              return AddStudentPage(studentId: studentId);
            },
          ),

          // Ders ekleme sayfası (Birleştirilmiş - hem ekleme hem düzenleme)
          GoRoute(
            path: 'add-lesson',
            name: RouteNames.addLesson,
            builder: (context, state) {
              final studentId = state.uri.queryParameters['studentId'];
              return AddEditLessonPage(studentId: studentId);
            },
          ),

          // Yeni ders ekleme sayfası (Ana sayfa)
          GoRoute(
            path: 'new-lesson',
            name: 'newLesson',
            builder: (context, state) {
              final studentId = state.uri.queryParameters['studentId'];
              final initialDateStr = state.uri.queryParameters['initialDate'];
              DateTime? initialDate;
              
              if (initialDateStr != null) {
                try {
                  initialDate = DateTime.parse(initialDateStr);
                } on Exception {
                  // Parse hatası durumunda null bırak
                }
              }
              
              return AddEditLessonPage(
                studentId: studentId,
                initialDate: initialDate,
              );
            },
          ),

          // Ders düzenleme sayfası
          GoRoute(
            path: 'edit-lesson/:id',
            name: 'editLesson',
            builder: (context, state) {
              final lessonId = state.pathParameters['id']!;
              return AddEditLessonPage(lessonId: lessonId);
            },
          ),

          // Ders detay sayfası
          GoRoute(
            path: 'lesson/:id',
            name: RouteNames.lessonDetails,
            builder: (context, state) {
              final lessonId = state.pathParameters['id']!;
              return LessonDetailsPage(lessonId: lessonId);
            },
          ),

          // Ödemeler listesi sayfası
          GoRoute(
            path: 'payments',
            name: 'payments',
            builder: (context, state) => const PaymentListPage(),
          ),

          // Ücret yönetim sayfası
          GoRoute(
            path: 'fee-management',
            name: 'feeManagement',
            builder: (context, state) => const FeeManagementPage(),
          ),

          // Otomatik ücret hesaplama sayfası
          GoRoute(
            path: 'auto-fee-calculation',
            name: 'autoFeeCalculation',
            builder: (context, state) => const AutoFeeCalculationPage(),
          ),

          // Ödeme ekleme sayfası
          GoRoute(
            path: 'add-payment',
            name: 'addPayment',
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              return AddPaymentPage(studentId: queryParams['studentId']);
            },
          ),

          // Ödeme düzenleme sayfası
          GoRoute(
            path: 'edit-payment/:id',
            name: 'editPayment',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return AddPaymentPage(paymentId: id);
            },
          ),

          // Ödeme geçmişi sayfası
          GoRoute(
            path: 'fee-history',
            name: 'feeHistory',
            builder: (context, state) {
              final queryParams = state.uri.queryParameters;
              return FeeHistoryPage(studentId: queryParams['studentId']);
            },
          ),

          // Payment Transaction routes
          GoRoute(
            path: 'payment-transactions/:paymentId',
            name: 'paymentTransactions',
            builder: (context, state) {
              final paymentId = state.pathParameters['paymentId'] ?? '';
              return PaymentTransactionsPage(paymentId: paymentId);
            },
          ),
          GoRoute(
            path: 'payment-transaction/:paymentId',
            name: 'addPaymentTransaction',
            builder: (context, state) {
              final paymentId = state.pathParameters['paymentId'] ?? '';
              return PaymentTransactionPage(paymentId: paymentId);
            },
          ),
          GoRoute(
            path: 'payment-transaction/:paymentId/:transactionId',
            name: 'editPaymentTransaction',
            builder: (context, state) {
              final paymentId = state.pathParameters['paymentId'] ?? '';
              final transactionId = state.pathParameters['transactionId'] ?? '';
              return PaymentTransactionPage(
                paymentId: paymentId,
                transactionId: transactionId,
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Sayfa Bulunamadı')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Aradığınız sayfa bulunamadı.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
}
