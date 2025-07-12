# Ders Planlama Uygulaması - Teknik Gereksinimler

Bu dosya, ders planlama uygulamasının geliştirilmesi için teknik gereksinimleri, hedef platformları ve teknik kısıtlamaları içerir.

## Geliştirme Ortamı

### Flutter SDK

- **Flutter Sürümü**: Flutter 3.24.0 veya daha yeni
- **Dart Sürümü**: Dart 3.7.0 veya daha yeni
- **Geliştirme IDE'si**: VS Code veya Cursor
- **Flutter Doctor**: Tüm bileşenler yeşil olmalı
- **Minimum Flutter Version**: 3.24.0 (stable channel)

## Hedef Platformlar

### Android

- **Minimum SDK Sürümü**: API level 21 (Android 5.0 Lollipop)
- **Hedef SDK Sürümü**: API level 34 (Android 14)
- **Desteklenen Ekran Boyutları**: Telefon ve tablet (5" - 10")
- **Desteklenen Yönler**: Dikey (portrait) yönelim
- **Desteklenen Mimari**: ARM64, ARM32, x86_64

### Gelecekteki Platformlar (Şu an kapsam dışı)

- iOS (v2.0'da planlanıyor)
- Web (v3.0'da planlanıyor)

## Uygulama Boyutu ve Performans

- **Maksimum APK Boyutu**: 25MB'dan az
- **Minimum Çalışma Belleği Gereksinimi**: 2GB RAM
- **Hedeflenen Çerçeve Hızı**: 60 FPS
- **Soğuk Başlatma Süresi**: 1.5 saniyeden az
- **Veritabanı Boyutu Limiti**: 50MB'a kadar
- **Bellek Kullanımı**: 100MB'dan az

## Bağımlılıklar ve Paketler

### Temel Paketler

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # State management
  sqflite: ^2.3.0           # SQLite veritabanı
  path_provider: ^2.1.1     # Dosya sistemi erişimi
  table_calendar: ^3.0.9    # Takvim widget'ı
  uuid: ^4.3.3              # Benzersiz ID üretimi
  intl: ^0.19.0             # Tarih/saat biçimlendirme
  go_router: ^13.2.0        # Rota yönetimi
  flutter_slidable: ^3.0.0  # Kaydırılabilir liste öğeleri
  shared_preferences: ^2.2.2 # Basit veri depolama
  flutter_local_notifications: ^16.3.2 # Yerel bildirimler
  permission_handler: ^11.3.0 # İzin yönetimi
  crypto: ^3.0.3            # Veri şifreleme
  connectivity_plus: ^5.0.2 # Bağlantı durumu kontrolü
```

### UI Bileşenleri

```yaml
dependencies:
  flutter_staggered_grid_view: ^0.7.0 # Esnek grid görünümü
  shimmer: ^3.0.0                    # Loading animasyonları
  lottie: ^3.0.0                     # Animasyonlar
  cached_network_image: ^3.3.1       # Resim önbellekleme
```

### Geliştirme Araçları

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4           # Mocking
  build_runner: ^2.4.8      # Code generation
  flutter_lints: ^3.0.1     # Linting
  integration_test:
    sdk: flutter
  flutter_launcher_icons: ^0.13.1 # App icon
  flutter_native_splash: ^2.3.9   # Splash screen
```

## Veri Depolama ve Yönetimi

### Yerel Veritabanı

- **Teknoloji**: SQLite 3.x
- **ORM Aracı**: Özel repository implementasyonları
- **Veri Yedekleme**: JSON formatında dosya sistemi
- **Veri Şifreleme**: AES-256 (hassas veriler için)
- **Migration Stratejisi**: Versiyon tabanlı migration

### Kullanıcı Tercihleri

- **Teknoloji**: SharedPreferences
- **Saklanan Veriler**:
  - Tema tercihleri (light/dark)
  - Görünüm ayarları
  - Bildirim tercihleri
  - Dil tercihleri

### Veri Güvenliği

```dart
// Veri şifreleme örneği
class DataEncryption {
  static const String _key = 'your-secret-key';
  
  static String encrypt(String data) {
    // AES-256 encryption implementation
  }
  
  static String decrypt(String encryptedData) {
    // AES-256 decryption implementation
  }
}
```

## Test Stratejisi

### Test Coverage Hedefleri

- **Unit Tests**: %70 minimum coverage (hedef: %80)
- **Widget Tests**: %50 minimum coverage (hedef: %60)
- **Integration Tests**: %30 minimum coverage (hedef: %40)
- **Performance Tests**: Kritik işlemler için
- **Security Tests**: Veri şifreleme ve güvenlik testleri

### Test Kategorileri

#### Unit Tests

```dart
// Örnek unit test
void main() {
  group('StudentProvider Tests', () {
    test('should add student successfully', () async {
      // Test implementation
    });
    
    test('should handle validation errors', () async {
      // Test implementation
    });
  });
}
```

#### Widget Tests

```dart
// Örnek widget test
void main() {
  testWidgets('StudentCard displays correct information', (tester) async {
    // Test implementation
  });
}
```

#### Integration Tests

```dart
// Örnek integration test
void main() {
  testWidgets('Complete student management flow', (tester) async {
    // Test implementation
  });
}
```

### Test Ortamı

- **Test Database**: In-memory SQLite
- **Mock Services**: Mockito ile mock implementasyonlar
- **Test Data**: Factory pattern ile test verileri

## Güvenlik Gereksinimleri

### Veri Güvenliği

- **Veri Şifreleme**: Hassas öğrenci verileri için AES-256
- **Erişim Kontrolü**: Tek kullanıcı odaklı
- **Veri Doğrulama**: Input validation ve sanitization
- **Güvenli Depolama**: Android Keystore kullanımı

### Güvenlik Kontrol Listesi

- [ ] Input validation tüm formlarda
- [ ] SQL injection koruması
- [ ] XSS koruması
- [ ] Dosya upload güvenliği
- [ ] Log güvenliği (hassas veri loglanmamalı)

## Uyumluluk

### Dil Desteği

- **Varsayılan Dil**: Türkçe
- **Gelecekteki Diller**: İngilizce (v2.0'da)
- **Çeviri Yönetimi**: ARB dosyaları ile

### Erişilebilirlik

- **Minimum Yazı Tipi Boyutu**: 14sp
- **Kontrast Oranı**: WCAG AA standardına uygunluk (4.5:1)
- **Dokunmatik Hedef Boyutu**: Minimum 48x48dp
- **Screen Reader Desteği**: TalkBack uyumluluğu
- **Renk Körlüğü Desteği**: Renk kontrastları

### Cihaz Uyumluluğu

- **Android Sürümleri**: 5.0 - 14
- **Ekran Boyutları**: 5" - 10"
- **Çözünürlükler**: 480x800 - 2560x1600
- **Yoğunluk**: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.2'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --debug

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.2'
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-bundle
          path: build/app/outputs/bundle/release/app-release.aab
```

### Build Otomasyonu

- **Otomatik Test**: Her commit'te
- **Otomatik Build**: Main branch'te
- **Otomatik Deploy**: Release tag'lerinde
- **Code Quality**: Lint ve format kontrolü

## Performans Optimizasyonu

### Widget Optimizasyonu

- **Const Constructors**: Mümkün olduğunca kullanım
- **ListView.builder**: Büyük listeler için
- **Lazy Loading**: Gerektiğinde veri yükleme
- **Image Caching**: Resim önbellekleme

### Veritabanı Optimizasyonu

- **Indexing**: Sık sorgulanan alanlar için
- **Batch Operations**: Toplu işlemler
- **Connection Pooling**: Bağlantı havuzu
- **Query Optimization**: Sorgu optimizasyonu

### Bellek Yönetimi

- **Dispose Pattern**: Widget dispose'ları
- **Weak References**: Zayıf referanslar
- **Memory Profiling**: Bellek profilleme
- **Garbage Collection**: Çöp toplama optimizasyonu

## Geliştirme Prensipleri

### Kod Kalitesi

- **Lint Kuralları**: flutter_lints paketi
- **Code Formatting**: dart format
- **Documentation**: Tüm public API'lar için
- **Code Review**: Pull request'lerde zorunlu

### Git Workflow

```bash
# Branch naming
feature/student-management
bugfix/calendar-display
hotfix/critical-error

# Commit message format
feat: add student management feature
fix: resolve calendar display issue
docs: update API documentation
```

### Versiyon Yönetimi

- **Semantic Versioning**: MAJOR.MINOR.PATCH
- **Changelog**: Her release için
- **Release Notes**: Kullanıcı dostu notlar
- **Migration Guide**: Breaking changes için

## Teknik Kısıtlamalar

### Çevrimdışı Çalışma

- **Offline-First**: Tamamen çevrimdışı çalışma
- **Data Sync**: Gelecekte cloud sync
- **Conflict Resolution**: Veri çakışması çözümü

### Bağımlılık Yönetimi

- **Minimum Bağımlılık**: Sadece gerekli paketler
- **Versiyon Sabitleme**: pubspec.lock kullanımı
- **Güvenlik Güncellemeleri**: Düzenli güncelleme

### Saat Dilimi Desteği

- **Yerel Saat Dilimi**: Kullanıcının saat dilimi
- **UTC Storage**: Veritabanında UTC
- **Display Conversion**: Görüntülemede dönüşüm

## Monitoring ve Analytics

### Crash Reporting

- **Firebase Crashlytics**: Crash raporlama
- **Error Tracking**: Hata takibi
- **Performance Monitoring**: Performans izleme

### Analytics

- **User Behavior**: Kullanıcı davranışları
- **Feature Usage**: Özellik kullanımı
- **Performance Metrics**: Performans metrikleri

## Çıktılar

### Release Artifacts

- **Release APK**: Google Play Store için
- **App Bundle**: AAB formatı
- **Debug APK**: Test için
- **Source Code**: GitHub repository

### Dokümantasyon

- **API Documentation**: Kod içi dokümantasyon
- **Architecture Diagrams**: Mimari diyagramlar
- **Database Schema**: Veritabanı şeması
- **User Guide**: Kullanıcı kılavuzu

### Kurulum Talimatları

- **Development Setup**: Geliştirme ortamı
- **Build Instructions**: Build talimatları
- **Deployment Guide**: Dağıtım kılavuzu
- **Troubleshooting**: Sorun giderme

Bu teknik gereksinimler, uygulamanın geliştirilmesi ve sürdürülmesi için bir çerçeve sağlar ve proje süreci boyunca güncellenebilir.
