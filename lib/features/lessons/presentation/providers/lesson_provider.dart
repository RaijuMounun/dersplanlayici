import 'package:ders_planlayici/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:flutter/material.dart'; // TimeOfDay için eklendi
import '../../domain/models/lesson_model.dart';
import '../../data/repositories/lesson_repository.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/widgets/app_recurring_picker.dart' as ui;
import 'package:intl/intl.dart';
import 'package:ders_planlayici/features/lessons/domain/models/recurring_pattern_model.dart';

/// Ders verilerini yöneten Provider sınıfı.
class LessonProvider extends ChangeNotifier {
  LessonProvider(
    this._repository,
    this._appSettingsProvider,
    this._studentProvider,
  ) {
    loadLessons();
  }
  final LessonRepository _repository;
  AppSettingsProvider _appSettingsProvider;
  StudentProvider _studentProvider;

  List<Lesson> _allLessons = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // AddEditLessonPage için state
  Lesson? _editingLesson;
  final _formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final notesController = TextEditingController();
  final feeController = TextEditingController();

  bool _isEditMode = false;
  DateTime _lessonDate = DateTime.now();
  TimeOfDay _lessonTime = TimeOfDay.now();
  String? _selectedStudentId;
  List<String> _studentSubjects = [];
  ui.RecurringInfo _recurringInfo = const ui.RecurringInfo(
    type: ui.RecurringType.none,
  );
  LessonStatus _status = LessonStatus.scheduled;
  final int _recurringOccurrences = 10;
  bool _isInitializing = false;
  bool _isDisposed = false;

  /// Tüm derslerin önbelleğe alınmış listesi.
  List<Lesson> get allLessons => _allLessons;

  /// Seçili tarihe göre filtrelenmiş dersler.
  List<Lesson> get lessonsForSelectedDate {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _allLessons.where((lesson) => lesson.date == dateStr).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  // AddEditLessonPage için getter'lar
  GlobalKey<FormState> get formKey => _formKey;
  Lesson? get editingLesson => _editingLesson;
  bool get isEditMode => _isEditMode;
  DateTime get lessonDate => _lessonDate;
  TimeOfDay get lessonTime => _lessonTime;
  String? get selectedStudentId => _selectedStudentId;
  List<String> get studentSubjects => _studentSubjects;
  ui.RecurringInfo get recurringInfo => _recurringInfo;
  LessonStatus get status => _status;
  int get recurringOccurrences => _recurringOccurrences;
  bool get isInitializing => _isInitializing;

  @override
  void dispose() {
    subjectController.dispose();
    notesController.dispose();
    feeController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  void updateDependencies(
    AppSettingsProvider appSettingsProvider,
    StudentProvider studentProvider,
  ) {
    _appSettingsProvider = appSettingsProvider;
    _studentProvider = studentProvider;
  }

  /// Seçili tarihi günceller ve dinleyicileri bilgilendirir.
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // AddEditLessonPage için form state'i güncelleyen metotlar
  void setLessonDate(DateTime date) {
    _lessonDate = date;
    notifyListeners();
  }

  void setLessonTime(TimeOfDay time) {
    _lessonTime = time;
    notifyListeners();
  }

  void setSelectedStudentId(String? studentId) {
    _selectedStudentId = studentId;
    if (studentId != null) {
      final student = _studentProvider.students.firstWhere(
        (s) => s.id == studentId,
        orElse: StudentModel.empty,
      );
      _studentSubjects = student.subjects ?? [];
    } else {
      _studentSubjects = [];
    }
    notifyListeners();
  }

  void setRecurringInfo(ui.RecurringInfo info) {
    _recurringInfo = info;
    notifyListeners();
  }

  void setStatus(LessonStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<void> initializeForm({
    String? lessonId,
    String? studentId,
    DateTime? initialDate,
  }) async {
    _isInitializing = true;
    _isEditMode = lessonId != null;
    notifyListeners();

    try {
      if (_isEditMode) {
        final lesson = await _repository.getLesson(lessonId!);
        if (lesson != null) {
          _editingLesson = lesson;
          _selectedStudentId = lesson.studentId;
          final dateParts = lesson.date.split('-');
          final timeParts = lesson.startTime.split(':');
          _lessonDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          _lessonTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          _status = lesson.status;

          // Controller'ları doldur
          subjectController.text = lesson.subject;
          notesController.text = lesson.notes ?? '';
          feeController.text = lesson.fee.toString();

          if (lesson.recurringPatternId != null) {
            final pattern = await _repository.getRecurringPattern(
              lesson.recurringPatternId!,
            );
            if (pattern != null) {
              // RecurringInfo'yu pattern'den oluştur
            }
          }
        }
      } else {
        // Yeni ders modu için başlangıç değerleri
        _editingLesson = null;
        subjectController.clear();
        notesController.clear();
        feeController.clear();
        _selectedStudentId = studentId;
        _lessonDate = initialDate ?? DateTime.now();
        _lessonTime = TimeOfDay.fromDateTime(_lessonDate);
        _status = LessonStatus.scheduled;
        _recurringInfo = const ui.RecurringInfo(type: ui.RecurringType.none);
      }
    } on Exception catch (e) {
      _error = 'Form başlatılırken bir hata oluştu: ${e.toString()}';
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> saveLesson() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      throw const ValidationException(
        message: 'Lütfen formdaki hataları düzeltin.',
      );
    }

    final startTime = DateTime(
      _lessonDate.year,
      _lessonDate.month,
      _lessonDate.day,
      _lessonTime.hour,
      _lessonTime.minute,
    );
    // Ders süresini ayarlardan al
    final lessonDuration = _appSettingsProvider.settings.defaultLessonDuration;
    final endTime = startTime.add(Duration(minutes: lessonDuration));

    final lessonToSave = Lesson(
      id: _editingLesson?.id ?? '', //
      studentId: _selectedStudentId!,
      studentName: '', // Bu bilgi studentProvider'dan alınmalı
      subject: subjectController.text,
      date: DateFormat('yyyy-MM-dd').format(_lessonDate),
      startTime:
          '${_lessonTime.hour.toString().padLeft(2, '0')}:${_lessonTime.minute.toString().padLeft(2, '0')}',
      endTime:
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      status: _status,
      notes: notesController.text,
      fee: double.tryParse(feeController.text) ?? 0,
      recurringPatternId: _editingLesson?.recurringPatternId,
    );

    if (_isEditMode) {
      await updateLesson(lessonToSave);
    } else {
      await addLesson(lessonToSave);
    }
  }

  /// Belirli bir asenkron işlemi sarmalayan, yükleme ve hata durumlarını yöneten yardımcı.
  Future<T> _executeAction<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;
    if (!_isDisposed) notifyListeners();

    try {
      return await action();
    } on Exception catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  /// Tüm dersleri veritabanından yükler ve `_allLessons` listesini günceller.
  Future<void> loadLessons() async {
    await _executeAction(() async {
      _allLessons = await _repository.getAllLessons();
    });
  }

  /// Yeni bir ders ekler.
  /// Çakışma kontrolü repository katmanında yapılır.
  Future<void> addLesson(Lesson lesson) async {
    final hasConflict = await _repository.checkLessonConflict(
      lesson.date,
      lesson.startTime,
      lesson.endTime,
    );

    if (hasConflict) {
      throw const LessonConflictException(
        message: 'Bu saatlerde başka bir ders zaten planlanmış.',
      );
    }

    await _executeAction(() => _repository.addLesson(lesson));
    await loadLessons(); // Yeni ders eklendikten sonra listeyi yenile
  }

  /// Mevcut bir dersi günceller.
  Future<void> updateLesson(Lesson lesson) async {
    final hasConflict = await _repository.checkLessonConflict(
      lesson.date,
      lesson.startTime,
      lesson.endTime,
      lessonId: lesson.id,
    );

    if (hasConflict) {
      throw const LessonConflictException(
        message: 'Bu saatlerde başka bir ders zaten planlanmış.',
      );
    }

    await _executeAction(() => _repository.updateLesson(lesson));
    await loadLessons(); // Ders güncellendikten sonra listeyi yenile
  }

  /// Bir dersi siler.
  Future<void> deleteLesson(String id) async {
    await _executeAction(() => _repository.deleteLesson(id));
    await loadLessons(); // Ders silindikten sonra listeyi yenile
  }

  Future<Map<String, int>> deleteRecurringLessons(String patternId) async {
    final result = await _executeAction(
      () => _repository.deleteRecurringLessons(patternId),
    );
    await loadLessons();
    return result;
  }

  Future<RecurringPattern?> getRecurringPattern(String patternId) async =>
      _executeAction(() => _repository.getRecurringPattern(patternId));

  /// Tekrarlanan bir ders serisi oluşturur.
  Future<void> createRecurringLessons({
    required Lesson baseLesson,
    required ui.RecurringInfo recurringInfo,
    required int occurrences,
  }) async {
    await _executeAction(
      () => _repository.createRecurringLessons(
        baseLesson: baseLesson,
        recurringInfo: recurringInfo,
        occurrences: occurrences,
      ),
    );
    await loadLessons();
  }

  /// ID'ye göre bir dersi getirir.
  Future<Lesson?> getLessonById(String id) async =>
      _executeAction(() => _repository.getLesson(id));
}
