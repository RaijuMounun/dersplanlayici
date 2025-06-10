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
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

class AddEditLessonPage extends StatefulWidget {
  final String? lessonId;

  const AddEditLessonPage({super.key, this.lessonId});

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

  bool _isEditMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.lessonId != null;

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
            // TODO: Tekrarlama bilgisini getir
          }
        } else {
          _errorMessage = 'Ders bulunamadı';
        }
      } catch (e) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Dersi Düzenle' : 'Yeni Ders Ekle'),
        actions: [
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
  }

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
              style: TextStyle(color: AppColors.error),
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
  Widget _buildMobileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormFields(),
        ),
      ),
    );
  }

  // Tablet için form tasarımı - Bazı alanlar yan yana
  Widget _buildTabletForm() {
    return SingleChildScrollView(
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
                _buildRecurringField(),
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
  }

  // Desktop için form tasarımı - Daha geniş ve çok alanlar yan yana
  Widget _buildDesktopForm() {
    return SingleChildScrollView(
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
                _buildRecurringField(),
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
  }

  // Tüm form alanlarını bir liste olarak döndür (mobil görünüm için)
  List<Widget> _buildFormFields() {
    return [
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
      _buildRecurringField(),
      const SizedBox(height: AppDimensions.spacing16),
      _buildNotesField(),
      const SizedBox(height: AppDimensions.spacing24),
      _buildSubmitButton(),
    ];
  }

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
  Widget _buildSubjectField() {
    return AppTextField(
      label: 'Ders Konusu',
      hint: 'Örn: Matematik, Fizik, İngilizce',
      controller: _subjectController,
      required: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ders konusu gereklidir';
        }
        return null;
      },
    );
  }

  // Tarih ve saat alanı
  Widget _buildDateTimeField() {
    return AppDateTimePicker(
      label: 'Ders Tarihi ve Saati',
      required: true,
      initialDateTime: _lessonDate,
      onDateTimeChanged: (dateTime) {
        setState(() {
          _lessonDate = dateTime;
        });
      },
    );
  }

  // Ücret alanı
  Widget _buildFeeField() {
    return AppTextField(
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
  }

  // Durum alanı
  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Durum', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spacing8),
        DropdownButtonFormField<LessonStatus>(
          value: _status,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing12,
              vertical: AppDimensions.spacing8,
            ),
          ),
          items: [
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
  }

  // Tekrarlama alanı
  Widget _buildRecurringField() {
    return AppRecurringPicker(
      label: 'Ders Tekrarı',
      initialValue: _recurringInfo,
      onChanged: (recurringInfo) {
        setState(() {
          _recurringInfo = recurringInfo;
        });
      },
    );
  }

  // Notlar alanı
  Widget _buildNotesField() {
    return AppTextField(
      label: 'Notlar',
      hint: 'Ders hakkında ekstra bilgiler...',
      controller: _notesController,
      maxLines: 3,
    );
  }

  // Kaydet butonu
  Widget _buildSubmitButton() {
    return AppButton(
      text: _isEditMode ? 'Güncelle' : 'Kaydet',
      onPressed: _saveLesson,
      icon: Icons.save,
      isLoading: _isLoading,
    );
  }

  // Dersi kaydet
  Future<void> _saveLesson() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_selectedStudentId == null || _selectedStudentId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir öğrenci seçin')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final lessonProvider = context.read<LessonProvider>();
      final studentProvider = context.read<StudentProvider>();

      // Başlangıç ve bitiş saatlerini hesapla
      final startTime = DateFormat('HH:mm').format(_lessonDate);
      final endTime = DateFormat(
        'HH:mm',
      ).format(_lessonDate.add(const Duration(hours: 1)));

      // Öğrenci adını bul
      final student = studentProvider.students.firstWhere(
        (s) => s.id == _selectedStudentId,
        orElse: () => Student(id: '0', name: 'Bilinmeyen Öğrenci', grade: ''),
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
        recurringPatternId: _recurringInfo.type != RecurringType.none
            ? 'recurrence-${DateTime.now().millisecondsSinceEpoch}'
            : null,
      );

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
    } catch (e) {
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
    } catch (e) {
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
}
