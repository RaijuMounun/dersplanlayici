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
import 'package:ders_planlayici/core/utils/phone_input_formatter.dart';

class AddEditStudentPage extends StatefulWidget {
  const AddEditStudentPage({super.key, this.studentId});
  final String? studentId;

  @override
  State<AddEditStudentPage> createState() => _AddEditStudentPageState();
}

class _AddEditStudentPageState extends State<AddEditStudentPage> {
  final _formKey = GlobalKey<FormState>();

  // Form için controller'lar
  final _nameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  List<String> _selectedSubjects = [];
  String? _selectedGrade;
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
          _selectedGrade = student.grade;
          _parentNameController.text = student.parentName ?? '';
          _phoneController.text = student.phone ?? '';
          _notesController.text = student.notes ?? '';
          _selectedSubjects = student.subjects ?? [];
        } else {
          _errorMessage = 'Öğrenci bulunamadı';
        }
      } on Exception catch (e) {
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
    _parentNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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

  // Tüm form alanlarını bir liste olarak döndür (mobil görünüm için)
  List<Widget> _buildFormFields() => [
    _buildNameField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildGradeField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildParentNameField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildPhoneField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildSubjectsField(),
    const SizedBox(height: AppDimensions.spacing16),
    _buildNotesField(),
    const SizedBox(height: AppDimensions.spacing24),
    _buildSubmitButton(),
  ];

  // İsim alanı
  Widget _buildNameField() => AppTextField(
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

  // Sınıf alanı
  Widget _buildGradeField() {
    final List<String> gradeLevels = [
      '1. Sınıf',
      '2. Sınıf',
      '3. Sınıf',
      '4. Sınıf',
      '5. Sınıf',
      '6. Sınıf',
      '7. Sınıf',
      '8. Sınıf',
      '9. Sınıf (Lise 1)',
      '10. Sınıf (Lise 2)',
      '11. Sınıf (Lise 3)',
      '12. Sınıf (Lise 4)',
      'Mezun',
      'Diğer',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedGrade,
      decoration: const InputDecoration(
        labelText: 'Sınıf *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.school),
      ),
      items: gradeLevels
          .map(
            (String grade) =>
                DropdownMenuItem<String>(value: grade, child: Text(grade)),
          )
          .toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedGrade = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Sınıf bilgisi gereklidir';
        }
        return null;
      },
    );
  }

  // Veli adı alanı
  Widget _buildParentNameField() => AppTextField(
    label: 'Veli Adı',
    hint: 'Velinin tam adı',
    controller: _parentNameController,
    textInputAction: TextInputAction.next,
    prefixIcon: const Icon(Icons.family_restroom),
  );

  // Telefon alanı
  Widget _buildPhoneField() => AppTextField(
    label: 'Telefon',
    hint: 'Örn: 532 123 45 67',
    controller: _phoneController,
    textInputAction: TextInputAction.next,
    keyboardType: TextInputType.phone,
    prefixIcon: const Icon(Icons.phone),
    inputFormatters: [PhoneInputFormatter()],
    validator: (value) {
      if (value != null && value.isNotEmpty) {
        final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length != 10) {
          return 'Lütfen geçerli bir 10 haneli telefon numarası girin.';
        }
      }
      return null;
    },
  );

  // E-posta alanı
  // Widget _buildEmailField() => AppTextField( ... ); // Kaldırıldı

  // Dersler alanı
  Widget _buildSubjectsField() {
    // Dersleri bir diyalogda seçtirmek daha iyi bir UX sağlar.
    // Sabit bir ders listesi. Bu, gelecekte ayarlardan veya ayrı bir tablodan gelebilir.
    final List<String> allSubjects = [
      'Matematik',
      'Geometri',
      'Fizik',
      'Kimya',
      'Biyoloji',
      'Türkçe',
      'Edebiyat',
      'Tarih',
      'Coğrafya',
      'Felsefe',
      'İngilizce',
      'Almanca',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dersler',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _selectedSubjects
              .map(
                (subject) => Chip(
                  label: Text(subject),
                  onDeleted: () {
                    setState(() {
                      _selectedSubjects.remove(subject);
                    });
                  },
                ),
              )
              .toList(),
        ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Ders Seç'),
          onPressed: () => _showSubjectSelectionDialog(allSubjects),
        ),
      ],
    );
  }

  void _showSubjectSelectionDialog(List<String> allSubjects) {
    showDialog(
      context: context,
      builder: (context) {
        // Diyalog içinde state yönetimi için geçici bir liste
        final tempSelectedSubjects = List<String>.from(_selectedSubjects);
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Dersleri Seç'),
            content: SingleChildScrollView(
              child: ListBody(
                children: allSubjects
                    .map(
                      (subject) => CheckboxListTile(
                        value: tempSelectedSubjects.contains(subject),
                        title: Text(subject),
                        onChanged: (bool? isChecked) {
                          setDialogState(() {
                            if (isChecked == true) {
                              tempSelectedSubjects.add(subject);
                            } else {
                              tempSelectedSubjects.remove(subject);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedSubjects = tempSelectedSubjects;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Notlar alanı
  Widget _buildNotesField() => AppTextField(
    label: 'Notlar',
    hint: 'Öğrenci hakkında ekstra bilgiler...',
    controller: _notesController,
    maxLines: 3,
    textInputAction: TextInputAction.done,
    prefixIcon: const Icon(Icons.note),
  );

  // Kaydet butonu
  Widget _buildSubmitButton() => AppButton(
    text: _isEditMode ? 'Güncelle' : 'Kaydet',
    onPressed: _saveStudent,
    icon: Icons.save,
    isLoading: _isLoading,
  );

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

      final student = StudentModel(
        id: _isEditMode ? widget.studentId : null,
        name: _nameController.text,
        grade: _selectedGrade,
        parentName: _parentNameController.text.isNotEmpty
            ? _parentNameController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: null, // Eposta kaldırıldı
        subjects: _selectedSubjects.isNotEmpty ? _selectedSubjects : null,
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
}
