import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:intl/intl.dart';

class AddLessonPage extends StatefulWidget {
  final String? studentId;

  const AddLessonPage({super.key, this.studentId});

  @override
  State<AddLessonPage> createState() => _AddLessonPageState();
}

class _AddLessonPageState extends State<AddLessonPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStudentId;
  String? _selectedStudentName;
  String? _selectedSubject;
  final _topicController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  late TimeOfDay _endTime;
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingStudents = true;
  List<Student> _students = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Başlangıç saatine bir saat ekleyerek bitiş saatini ayarla
    final now = TimeOfDay.now();
    _endTime = TimeOfDay(
      hour: (now.hour + 1) % 24, // 24 saati geçerse başa dön
      minute: now.minute,
    );

    // Provider erişimini build sonrasına ertele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStudents = true;
    });

    try {
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      await studentProvider.loadStudents();

      if (!mounted) return;

      setState(() {
        _students = studentProvider.students;
        _isLoadingStudents = false;

        // Eğer url'den studentId parametresi geldiyse onu seç
        if (widget.studentId != null && widget.studentId!.isNotEmpty) {
          _selectedStudentId = widget.studentId;
          final selectedStudent = _students.firstWhere(
            (student) => student.id == widget.studentId,
            orElse: () => _students.first,
          );
          _selectedStudentName = selectedStudent.name;

          // Öğrencinin seçtiği konulardan ilkini otomatik seç
          if (selectedStudent.subjects != null &&
              selectedStudent.subjects!.isNotEmpty) {
            _selectedSubject = selectedStudent.subjects!.first;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Öğrenciler yüklenirken hata oluştu: $e';
        _isLoadingStudents = false;
      });
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Ders Ekle')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isLoadingStudents
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text('Hata: $_error'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentDropdown(),
                    const SizedBox(height: 16),
                    _buildSubjectDropdown(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Konu',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDatePicker(context),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            'Başlangıç Saati',
                            _startTime,
                            (time) {
                              setState(() {
                                _startTime = time;

                                // Eğer bitiş saati başlangıçtan önceyse, bitiş saatini güncelle
                                if (_endTime.hour < _startTime.hour ||
                                    (_endTime.hour == _startTime.hour &&
                                        _endTime.minute < _startTime.minute)) {
                                  _endTime = TimeOfDay(
                                    hour:
                                        (_startTime.hour + 1) %
                                        24, // 24 saati geçerse başa dön
                                    minute: _startTime.minute,
                                  );
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            'Bitiş Saati',
                            _endTime,
                            (time) {
                              setState(() {
                                _endTime = time;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notlar',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveLesson,
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

  Widget _buildStudentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStudentId,
      decoration: const InputDecoration(
        labelText: 'Öğrenci',
        border: OutlineInputBorder(),
      ),
      items: _students.map((student) {
        return DropdownMenuItem<String>(
          value: student.id,
          child: Text(student.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedStudentId = value;
          final selectedStudent = _students.firstWhere(
            (student) => student.id == value,
          );
          _selectedStudentName = selectedStudent.name;

          // Öğrencinin ilk dersini otomatik seç
          if (selectedStudent.subjects != null &&
              selectedStudent.subjects!.isNotEmpty) {
            _selectedSubject = selectedStudent.subjects!.first;
          } else {
            _selectedSubject = null;
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir öğrenci seçin';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectDropdown() {
    // Seçilen öğrencinin dersleri
    List<String> availableSubjects = [];

    if (_selectedStudentId != null) {
      final selectedStudent = _students.firstWhere(
        (student) => student.id == _selectedStudentId,
        orElse: () => Student(id: '', name: '', grade: ''),
      );
      availableSubjects = selectedStudent.subjects?.toList() ?? [];
    }

    return DropdownButtonFormField<String>(
      value: _selectedSubject,
      decoration: const InputDecoration(
        labelText: 'Ders',
        border: OutlineInputBorder(),
      ),
      items: availableSubjects.map((subject) {
        return DropdownMenuItem<String>(value: subject, child: Text(subject));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubject = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir ders seçin';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tarih',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null && picked != time) {
              onTimeSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveLesson() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStudentId == null ||
          _selectedStudentName == null ||
          _selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen öğrenci ve ders seçin')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Ders nesnesini oluştur
        final lesson = Lesson(
          id: '', // ID repository tarafından atanacak
          studentId: _selectedStudentId!,
          studentName: _selectedStudentName!,
          subject: _selectedSubject!,
          topic: _topicController.text,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
          startTime:
              '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
          endTime:
              '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
          status: LessonStatus.scheduled,
          notes: _notesController.text,
        );

        // Provider üzerinden dersi kaydet
        await Provider.of<LessonProvider>(
          context,
          listen: false,
        ).addLesson(lesson);

        // Başarılı kayıt sonrası geri dön
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ders başarıyla eklendi')),
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
