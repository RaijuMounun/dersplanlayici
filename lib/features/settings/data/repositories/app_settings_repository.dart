import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/core/error/app_exception.dart' as app_exception;
import 'package:ders_planlayici/core/error/error_logger.dart';
import 'package:ders_planlayici/features/settings/domain/models/app_settings_model.dart';
import 'package:flutter/material.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._databaseHelper);
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
  Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      await _databaseHelper.insertOrUpdateAppSettings(
        settings.toMap(),
      );
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ayarlar kaydedilemedi',
        code: 'save_settings_failed',
        details: e.toString(),
      );
    }
  }

  /// Tema ayarını günceller
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tema ayarı güncellenemedi',
        code: 'update_theme_failed',
        details: e.toString(),
      );
    }
  }

  /// Ders bildirim zamanı ayarını günceller
  Future<void> updateNotificationTime(NotificationTime notificationTime) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        lessonNotificationTime: notificationTime,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Bildirim zamanı ayarı güncellenemedi',
        code: 'update_notification_time_failed',
        details: e.toString(),
      );
    }
  }

  /// Hafta sonu gösterme ayarını günceller
  Future<void> updateShowWeekends(bool showWeekends) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        showWeekends: showWeekends,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Hafta sonu gösterme ayarı güncellenemedi',
        code: 'update_show_weekends_failed',
        details: e.toString(),
      );
    }
  }

  /// Varsayılan ders süresi ayarını günceller
  Future<void> updateDefaultLessonDuration(int defaultLessonDuration) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultLessonDuration: defaultLessonDuration,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Varsayılan ders süresi ayarı güncellenemedi',
        code: 'update_default_duration_failed',
        details: e.toString(),
      );
    }
  }

  /// Varsayılan ders ücreti ayarını günceller
  Future<void> updateDefaultLessonFee(double defaultLessonFee) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultLessonFee: defaultLessonFee,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Varsayılan ders ücreti ayarı güncellenemedi',
        code: 'update_default_fee_failed',
        details: e.toString(),
      );
    }
  }

  /// Para birimi ayarını günceller
  Future<void> updateCurrency(String currency) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(currency: currency);
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Para birimi ayarı güncellenemedi',
        code: 'update_currency_failed',
        details: e.toString(),
      );
    }
  }

  /// Varsayılan ders konusu ayarını günceller
  Future<void> updateDefaultSubject(String? defaultSubject) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        defaultSubject: defaultSubject,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Varsayılan ders konusu ayarı güncellenemedi',
        code: 'update_default_subject_failed',
        details: e.toString(),
      );
    }
  }

  /// Silme onayı ayarını günceller
  Future<void> updateConfirmBeforeDelete(bool confirmBeforeDelete) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        confirmBeforeDelete: confirmBeforeDelete,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Silme onayı ayarı güncellenemedi',
        code: 'update_confirm_delete_failed',
        details: e.toString(),
      );
    }
  }

  /// Ders renklerini gösterme ayarını günceller
  Future<void> updateShowLessonColors(bool showLessonColors) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        showLessonColors: showLessonColors,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ders renklerini gösterme ayarı güncellenemedi',
        code: 'update_show_colors_failed',
        details: e.toString(),
      );
    }
  }

  /// Ek ayarları günceller
  Future<void> updateAdditionalSettings(
    Map<String, dynamic> additionalSettings,
  ) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        additionalSettings: additionalSettings,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ek ayarlar güncellenemedi',
        code: 'update_additional_settings_failed',
        details: e.toString(),
      );
    }
  }

  /// Ders hatırlatmalarını aktif/pasif yapar
  Future<void> updateLessonRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        lessonRemindersEnabled: enabled,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ders hatırlatmaları ayarı güncellenemedi',
        code: 'update_lesson_reminders_failed',
        details: e.toString(),
      );
    }
  }

  /// Hatırlatma dakikasını günceller
  Future<void> updateReminderMinutes(int minutes) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        reminderMinutes: minutes,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Hatırlatma dakikası güncellenemedi',
        code: 'update_reminder_minutes_failed',
        details: e.toString(),
      );
    }
  }

  /// Ödeme hatırlatmalarını aktif/pasif yapar
  Future<void> updatePaymentRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        paymentRemindersEnabled: enabled,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Ödeme hatırlatmaları ayarı güncellenemedi',
        code: 'update_payment_reminders_failed',
        details: e.toString(),
      );
    }
  }

  /// Doğum günü hatırlatmalarını aktif/pasif yapar
  Future<void> updateBirthdayRemindersEnabled(bool enabled) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        birthdayRemindersEnabled: enabled,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Doğum günü hatırlatmaları ayarı güncellenemedi',
        code: 'update_birthday_reminders_failed',
        details: e.toString(),
      );
    }
  }
}
