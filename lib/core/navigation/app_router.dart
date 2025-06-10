import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/home/presentation/pages/home_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/add_student_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/student_details_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/add_lesson_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/lesson_details_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/add_edit_lesson_page.dart';
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

          // Ders ekleme sayfası (Eski sayfa)
          GoRoute(
            path: 'add-lesson',
            name: RouteNames.addLesson,
            builder: (context, state) {
              final studentId = state.uri.queryParameters['studentId'];
              return AddLessonPage(studentId: studentId);
            },
          ),

          // Yeni ders ekleme sayfası
          GoRoute(
            path: 'new-lesson',
            name: 'newLesson',
            builder: (context, state) {
              final studentId = state.uri.queryParameters['studentId'];
              return AddEditLessonPage(studentId: studentId);
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
