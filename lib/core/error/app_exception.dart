/// Uygulama genelinde kullanılacak özel hata sınıflarını içerir.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({required this.message, this.code, this.details});

  @override
  String toString() =>
      'AppException(message: $message, code: $code, details: $details)';
}

/// Veritabanı işlemlerinde oluşabilecek hataları temsil eder.
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code = 'database_error',
    super.details,
  });
}

/// Veri bulunamadığında oluşacak hataları temsil eder.
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'not_found',
    super.details,
  });
}

/// Geçersiz veri durumunda oluşacak hataları temsil eder.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'validation_error',
    super.details,
  });
}

/// Çakışan dersler olduğunda oluşacak hataları temsil eder.
class LessonConflictException extends AppException {
  const LessonConflictException({
    required super.message,
    super.code = 'lesson_conflict',
    super.details,
  });
}

/// Tekrarlayan derslerle ilgili oluşabilecek hataları temsil eder.
class RecurringLessonException extends AppException {
  const RecurringLessonException({
    required super.message,
    super.code = 'recurring_lesson_error',
    super.details,
  });
}
