import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GoRouter navigasyon işlemlerini kolaylaştırmak için extension metotları.
extension NavigationExtension on BuildContext {
  /// Ana sayfaya gider
  void goToHome() => go('/');

  /// Öğrenci ekleme sayfasına gider
  void goToAddStudent() => go('/add-student');

  /// Öğrenci detay sayfasına gider
  void goToStudentDetails(String studentId) => go('/student/$studentId');

  /// Ders ekleme sayfasına gider
  void goToAddLesson() => go('/add-lesson');

  /// Ders detay sayfasına gider
  void goToLessonDetails(String lessonId) => go('/lesson/$lessonId');

  /// Üst sayfaya geri döner
  void goBack() => pop();

  /// Belirtilen rotaya adlandırılmış rota ile gider
  void goNamed(String name, {Map<String, String> params = const {}}) {
    GoRouter.of(this).goNamed(name, pathParameters: params);
  }
}
