import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGrade = '5. Sınıf';
  final List<String> _selectedSubjects = [];
  bool _isLoading = false;

  final List<String> _availableGrades = [
    '1. Sınıf',
    '2. Sınıf',
    '3. Sınıf',
    '4. Sınıf',
    '5. Sınıf',
    '6. Sınıf',
    '7. Sınıf',
    '8. Sınıf',
  ];

  final List<String> _availableSubjects = [
    'Matematik',
    'Türkçe',
    'Fen Bilgisi',
    'Sosyal Bilgiler',
    'İngilizce',
    'Hayat Bilgisi',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Öğrenci Ekle')),
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
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveStudent,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Kaydet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Öğrenci nesnesini oluştur
        final student = Student(
          id: '', // ID repository tarafından atanacak
          name: _nameController.text,
          grade: _selectedGrade,
          parentName: _parentNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          subjects: List.from(_selectedSubjects),
          notes: '',
        );

        // Provider üzerinden öğrenciyi kaydet
        await Provider.of<StudentProvider>(
          context,
          listen: false,
        ).addStudent(student);

        // Başarılı kayıt sonrası geri dön
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Öğrenci başarıyla eklendi')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
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
}
