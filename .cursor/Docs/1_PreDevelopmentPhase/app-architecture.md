# Ders Planlama Uygulaması - Uygulama Mimarisi

Bu dosya, ders planlama uygulamasının mimari yapısını, kullanılacak tasarım desenlerini ve kodun organizasyonunu açıklamaktadır.

## Mimari Yaklaşım

Uygulamamız için **Feature-first** mimari yaklaşımını benimseyeceğiz ve **Provider** state management çözümünü kullanacağız. Bu yaklaşım, kodun özellik bazında organize edilmesini sağlar ve uygulamanın büyümesi durumunda bakımı kolaylaştırır.

### 🎯 Mimari Prensipleri

- **SOLID Principles**: Tüm sınıflar SOLID prensiplerine uygun
- **Dependency Injection**: Basit constructor injection
- **Separation of Concerns**: Her katman kendi sorumluluğuna odaklanır
- **Testability**: Tüm bileşenler test edilebilir
- **Maintainability**: Kod bakımı kolay ve anlaşılır
- **Scalability**: Gelecekteki özellikler için genişletilebilir
- **Offline-First**: Tamamen çevrimdışı çalışma
- **Security-First**: Güvenlik her katmanda düşünülür

### Klasör Yapısı

```
lib/
├── main.dart                  # Uygulama giriş noktası
├── app.dart                   # Uygulama tema ve router yapılandırması
├── core/                      # Tüm uygulama genelinde kullanılan bileşenler
│   ├── constants/             # Sabitler (colors, strings, themes, vb.)
│   ├── error/                 # Hata yönetimi
│   ├── utils/                 # Yardımcı fonksiyonlar
│   ├── widgets/               # Ortak widget'lar
│   ├── services/              # Temel servisler
│   └── security/              # Güvenlik bileşenleri
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
└── shared/                    # Paylaşılan bileşenler
    ├── models/                # Ortak modeller
    ├── widgets/               # Ortak widget'lar
    └── utils/                 # Ortak yardımcı fonksiyonlar
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
class StudentModel {
  final String id;
  final String name;
  final String parentName;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final double lessonFee;
  final String? notes;
  final int grade;
  final List<String> subjects;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const StudentModel({
    required this.id,
    required this.name,
    required this.parentName,
    this.phoneNumber,
    this.parentPhoneNumber,
    required this.lessonFee,
    this.notes,
    required this.grade,
    required this.subjects,
    required this.createdAt,
    required this.updatedAt,
  });
  
  StudentModel copyWith({
    String? id,
    String? name,
    String? parentName,
    String? phoneNumber,
    String? parentPhoneNumber,
    double? lessonFee,
    String? notes,
    int? grade,
    List<String>? subjects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentName: parentName ?? this.parentName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      parentPhoneNumber: parentPhoneNumber ?? this.parentPhoneNumber,
      lessonFee: lessonFee ?? this.lessonFee,
      notes: notes ?? this.notes,
      grade: grade ?? this.grade,
      subjects: subjects ?? this.subjects,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentName': parentName,
      'phoneNumber': phoneNumber,
      'parentPhoneNumber': parentPhoneNumber,
      'lessonFee': lessonFee,
      'notes': notes,
      'grade': grade,
      'subjects': subjects,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      parentName: json['parentName'],
      phoneNumber: json['phoneNumber'],
      parentPhoneNumber: json['parentPhoneNumber'],
      lessonFee: json['lessonFee'].toDouble(),
      notes: json['notes'],
      grade: json['grade'],
      subjects: List<String>.from(json['subjects']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
```

### Lesson (Ders)

```dart
class LessonModel {
  final String id;
  final String studentId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? notes;
  final bool isCompleted;
  final bool isRecurring;
  final RecurringPatternModel? recurringPattern;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const LessonModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.notes,
    this.isCompleted = false,
    this.isRecurring = false,
    this.recurringPattern,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Duration get duration {
    final start = startTime.hour * 60 + startTime.minute;
    final end = endTime.hour * 60 + endTime.minute;
    return Duration(minutes: end - start);
  }
  
  LessonModel copyWith({
    String? id,
    String? studentId,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? notes,
    bool? isCompleted,
    bool? isRecurring,
    RecurringPatternModel? recurringPattern,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
      'isRecurring': isRecurring ? 1 : 0,
      'recurringPattern': recurringPattern?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final startTimeParts = json['startTime'].split(':');
    final endTimeParts = json['endTime'].split(':');
    
    return LessonModel(
      id: json['id'],
      studentId: json['studentId'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      notes: json['notes'],
      isCompleted: json['isCompleted'] == 1,
      isRecurring: json['isRecurring'] == 1,
      recurringPattern: json['recurringPattern'] != null 
          ? RecurringPatternModel.fromJson(json['recurringPattern'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
```

### RecurringPattern (Tekrarlama Deseni)

```dart
enum RecurringType { weekly, monthly, yearly }

class RecurringPatternModel {
  final String id;
  final RecurringType type;
  final int interval;
  final DateTime? endDate;
  final DateTime createdAt;
  
  const RecurringPatternModel({
    required this.id,
    required this.type,
    required this.interval,
    this.endDate,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'interval': interval,
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory RecurringPatternModel.fromJson(Map<String, dynamic> json) {
    return RecurringPatternModel(
      id: json['id'],
      type: RecurringType.values.firstWhere((e) => e.name == json['type']),
      interval: json['interval'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

### Fee (Ücret)

```dart
class FeeModel {
  final String id;
  final String studentId;
  final String? lessonId;
  final double amount;
  final bool isPaid;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const FeeModel({
    required this.id,
    required this.studentId,
    this.lessonId,
    required this.amount,
    this.isPaid = false,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'lessonId': lessonId,
      'amount': amount,
      'isPaid': isPaid ? 1 : 0,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      id: json['id'],
      studentId: json['studentId'],
      lessonId: json['lessonId'],
      amount: json['amount'].toDouble(),
      isPaid: json['isPaid'] == 1,
      date: DateTime.parse(json['date']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
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
class LessonProvider extends ChangeNotifier {
  final LessonRepository _repository;
  
  LessonProvider(this._repository);
  
  List<LessonModel> _lessons = [];
  bool _isLoading = false;
  String? _error;
  
  List<LessonModel> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchLessons(DateTime date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _lessons = await _repository.getLessonsByDate(date);
    } catch (e) {
      _error = e.toString();
      AppErrorHandler.handleError(null, e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addLesson(LessonModel lesson) async {
    try {
      await _repository.addLesson(lesson);
      await fetchLessons(lesson.date);
    } catch (e) {
      _error = e.toString();
      AppErrorHandler.handleError(null, e);
      notifyListeners();
    }
  }
  
  Future<void> updateLesson(LessonModel lesson) async {
    try {
      await _repository.updateLesson(lesson);
      await fetchLessons(lesson.date);
    } catch (e) {
      _error = e.toString();
      AppErrorHandler.handleError(null, e);
      notifyListeners();
    }
  }
  
  Future<void> deleteLesson(String lessonId) async {
    try {
      await _repository.deleteLesson(lessonId);
      _lessons.removeWhere((lesson) => lesson.id == lessonId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      AppErrorHandler.handleError(null, e);
      notifyListeners();
    }
  }
}
```

## Basitleştirilmiş Dependency Injection

GetIt yerine daha basit bir DI yaklaşımı:

```dart
class AppDependencies {
  static final _instance = AppDependencies._();
  factory AppDependencies() => _instance;
  AppDependencies._();
  
  late final DatabaseService _database;
  late final LessonRepository _lessonRepository;
  late final StudentRepository _studentRepository;
  late final FeeRepository _feeRepository;
  
  void initialize() {
    _database = DatabaseServiceImpl();
    _lessonRepository = LessonRepositoryImpl(_database);
    _studentRepository = StudentRepositoryImpl(_database);
    _feeRepository = FeeRepositoryImpl(_database);
  }
  
  DatabaseService get database => _database;
  LessonRepository get lessonRepository => _lessonRepository;
  StudentRepository get studentRepository => _studentRepository;
  FeeRepository get feeRepository => _feeRepository;
}

// Kullanım
final dependencies = AppDependencies();
dependencies.initialize();

// Provider'larda kullanım
class LessonProvider extends ChangeNotifier {
  final LessonRepository _repository;
  
  LessonProvider() : _repository = AppDependencies().lessonRepository;
  
  // Implementation...
}
```

## Global Error Handling

```dart
class AppErrorHandler {
  static void handleError(BuildContext? context, dynamic error) {
    String message = 'Bir hata oluştu';
    
    if (error is DatabaseException) {
      message = 'Veritabanı hatası: ${error.message}';
    } else if (error is ValidationException) {
      message = 'Geçersiz veri: ${error.message}';
    } else if (error is NetworkException) {
      message = 'Bağlantı hatası: ${error.message}';
    } else if (error is PermissionException) {
      message = 'İzin hatası: ${error.message}';
    }
    
    // Log error
    _logError(error);
    
    // Show user-friendly message
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Tamam',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
  
  static void _logError(dynamic error) {
    // Log error to file or analytics service
    print('Error: $error');
  }
}

// Custom Exceptions
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
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
  parent_name TEXT NOT NULL,
  phone_number TEXT,
  parent_phone_number TEXT,
  lesson_fee REAL NOT NULL,
  notes TEXT,
  grade INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE INDEX idx_students_name ON students(name);
CREATE INDEX idx_students_grade ON students(grade);
```

**subjects**

```sql
CREATE TABLE subjects (
  id TEXT PRIMARY KEY,
  student_id TEXT NOT NULL,
  name TEXT NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
);

CREATE INDEX idx_subjects_student_id ON subjects(student_id);
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
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
  FOREIGN KEY (recurring_pattern_id) REFERENCES recurring_patterns (id) ON DELETE SET NULL
);

CREATE INDEX idx_lessons_date ON lessons(date);
CREATE INDEX idx_lessons_student_id ON lessons(student_id);
CREATE INDEX idx_lessons_is_completed ON lessons(is_completed);
```

**recurring_patterns**

```sql
CREATE TABLE recurring_patterns (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  interval INTEGER NOT NULL,
  end_date TEXT,
  created_at TEXT NOT NULL
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
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons (id) ON DELETE SET NULL
);

CREATE INDEX idx_fees_student_id ON fees(student_id);
CREATE INDEX idx_fees_is_paid ON fees(is_paid);
CREATE INDEX idx_fees_date ON fees(date);
```

## Navigasyon

Uygulamada bottom navigation bar kullanılarak ana sayfalar arasında gezinme sağlanacak:

```dart
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  static const List<Widget> _pages = [
    CalendarScreen(),
    StudentsScreen(),
    FeesScreen(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
```

## Güvenlik Planı

### Veri Şifreleme

```dart
class DataEncryption {
  static const String _key = 'your-secret-key-32-chars-long';
  
  static String encrypt(String data) {
    // AES-256 encryption implementation
    // Kullanıcı şifreleri ve hassas veriler için
    return data; // Placeholder
  }
  
  static String decrypt(String encryptedData) {
    // AES-256 decryption implementation
    return encryptedData; // Placeholder
  }
}
```

### Input Validation

```dart
class ValidationUtils {
  static String? validateStudentName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Öğrenci adı boş olamaz';
    }
    if (name.trim().length < 2) {
      return 'Öğrenci adı en az 2 karakter olmalıdır';
    }
    if (name.trim().length > 50) {
      return 'Öğrenci adı en fazla 50 karakter olabilir';
    }
    return null;
  }
  
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Opsiyonel alan
    }
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }
  
  static String? validateLessonFee(String? fee) {
    if (fee == null || fee.trim().isEmpty) {
      return 'Ders ücreti boş olamaz';
    }
    final feeValue = double.tryParse(fee);
    if (feeValue == null || feeValue <= 0) {
      return 'Geçerli bir ücret giriniz';
    }
    return null;
  }
}
```

## Offline-First Yaklaşım

```dart
class OfflineDataManager {
  final DatabaseService _database;
  final SharedPreferences _preferences;
  
  OfflineDataManager(this._database, this._preferences);
  
  Future<void> backupData() async {
    try {
      final students = await _database.getAllStudents();
      final lessons = await _database.getAllLessons();
      final fees = await _database.getAllFees();
      
      final backup = {
        'students': students.map((s) => s.toJson()).toList(),
        'lessons': lessons.map((l) => l.toJson()).toList(),
        'fees': fees.map((f) => f.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final backupJson = jsonEncode(backup);
      await _preferences.setString('data_backup', backupJson);
    } catch (e) {
      AppErrorHandler.handleError(null, e);
    }
  }
  
  Future<void> restoreData() async {
    try {
      final backupJson = _preferences.getString('data_backup');
      if (backupJson != null) {
        final backup = jsonDecode(backupJson);
        
        // Restore data from backup
        // Implementation...
      }
    } catch (e) {
      AppErrorHandler.handleError(null, e);
    }
  }
}
```

## Uygulanacak Bağımlılıklar (Dependencies)

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
  crypto: ^3.0.3            # Şifreleme
  flutter_secure_storage: ^9.0.0 # Güvenli depolama

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4           # Mocking
  build_runner: ^2.4.8      # Code generation
  flutter_lints: ^3.0.1     # Linting
  integration_test:
    sdk: flutter
```

## Kullanılacak Tasarım Desenleri

1. **Repository Pattern**: Veri erişimi soyutlamak için
2. **Provider Pattern**: State yönetimi için
3. **Factory Pattern**: Nesnelerin oluşturulmasını soyutlamak için
4. **Observer Pattern**: UI güncellemeleri için (Provider içinde kullanılır)
5. **Singleton Pattern**: Dependency injection için
6. **Builder Pattern**: Karmaşık nesnelerin oluşturulması için

## Performans Düşünceleri

- Büyük veri listeleri için `ListView.builder` kullanımı
- Gereksiz yeniden oluşturmalardan kaçınmak için `const` yapıcıların kullanımı
- Veritabanı işlemleri için isolate veya compute kullanımı
- Ağır hesaplamalar için memoization tekniği
- Resim önbellekleme ve lazy loading
- Widget tree optimizasyonu

## Mimarinin Güçlü Yönleri

1. **Modülerlik**: Her özellik kendi klasörüne sahiptir ve bağımsız olarak geliştirilebilir
2. **Test Edilebilirlik**: Katmanlı mimari ve soyutlamalar sayesinde birim testleri yazımı kolaylaşır
3. **Bakım Kolaylığı**: Kod düzeni sayesinde ileride yapılacak değişiklikler daha kolay olacaktır
4. **Ölçeklenebilirlik**: Yeni özellikler eklendiğinde mevcut kod etkilenmez
5. **Sorumlulukların Ayrılması**: Her sınıf ve katman belirli sorumluluklara sahiptir
6. **Güvenlik**: Veri şifreleme ve input validation ile güvenli
7. **Offline-First**: Tamamen çevrimdışı çalışabilir
8. **Error Handling**: Merkezi hata yönetimi
