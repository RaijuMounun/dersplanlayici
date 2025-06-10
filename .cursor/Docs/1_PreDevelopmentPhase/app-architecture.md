# Ders Planlama Uygulaması - Uygulama Mimarisi

Bu dosya, ders planlama uygulamasının mimari yapısını, kullanılacak tasarım desenlerini ve kodun organizasyonunu açıklamaktadır.

## Mimari Yaklaşım

Uygulamamız için **Feature-first** mimari yaklaşımını benimseyeceğiz ve **Provider** state management çözümünü kullanacağız. Bu yaklaşım, kodun özellik bazında organize edilmesini sağlar ve uygulamanın büyümesi durumunda bakımı kolaylaştırır.

### Klasör Yapısı

```
lib/
├── main.dart                  # Uygulama giriş noktası
├── app.dart                   # Uygulama tema ve router yapılandırması
├── core/                      # Tüm uygulama genelinde kullanılan bileşenler
│   ├── constants/             # Sabitler (colors, strings, themes, vb.)
│   ├── error/                 # Hata yönetimi
│   ├── utils/                 # Yardımcı fonksiyonlar
│   └── widgets/               # Ortak widget'lar
├── features/                  # Uygulama özellikleri
│   ├── calendar/              # Takvim özelliği
│   │   ├── data/              # Veri katmanı
│   │   ├── domain/            # İş mantığı
│   │   └── presentation/      # UI katmanı
│   ├── lessons/               # Ders yönetimi özelliği
│   │   ├── data/              
│   │   ├── domain/            
│   │   └── presentation/      
│   ├── students/              # Öğrenci yönetimi özelliği
│   │   ├── data/              
│   │   ├── domain/            
│   │   └── presentation/      
│   └── fees/                  # Ücret takibi özelliği
│       ├── data/              
│       ├── domain/            
│       └── presentation/      
└── services/                  # Servisler
    ├── database/              # Veritabanı hizmetleri
    ├── notifications/         # Bildirim hizmetleri (ileride)
    └── preferences/           # Uygulama tercihleri
```

## Katmanlı Mimari

Her özellik için üç katmanlı bir mimari kullanacağız:

### 1. Data Katmanı
- **Repositories**: Veri erişim işlemlerini soyutlar
- **Data Sources**: Verilerin geldiği kaynak (yerel veritabanı, API vb.)
- **Models**: Veri modelleri ve dönüşümleri

### 2. Domain Katmanı
- **Entities**: İş mantığı için veri modelleri
- **Use Cases**: İş mantığı işlemleri
- **Repository Interfaces**: Repository soyutlamaları

### 3. Presentation Katmanı
- **Widgets**: UI bileşenleri
- **Pages/Screens**: Tam sayfa ekranlar
- **Providers**: State yönetimi

## Veri Modelleri

Uygulamada kullanılacak temel veri modelleri:

### Student (Öğrenci)
```dart
class Student {
  final String id;
  final String name;
  final String parentName;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final double lessonFee;
  final String? notes;
  final int grade;
  final List<String> subjects;
  
  // Constructor ve diğer metodlar...
}
```

### Lesson (Ders)
```dart
class Lesson {
  final String id;
  final String studentId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? notes;
  final bool isCompleted;
  final bool isRecurring;
  final RecurringPattern? recurringPattern;
  
  // Constructor ve diğer metodlar...
}
```

### RecurringPattern (Tekrarlama Deseni)
```dart
class RecurringPattern {
  final RecurringType type; // Haftalık, aylık vb.
  final int interval;
  final DateTime? endDate;
  
  // Constructor ve diğer metodlar...
}
```

### Fee (Ücret)
```dart
class Fee {
  final String id;
  final String studentId;
  final String? lessonId;
  final double amount;
  final bool isPaid;
  final DateTime date;
  
  // Constructor ve diğer metodlar...
}
```

## State Management

Provider paketi ile state management yapısı:

```dart
// Ana provider yapısı
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CalendarProvider()),
    ChangeNotifierProvider(create: (_) => LessonProvider()),
    ChangeNotifierProvider(create: (_) => StudentProvider()),
    ChangeNotifierProvider(create: (_) => FeeProvider()),
  ],
  child: MyApp(),
)
```

### Provider Örnekleri

```dart
// Ders provider örneği
class LessonProvider extends ChangeNotifier {
  final LessonRepository _repository;
  List<Lesson> _lessons = [];
  
  List<Lesson> get lessons => _lessons;
  
  Future<void> fetchLessons(DateTime date) async {
    _lessons = await _repository.getLessonsByDate(date);
    notifyListeners();
  }
  
  Future<void> addLesson(Lesson lesson) async {
    await _repository.addLesson(lesson);
    await fetchLessons(lesson.date);
  }
  
  // Diğer metodlar...
}
```

## Veritabanı Yapısı

SQLite veritabanı kullanarak yerel depolama:

### Tablolar

**students**
```sql
CREATE TABLE students (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  parent_name TEXT,
  phone_number TEXT,
  parent_phone_number TEXT,
  lesson_fee REAL NOT NULL,
  notes TEXT,
  grade INTEGER NOT NULL,
  created_at TEXT NOT NULL
);
```

**subjects**
```sql
CREATE TABLE subjects (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL,
  name TEXT NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
);
```

**lessons**
```sql
CREATE TABLE lessons (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL,
  date TEXT NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  notes TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0,
  is_recurring INTEGER NOT NULL DEFAULT 0,
  recurring_pattern_id TEXT,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
  FOREIGN KEY (recurring_pattern_id) REFERENCES recurring_patterns (id) ON DELETE SET NULL
);
```

**recurring_patterns**
```sql
CREATE TABLE recurring_patterns (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  interval INTEGER NOT NULL,
  end_date TEXT
);
```

**fees**
```sql
CREATE TABLE fees (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL,
  lesson_id TEXT,
  amount REAL NOT NULL,
  is_paid INTEGER NOT NULL DEFAULT 0,
  date TEXT NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE SET NULL
);
```

## Navigasyon

Uygulamada bottom navigation bar kullanılarak ana sayfalar arasında gezinme sağlanacak:

```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: 'Takvim',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Öğrenciler',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.attach_money),
      label: 'Ücretler',
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
)
```

Ekranlar arası geçiş için Navigator 2.0 kullanılacak ve GoRouter paketi ile route yönetimi yapılacak.

## Dependency Injection

GetIt paketi ile dependency injection yapısı oluşturulacak:

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<LessonRepository>(() => LessonRepositoryImpl(getIt()));
  getIt.registerLazySingleton<StudentRepository>(() => StudentRepositoryImpl(getIt()));
  getIt.registerLazySingleton<FeeRepository>(() => FeeRepositoryImpl(getIt()));
  
  // Data sources
  getIt.registerLazySingleton<LessonDataSource>(() => LessonDataSourceImpl(getIt()));
  getIt.registerLazySingleton<StudentDataSource>(() => StudentDataSourceImpl(getIt()));
  getIt.registerLazySingleton<FeeDataSource>(() => FeeDataSourceImpl(getIt()));
  
  // Services
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseServiceImpl());
  
  // Providers
  getIt.registerFactory<LessonProvider>(() => LessonProvider(getIt()));
  getIt.registerFactory<StudentProvider>(() => StudentProvider(getIt()));
  getIt.registerFactory<FeeProvider>(() => FeeProvider(getIt()));
}
```

## Uygulanacak Bağımlılıklar (Dependencies)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5          # State management
  sqflite: ^2.3.0           # SQLite veritabanı
  path_provider: ^2.1.1     # Dosya sistemi erişimi
  table_calendar: ^3.0.9    # Takvim widget'ı
  uuid: ^4.0.0              # Benzersiz ID üretimi
  intl: ^0.18.1             # Tarih/saat biçimlendirme
  go_router: ^12.0.0        # Rota yönetimi
  get_it: ^7.6.4            # Dependency injection
  flutter_slidable: ^3.0.0  # Kaydırılabilir liste öğeleri
  shared_preferences: ^2.2.2 # Basit veri depolama
```

## Kullanılacak Tasarım Desenleri

1. **Repository Pattern**: Veri erişimi soyutlamak için
2. **Provider Pattern**: State yönetimi için
3. **Factory Pattern**: Nesnelerin oluşturulmasını soyutlamak için
4. **Dependency Injection**: Bağımlılıkların yönetimi için
5. **Observer Pattern**: UI güncellemeleri için (Provider içinde kullanılır)

## Performans Düşünceleri

- Büyük veri listeleri için `ListView.builder` kullanımı
- Gereksiz yeniden oluşturmalardan kaçınmak için `const` yapıcıların kullanımı
- Veritabanı işlemleri için isolate veya compute kullanımı
- Ağır hesaplamalar için memoization tekniği

## Mimarinin Güçlü Yönleri

1. **Modülerlik**: Her özellik kendi klasörüne sahiptir ve bağımsız olarak geliştirilebilir
2. **Test Edilebilirlik**: Katmanlı mimari ve soyutlamalar sayesinde birim testleri yazımı kolaylaşır
3. **Bakım Kolaylığı**: Kod düzeni sayesinde ileride yapılacak değişiklikler daha kolay olacaktır
4. **Ölçeklenebilirlik**: Yeni özellikler eklendiğinde mevcut kod etkilenmez
5. **Sorumlulukların Ayrılması**: Her sınıf ve katman belirli sorumluluklara sahiptir 