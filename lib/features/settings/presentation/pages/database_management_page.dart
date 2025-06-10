import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/core/error/error_handler.dart';
import 'package:file_picker/file_picker.dart';

class DatabaseManagementPage extends StatefulWidget {
  const DatabaseManagementPage({super.key});

  @override
  State<DatabaseManagementPage> createState() => _DatabaseManagementPageState();
}

class _DatabaseManagementPageState extends State<DatabaseManagementPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Map<String, dynamic>? _databaseInfo;
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final info = await _databaseHelper.getDatabaseInfo();

      if (!mounted) return;

      setState(() {
        _databaseInfo = info;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = 'Veritabanı bilgileri yüklenirken hata oluştu: $e';
      });

      ErrorHandler.logError(e, hint: 'Veritabanı bilgileri yüklenirken hata');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetDatabase() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // Onay diyaloğu göster
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Veritabanını Sıfırla'),
          content: const Text(
            'Bu işlem tüm verileri silecek ve veritabanını yeniden oluşturacaktır. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Evet, Sıfırla'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (confirmed == true) {
        await _databaseHelper.resetDatabase();
        await _loadDatabaseInfo();

        if (!mounted) return;

        setState(() {
          _message = 'Veritabanı başarıyla sıfırlandı.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.logError(e, hint: 'Veritabanı sıfırlanırken hata');

      ErrorHandler.showErrorSnackBar(
        context,
        message: 'Veritabanı sıfırlanırken hata oluştu: $e',
      );

      setState(() {
        _message = 'Veritabanı sıfırlanırken hata oluştu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _backupDatabase() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final backupPath = await _databaseHelper.backupDatabase();

      if (!mounted) return;

      setState(() {
        _message = 'Veritabanı yedeklendi: $backupPath';
      });
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.logError(e, hint: 'Veritabanı yedeklenirken hata');

      ErrorHandler.showErrorSnackBar(
        context,
        message: 'Veritabanı yedeklenirken hata oluştu',
      );

      setState(() {
        _message = 'Veritabanı yedeklenirken hata oluştu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restoreDatabase() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // Dosya seçiciyi aç
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Yedek Dosyasını Seç',
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['backup', 'db'],
      );

      if (!mounted) return;

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          // Onay diyaloğu göster
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Veritabanını Geri Yükle'),
              content: const Text(
                'Bu işlem mevcut veritabanını yedekten geri yükleyecektir. Mevcut veriler kaybolacaktır. Devam etmek istiyor musunuz?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Evet, Geri Yükle'),
                ),
              ],
            ),
          );

          if (!mounted) return;

          if (confirmed == true) {
            await _databaseHelper.restoreDatabase(path);
            await _loadDatabaseInfo();

            if (!mounted) return;

            setState(() {
              _message = 'Veritabanı başarıyla geri yüklendi.';
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;

      ErrorHandler.logError(e, hint: 'Veritabanı geri yüklenirken hata');

      ErrorHandler.showErrorSnackBar(
        context,
        message: 'Veritabanı geri yüklenirken hata oluştu',
      );

      setState(() {
        _message = 'Veritabanı geri yüklenirken hata oluştu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Veritabanı Yönetimi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Veritabanı bilgileri
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Veritabanı Bilgileri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_databaseInfo != null) ...[
                            Text('Yol: ${_databaseInfo!['path']}'),
                            const SizedBox(height: 8),
                            Text(
                              'Tablolar: ${_databaseInfo!['tables'].join(', ')}',
                            ),
                            const SizedBox(height: 16),
                            const Text('Tablo Verileri:'),
                            const SizedBox(height: 8),
                            if (_databaseInfo!.containsKey('counts'))
                              ..._databaseInfo!['counts'].entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    '${entry.key}: ${entry.value} kayıt',
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // İşlem butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetDatabase,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Sıfırla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _backupDatabase,
                        icon: const Icon(Icons.backup),
                        label: const Text('Yedekle'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _restoreDatabase,
                        icon: const Icon(Icons.restore),
                        label: const Text('Geri Yükle'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Mesaj alanı
                  if (_message.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _message.contains('hata')
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_message),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDatabaseInfo,
        tooltip: 'Yenile',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
