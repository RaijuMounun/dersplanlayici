import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:intl/intl.dart';

/// Loglama seviyesi enum'u
enum LogLevel { debug, info, warning, error, critical }

/// Log kaydı sınıfı
class LogRecord {

  LogRecord({
    required this.level,
    required this.message,
    this.tag,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
  final LogLevel level;
  final String message;
  final String? tag;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  /// LogRecord'u formatlanmış log stringi olarak temsil eder
  String toFormattedString() {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final formattedDate = dateFormat.format(timestamp);
    final levelStr = level.toString().split('.').last.toUpperCase().padRight(8);
    final tagStr = tag != null ? '[$tag] ' : '';

    String result = '[$formattedDate] $levelStr $tagStr$message';

    if (error != null) {
      result += '\nError: $error';
    }

    if (stackTrace != null) {
      result += '\nStackTrace:\n$stackTrace';
    }

    if (metadata != null && metadata!.isNotEmpty) {
      result += '\nMetadata: ${jsonEncode(metadata)}';
    }

    return result;
  }
}

/// Basitleştirilmiş dosya log hedefi
class SimpleFileLogDestination {

  SimpleFileLogDestination({
    this.minLevel = LogLevel.info,
    this.baseFileName = 'app_log',
    this.maxSizeInBytes = 5 * 1024 * 1024, // 5 MB
    this.maxFiles = 3,
  });
  final LogLevel minLevel;
  final String baseFileName;
  final int maxSizeInBytes;
  final int maxFiles;

  File? _currentLogFile;
  IOSink? _logSink;
  int _currentFileSize = 0;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final directory = await path_provider.getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _currentLogFile = File('${logDir.path}/$baseFileName.log');

      if (await _currentLogFile!.exists()) {
        _currentFileSize = await _currentLogFile!.length();
      }

      _logSink = _currentLogFile!.openWrite(mode: FileMode.append);
      _isInitialized = true;
    } on Exception catch (e) {
      debugPrint('Log dosyası başlatılamadı: $e');
    }
  }

  Future<void> log(LogRecord record) async {
    if (record.level.index < minLevel.index) return;
    if (!_isInitialized) await _initialize();
    if (_logSink == null) return;

    try {
      final logLine = '${record.toFormattedString()}\n';
      _logSink!.write(logLine);
      _currentFileSize += logLine.length;

      if (_currentFileSize >= maxSizeInBytes) {
        await _rotateLogFiles();
      }
    } on Exception catch (e) {
      debugPrint('Log dosyasına yazarken hata: $e');
    }
  }

  Future<void> _rotateLogFiles() async {
    try {
      // Önce mevcut sink'i kapat
      await flush();
      await _logSink?.close();
      _logSink = null;

      final directory = await path_provider.getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      // Eski log dosyalarını sil (güvenli şekilde)
      for (int i = maxFiles - 1; i >= 0; i--) {
        final oldFile = File('${logDir.path}/$baseFileName.$i.log');
        if (await oldFile.exists()) {
          try {
            await oldFile.delete();
          } on Exception catch (e) {
            debugPrint('Eski log dosyası silinemedi: $e');
          }
        }
      }

      // Mevcut log dosyasını .0.log olarak kaydet (güvenli şekilde)
      if (_currentLogFile != null && await _currentLogFile!.exists()) {
        try {
          final backupFile = File('${logDir.path}/$baseFileName.0.log');
          await _currentLogFile!.copy(backupFile.path);
          await _currentLogFile!.delete();
        } on Exception catch (e) {
          debugPrint('Log dosyası yedeklenemedi: $e');
          // Yedekleme başarısızsa, rotasyonu atla
          return;
        }
      }

      // Yeni log dosyası oluştur
      _currentLogFile = File('${logDir.path}/$baseFileName.log');
      _logSink = _currentLogFile!.openWrite(mode: FileMode.write);
      _currentFileSize = 0;
    } on Exception catch (e) {
      debugPrint('Log dosyası rotasyonu başarısız: $e');
      // Rotasyon başarısızsa, mevcut dosyaya devam et
      try {
        if (_currentLogFile != null) {
          _logSink = _currentLogFile!.openWrite(mode: FileMode.append);
        }
      } on Exception catch (e2) {
        debugPrint('Log dosyası yeniden açılamadı: $e2');
      }
    }
  }

  Future<void> flush() async {
    try {
      await _logSink?.flush();
    } on Exception catch (e) {
      debugPrint('Log flush hatası: $e');
    }
  }

  Future<void> close() async {
    try {
      await flush();
      await _logSink?.close();
      _logSink = null;
      _isInitialized = false;
    } on Exception catch (e) {
      debugPrint('Log kapatma hatası: $e');
    }
  }
}

/// Basitleştirilmiş hata yönetimi ve loglama sınıfı
class ErrorLogger {
  factory ErrorLogger() => _instance;

  ErrorLogger._internal() {
    _fileDestination = SimpleFileLogDestination();
  }
  static final ErrorLogger _instance = ErrorLogger._internal();

  late final SimpleFileLogDestination _fileDestination;
  final bool _isInitialized = false;

  /// Debug seviyesinde log kaydı
  Future<void> debug(
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(LogLevel.debug, message, tag: tag, metadata: metadata);
  }

  /// Info seviyesinde log kaydı
  Future<void> info(
    String message, {
    String? tag,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(LogLevel.info, message, tag: tag, metadata: metadata);
  }

  /// Warning seviyesinde log kaydı
  Future<void> warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  /// Error seviyesinde log kaydı
  Future<void> error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  /// Critical seviyesinde log kaydı
  Future<void> critical(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      LogLevel.critical,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  /// İstisna ve hata loglaması
  Future<void> logException(
    Object exception, {
    String? message,
    String? tag,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    final logMessage = message ?? 'Yakalanan istisna: ${exception.runtimeType}';
    await error(
      logMessage,
      tag: tag ?? 'Exception',
      error: exception,
      stackTrace: stackTrace ?? StackTrace.current,
      metadata: metadata,
    );
  }

  /// İç log işlevselliği
  Future<void> _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    final record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    // Konsol loglaması
    final consoleMessage = record.toFormattedString();
    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        debugPrint(consoleMessage);
        break;
      case LogLevel.warning:
      case LogLevel.error:
      case LogLevel.critical:
        debugPrint('\x1B[31m$consoleMessage\x1B[0m'); // Kırmızı renk
        break;
    }

    // Dosya loglaması (sadece debug modda)
    if (!kReleaseMode) {
      try {
        await _fileDestination.log(record);
      } on Exception catch (e) {
        debugPrint('Dosya loglaması başarısız: $e');
      }
    }
  }

  /// Servis kapatılırken kaynakları serbest bırakır
  Future<void> dispose() async {
    try {
      await _fileDestination.close();
    } on Exception catch (e) {
      debugPrint('ErrorLogger dispose hatası: $e');
    }
  }
}
