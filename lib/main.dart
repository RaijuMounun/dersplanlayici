import 'package:flutter/material.dart';
import 'package:ders_planlayici/app/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/core/error/error_logger.dart';

void main() async {
  // Flutter bağlantısını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Hata yakalama
  final errorLogger = ErrorLogger();
  FlutterError.onError = (FlutterErrorDetails details) {
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
