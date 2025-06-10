import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/app_button.dart';
import 'package:ders_planlayici/core/widgets/app_text_field.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';

class AddEditStudentPage extends StatefulWidget {
  final String? studentId;

  const AddEditStudentPage({super.key, this.studentId});

  @override
  State<AddEditStudentPage> createState() => _AddEditStudentPageState();
}

class _AddEditStudentPageState extends State<AddEditStudentPage> {
  final _formKey = GlobalKey<FormState>();

  // Form için controller'lar
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _subjectsController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.studentId != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  Future<void> _initializeForm() async {
    // Eğer düzenleme modundaysa, öğrenci bilgilerini yükle
    if (_isEditMode) {
      setState(() {
        _isLoading = true;
      });

      try {
        final studentProvider = context.read<StudentProvider>();
        final student = studentProvider.getStudentById(widget.studentId!);

        if (student != null) {
          _nameController.text = student.name;
          _gradeController.text = student.grade;
          _parentNameController.text = student.parentName ?? '';
          _phoneController.text = student.phone ?? '';
          _emailController.text = student.email ?? '';
          _notesController.text = student.notes ?? '';

          if (student.subjects != null && student.subjects!.isNotEmpty) {
            _subjectsController.text = student.subjects!.join(', ');
          }
        } else {
          _errorMessage = 'Öğrenci bulunamadı';
        }
      } catch (e) {
        _errorMessage = 'Öğrenci yüklenirken hata oluştu: $e';
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _subjectsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Öğrenciyi Düzenle' : 'Yeni Öğrenci Ekle'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeleteStudent,
              tooltip: 'Öğrenciyi Sil',
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
                    Expanded(child: _buildNameField()),
                    const SizedBox(width: AppDimensions.spacing16),
                    Expanded(child: _buildGradeField()),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildParentNameField()),
                    const SizedBox(width: AppDimensions.spacing16),
                    Expanded(child: _buildPhoneField()),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _buildEmailField(),
                const SizedBox(height: AppDimensions.spacing16),
                _buildSubjectsField(),
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
                    Expanded(flex: 2, child: _buildNameField()),
                    const SizedBox(width: AppDimensions.spacing16),
                    Expanded(child: _buildGradeField()),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildParentNameField()),
                    const SizedBox(width: AppDimensions.spacing16),
                    Expanded(child: _buildPhoneField()),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildEmailField()),
                    const SizedBox(width: AppDimensions.spacing16),
                    Expanded(child: _buildSubjectsField()),
                  ],
                ),
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
      _buildNameField(),
      const SizedBox(height: AppDimensions.spacing16),
      _buildGradeField(),
      const SizedBox(height: AppDimensions.spacing16),
      _buildParentNameField(),
      const SizedBox(height: AppDimensions.spacing16),
      _buildPhoneField(),
      const SizedBox(height: AppDimensions.spacing16),
      _buildEmailField(),
      const SizedBox(height: AppDimensions.spacing16),
      _buildSubjectsField(),
      const SizedBox(height: AppDimensions.spacing16),
      _buildNotesField(),
      const SizedBox(height: AppDimensions.spacing24),
      _buildSubmitButton(),
    ];
  }

  // İsim alanı
  Widget _buildNameField() {
    return AppTextField(
      label: 'Öğrenci Adı',
      hint: 'Öğrencinin tam adı',
      controller: _nameController,
      required: true,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.person),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Öğrenci adı gereklidir';
        }
        return null;
      },
    );
  }

  // Sınıf alanı
  Widget _buildGradeField() {
    return AppTextField(
      label: 'Sınıf',
      hint: 'Örn: 10. Sınıf, Lise 2',
      controller: _gradeController,
      required: true,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.school),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Sınıf bilgisi gereklidir';
        }
        return null;
      },
    );
  }

  // Veli adı alanı
  Widget _buildParentNameField() {
    return AppTextField(
      label: 'Veli Adı',
      hint: 'Velinin tam adı',
      controller: _parentNameController,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.family_restroom),
    );
  }

  // Telefon alanı
  Widget _buildPhoneField() {
    return AppTextField(
      label: 'Telefon',
      hint: 'Örn: 0532 123 4567',
      controller: _phoneController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone),
    );
  }

  // E-posta alanı
  Widget _buildEmailField() {
    return AppTextField(
      label: 'E-posta',
      hint: 'Örn: ornek@email.com',
      controller: _emailController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          // E-posta formatı kontrolü
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Geçerli bir e-posta adresi girin';
          }
        }
        return null;
      },
    );
  }

  // Dersler alanı
  Widget _buildSubjectsField() {
    return AppTextField(
      label: 'Dersler',
      hint: 'Virgülle ayırarak girin (Matematik, Fizik, ...)',
      controller: _subjectsController,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.book),
    );
  }

  // Notlar alanı
  Widget _buildNotesField() {
    return AppTextField(
      label: 'Notlar',
      hint: 'Öğrenci hakkında ekstra bilgiler...',
      controller: _notesController,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.note),
    );
  }

  // Kaydet butonu
  Widget _buildSubmitButton() {
    return AppButton(
      text: _isEditMode ? 'Güncelle' : 'Kaydet',
      onPressed: _saveStudent,
      icon: Icons.save,
      isLoading: _isLoading,
    );
  }

  // Öğrenciyi kaydet
  Future<void> _saveStudent() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final studentProvider = context.read<StudentProvider>();

      // Virgülle ayrılmış dersler listesini oluştur
      final List<String>? subjects = _subjectsController.text.isNotEmpty
          ? _subjectsController.text.split(',').map((e) => e.trim()).toList()
          : null;

      final student = Student(
        id: _isEditMode ? widget.studentId : null,
        name: _nameController.text,
        grade: _gradeController.text,
        parentName: _parentNameController.text.isNotEmpty
            ? _parentNameController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        subjects: subjects,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (_isEditMode) {
        await studentProvider.updateStudent(student);
      } else {
        await studentProvider.addStudent(student);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Öğrenci güncellendi' : 'Yeni öğrenci eklendi',
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

  // Öğrenci silme onayı
  void _confirmDeleteStudent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: const Text(
          'Bu öğrenciyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve öğrenciye ait tüm ders kayıtları da silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteStudent();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Öğrenciyi sil
  Future<void> _deleteStudent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<StudentProvider>().deleteStudent(widget.studentId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci silindi'),
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
