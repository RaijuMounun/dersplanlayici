/// Uygulama tema modu
enum ThemeMode {
  system, // Sistem temasını kullan
  light, // Açık tema
  dark, // Koyu tema
}

/// Bildirim süresi
enum NotificationTime {
  none, // Bildirim yok
  fiveMinutes, // 5 dakika önce
  fifteenMinutes, // 15 dakika önce
  thirtyMinutes, // 30 dakika önce
  oneHour, // 1 saat önce
  oneDay, // 1 gün önce
}

/// Uygulama ayarlarını temsil eden model sınıfı.
class AppSettingsModel { // Ek ayarlar

  AppSettingsModel({
    this.themeMode = ThemeMode.system,
    this.lessonNotificationTime = NotificationTime.fifteenMinutes,
    this.showWeekends = true,
    this.defaultLessonDuration = 90,
    this.defaultLessonFee = 0.0,
    this.currency = 'TL',
    this.defaultSubject,
    this.confirmBeforeDelete = true,
    this.showLessonColors = true,
    this.additionalSettings,
  });

  /// Varsayılan ayarlar.
  factory AppSettingsModel.defaultSettings() => AppSettingsModel(
      themeMode: ThemeMode.system,
      lessonNotificationTime: NotificationTime.fifteenMinutes,
      showWeekends: true,
      defaultLessonDuration: 90,
      defaultLessonFee: 0.0,
      currency: 'TL',
      defaultSubject: null,
      confirmBeforeDelete: true,
      showLessonColors: true,
    );

  /// Map objesinden AppSettingsModel nesnesine dönüştürür.
  factory AppSettingsModel.fromMap(Map<String, dynamic> map) => AppSettingsModel(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.${map['themeMode']}',
        orElse: () => ThemeMode.system,
      ),
      lessonNotificationTime: NotificationTime.values.firstWhere(
        (e) =>
            e.toString() == 'NotificationTime.${map['lessonNotificationTime']}',
        orElse: () => NotificationTime.fifteenMinutes,
      ),
      showWeekends: map['showWeekends'] as bool? ?? true,
      defaultLessonDuration: map['defaultLessonDuration'] as int? ?? 90,
      defaultLessonFee: map['defaultLessonFee'] as double? ?? 0.0,
      currency: map['currency'] as String? ?? 'TL',
      defaultSubject: map['defaultSubject'] as String?,
      confirmBeforeDelete: map['confirmBeforeDelete'] as bool? ?? true,
      showLessonColors: map['showLessonColors'] as bool? ?? true,
      additionalSettings: map['additionalSettings'] as Map<String, dynamic>?,
    );
  final ThemeMode themeMode;
  final NotificationTime lessonNotificationTime;
  final bool showWeekends;
  final int defaultLessonDuration; // Dakika cinsinden
  final double defaultLessonFee; // TL cinsinden
  final String? currency; // Para birimi (TL, USD, EUR, vb.)
  final String? defaultSubject; // Varsayılan ders konusu
  final bool confirmBeforeDelete; // Silmeden önce onay iste
  final bool showLessonColors; // Dersleri renklendir
  final Map<String, dynamic>? additionalSettings;

  /// AppSettingsModel nesnesini Map objesine dönüştürür.
  Map<String, dynamic> toMap() => {
      'themeMode': themeMode.toString().split('.').last,
      'lessonNotificationTime': lessonNotificationTime
          .toString()
          .split('.')
          .last,
      'showWeekends': showWeekends,
      'defaultLessonDuration': defaultLessonDuration,
      'defaultLessonFee': defaultLessonFee,
      'currency': currency,
      'defaultSubject': defaultSubject,
      'confirmBeforeDelete': confirmBeforeDelete,
      'showLessonColors': showLessonColors,
      'additionalSettings': additionalSettings,
    };

  /// Güncellenmiş bir ayarlar nesnesi oluşturur.
  AppSettingsModel copyWith({
    ThemeMode? themeMode,
    NotificationTime? lessonNotificationTime,
    bool? showWeekends,
    int? defaultLessonDuration,
    double? defaultLessonFee,
    String? currency,
    String? defaultSubject,
    bool? confirmBeforeDelete,
    bool? showLessonColors,
    Map<String, dynamic>? additionalSettings,
  }) => AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      lessonNotificationTime:
          lessonNotificationTime ?? this.lessonNotificationTime,
      showWeekends: showWeekends ?? this.showWeekends,
      defaultLessonDuration:
          defaultLessonDuration ?? this.defaultLessonDuration,
      defaultLessonFee: defaultLessonFee ?? this.defaultLessonFee,
      currency: currency ?? this.currency,
      defaultSubject: defaultSubject ?? this.defaultSubject,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      showLessonColors: showLessonColors ?? this.showLessonColors,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );

  @override
  String toString() => 'AppSettingsModel(themeMode: $themeMode, lessonNotificationTime: $lessonNotificationTime)';
}
