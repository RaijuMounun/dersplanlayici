import 'dart:io';
import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/core/error/app_exception.dart' as app_exception;
import 'package:ders_planlayici/features/settings/domain/models/database_backup_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseBackupRepository {

  DatabaseBackupRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();
  final DatabaseHelper _databaseHelper;

  /// Veritabanı yedeklerini getirir
  Future<List<DatabaseBackupModel>> getBackups() async {
    try {
      final backupMaps = await _databaseHelper.getDatabaseBackups();
      return backupMaps.map(DatabaseBackupModel.fromMap).toList();
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Yedekler alınamadı',
        code: 'get_backups_failed',
        details: e.toString(),
      );
    }
  }

  /// Veritabanı yedeği oluşturur
  Future<DatabaseBackupModel> createBackup() async {
    try {
      // Veritabanı dosyasını al
      final db = await _databaseHelper.database;
      final dbPath = db.path;
      final dbFile = File(dbPath);

      // Yedekleme dizinini oluştur
      final backupDir = await _getBackupDirectory();
      if (!backupDir.existsSync()) {
        await backupDir.create(recursive: true);
      }

      // Yedek dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'backup_$timestamp.db';
      final backupPath = join(backupDir.path, backupFileName);
      final backupFile = File(backupPath);

      // Dosyayı kopyala
      await dbFile.copy(backupPath);

      // Dosya boyutunu al
      final fileSize = await backupFile.length();

      // Yedek bilgilerini veritabanına kaydet
      final backup = DatabaseBackupModel(
        path: backupPath,
        fileName: backupFileName,
        createdAt: DateTime.now(),
        fileSize: fileSize,
      );

      await _databaseHelper.insertDatabaseBackup(backup.toMap());

      return backup;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Yedek oluşturulamadı',
        code: 'create_backup_failed',
        details: e.toString(),
      );
    }
  }

  /// Veritabanı yedeğini geri yükler
  Future<bool> restoreBackup(DatabaseBackupModel backup) async {
    try {
      // Önce veritabanını kapat
      final db = await _databaseHelper.database;
      await db.close();

      // Yedek dosyasını kontrol et
      final backupFile = File(backup.path);
      if (!backupFile.existsSync()) {
        throw app_exception.DatabaseException(
          message: 'Yedek dosyası bulunamadı',
          code: 'backup_file_not_found',
          details: 'Dosya: ${backup.path}',
        );
      }

      // Mevcut veritabanı dosyasını bul
      final databasesPath = await getDatabasesPath();
      final dbPath = join(databasesPath, 'ders_planlayici.db');
      final dbFile = File(dbPath);

      // Geçici yedek oluştur
      if (dbFile.existsSync()) {
        final tempBackupPath = '$dbPath.bak';
        await dbFile.copy(tempBackupPath);
      }

      // Yedek dosyasını kopyala
      await backupFile.copy(dbPath);

      return true;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Yedek geri yüklenemedi',
        code: 'restore_backup_failed',
        details: e.toString(),
      );
    }
  }

  /// Veritabanı yedeğini siler
  Future<bool> deleteBackup(DatabaseBackupModel backup) async {
    try {
      // Veritabanından sil
      await _databaseHelper.deleteDatabaseBackup(backup.path);

      // Dosyayı sil
      final backupFile = File(backup.path);
      if (backupFile.existsSync()) {
        await backupFile.delete();
      }

      return true;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Yedek silinemedi',
        code: 'delete_backup_failed',
        details: e.toString(),
      );
    }
  }

  /// Veritabanı bilgilerini getirir
  Future<DatabaseInfoModel> getDatabaseInfo() async {
    try {
      final infoMap = await _databaseHelper.getDatabaseInfo();
      return DatabaseInfoModel.fromMap(infoMap);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Veritabanı bilgileri alınamadı',
        code: 'get_db_info_failed',
        details: e.toString(),
      );
    }
  }

  /// Yedekleme dizinini döndürür
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(join(appDir.path, 'backups'));
  }
}
