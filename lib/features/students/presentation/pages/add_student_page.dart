import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

class AddStudentPage extends StatefulWidget {
  final String? studentId;
  const AddStudentPage({super.key, this.studentId});

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
    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      final studentProvider = context.read<StudentProvider>();
      final student = studentProvider.getStudentById(widget.studentId!);

      if (student != null) {
        setState(() {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci bilgileri yüklenirken hata oluştu: $e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Öğrenciyi Düzenle' : 'Öğrenci Ekle'),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Öğrenci Adı Soyadı',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen öğrenci adını girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _parentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Veli Adı Soyadı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        border: OutlineInputBorder(),
                        prefixText: '+90 ',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notlar',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sınıf',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGrade,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _availableGrades.map((grade) {
                        return DropdownMenuItem<String>(
                          value: grade,
                          child: Text(grade),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGrade = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Dersler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableSubjects.map((subject) {
                        final isSelected = _selectedSubjects.contains(subject);
                        return FilterChip(
                          label: Text(subject),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSubjects.add(subject);
                              } else {
                                _selectedSubjects.remove(subject);
                              }
                            });
                          },
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(180),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveStudent,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isEditMode ? 'Güncelle' : 'Kaydet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Öğrenci nesnesini oluştur
      final student = _isEditMode
          ? _originalStudent!.copyWith(
              name: _nameController.text,
              grade: _selectedGrade,
              parentName: _parentNameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              subjects: List.from(_selectedSubjects),
              notes: _notesController.text,
            )
          : Student(
              name: _nameController.text,
              grade: _selectedGrade,
              parentName: _parentNameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              subjects: List.from(_selectedSubjects),
              notes: _notesController.text,
            );

      // Provider üzerinden öğrenciyi kaydet veya güncelle
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );

      if (_isEditMode) {
        await studentProvider.updateStudent(student);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Öğrenci başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await studentProvider.addStudent(student);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Öğrenci başarıyla eklendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Başarılı kayıt sonrası geri dön
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
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

  void _confirmDeleteStudent() {
    if (!_isEditMode || _originalStudent == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: Text(
          '${_originalStudent!.name} adlı öğrenciyi silmek istediğinizden emin misiniz?',
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

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<StudentProvider>().deleteStudent(_originalStudent!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
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
}
