import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/app_button.dart';
import 'package:ders_planlayici/core/widgets/app_text_field.dart';
import 'package:ders_planlayici/core/widgets/app_date_time_picker.dart';
import 'package:ders_planlayici/core/widgets/app_recurring_picker.dart';
import 'package:ders_planlayici/core/widgets/app_student_picker.dart';
import 'package:ders_planlayici/core/error/error_handler.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/core/navigation/route_names.dart';

class AddEditLessonPage extends StatefulWidget {
  const AddEditLessonPage({
    super.key,
    this.lessonId,
    this.studentId,
    this.initialDate,
  });
  final String? lessonId;
  final String? studentId;
  final DateTime? initialDate;

  @override
  State<AddEditLessonPage> createState() => _AddEditLessonPageState();
}

class _AddEditLessonPageState extends State<AddEditLessonPage> {
  final _formKey = GlobalKey<FormState>();

  // Form için controller'lar
  final _subjectController = TextEditingController();
  final _notesController = TextEditingController();
  final _feeController = TextEditingController();

  // Form değerleri
  DateTime _lessonDate = DateTime.now();
  String? _selectedStudentId;
  double _fee = 0;
  RecurringInfo _recurringInfo = const RecurringInfo(type: RecurringType.none);
  LessonStatus _status = LessonStatus.scheduled;
  int _recurringOccurrences = 10; // Tekrar sayısı

  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.lessonId != null;

    // Başlangıç tarihini ayarla
    if (widget.initialDate != null) {
      _lessonDate = widget.initialDate!;
    }

    // URL'den gelen studentId varsa, seç
    if (widget.studentId != null) {
      _selectedStudentId = widget.studentId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Öğrencileri yükle
      if (!mounted) return;
      await context.read<StudentProvider>().loadStudents();

      // Eğer düzenleme modundaysa, ders bilgilerini yükle
      if (_isEditMode && mounted) {
        final lessonProvider = context.read<LessonProvider>();
        final lesson = await lessonProvider.getLessonById(widget.lessonId!);

        if (lesson != null && mounted) {
          _subjectController.text = lesson.subject;
          _notesController.text = lesson.notes ?? '';
          _feeController.text = lesson.fee.toString();

          final dateParts = lesson.date.split('-');
          final startTimeParts = lesson.startTime.split(':');

          _lessonDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
          );

          _selectedStudentId = lesson.studentId;
          _fee = lesson.fee;
          _status = lesson.status;

          if (lesson.recurringPatternId != null) {
            await _loadRecurringPattern(lesson.recurringPatternId!);
          }
        }
      }
    } on Exception catch (e) {
      if (!mounted) return;
      AppErrorHandler.handleError(context, e);
      if (!mounted) return;
      context.pop(); // Hata sonrası sayfayı kapat
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_isEditMode ? 'Dersi Düzenle' : 'Yeni Ders Ekle'),
      actions: [
        if (_isEditMode && _isRecurring())
          IconButton(
            icon: const Icon(Icons.repeat),
            tooltip: 'Tekrarlanan Ders Serisi',
            onPressed: _showRecurringLessonOptions,
          ),
        if (_isEditMode)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteLesson,
            tooltip: 'Dersi Sil',
          ),
      ],
    ),
    body: _buildBody(),
  );

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ResponsiveUtils.deviceValue<Widget>(
      context: context,
      mobile: _buildMobileForm(),
      tablet: _buildTabletForm(),
      desktop: _buildDesktopForm(),
    );
  }

  // Mobil için form tasarımı - Tek sütun
  Widget _buildMobileForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppDimensions.spacing16),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormFields(),
      ),
    ),
  );

  // Tablet için form tasarımı - Bazı alanlar yan yana
  Widget _buildTabletForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppDimensions.spacing24),
    child: Center(
      child: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStudentField()),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(child: _buildSubjectField()),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              _buildDateTimeField(),
              const SizedBox(height: AppDimensions.spacing16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildFeeField()),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(child: _buildStatusField()),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              _buildRecurringPicker(),
              const SizedBox(height: AppDimensions.spacing16),
              _buildNotesField(),
              const SizedBox(height: AppDimensions.spacing24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    ),
  );

  // Desktop için form tasarımı - Daha geniş ve çok alanlar yan yana
  Widget _buildDesktopForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppDimensions.spacing32),
    child: Center(
      child: SizedBox(
        width: 800,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildStudentField()),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(flex: 2, child: _buildSubjectField()),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(child: _buildFeeField()),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildDateTimeField()),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(child: _buildStatusField()),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              _buildRecurringPicker(),
              const SizedBox(height: AppDimensions.spacing16),
              _buildNotesField(),
              const SizedBox(height: AppDimensions.spacing24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    ),
  );

  // Tüm form alanlarını bir liste olarak döndür (mobil görünüm için)
  List<Widget> _buildFormFields() => [
    _buildStudentField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildSubjectField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildDateTimeField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildFeeField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildStatusField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildRecurringPicker(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildNotesField(),
    const SizedBox(height: AppDimensions.spacing24),
    _buildSubmitButton(),
  ];

  // Öğrenci seçim alanı
  Widget _buildStudentField() {
    final studentProvider = context.watch<StudentProvider>();

    return AppStudentPicker(
      label: 'Öğrenci',
      required: true,
      initialSelectedId: _selectedStudentId,
      students: studentProvider.students,
      onStudentSelected: (studentId) {
        setState(() {
          _selectedStudentId = studentId;
        });
      },
      showAddButton: true,
      onAddPressed: () {
        // Öğrenci ekleme sayfasına git
        context.pushNamed(RouteNames.addStudent).then((_) {
          // Geri döndüğünde öğrenci listesini güncelle
          if (mounted) {
            context.read<StudentProvider>().loadStudents();
          }
        });
      },
    );
  }

  // Ders konusu alanı
  Widget _buildSubjectField() => AppTextField(
    label: 'Ders Konusu',
    hint: 'Örn: Matematik, Fizik, İngilizce',
    controller: _subjectController,
    required: false,
  );

  // Tarih ve saat alanı
  Widget _buildDateTimeField() => AppDateTimePicker(
    label: 'Ders Tarihi ve Saati',
    required: true,
    initialDateTime: _lessonDate,
    onDateTimeChanged: (dateTime) {
      setState(() {
        _lessonDate = dateTime;
      });
    },
  );

  // Ücret alanı
  Widget _buildFeeField() => AppTextField(
    label: 'Ders Ücreti',
    hint: 'Örn: 100',
    controller: _feeController,
    keyboardType: TextInputType.number,
    prefixIcon: const Icon(Icons.attach_money),
    onChanged: (value) {
      setState(() {
        _fee = double.tryParse(value) ?? 0;
      });
    },
  );

  // Durum alanı
  Widget _buildStatusField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Durum', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: AppDimensions.spacing8),
      DropdownButtonFormField<LessonStatus>(
        value: _status,
        decoration: const InputDecoration(
          filled: true,
          fillColor: null, // Tema rengini kullan
          border: null, // Tema border'ını kullan
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: LessonStatus.scheduled,
            child: Text('Planlandı'),
          ),
          DropdownMenuItem(
            value: LessonStatus.completed,
            child: Text('Tamamlandı'),
          ),
          DropdownMenuItem(
            value: LessonStatus.cancelled,
            child: Text('İptal Edildi'),
          ),
          DropdownMenuItem(
            value: LessonStatus.postponed,
            child: Text('Ertelendi'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _status = value;
            });
          }
        },
      ),
    ],
  );

  /// Tekrarlanan ders özelliklerine göre tekrar seçimini yapılandırır.
  Widget _buildRecurringPicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppRecurringPicker(
        label: 'Tekrarlama',
        initialValue: _recurringInfo,
        onChanged: (value) {
          setState(() {
            _recurringInfo = value;
          });
        },
      ),

      // Tekrarlama sayısı seçimi
      if (_recurringInfo.type != RecurringType.none) ...[
        const SizedBox(height: AppDimensions.spacing16),
        Row(
          children: [
            const Text('Tekrar Sayısı:'),
            const SizedBox(width: AppDimensions.spacing8),
            Expanded(
              child: Slider(
                value: _recurringOccurrences.toDouble(),
                min: 1,
                max: 52, // Maksimum bir yıl (52 hafta)
                divisions: 51,
                label: _recurringOccurrences.toString(),
                onChanged: (value) {
                  setState(() {
                    _recurringOccurrences = value.toInt();
                  });
                },
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$_recurringOccurrences',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          _getOccurrencesText(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ],
  );

  /// Tekrar sayısına göre açıklama metni oluşturur
  String _getOccurrencesText() =>
      'Seçilen tarihten itibaren $_recurringOccurrences adet ders oluşturulacak';

  /// Ders tekrarlanan bir ders mi kontrol eder
  bool _isRecurring() => _recurringInfo.type != RecurringType.none;

  /// Tekrarlanan ders serisi seçeneklerini gösterir
  void _showRecurringLessonOptions() {
    if (!_isEditMode || !_isRecurring()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tekrarlanan Ders Serisi'),
        content: const Text(
          'Bu ders bir tekrarlanan ders serisinin parçasıdır. '
          'Yapacağınız değişiklikler yalnızca bu dersi mi, '
          'yoksa tüm seriyi mi etkileyecek?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteRecurringSeriesDialog();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Tüm Seriyi Sil'),
          ),
        ],
      ),
    );
  }

  /// Tekrarlanan ders serisini silme onayı diyaloğunu gösterir
  void _showDeleteRecurringSeriesDialog() async {
    final lessonProvider = context.read<LessonProvider>();
    final lesson = await lessonProvider.getLessonById(widget.lessonId!);
    if (lesson?.recurringPatternId == null) return;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Seriyi Sil'),
        content: const Text(
          'Tekrarlanan derslerin tamamını silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRecurringSeries(lesson!.recurringPatternId!);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Tüm Seriyi Sil'),
          ),
        ],
      ),
    );
  }

  /// Tekrarlanan ders serisini siler
  Future<void> _deleteRecurringSeries(String patternId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lessonProvider = context.read<LessonProvider>();
      final allLessons = lessonProvider.allLessons;
      final lessonsToDelete = allLessons
          .where((l) => l.recurringPatternId == patternId)
          .toList();

      int successCount = 0;
      int errorCount = 0;

      for (final lesson in lessonsToDelete) {
        try {
          await lessonProvider.deleteLesson(lesson.id);
          successCount++;
        } on Exception {
          errorCount++;
          // Optional: Log the error
        }
      }

      if (!context.mounted) return;

      String message = '$successCount ders başarıyla silindi';
      if (errorCount > 0) {
        message += ', $errorCount ders silinemedi';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: errorCount > 0
              ? AppColors.warning
              : AppColors.success,
        ),
      );

      if (!mounted) return;
      context.goNamed(RouteNames.lessons); // Go to the lessons list page
    } on Exception catch (e) {
      if (!context.mounted) return;
      AppErrorHandler.handleError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Notlar alanı
  Widget _buildNotesField() => AppTextField(
    label: 'Notlar',
    hint: 'Ders hakkında ekstra bilgiler...',
    controller: _notesController,
    maxLines: 3,
  );

  // Kaydet butonu
  Widget _buildSubmitButton() => AppButton(
    text: _isEditMode ? 'Güncelle' : 'Kaydet',
    onPressed: _saveForm,
    icon: Icons.save,
    isLoading: _isLoading,
  );

  /// Formu kaydeder
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final lessonProvider = context.read<LessonProvider>();
      final studentProvider = context.read<StudentProvider>();
      final selectedStudent = studentProvider.getStudentById(
        _selectedStudentId!,
      );

      final lesson = Lesson(
        id: widget.lessonId ?? '',
        studentId: _selectedStudentId!,
        studentName: selectedStudent!.name,
        subject: _subjectController.text,
        date: DateFormat('yyyy-MM-dd').format(_lessonDate),
        startTime: DateFormat('HH:mm').format(_lessonDate),
        endTime: DateFormat('HH:mm').format(
          _lessonDate.add(const Duration(minutes: 90)),
        ), // Süreye göre ayarlanmalı
        status: _status,
        notes: _notesController.text,
        fee: _fee,
      );

      if (_isEditMode) {
        await lessonProvider.updateLesson(lesson);
      } else {
        if (_recurringInfo.type != RecurringType.none) {
          await lessonProvider.createRecurringLessons(
            baseLesson: lesson,
            recurringInfo: _recurringInfo,
            occurrences: _recurringOccurrences,
          );
        } else {
          await lessonProvider.addLesson(lesson);
        }
      }

      if (!mounted) return;
      context.pop(); // Başarılı olunca sayfayı kapat
    } on Exception catch (e) {
      if (!mounted) return;
      AppErrorHandler.handleError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Ders silme onayı
  void _confirmDeleteLesson() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersi Sil'),
        content: const Text('Bu dersi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      await context.read<LessonProvider>().deleteLesson(widget.lessonId!);
      if (!mounted) return;
      context.pop();
    } on Exception catch (e) {
      if (!mounted) return;
      AppErrorHandler.handleError(context, e);
    }
  }

  // Tekrarlama deseni bilgilerini yükler
  Future<void> _loadRecurringPattern(String patternId) async {
    try {
      if (!mounted) return;
      final lessonProvider = context.read<LessonProvider>();
      final pattern = await lessonProvider.getRecurringPattern(patternId);
      if (pattern != null && mounted) {
        setState(() {
          _recurringInfo = RecurringInfo.fromPattern(pattern);
        });
      }
    } on Exception catch (e) {
      if (!mounted) return;
      AppErrorHandler.handleError(context, e);
    }
  }
}
