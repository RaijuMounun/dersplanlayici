import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/core/error/app_exception.dart' as app_exception;
import 'package:ders_planlayici/core/error/error_logger.dart';
import 'package:ders_planlayici/features/settings/domain/models/app_settings_model.dart';

class AppSettingsRepository {
  AppSettingsRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();
  final DatabaseHelper _databaseHelper;

  /// Uygulama ayarlarını getirir
  Future<AppSettingsModel> getSettings() async {
    try {
      await ErrorLogger().info('Ayarlar alınıyor...', tag: 'AppSettingsRepository');
      final settingsMap = await _databaseHelper.getAppSettings();
      await ErrorLogger().debug(
        'DatabaseHelper\'dan gelen veri: $settingsMap',
        tag: 'AppSettingsRepository',
      );

      if (settingsMap == null) {
        await ErrorLogger().info(
          'Ayarlar null, varsayılan ayarlar döndürülüyor',
          tag: 'AppSettingsRepository',
        );
        // Eğer veritabanında ayarlar yoksa, varsayılan ayarları döndür
        return AppSettingsModel.defaultSettings();
      }

      await ErrorLogger().info('AppSettingsModel.fromMap çağrılıyor...', tag: 'AppSettingsRepository');
      final result = AppSettingsModel.fromMap(settingsMap);
      await ErrorLogger().info('AppSettingsModel başarıyla oluşturuldu', tag: 'AppSettingsRepository');
      return result;
    } catch (e, stackTrace) {
      await ErrorLogger().error(
        'Ayarlar alınırken hata oluştu',
        tag: 'AppSettingsRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw app_exception.DatabaseException(
        message: 'Ayarlar alınamadı',
        code: 'get_settings_failed',
        details: e.toString(),
      );
    }
  }

  /// Uygulama ayarlarını kaydeder
  Future<bool> saveSettings(AppSettingsModel settings) async {
    try {
      final result = await _databaseHelper.insertOrUpdateAppSettings(
        settings.toMap(),
      );
      return result > 0;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ayarlar kaydedilemedi',
        code: 'save_settings_failed',
        details: e.toString(),
      );
    }
  }

  /// Tema ayarını günceller
  Future<bool> updateThemeMode(ThemeMode themeMode) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tema ayarı güncellenemedi',
        code: 'update_theme_failed',
        details: e.toString(),
      );
    }
  }

  /// Ders bildirim zamanı ayarını günceller
  Future<bool> updateNotificationTime(NotificationTime notificationTime) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        lessonNotificationTime: notificationTime,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Bildirim zamanı ayarı güncellenemedi',
        code: 'update_notification_time_failed',
        details: e.toString(),
      );
    }
  }

  /// Hafta sonu gösterme ayarını günceller
  Future<bool> updateShowWeekends(bool showWeekends) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        showWeekends: showWeekends,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Hafta sonu gösterme ayarı güncellenemedi',
        code: 'update_show_weekends_failed',
        details: e.toString(),
      );
    }
  }

  /// Varsayılan ders süresi ayarını günceller
  Future<bool> updateDefaultLessonDuration(int defaultLessonDuration) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultLessonDuration: defaultLessonDuration,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Varsayılan ders süresi ayarı güncellenemedi',
        code: 'update_default_duration_failed',
        details: e.toString(),
      );
    }
  }

  /// Varsayılan ders ücreti ayarını günceller
  Future<bool> updateDefaultLessonFee(double defaultLessonFee) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultLessonFee: defaultLessonFee,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Varsayılan ders ücreti ayarı güncellenemedi',
        code: 'update_default_fee_failed',
        details: e.toString(),
      );
    }
  }

  /// Para birimi ayarını günceller
  Future<bool> updateCurrency(String currency) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(currency: currency);
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Para birimi ayarı güncellenemedi',
        code: 'update_currency_failed',
        details: e.toString(),
      );
    }
  }

  /// Varsayılan ders konusu ayarını günceller
  Future<bool> updateDefaultSubject(String? defaultSubject) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultSubject: defaultSubject,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Varsayılan ders konusu ayarı güncellenemedi',
        code: 'update_default_subject_failed',
        details: e.toString(),
      );
    }
  }

  /// Silme onayı ayarını günceller
  Future<bool> updateConfirmBeforeDelete(bool confirmBeforeDelete) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        confirmBeforeDelete: confirmBeforeDelete,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Silme onayı ayarı güncellenemedi',
        code: 'update_confirm_delete_failed',
        details: e.toString(),
      );
    }
  }

  /// Ders renklerini gösterme ayarını günceller
  Future<bool> updateShowLessonColors(bool showLessonColors) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        showLessonColors: showLessonColors,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ders renklerini gösterme ayarı güncellenemedi',
        code: 'update_show_colors_failed',
        details: e.toString(),
      );
    }
  }

  /// Ek ayarları günceller
  Future<bool> updateAdditionalSettings(
    Map<String, dynamic> additionalSettings,
  ) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        additionalSettings: additionalSettings,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ek ayarlar güncellenemedi',
        code: 'update_additional_settings_failed',
        details: e.toString(),
      );
    }
  }

  /// Ders hatırlatmalarını aktif/pasif yapar
  Future<bool> updateLessonRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        lessonRemindersEnabled: enabled,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ders hatırlatmaları ayarı güncellenemedi',
        code: 'update_lesson_reminders_failed',
        details: e.toString(),
      );
    }
  }

  /// Hatırlatma dakikasını günceller
  Future<bool> updateReminderMinutes(int minutes) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        reminderMinutes: minutes,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Hatırlatma dakikası güncellenemedi',
        code: 'update_reminder_minutes_failed',
        details: e.toString(),
      );
    }
  }

  /// Ödeme hatırlatmalarını aktif/pasif yapar
  Future<bool> updatePaymentRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        paymentRemindersEnabled: enabled,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ödeme hatırlatmaları ayarı güncellenemedi',
        code: 'update_payment_reminders_failed',
        details: e.toString(),
      );
    }
  }

  /// Doğum günü hatırlatmalarını aktif/pasif yapar
  Future<bool> updateBirthdayRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        birthdayRemindersEnabled: enabled,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Doğum günü hatırlatmaları ayarı güncellenemedi',
        code: 'update_birthday_reminders_failed',
        details: e.toString(),
      );
    }
  }
}
