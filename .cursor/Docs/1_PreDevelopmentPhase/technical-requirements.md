# Ders Planlama Uygulaması - Teknik Gereksinimler

Bu dosya, ders planlama uygulamasının geliştirilmesi için teknik gereksinimleri, hedef platformları ve teknik kısıtlamaları içerir.

## Geliştirme Ortamı

### Flutter SDK
- **Flutter Sürümü**: Flutter 3.16.0 veya daha yeni
- **Dart Sürümü**: Dart 3.2.0 veya daha yeni
- **Geliştirme IDE'si**: VS Code veya Cursor

## Hedef Platformlar

### Android
- **Minimum SDK Sürümü**: API level 21 (Android 5.0 Lollipop)
- **Hedef SDK Sürümü**: API level 34 (Android 14)
- **Desteklenen Ekran Boyutları**: Telefon ve tablet (5" - 10")
- **Desteklenen Yönler**: Dikey (portrait) yönelim

### Gelecekteki Platformlar (Şu an kapsam dışı)
- iOS
- Web

## Uygulama Boyutu ve Performans

- **Maksimum APK Boyutu**: 30MB'dan az
- **Minimum Çalışma Belleği Gereksinimi**: 2GB RAM
- **Hedeflenen Çerçeve Hızı**: 60 FPS
- **Soğuk Başlatma Süresi**: 2 saniyeden az
- **Veritabanı Boyutu Limiti**: 50MB'a kadar

## Bağımlılıklar ve Paketler

### Temel Paketler
- **State Management**: provider ^6.0.5
- **Veritabanı**: sqflite ^2.3.0
- **Dosya Erişimi**: path_provider ^2.1.1
- **Takvim Widget'ı**: table_calendar ^3.0.9
- **ID Üretimi**: uuid ^4.0.0
- **Tarih/Saat Biçimlendirme**: intl ^0.18.1

### UI Bileşenleri
- **Rota Yönetimi**: go_router ^12.0.0
- **Kaydırılabilir Liste Öğeleri**: flutter_slidable ^3.0.0
- **Basit Veri Depolama**: shared_preferences ^2.2.2

### Mimari Paketler
- **Dependency Injection**: get_it ^7.6.4

## Veri Depolama ve Yönetimi

### Yerel Veritabanı
- **Teknoloji**: SQLite
- **ORM Aracı**: Özel repository implementasyonları
- **Veri Yedekleme**: Uygulama dosya sistemine JSON formatında

### Kullanıcı Tercihleri
- **Teknoloji**: SharedPreferences
- **Saklanan Veriler**: Tema tercihleri, görünüm ayarları, vb.

## Güvenlik Gereksinimleri

- **Veri Şifreleme**: Hassas öğrenci verileri için temel şifreleme
- **Erişim Kontrolü**: Tek kullanıcı odaklı, şimdilik kimlik doğrulama yok

## Uyumluluk

### Dil Desteği
- **Varsayılan Dil**: Türkçe
- **Gelecekteki Diller**: İngilizce (şimdilik kapsam dışı)

### Erişilebilirlik
- **Minimum Yazı Tipi Boyutu**: 14sp
- **Kontrast Oranı**: WCAG AA standardına uygunluk (4.5:1)
- **Dokunmatik Hedef Boyutu**: Minimum 48x48dp

## Test Gereksinimleri

- **Birim Testleri**: Kritik iş mantığı için
- **Widget Testleri**: Ana UI bileşenleri için
- **Manuel Testler**: Farklı Android sürümleri ve ekran boyutları için

## Geliştirme Prensipleri

- **Kod Stilieri**: Dart ve Flutter standart stil kılavuzlarına uygunluk
- **Dökümantasyon**: Kritik sınıflar ve yöntemler için kod içi dökümantasyon
- **Versiyon Kontrolü**: Git
- **Kodlama Standartları**: Lint kurallarına uygunluk (analysis_options.yaml)

## Teknik Kısıtlamalar

- **Çevrimdışı Çalışma**: Uygulama tamamen çevrimdışı çalışacak
- **Bağımlılık Yönetimi**: Minimum sayıda üçüncü taraf bağımlılığı
- **Saat Dilimi Desteği**: Yerel saat dilimi kullanımı

## Çıktılar

- **Release APK**: Google Play Store'da yayımlanabilir APK
- **Teknik Dokümantasyon**: Veritabanı şeması ve mimari diyagramlar
- **Kurulum Talimatları**: Geliştirme ortamı kurulum adımları

Bu teknik gereksinimler, uygulamanın geliştirilmesi ve sürdürülmesi için bir çerçeve sağlar ve proje süreci boyunca güncellenebilir. 