import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/app_button.dart';
import 'package:ders_planlayici/core/widgets/app_text_field.dart';
import 'package:ders_planlayici/core/widgets/app_date_time_picker.dart';
import 'package:ders_planlayici/core/widgets/app_student_picker.dart';
import 'package:ders_planlayici/core/error/error_handler.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/core/error/validation_exception.dart';

class AddEditLessonPage extends StatefulWidget {
  const AddEditLessonPage({
    super.key,
    this.lessonId,
    this.studentId,
    this.initialDate,
  });
  final String? lessonId;
  final String? studentId;
  final String? initialDate;

  @override
  State<AddEditLessonPage> createState() => _AddEditLessonPageState();
}

class _AddEditLessonPageState extends State<AddEditLessonPage> {
  // Bu state'ler Provider'a taşındı.
  // final _formKey = GlobalKey<FormState>();
  // final _subjectController = TextEditingController();
  // final _notesController = TextEditingController();
  // final _feeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider'ı dinlemeye başla ve formu başlat
      final lessonProvider = context.read<LessonProvider>();
      final initialDateTime = widget.initialDate != null
          ? DateTime.tryParse(widget.initialDate!)
          : null;
      lessonProvider
          .initializeForm(
            lessonId: widget.lessonId,
            studentId: widget.studentId,
            initialDate: initialDateTime,
          )
          .then((_) {
            if (mounted && lessonProvider.isEditMode) {
              final lesson = lessonProvider.editingLesson;
              if (lesson != null) {
                // _subjectController.text = lesson.subject; // Removed
                // _notesController.text = lesson.notes ?? ''; // Removed
                // _feeController.text = lesson.fee.toString(); // Removed
              }
            }
          })
          .catchError((error) {
            if (mounted) {
              AppErrorHandler.handleError(context, error);
            }
          });
      // Öğrencileri de yükleyelim
      context.read<StudentProvider>().loadStudents();
    });
  }

  @override
  void dispose() {
    // Controller'lar artık Provider'da yönetiliyor, burada dispose etmeye gerek yok.
    // Ancak, Provider'ın kendisi dispose edildiğinde controller'ları dispose etmeli.
    // Bunu provider'ın dispose metodunda yapacağız.
    super.dispose();
  }

  Future<void> _saveForm() async {
    final lessonProvider = context.read<LessonProvider>();
    try {
      await lessonProvider.saveLesson();
      if (mounted) context.pop();
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<LessonProvider>();
    final studentProvider = context.watch<StudentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lessonProvider.isEditMode ? 'Dersi Düzenle' : 'Yeni Ders Ekle',
        ),
        actions: [
          if (lessonProvider.isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // _confirmDeleteLesson(),
              },
              tooltip: 'Dersi Sil',
            ),
        ],
      ),
      body: _buildBody(lessonProvider, studentProvider),
    );
  }

  Widget _buildBody(
    LessonProvider lessonProvider,
    StudentProvider studentProvider,
  ) {
    if (lessonProvider.isInitializing || studentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lessonProvider.error != null) {
      return Center(child: Text('Hata: ${lessonProvider.error}'));
    }

    return ResponsiveUtils.deviceValue<Widget>(
      context: context,
      mobile: _buildMobileForm(lessonProvider),
      tablet: _buildTabletForm(lessonProvider),
      desktop: _buildDesktopForm(lessonProvider),
    );
  }

  Widget _buildMobileForm(LessonProvider lessonProvider) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Form(
          key: lessonProvider.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildFormFields(lessonProvider),
          ),
        ),
      );

  Widget _buildTabletForm(LessonProvider lessonProvider) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Form(
              key: lessonProvider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildFormFields(lessonProvider),
              ),
            ),
          ),
        ),
      );

  Widget _buildDesktopForm(LessonProvider lessonProvider) =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Center(
          child: SizedBox(
            width: 800,
            child: Form(
              key: lessonProvider.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildFormFields(lessonProvider),
              ),
            ),
          ),
        ),
      );

  List<Widget> _buildFormFields(LessonProvider lessonProvider) {
    final studentProvider = context.read<StudentProvider>();
    return [
      AppStudentPicker(
        students: studentProvider.students,
        initialSelectedId: lessonProvider.selectedStudentId,
        onStudentSelected: (studentId) =>
            lessonProvider.setSelectedStudentId(studentId),
        label: 'Öğrenci',
        required: true,
      ),
      const SizedBox(height: AppDimensions.spacing16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              controller: lessonProvider.subjectController,
              label: 'Ders Konusu',
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Lütfen bir konu girin' : null,
            ),
          ),
          if (lessonProvider.studentSubjects.isNotEmpty) ...[
            const SizedBox(width: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Icon(Icons.arrow_drop_down),
                items: lessonProvider.studentSubjects
                    .map((subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    lessonProvider.subjectController.text = value;
                  }
                },
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: AppDimensions.spacing16),
      AppDateTimePicker(
        initialDateTime: lessonProvider.lessonDate,
        onDateTimeChanged: (dateTime) {
          lessonProvider.setLessonDate(dateTime);
          lessonProvider.setLessonTime(TimeOfDay.fromDateTime(dateTime));
        },
        label: 'Ders Tarihi ve Saati',
        required: true,
      ),
      const SizedBox(height: AppDimensions.spacing16),
      AppTextField(
        controller: lessonProvider.feeController,
        label: 'Ders Ücreti',
        keyboardType: TextInputType.number,
        suffix: const Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Text('TL'),
        ),
      ),
      const SizedBox(height: AppDimensions.spacing16),
      // Status ve Recurring Picker'lar da provider'ı kullanacak şekilde güncellenmeli
      const SizedBox(height: AppDimensions.spacing16),
      AppTextField(
        controller: lessonProvider.notesController,
        label: 'Notlar',
        maxLines: 3,
      ),
      const SizedBox(height: AppDimensions.spacing24),
      AppButton(
        text: lessonProvider.isEditMode
            ? 'Değişiklikleri Kaydet'
            : 'Dersi Ekle',
        onPressed: _saveForm,
      ),
    ];
  }
}
