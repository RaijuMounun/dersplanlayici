import 'package:flutter/material.dart';
import 'package:ders_planlayici/app/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ders_planlayici/core/error/error_logger.dart';

void main() async {
  // Flutter bağlantısını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Klavye olayları için güvenlik önlemleri
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Hata yakalama
  final errorLogger = ErrorLogger();
  FlutterError.onError = (FlutterErrorDetails details) {
    // Klavye olayları ile ilgili hataları filtrele
    if (details.exception.toString().contains('KeyDownEvent') ||
        details.exception.toString().contains('HardwareKeyboard')) {
      // Bu hataları logla ama uygulamayı durdurma
      errorLogger.warning(
        'Keyboard event error (non-critical)',
        tag: 'KeyboardError',
        error: details.exception,
        stackTrace: details.stack,
        metadata: {
          'library': details.library ?? 'unknown',
          'context': details.context?.toString() ?? 'unknown',
        },
      );
      return;
    }

    FlutterError.presentError(details);
    errorLogger.error(
      'Flutter framework error',
      tag: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
      metadata: {
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'unknown',
      },
    );
  };

  // Platform-level hataları yakala
  PlatformDispatcher.instance.onError = (error, stack) {
    // JSON parse hatalarını filtrele
    if (error.toString().contains('Unable to parse JSON message') ||
        error.toString().contains('The document is empty')) {
      errorLogger.warning(
        'JSON parse error (non-critical)',
        tag: 'JSONError',
        error: error,
        stackTrace: stack,
      );
      return true; // Hatayı yakala ve devam et
    }

    errorLogger.error(
      'Platform dispatcher error',
      tag: 'PlatformError',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  try {
    // Tarih yerelleştirmesini başlat
    await initializeDateFormatting('tr_TR', null);
    Intl.defaultLocale = 'tr_TR';

    // SQLite FFI'yi başlat (Windows, Linux ve macOS için)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    runApp(const DersPlanlamaApp());
  } catch (e, stackTrace) {
    await errorLogger.critical(
      'Application failed to start',
      tag: 'Startup',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow; // Ana hataları uygulama dışına yansıt
  }
}
