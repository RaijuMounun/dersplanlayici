class ValidationException implements Exception {
  const ValidationException({required this.message});
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
