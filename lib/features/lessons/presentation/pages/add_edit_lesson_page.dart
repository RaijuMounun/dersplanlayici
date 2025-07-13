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
import 'package:ders_planlayici/core/error/app_exception.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';

class AddEditLessonPage extends StatefulWidget {

  const AddEditLessonPage({super.key, this.lessonId, this.studentId});
  final String? lessonId;
  final String? studentId;

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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.lessonId != null;

    // URL'den gelen studentId varsa, seç
    if (widget.studentId != null) {
      _selectedStudentId = widget.studentId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    // Öğrencileri yükle
    if (!mounted) return;
    final studentProvider = context.read<StudentProvider>();
    await studentProvider.loadStudents();

    // Eğer düzenleme modundaysa, ders bilgilerini yükle
    if (_isEditMode && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (!mounted) return;
        final lessonProvider = context.read<LessonProvider>();
        final lesson = lessonProvider.getLessonById(widget.lessonId!);

        if (lesson != null) {
          if (!mounted) return;
          _subjectController.text = lesson.subject;
          _notesController.text = lesson.notes ?? '';
          _feeController.text = lesson.fee.toString();

          // Tarih ve saati parse et
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

          // Eğer tekrarlanan bir dersse
          if (lesson.recurringPatternId != null) {
            // Tekrarlama bilgisini getir
            await _loadRecurringPattern(lesson.recurringPatternId!);
          }
        } else {
          _errorMessage = 'Ders bulunamadı';
        }
      } on Exception catch (e) {
        _errorMessage = 'Ders yüklenirken hata oluştu: $e';
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppButton(
              text: 'Geri Dön',
              onPressed: () => context.pop(),
              type: AppButtonType.outline,
            ),
          ],
        ),
      );
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
        context.push('/add-student').then((_) {
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
  String _getOccurrencesText() => 'Seçilen tarihten itibaren $_recurringOccurrences adet ders oluşturulacak';

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
  void _showDeleteRecurringSeriesDialog() {
    final lesson = context.read<LessonProvider>().getLessonById(
      widget.lessonId!,
    );
    if (lesson == null || lesson.recurringPatternId == null) return;

    showDialog(
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
              _deleteRecurringSeries(lesson.recurringPatternId!);
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
      final result = await context
          .read<LessonProvider>()
          .deleteRecurringLessons(patternId);

      if (!mounted) return;

      final successCount = result['success'] ?? 0;
      final errorCount = result['error'] ?? 0;

      String message = '$successCount ders başarıyla silindi';
      if (errorCount > 0) {
        message += ', $errorCount ders silinemedi';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: errorCount > 0
              ? AppColors.warning
              : AppColors.success,
        ),
      );

      Navigator.of(context).pop(); // Form sayfasını kapat
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seri silinirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
    // Form geçerliliğini kontrol et
    if (!_formKey.currentState!.validate()) {
      // Hatalı alanlar zaten form tarafından gösterilecek
      return;
    }

    // Öğrenci seçili mi kontrol et
    if (_selectedStudentId == null) {
      setState(() {
        _errorMessage = 'Lütfen bir öğrenci seçin';
      });
      return;
    }

    // Form kaydediliyor
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Seçilen öğrenci bilgilerini al
      final studentProvider = context.read<StudentProvider>();
      final student = studentProvider.getStudentById(_selectedStudentId!);

      if (student == null) {
        throw const AppException(message: 'Seçilen öğrenci bulunamadı');
      }

      // Saat formatlarını düzenle
      final startTime = DateFormat('HH:mm').format(
        DateTime(
          _lessonDate.year,
          _lessonDate.month,
          _lessonDate.day,
          _lessonDate.hour,
          _lessonDate.minute,
        ),
      );

      final endTime = DateFormat('HH:mm').format(
        DateTime(
          _lessonDate.year,
          _lessonDate.month,
          _lessonDate.day,
          _lessonDate.hour + 1,
          _lessonDate.minute,
        ),
      );

      final lesson = Lesson(
        id: _isEditMode ? widget.lessonId! : null,
        studentId: _selectedStudentId!,
        studentName: student.name,
        subject: _subjectController.text,
        date: DateFormat('yyyy-MM-dd').format(_lessonDate),
        startTime: startTime,
        endTime: endTime,
        status: _status,
        fee: _fee,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final lessonProvider = context.read<LessonProvider>();

      if (_isRecurring()) {
        // Tekrarlanan ders serisi oluştur
        await lessonProvider.createRecurringLessons(
          baseLesson: lesson,
          recurringInfo: _recurringInfo,
          occurrences: _recurringOccurrences,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tekrarlanan ders serisi oluşturuldu: ${_recurringOccurrences + 1} ders',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      } else {
        // Tekrarlanmayan tek ders
        if (_isEditMode) {
          await lessonProvider.updateLesson(lesson);
        } else {
          await lessonProvider.addLesson(lesson);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode ? 'Ders güncellendi' : 'Yeni ders eklendi',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Ders silme onayı
  void _confirmDeleteLesson() {
    // dialogContext kullanarak context karışıklığını önle
    final BuildContext currentContext = context;
    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dersi Sil'),
        content: const Text(
          'Bu dersi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteLesson();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Dersi sil
  Future<void> _deleteLesson() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<LessonProvider>().deleteLesson(widget.lessonId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ders silindi'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Tekrarlama deseni bilgilerini yükler
  Future<void> _loadRecurringPattern(String patternId) async {
    try {
      final lessonProvider = Provider.of<LessonProvider>(
        context,
        listen: false,
      );

      final pattern = await lessonProvider.getRecurringPattern(patternId);

      if (pattern != null) {
        // RecurringPattern modelinden RecurringInfo modeline dönüştürme
        // İki farklı RecurringType enum'u var:
        // 1) core/widgets/app_recurring_picker.dart içindeki
        // 2) features/lessons/domain/models/recurring_pattern_model.dart içindeki

        // core/widgets/app_recurring_picker.dart içindeki RecurringType'a dönüştürme
        RecurringType pickerType = RecurringType.weekly; // Varsayılan değer

        // Tip değerini string karşılaştırması ile bulalım
        final patternTypeName = pattern.type.toString().split('.').last;

        if (patternTypeName == 'weekly') {
          pickerType = pattern.interval == 2
              ? RecurringType.biweekly
              : RecurringType.weekly;
        } else if (patternTypeName == 'monthly') {
          pickerType = RecurringType.monthly;
        }

        setState(() {
          _recurringInfo = RecurringInfo(
            type: pickerType,
            interval: pattern.interval,
            weekdays: pattern.daysOfWeek,
            dayOfMonth: pattern.dayOfMonth,
            endDate: pattern.endDate != null
                ? DateTime.parse(pattern.endDate!)
                : null,
          );
          _recurringOccurrences = 5; // Varsayılan değer, backend'den gelmiyorsa
        });
      }
    } on Exception {
      // Hata durumunda sessiz bir şekilde devam et
      // ve en azından temel ders bilgilerini göster
      // Log işlemi async olduğu için burada yapmıyoruz
    }
  }
}
