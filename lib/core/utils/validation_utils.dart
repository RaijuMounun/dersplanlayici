import 'package:ders_planlayici/core/error/app_exception.dart';

/// Form alanlarının validasyonu için yardımcı fonksiyonlar içeren sınıf
class ValidationUtils {
  /// Alanın boş olup olmadığını kontrol eder
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} boş bırakılamaz';
    }
    return null;
  }

  /// Email formatını kontrol eder
  static String? validateEmail(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'E-posta adresi boş bırakılamaz' : null;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    return null;
  }

  /// Telefon numarası formatını kontrol eder
  static String? validatePhone(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Telefon numarası boş bırakılamaz' : null;
    }

    // Sadece rakamları alır
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Telefon numarası en az 10 rakam içermelidir';
    }

    return null;
  }

  /// Tarih formatını kontrol eder (YYYY-MM-DD)
  static String? validateDate(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Tarih boş bırakılamaz' : null;
    }

    try {
      final date = DateTime.parse(value);
      if (date.toString().substring(0, 10) != value) {
        return 'Geçerli bir tarih formatı giriniz (YYYY-MM-DD)';
      }
    } catch (e) {
      return 'Geçerli bir tarih formatı giriniz (YYYY-MM-DD)';
    }

    return null;
  }

  /// Saat formatını kontrol eder (HH:MM)
  static String? validateTime(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Saat boş bırakılamaz' : null;
    }

    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');

    if (!timeRegex.hasMatch(value)) {
      return 'Geçerli bir saat formatı giriniz (HH:MM)';
    }

    return null;
  }

  /// Sayısal değer kontrolü yapar
  static String? validateNumber(
    String? value, {
    bool isRequired = false,
    double? min,
    double? max,
  }) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Bu alan boş bırakılamaz' : null;
    }

    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Geçerli bir sayısal değer giriniz';
    }

    if (min != null && numValue < min) {
      return 'Değer $min değerinden küçük olamaz';
    }

    if (max != null && numValue > max) {
      return 'Değer $max değerinden büyük olamaz';
    }

    return null;
  }

  /// Girilen değerin minimum uzunluğunu kontrol eder
  static String? validateMinLength(
    String? value, {
    required int minLength,
    bool isRequired = false,
  }) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Bu alan boş bırakılamaz' : null;
    }

    if (value.length < minLength) {
      return 'Bu alan en az $minLength karakter içermelidir';
    }

    return null;
  }

  /// Birden fazla validasyon fonksiyonunu birleştirir
  static String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Verilen exception'ı form hata mesajına dönüştürür
  static String getErrorMessage(dynamic exception) {
    if (exception is ValidationException) {
      return exception.message;
    } else if (exception is AppException) {
      return 'Hata: ${exception.message}';
    } else {
      return 'Beklenmeyen bir hata oluştu';
    }
  }
}
