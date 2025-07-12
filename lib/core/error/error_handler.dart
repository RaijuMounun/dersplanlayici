import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:ders_planlayici/core/error/error_logger.dart';

/// Uygulamada oluşan hataları merkezi olarak yöneten sınıf.
class ErrorHandler {
  /// Hata loglama fonksiyonu
  static void logError(dynamic error, {StackTrace? stackTrace, String? hint}) {
    if (error is AppException) {
      developer.log(
        'AppException: ${error.message}',
        error: error,
        stackTrace: stackTrace,
        name: 'ErrorHandler',
      );
    } else {
      developer.log(
        'Error: $error${hint != null ? ' | Hint: $hint' : ''}',
        error: error,
        stackTrace: stackTrace,
        name: 'ErrorHandler',
      );
    }

    // Debug modda ise konsola detaylı hata yazdır
    if (kDebugMode) {
      ErrorLogger().error(
        'Hata oluştu',
        tag: 'ErrorHandler',
        error: error,
        stackTrace: stackTrace,
        metadata: hint != null ? {'hint': hint} : null,
      );
    }
  }

  /// Hata işleme fonksiyonu
  static Future<T> handleError<T>(
    Future<T> Function() asyncFunction, {
    String? errorMessage,
    Function(dynamic error)? onError,
    bool shouldRethrow = false,
  }) async {
    try {
      return await asyncFunction();
    } catch (e, stackTrace) {
      final displayMessage = errorMessage ?? 'Bir hata oluştu';
      logError(e, stackTrace: stackTrace, hint: displayMessage);

      if (onError != null) {
        onError(e);
      }

      if (shouldRethrow) {
        rethrow;
      }

      // Varsayılan değer döndür
      return _getDefaultValue<T>();
    }
  }

  /// Snackbar ile hata mesajı göster
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      action: SnackBarAction(
        label: 'Tamam',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Dialog ile hata mesajı göster
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) async => showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(message)),
          actions: <Widget>[
            TextButton(
              child: Text(buttonText ?? 'Tamam'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
    );

  /// Tip için varsayılan değer döndürür
  static T _getDefaultValue<T>() {
    if (T == List || T == List<dynamic>) {
      return <dynamic>[] as T;
    } else if (T == Map || T == Map<dynamic, dynamic>) {
      return <dynamic, dynamic>{} as T;
    } else if (T == int) {
      return 0 as T;
    } else if (T == double) {
      return 0.0 as T;
    } else if (T == bool) {
      return false as T;
    } else if (T == String) {
      return '' as T;
    } else {
      return null as T;
    }
  }
}
