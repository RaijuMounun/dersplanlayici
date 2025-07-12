/// Veritabanı yedeklerini temsil eden model sınıfı.
class DatabaseBackupModel { // Bayt cinsinden

  DatabaseBackupModel({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.fileSize,
  });

  /// Map objesinden DatabaseBackupModel nesnesine dönüştürür.
  factory DatabaseBackupModel.fromMap(Map<String, dynamic> map) => DatabaseBackupModel(
      path: map['path'] as String,
      fileName: map['fileName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      fileSize: map['fileSize'] as int,
    );
  final String path;
  final String fileName;
  final DateTime createdAt;
  final int fileSize;

  /// Formatlı dosya boyutu (KB, MB olarak).
  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      final kb = (fileSize / 1024).toStringAsFixed(2);
      return '$kb KB';
    } else {
      final mb = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      return '$mb MB';
    }
  }

  /// Formatlı oluşturulma zamanı.
  String get formattedDate => '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

  /// DatabaseBackup nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'path': path,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'fileSize': fileSize,
    };

  @override
  String toString() => 'DatabaseBackupModel(fileName: $fileName, createdAt: $formattedDate, size: $formattedSize)';
}

/// Veritabanı bilgilerini temsil eden model sınıfı.
class DatabaseInfoModel {

  DatabaseInfoModel({
    required this.path,
    required this.tables,
    required this.recordCounts,
    required this.totalRecords,
    required this.lastModified,
  });

  /// Map objesinden DatabaseInfoModel nesnesine dönüştürür.
  factory DatabaseInfoModel.fromMap(Map<String, dynamic> map) {
    final counts = (map['counts'] as Map<dynamic, dynamic>).cast<String, int>();
    final totalCount = counts.values.fold<int>(0, (sum, count) => sum + count);

    return DatabaseInfoModel(
      path: map['path'] as String,
      tables: (map['tables'] as List<dynamic>).cast<String>(),
      recordCounts: counts,
      totalRecords: totalCount,
      lastModified: DateTime.now(), // Bu bilgi genellikle map'te bulunmaz
    );
  }
  final String path;
  final List<String> tables;
  final Map<String, int> recordCounts;
  final int totalRecords;
  final DateTime lastModified;

  /// DatabaseInfoModel nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'path': path,
      'tables': tables,
      'counts': recordCounts,
      'totalRecords': totalRecords,
      'lastModified': lastModified.toIso8601String(),
    };

  @override
  String toString() => 'DatabaseInfoModel(path: $path, tables: ${tables.length}, totalRecords: $totalRecords)';
}
