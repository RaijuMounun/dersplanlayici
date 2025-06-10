/// Uygulama genelinde kullanılan sabit değerleri içerir.
class AppConstants {
  AppConstants._();

  // Uygulama Bilgileri
  static const String appName = 'Ders Planlayıcı';
  static const String appVersion = '1.0.0';

  // Veritabanı
  static const String dbName = 'ders_planlayici.db';
  static const int dbVersion = 1;

  // Tablolar
  static const String studentTable = 'students';
  static const String lessonTable = 'lessons';
  static const String recurringPatternTable = 'recurring_patterns';
  static const String feeTable = 'fees';
  static const String subjectTable = 'subjects';

  // Tarih & Saat Formatları
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Ekran Boyutları
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  static const double smallRadius = 4.0;
  static const double mediumRadius = 8.0;
  static const double largeRadius = 16.0;

  // Asset Yolları
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';

  // Sayfa Başlıkları
  static const String calendarTitle = 'Takvim';
  static const String studentsTitle = 'Öğrenciler';
  static const String feesTitle = 'Ücretler';
  static const String settingsTitle = 'Ayarlar';

  // Form Etiketleri
  static const String studentNameLabel = 'Öğrenci Adı';
  static const String parentNameLabel = 'Veli Adı';
  static const String phoneLabel = 'Telefon';
  static const String parentPhoneLabel = 'Veli Telefonu';
  static const String lessonFeeLabel = 'Ders Ücreti';
  static const String gradeLabel = 'Sınıf';
  static const String notesLabel = 'Notlar';
  static const String subjectsLabel = 'Dersler';

  static const String lessonDateLabel = 'Tarih';
  static const String startTimeLabel = 'Başlangıç Saati';
  static const String endTimeLabel = 'Bitiş Saati';
  static const String isRecurringLabel = 'Tekrarlansın mı?';

  // Buton Metinleri
  static const String saveButton = 'Kaydet';
  static const String cancelButton = 'İptal';
  static const String deleteButton = 'Sil';
  static const String editButton = 'Düzenle';
  static const String addButton = 'Ekle';
}
