/// Uygulama içinde kullanılan temel exception sınıfı
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({required this.message, this.code, this.details});

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Veritabanı işlemlerinde oluşan hataları temsil eder
class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code, super.details});
}

/// Veri modeli işlemlerinde oluşan hataları temsil eder
class ModelException extends AppException {
  const ModelException({required super.message, super.code, super.details});
}

/// Ağ işlemlerinde oluşan hataları temsil eder
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.details});
}

/// Uygulama mantığı içinde oluşan hataları temsil eder
class BusinessLogicException extends AppException {
  const BusinessLogicException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Kullanıcı girdisi hatalarını temsil eder
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
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
