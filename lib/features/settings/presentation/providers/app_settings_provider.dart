import 'package:flutter/foundation.dart';
import 'package:ders_planlayici/features/settings/domain/models/app_settings_model.dart';
import 'package:ders_planlayici/features/settings/data/repositories/app_settings_repository.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:ders_planlayici/core/error/error_logger.dart';

/// Uygulama ayarlarını yöneten provider sınıfı.
class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider(this._settingsRepository);
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

  /// Ders hatırlatmalarının aktif olup olmadığını döndürür.
  bool get lessonRemindersEnabled => _settings.lessonRemindersEnabled;

  /// Hatırlatma dakikasını döndürür.
  int get reminderMinutes => _settings.reminderMinutes;

  /// Ödeme hatırlatmalarının aktif olup olmadığını döndürür.
  bool get paymentRemindersEnabled => _settings.paymentRemindersEnabled;

  /// Doğum günü hatırlatmalarının aktif olup olmadığını döndürür.
  bool get birthdayRemindersEnabled => _settings.birthdayRemindersEnabled;

  /// Provider'ı başlatır ve ayarları yükler.
  Future<void> initialize() async {
    await _loadSettings();
  }

  /// Uygulama ayarlarını yükler.
  Future<void> _loadSettings() async {
    _setLoading(true);
    _error = null;

    try {
      await ErrorLogger().info(
        'Ayarlar yükleniyor...',
        tag: 'AppSettingsProvider',
      );
      _settings = await _settingsRepository.getSettings();
      await ErrorLogger().info(
        'Ayarlar başarıyla yüklendi',
        tag: 'AppSettingsProvider',
      );
      notifyListeners();
    } on AppException catch (e) {
      await ErrorLogger().error(
        'Ayarlar yüklenirken beklenen bir hata oluştu (AppException)',
        tag: 'AppSettingsProvider',
        error: e,
      );
      _error = e;
      notifyListeners();
    } on Exception catch (e, stackTrace) {
      await ErrorLogger().error(
        'Ayarlar yüklenirken beklenmedik bir hata oluştu (Exception)',
        tag: 'AppSettingsProvider',
        error: e,
        stackTrace: stackTrace,
      );
      _error = DatabaseException(
        message: 'Ayarlar yüklenirken bir hata oluştu: ${e.toString()}',
        code: 'load_settings_failed',
        details: e.toString(),
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

  /// Ders hatırlatmalarını aktif/pasif yapar.
  Future<void> updateLessonRemindersEnabled(bool enabled) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateLessonRemindersEnabled(enabled);
      _settings = _settings.copyWith(lessonRemindersEnabled: enabled);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Ders hatırlatmaları ayarı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Hatırlatma dakikasını günceller.
  Future<void> updateReminderMinutes(int minutes) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateReminderMinutes(minutes);
      _settings = _settings.copyWith(reminderMinutes: minutes);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Hatırlatma dakikası güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Ödeme hatırlatmalarını aktif/pasif yapar.
  Future<void> updatePaymentRemindersEnabled(bool enabled) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updatePaymentRemindersEnabled(enabled);
      _settings = _settings.copyWith(paymentRemindersEnabled: enabled);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Ödeme hatırlatmaları ayarı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Doğum günü hatırlatmalarını aktif/pasif yapar.
  Future<void> updateBirthdayRemindersEnabled(bool enabled) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateBirthdayRemindersEnabled(enabled);
      _settings = _settings.copyWith(birthdayRemindersEnabled: enabled);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Doğum günü hatırlatmaları ayarı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Para birimi ayarını günceller.
  Future<void> updateCurrency(String currency) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateCurrency(currency);
      _settings = _settings.copyWith(currency: currency);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Para birimi ayarı güncellenirken bir hata oluştu: ${e.toString()}',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Varsayılan ders konusu ayarını günceller.
  Future<void> updateDefaultSubject(String? defaultSubject) async {
    _setLoading(true);
    _error = null;

    try {
      await _settingsRepository.updateDefaultSubject(defaultSubject);
      _settings = _settings.copyWith(defaultSubject: defaultSubject);
      notifyListeners();
    } on AppException catch (e) {
      _error = e;
      notifyListeners();
    } on Exception catch (e) {
      _error = DatabaseException(
        message:
            'Varsayılan ders konusu ayarı güncellenirken bir hata oluştu: ${e.toString()}',
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
