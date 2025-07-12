import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/core/widgets/loading_indicator.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key, this.studentId});
  final String? studentId;

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedGrade = '5. Sınıf';
  final List<String> _selectedSubjects = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  Student? _originalStudent;

  final List<String> _availableGrades = [
    '1. Sınıf',
    '2. Sınıf',
    '3. Sınıf',
    '4. Sınıf',
    '5. Sınıf',
    '6. Sınıf',
    '7. Sınıf',
    '8. Sınıf',
    'Lise 1',
    'Lise 2',
    'Lise 3',
    'Lise 4',
    'Üniversite',
    'Mezun',
  ];

  final List<String> _availableSubjects = [
    'Matematik',
    'Türkçe',
    'Fen Bilgisi',
    'Sosyal Bilgiler',
    'İngilizce',
    'Hayat Bilgisi',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Tarih',
    'Coğrafya',
    'Edebiyat',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.studentId != null;

    // Eğer düzenleme modundaysa, öğrenci bilgilerini yükle
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadStudentDetails();
      });
    }
  }

  Future<void> _loadStudentDetails() async {
    if (!mounted) return;

    try {
      // LoadingIndicator ile işlemi saralım - bu donma sorununu önleyecek
      final studentProvider = context.read<StudentProvider>();
      await LoadingIndicator.wrapWithLoading(
        context: context,
        message: 'Öğrenci bilgileri yükleniyor...',
        future: Future(() async {
          await studentProvider.loadStudents(notify: false);

          // State güncellemesini ayrı bir mikro görevde yap
          await Future.microtask(() {
            if (mounted) {
              studentProvider.notifyListeners();
            }
          });

          return studentProvider.getStudentById(widget.studentId!);
        }),
      ).then((student) {
        if (student != null) {
          setState(() {
            _isLoading = false;
            _originalStudent = student;
            _nameController.text = student.name;
            _parentNameController.text = student.parentName ?? '';
            _phoneController.text = student.phone ?? '';
            _emailController.text = student.email ?? '';
            _notesController.text = student.notes ?? '';
            _selectedGrade = student.grade;

            if (student.subjects != null) {
              _selectedSubjects.clear();
              _selectedSubjects.addAll(student.subjects!);
            }
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Öğrenci bulunamadı'),
                backgroundColor: AppColors.error,
              ),
            );
            context.pop();
          }
        }
      });
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci bilgileri yüklenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileForm(),
              tablet: _buildTabletForm(),
              desktop: _buildDesktopForm(),
            ),
    );

  // Mobil görünüm için form
  Widget _buildMobileForm() => SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildParentNameField(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildPhoneField(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildEmailField(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildGradeField(),
            const SizedBox(height: AppDimensions.spacing24),
            _buildSubjectsField(),
            const SizedBox(height: AppDimensions.spacing16),
            _buildNotesField(),
            const SizedBox(height: AppDimensions.spacing32),
            _buildSaveButton(),
          ],
        ),
      ),
    );

  // Tablet görünüm için form
  Widget _buildTabletForm() => SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildParentNameField(),
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildPhoneField(),
                      const SizedBox(height: AppDimensions.spacing16),
                      _buildEmailField(),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGradeField(),
                      const SizedBox(height: AppDimensions.spacing24),
                      _buildSubjectsField(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing24),
            _buildNotesField(),
            const SizedBox(height: AppDimensions.spacing32),
            Center(child: _buildSaveButton()),
          ],
        ),
      ),
    );

  // Masaüstü görünüm için form
  Widget _buildDesktopForm() => Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameField(),
                        const SizedBox(height: AppDimensions.spacing16),
                        _buildParentNameField(),
                        const SizedBox(height: AppDimensions.spacing16),
                        _buildPhoneField(),
                        const SizedBox(height: AppDimensions.spacing16),
                        _buildEmailField(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing32),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGradeField(),
                        const SizedBox(height: AppDimensions.spacing24),
                        _buildSubjectsField(),
                        const SizedBox(height: AppDimensions.spacing24),
                        _buildNotesField(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing32),
              _buildSaveButton(width: 300),
            ],
          ),
        ),
      ),
    );

  // Form alanları
  Widget _buildNameField() => TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Öğrenci Adı Soyadı *',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: const Icon(Icons.person),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen öğrenci adını girin';
        }
        if (value.length < 3) {
          return 'Ad en az 3 karakter olmalıdır';
        }
        return null;
      },
    );

  Widget _buildParentNameField() => TextFormField(
      controller: _parentNameController,
      decoration: InputDecoration(
        labelText: 'Veli Adı Soyadı',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: const Icon(Icons.people),
      ),
      textInputAction: TextInputAction.next,
    );

  Widget _buildPhoneField() => TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Telefon',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: const Icon(Icons.phone),
        prefixText: '+90 ',
        hintText: '5XX XXX XX XX',
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          // Basit bir telefon numarası doğrulama
          final phoneRegex = RegExp(r'^[0-9]{10}$');
          if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
            return 'Geçerli bir telefon numarası girin';
          }
        }
        return null;
      },
      onChanged: (value) {
        // Telefon numarası formatını düzenle
        if (value.isNotEmpty) {
          final String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
          String formatted = '';

          for (int i = 0; i < digitsOnly.length && i < 10; i++) {
            if (i == 3 || i == 6) {
              formatted += ' ';
            }
            formatted += digitsOnly[i];
          }

          if (formatted != value) {
            _phoneController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
    );

  Widget _buildEmailField() => TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'E-posta',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          // E-posta doğrulama
          final emailRegex = RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          );
          if (!emailRegex.hasMatch(value)) {
            return 'Geçerli bir e-posta adresi girin';
          }
        }
        return null;
      },
    );

  Widget _buildGradeField() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sınıf *',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        DropdownButtonFormField<String>(
          value: _selectedGrade,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing12,
            ),
          ),
          items: _availableGrades.map((grade) => DropdownMenuItem<String>(value: grade, child: Text(grade))).toList(),
          onChanged: (value) =>
              value != null ? setState(() => _selectedGrade = value) : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen bir sınıf seçin';
            }
            return null;
          },
        ),
      ],
    );

  Widget _buildSubjectsField() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dersler',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.formBorder),
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
            color: AppColors.inputBackground,
          ),
          child: Wrap(
            spacing: AppDimensions.spacing8,
            runSpacing: AppDimensions.spacing8,
            children: _availableSubjects.map((subject) {
              final isSelected = _selectedSubjects.contains(subject);
              return FilterChip(
                label: Text(subject),
                selected: isSelected,
                onSelected: (selected) => setState(
                  () => selected
                      ? _selectedSubjects.add(subject)
                      : _selectedSubjects.remove(subject),
                ),
                selectedColor: AppColors.primary.withAlpha(180),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(color: isSelected ? Colors.white : null),
              );
            }).toList(),
          ),
        ),
      ],
    );

  Widget _buildNotesField() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notlar',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing8),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.inputBackground,
            hintText: 'Öğrenci hakkında notlar...',
          ),
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );

  Widget _buildSaveButton({double? width}) => SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveStudent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : Text(
                _isEditMode ? 'Güncelle' : 'Kaydet',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );

  void _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Öğrenci nesnesini oluştur
    final student = _isEditMode
        ? _originalStudent!.copyWith(
            name: _nameController.text.trim(),
            grade: _selectedGrade,
            parentName: _parentNameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            subjects: List.from(_selectedSubjects),
            notes: _notesController.text.trim(),
          )
        : Student(
            name: _nameController.text.trim(),
            grade: _selectedGrade,
            parentName: _parentNameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            subjects: List.from(_selectedSubjects),
            notes: _notesController.text.trim(),
          );

    // Provider üzerinden öğrenciyi kaydet veya güncelle
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );

    try {
      // LoadingIndicator ile işlemi saralım - bu donma sorununu önleyecek
      await LoadingIndicator.wrapWithLoading(
        context: context,
        message: _isEditMode
            ? 'Öğrenci güncelleniyor...'
            : 'Öğrenci kaydediliyor...',
        future: Future(() async {
          if (_isEditMode) {
            await studentProvider.updateStudent(student, notify: false);
          } else {
            await studentProvider.addStudent(student, notify: false);
          }

          // State güncellemesini ayrı bir mikro görevde yap
          await Future.microtask(studentProvider.notifyListeners);

          return true;
        }),
      );

      // İşlem başarılı oldu, kullanıcıya bildir ve sayfadan çık
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Öğrenci başarıyla güncellendi'
                  : 'Öğrenci başarıyla eklendi',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Sayfadan çık
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _confirmDeleteStudent() {
    if (!_isEditMode || _originalStudent == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: Text(
          '${_originalStudent!.name} adlı öğrenciyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
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

  Future<void> _deleteStudent() async {
    if (!_isEditMode || _originalStudent == null) return;

    try {
      final studentProvider = context.read<StudentProvider>();

      // LoadingIndicator ile işlemi saralım - bu donma sorununu önleyecek
      await LoadingIndicator.wrapWithLoading(
        context: context,
        message: 'Öğrenci siliniyor...',
        future: Future(() async {
          await studentProvider.deleteStudent(
            _originalStudent!.id,
            notify: false,
          );

          // State güncellemesini ayrı bir mikro görevde yap
          await Future.microtask(studentProvider.notifyListeners);

          return true;
        }),
      );

      // İşlem başarılı oldu, kullanıcıya bildir ve sayfadan çık
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci başarıyla silindi'),
            backgroundColor: AppColors.success,
          ),
        );

        // Sayfadan çık
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci silinirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
