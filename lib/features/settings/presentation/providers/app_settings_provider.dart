import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/settings/domain/models/app_settings_model.dart';
import 'package:ders_planlayici/features/settings/data/repositories/app_settings_repository.dart';

/// Uygulama ayarlarını yöneten provider sınıfı.
class AppSettingsProvider extends ChangeNotifier {

  AppSettingsProvider(this._repository) {
    loadSettings();
  }
  final AppSettingsRepository _repository;

  AppSettingsModel _settings = AppSettingsModel.defaultSettings();
  bool _isLoading = false;
  String? _error;

  AppSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _executeAction(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
      notifyListeners();
    try {
      await action();
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSettings() async {
    await _executeAction(() async {
      _settings = await _repository.getSettings();
    });
  }

  /// Belirli bir ayarı güncelleyen ve state'i yenileyen genel bir metot.
  Future<void> _updateSetting<T>(
    Future<void> Function(T) updateRepo,
    T value,
    AppSettingsModel Function(T) copyWith,
  ) async {
    await _executeAction(() async {
      await updateRepo(value);
      _settings = copyWith(value);
    });
  }

  Future<void> updateThemeMode(ThemeMode themeMode) => _updateSetting(
    _repository.updateThemeMode,
    themeMode,
    (v) => _settings.copyWith(themeMode: v),
  );

  Future<void> updateNotificationTime(NotificationTime time) => _updateSetting(
    _repository.updateNotificationTime,
    time,
    (v) => _settings.copyWith(lessonNotificationTime: v),
  );

  Future<void> updateConfirmBeforeDelete(bool confirm) => _updateSetting(
    _repository.updateConfirmBeforeDelete,
    confirm,
    (v) => _settings.copyWith(confirmBeforeDelete: v),
  );

  Future<void> updateShowWeekends(bool show) => _updateSetting(
    _repository.updateShowWeekends,
    show,
    (v) => _settings.copyWith(showWeekends: v),
  );

  Future<void> updateShowLessonColors(bool show) => _updateSetting(
    _repository.updateShowLessonColors,
    show,
    (v) => _settings.copyWith(showLessonColors: v),
  );

  Future<void> updateDefaultLessonDuration(int duration) => _updateSetting(
    _repository.updateDefaultLessonDuration,
    duration,
    (v) => _settings.copyWith(defaultLessonDuration: v),
  );

  Future<void> updateDefaultLessonFee(double fee) => _updateSetting(
    _repository.updateDefaultLessonFee,
    fee,
    (v) => _settings.copyWith(defaultLessonFee: v),
  );

  Future<void> updateCurrency(String currency) => _updateSetting(
        _repository.updateCurrency,
        currency,
        (v) => _settings.copyWith(currency: v),
      );

  Future<void> updateDefaultSubject(String? subject) => _updateSetting(
        _repository.updateDefaultSubject,
        subject,
        (v) => _settings.copyWith(defaultSubject: v),
      );

  Future<void> updateLessonRemindersEnabled(bool enabled) => _updateSetting(
    _repository.updateLessonRemindersEnabled,
    enabled,
    (v) => _settings.copyWith(lessonRemindersEnabled: v),
  );

  Future<void> updateReminderMinutes(int minutes) => _updateSetting(
    _repository.updateReminderMinutes,
    minutes,
    (v) => _settings.copyWith(reminderMinutes: v),
  );

  Future<void> updatePaymentRemindersEnabled(bool enabled) => _updateSetting(
    _repository.updatePaymentRemindersEnabled,
    enabled,
    (v) => _settings.copyWith(paymentRemindersEnabled: v),
  );

  Future<void> updateBirthdayRemindersEnabled(bool enabled) => _updateSetting(
    _repository.updateBirthdayRemindersEnabled,
    enabled,
    (v) => _settings.copyWith(birthdayRemindersEnabled: v),
  );
}
