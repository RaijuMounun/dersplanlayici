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
  final LogLevel level;
  final String message;
  final String? tag;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  LogRecord({
    required this.level,
    required this.message,
    this.tag,
    DateTime? timestamp,
    this.error,
    this.stackTrace,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// LogRecord'u map olarak temsil eder
  Map<String, dynamic> toMap() {
    return {
      'level': level.toString().split('.').last,
      'message': message,
      'tag': tag,
      'timestamp': timestamp.toIso8601String(),
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'metadata': metadata,
    };
  }

  /// LogRecord'u JSON string olarak temsil eder
  String toJson() {
    return jsonEncode(toMap());
  }

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

/// Log hedef arayüzü
abstract class LogDestination {
  Future<void> log(LogRecord record);
  Future<void> flush();
  Future<void> close();
}

/// Konsol log hedefi
class ConsoleLogDestination implements LogDestination {
  final LogLevel minLevel;

  ConsoleLogDestination({this.minLevel = LogLevel.debug});

  @override
  Future<void> log(LogRecord record) async {
    if (record.level.index < minLevel.index) return;

    final message = record.toFormattedString();

    switch (record.level) {
      case LogLevel.debug:
      case LogLevel.info:
        debugPrint(message);
        break;
      case LogLevel.warning:
      case LogLevel.error:
      case LogLevel.critical:
        debugPrint('\x1B[31m$message\x1B[0m'); // Kırmızı renk
        break;
    }
  }

  @override
  Future<void> flush() async {
    // Konsol için flush işlemi yok
  }

  @override
  Future<void> close() async {
    // Konsol için kapama işlemi yok
  }
}

/// Dosya log hedefi
class FileLogDestination implements LogDestination {
  final LogLevel minLevel;
  final String baseFileName;
  final int maxSizeInBytes;
  final int maxFiles;

  File? _currentLogFile;
  IOSink? _logSink;
  int _currentFileSize = 0;

  FileLogDestination({
    this.minLevel = LogLevel.info,
    this.baseFileName = 'app_log',
    this.maxSizeInBytes = 5 * 1024 * 1024, // 5 MB
    this.maxFiles = 5,
  });

  Future<void> _initialize() async {
    if (_currentLogFile != null) return;

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
  }

  @override
  Future<void> log(LogRecord record) async {
    if (record.level.index < minLevel.index) return;

    await _initialize();

    final logLine = '${record.toFormattedString()}\n';
    _logSink!.write(logLine);

    _currentFileSize += logLine.length;

    if (_currentFileSize >= maxSizeInBytes) {
      await _rotateLogFiles();
    }
  }

  Future<void> _rotateLogFiles() async {
    await flush();

    // Eski log dosyalarını kontrol et ve sil
    final directory = await path_provider.getApplicationDocumentsDirectory();
    final logDir = Directory('${directory.path}/logs');

    for (int i = maxFiles - 1; i >= 0; i--) {
      final oldFile = File('${logDir.path}/$baseFileName.$i.log');

      if (await oldFile.exists()) {
        if (i == maxFiles - 1) {
          await oldFile.delete();
        } else {
          final newFile = File('${logDir.path}/$baseFileName.${i + 1}.log');
          await oldFile.rename(newFile.path);
        }
      }
    }

    // Mevcut log dosyasını .0.log olarak kaydet
    final backupFile = File('${logDir.path}/$baseFileName.0.log');
    await _currentLogFile!.rename(backupFile.path);

    // Yeni log dosyası oluştur
    _currentLogFile = File('${logDir.path}/$baseFileName.log');
    _logSink = _currentLogFile!.openWrite(mode: FileMode.write);
    _currentFileSize = 0;
  }

  @override
  Future<void> flush() async {
    await _logSink?.flush();
  }

  @override
  Future<void> close() async {
    await flush();
    await _logSink?.close();
    _logSink = null;
  }
}

/// Hata yönetimi ve loglama sınıfı
///
/// Bu sınıf, uygulamanın farklı bölümlerinden gelen hataları ve
/// log mesajlarını işlemek ve farklı hedeflere yönlendirmek için kullanılır.
class ErrorLogger {
  static final ErrorLogger _instance = ErrorLogger._internal();

  final List<LogDestination> _destinations = [];
  final StreamController<LogRecord> _logStreamController =
      StreamController<LogRecord>.broadcast();

  // Log mesajlarını dinlemek için stream
  Stream<LogRecord> get onLog => _logStreamController.stream;

  factory ErrorLogger() => _instance;

  ErrorLogger._internal() {
    // Varsayılan olarak konsol hedefini ekle
    addDestination(ConsoleLogDestination());

    // Yayın modunda değilse dosya hedefini ekle
    if (!kReleaseMode) {
      addDestination(FileLogDestination());
    }
  }

  /// Log hedefi ekler
  void addDestination(LogDestination destination) {
    _destinations.add(destination);
  }

  /// Log hedefi kaldırır
  void removeDestination(LogDestination destination) {
    _destinations.remove(destination);
  }

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

    _logStreamController.add(record);

    for (final destination in _destinations) {
      try {
        await destination.log(record);
      } catch (e) {
        debugPrint('Log hedefine yazarken hata oluştu: $e');
      }
    }
  }

  /// Tüm log hedeflerini temizler
  Future<void> flush() async {
    for (final destination in _destinations) {
      try {
        await destination.flush();
      } catch (e) {
        debugPrint('Log hedefini temizlerken hata oluştu: $e');
      }
    }
  }

  /// Servis kapatılırken kaynakları serbest bırakır
  Future<void> dispose() async {
    await flush();

    for (final destination in _destinations) {
      try {
        await destination.close();
      } catch (e) {
        debugPrint('Log hedefini kapatırken hata oluştu: $e');
      }
    }

    await _logStreamController.close();
  }
}
