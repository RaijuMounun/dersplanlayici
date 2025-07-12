import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/settings/domain/models/app_settings_model.dart';
import 'package:ders_planlayici/features/settings/data/repositories/app_settings_repository.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';

/// Uygulama ayarlarını yöneten provider sınıfı.
class AppSettingsProvider extends ChangeNotifier {

  AppSettingsProvider(this._settingsRepository) {
    _loadSettings();
  }
  final AppSettingsRepository _settingsRepository;

  AppSettingsModel _settings = AppSettingsModel.defaultSettings();
  bool _isLoading = false;
  AppException? _error;

  /// Mevcut ayarları döndürür.
  AppSettingsModel get settings => _settings;

  /// Yükleme durumunu döndürür.
  bool get isLoading => _isLoading;

  /// Hata durumunu döndürür.
  AppException? get error => _error;

  /// Silmeden önce onay isteyip istememeyi belirleyen ayarı döndürür.
  bool get confirmBeforeDelete => _settings.confirmBeforeDelete;

  /// Uygulama ayarlarını yükler.
  Future<void> _loadSettings() async {
    _setLoading(true);
    _error = null;

    try {
      _settings = await _settingsRepository.getSettings();
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Ayarlar yüklenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Tema modunu günceller.
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateThemeMode(themeMode);
      _settings = _settings.copyWith(themeMode: themeMode);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message: 'Tema modu güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Bildirim zamanını günceller.
  Future<void> updateNotificationTime(NotificationTime time) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateNotificationTime(time);
      _settings = _settings.copyWith(lessonNotificationTime: time);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Bildirim zamanı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Silmeden önce onay isteme ayarını günceller.
  Future<void> updateConfirmBeforeDelete(bool confirm) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateConfirmBeforeDelete(confirm);
      _settings = _settings.copyWith(confirmBeforeDelete: confirm);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Silme onayı ayarı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Hafta sonu gösterme ayarını günceller.
  Future<void> updateShowWeekends(bool show) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateShowWeekends(show);
      _settings = _settings.copyWith(showWeekends: show);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Hafta sonu gösterme ayarı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ders renklerini gösterme ayarını günceller.
  Future<void> updateShowLessonColors(bool show) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateShowLessonColors(show);
      _settings = _settings.copyWith(showLessonColors: show);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Ders renklerini gösterme ayarı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Varsayılan ders süresini günceller.
  Future<void> updateDefaultLessonDuration(int duration) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateDefaultLessonDuration(duration);
      _settings = _settings.copyWith(defaultLessonDuration: duration);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Varsayılan ders süresi güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Varsayılan ders ücretini günceller.
  Future<void> updateDefaultLessonFee(double fee) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateDefaultLessonFee(fee);
      _settings = _settings.copyWith(defaultLessonFee: fee);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Varsayılan ders ücreti güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Yükleme durumunu günceller.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
