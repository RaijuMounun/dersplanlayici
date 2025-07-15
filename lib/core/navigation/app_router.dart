import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/home/presentation/screens/home_page.dart';
import 'package:ders_planlayici/features/students/presentation/screens/add_edit_student_page.dart';
import 'package:ders_planlayici/features/students/presentation/screens/student_details_page.dart';
import 'package:ders_planlayici/features/students/presentation/screens/student_list_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/screens/lessons_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/screens/lesson_details_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/screens/add_edit_lesson_page.dart';
import 'package:ders_planlayici/features/fees/presentation/screens/payment_list_page.dart';
import 'package:ders_planlayici/features/fees/presentation/screens/add_payment_page.dart';
import 'package:ders_planlayici/features/fees/presentation/screens/payment_transactions_page.dart';
import 'package:ders_planlayici/features/calendar/presentation/screens/calendar_page.dart';
import 'package:ders_planlayici/features/settings/presentation/screens/settings_page.dart';
import 'route_names.dart';

/// Uygulama genelinde navigasyon için kullanılan router sınıfı.
class AppRouter {
  /// Router'ı oluşturur
  static final GoRouter router = GoRouter(
    initialLocation: '/calendar',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/calendar'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomePage(navigationShell: navigationShell),
        branches: [
          // Takvim Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: RouteNames.calendar,
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          // Dersler Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lessons',
                name: RouteNames.lessons,
                builder: (context, state) => const LessonsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: RouteNames.addLesson,
                    builder: (context, state) {
                      final initialDate =
                          state.uri.queryParameters['initialDate'];
                      return AddEditLessonPage(initialDate: initialDate);
                    },
                  ),
                  GoRoute(
                    path: ':id/details',
                    name: RouteNames.lessonDetails,
                    builder: (context, state) => LessonDetailsPage(
                      lessonId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    name: RouteNames.editLesson,
                    builder: (context, state) =>
                        AddEditLessonPage(lessonId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          // Öğrenciler Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/students',
                name: RouteNames.students,
                builder: (context, state) => const StudentListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: RouteNames.addStudent,
                    builder: (context, state) => const AddEditStudentPage(),
                  ),
                  GoRoute(
                    path: ':id/details',
                    name: RouteNames.studentDetails,
                    builder: (context, state) => StudentDetailsPage(
                      studentId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    name: RouteNames.editStudent,
                    builder: (context, state) => AddEditStudentPage(
                      studentId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Ödemeler Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/payments',
                name: RouteNames.payments,
                builder: (context, state) => const PaymentListPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: RouteNames.addPayment,
                    builder: (context, state) => const AddPaymentPage(),
                  ),
                  GoRoute(
                    path: 'edit/:paymentId',
                    name: RouteNames.editPayment,
                    builder: (context, state) => AddPaymentPage(
                      paymentId: state.pathParameters['paymentId'],
                    ),
                  ),
                  GoRoute(
                    path: 'transactions/:paymentId',
                    name: RouteNames.paymentTransactions,
                    builder: (context, state) => PaymentTransactionsPage(
                      paymentId: state.pathParameters['paymentId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Ayarlar Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
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
              onPressed: () => context.goNamed(RouteNames.students),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
}
