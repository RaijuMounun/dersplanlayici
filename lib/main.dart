import 'package:flutter/material.dart';
import 'package:ders_planlayici/app/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Flutter bağlantısını başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Tarih yerelleştirmesini başlat
  await initializeDateFormatting('tr_TR', null);
  Intl.defaultLocale = 'tr_TR';

  // SQLite FFI'yi başlat (Windows, Linux ve macOS için)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Hata yakalama
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Hata: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(const DersPlanlamaApp());
}
