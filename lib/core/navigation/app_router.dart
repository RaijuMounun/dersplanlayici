import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/home/presentation/pages/home_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/add_student_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/student_details_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/add_lesson_page.dart';
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

          // Ders ekleme sayfası
          GoRoute(
            path: 'add-lesson',
            name: RouteNames.addLesson,
            builder: (context, state) => const AddLessonPage(),
          ),

          // Ders detay sayfası
          GoRoute(
            path: 'lesson/:id',
            name: RouteNames.lessonDetails,
            builder: (context, state) {
              final lessonId = state.pathParameters['id']!;
              // TODO: Lesson Details sayfası oluşturulacak
              return Scaffold(
                appBar: AppBar(title: Text('Ders Detayı: $lessonId')),
                body: Center(child: Text('Ders ID: $lessonId')),
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
