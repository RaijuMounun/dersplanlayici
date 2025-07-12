import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key, this.studentId, this.paymentId});
  final String? studentId;
  final String? paymentId;

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingStudents = true;
  List<Student> _students = [];
  List<Lesson> _lessons = [];
  bool _isLoadingLessons = false;

  String? _selectedStudentId;
  String? _selectedStudentName;
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  PaymentMethod? _paymentMethod;
  final _notesController = TextEditingController();
  List<String> _selectedLessonIds = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    setState(() {
      _isLoadingStudents = true;
    });

    try {
      // Öğrencileri yükle
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      await studentProvider.loadStudents();

      if (!mounted) return;

      setState(() {
        _students = studentProvider.students;
        _isLoadingStudents = false;

        // Eğer URL'den studentId parametresi geldiyse onu seç
        if (widget.studentId != null && widget.studentId!.isNotEmpty) {
          _selectedStudentId = widget.studentId;
          final selectedStudent = _students.firstWhere(
            (student) => student.id == widget.studentId,
            orElse: () => Student(id: '', name: '', grade: ''),
          );
          _selectedStudentName = selectedStudent.name;
          _loadStudentLessons();
        }
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingStudents = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Öğrenciler yüklenirken hata oluştu: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _loadStudentLessons() async {
    if (_selectedStudentId == null) return;

    setState(() {
      _isLoadingLessons = true;
      _selectedLessonIds = [];
    });

    try {
      final lessonProvider = Provider.of<LessonProvider>(
        context,
        listen: false,
      );
      await lessonProvider.loadLessonsByStudent(_selectedStudentId!);

      if (!mounted) return;

      setState(() {
        _lessons = lessonProvider.lessons
            .where(
              (lesson) =>
                  lesson.status == LessonStatus.scheduled ||
                  lesson.status == LessonStatus.completed,
            )
            .toList();
        _isLoadingLessons = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingLessons = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dersler yüklenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ödeme Ekle')),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _isLoadingStudents
        ? const Center(child: CircularProgressIndicator())
        : _buildForm(),
  );

  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppDimensions.spacing16),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentDropdown(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildDescriptionField(),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            children: [
              Expanded(child: _buildAmountField()),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(child: _buildPaidAmountField()),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: 'Tarih',
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: _buildDatePicker(
                  label: 'Son Ödeme Tarihi',
                  selectedDate: _dueDate,
                  onDateSelected: (date) {
                    setState(() {
                      _dueDate = date;
                    });
                  },
                  isOptional: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          _buildStatusDropdown(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildPaymentMethodDropdown(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildNotesField(),
          if (_selectedStudentId != null && _lessons.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing24),
            _buildLessonsList(),
          ],
          const SizedBox(height: AppDimensions.spacing32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStudentDropdown() => DropdownButtonFormField<String>(
    value: _selectedStudentId,
    decoration: const InputDecoration(
      labelText: 'Öğrenci',
      border: OutlineInputBorder(),
    ),
    items: _students
        .map(
          (student) => DropdownMenuItem<String>(
            value: student.id,
            child: Text(student.name),
          ),
        )
        .toList(),
    onChanged: (value) {
      if (value == null) return;

      setState(() {
        _selectedStudentId = value;
        _selectedStudentName = _students
            .firstWhere((student) => student.id == value)
            .name;
        _selectedLessonIds = [];
      });

      _loadStudentLessons();
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Lütfen bir öğrenci seçin';
      }
      return null;
    },
  );

  Widget _buildDescriptionField() => TextFormField(
    controller: _descriptionController,
    decoration: const InputDecoration(
      labelText: 'Açıklama',
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Lütfen açıklama girin';
      }
      return null;
    },
  );

  Widget _buildAmountField() => TextFormField(
    controller: _amountController,
    decoration: const InputDecoration(
      labelText: 'Toplam Tutar (₺)',
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Tutar gerekli';
      }
      final amount = double.tryParse(value.replaceAll(',', '.'));
      if (amount == null) {
        return 'Geçerli bir tutar girin';
      }
      if (amount <= 0) {
        return 'Tutar sıfırdan büyük olmalı';
      }
      return null;
    },
  );

  Widget _buildPaidAmountField() => TextFormField(
    controller: _paidAmountController,
    decoration: const InputDecoration(
      labelText: 'Ödenen Tutar (₺)',
      border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (value == null || value.isEmpty) {
        // Ödenen tutar boş bırakılabilir (0 olarak kabul edilir)
        return null;
      }
      final paidAmount = double.tryParse(value.replaceAll(',', '.'));
      if (paidAmount == null) {
        return 'Geçerli bir tutar girin';
      }
      if (paidAmount < 0) {
        return 'Tutar negatif olamaz';
      }
      return null;
    },
  );

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
    bool isOptional = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (isOptional) ...[
            const SizedBox(width: AppDimensions.spacing4),
            const Text(
              '(Opsiyonel)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: AppDimensions.spacing8),
      InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onDateSelected(picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing16,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(AppDimensions.radius4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(selectedDate)
                    : 'Tarih Seçin',
                style: TextStyle(
                  fontSize: 16,
                  color: selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: selectedDate != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildStatusDropdown() => DropdownButtonFormField<PaymentStatus>(
    value: _paymentStatus,
    decoration: const InputDecoration(
      labelText: 'Ödeme Durumu',
      border: OutlineInputBorder(),
    ),
    items: PaymentStatus.values.map((status) {
      String label;
      switch (status) {
        case PaymentStatus.pending:
          label = 'Beklemede';
          break;
        case PaymentStatus.paid:
          label = 'Ödenmiş';
          break;
        case PaymentStatus.partiallyPaid:
          label = 'Kısmi Ödenmiş';
          break;
        case PaymentStatus.overdue:
          label = 'Gecikmiş';
          break;
        case PaymentStatus.cancelled:
          label = 'İptal Edilmiş';
          break;
      }
      return DropdownMenuItem<PaymentStatus>(value: status, child: Text(label));
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        setState(() {
          _paymentStatus = value;
        });
      }
    },
  );

  Widget _buildPaymentMethodDropdown() =>
      DropdownButtonFormField<PaymentMethod>(
        value: _paymentMethod,
        decoration: const InputDecoration(
          labelText: 'Ödeme Yöntemi',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<PaymentMethod>(
            value: null,
            child: Text('Seçiniz'),
          ),
          ...PaymentMethod.values.map((method) {
            String label;
            switch (method) {
              case PaymentMethod.cash:
                label = 'Nakit';
                break;
              case PaymentMethod.creditCard:
                label = 'Kredi Kartı';
                break;
              case PaymentMethod.bankTransfer:
                label = 'Banka Havalesi';
                break;
              case PaymentMethod.other:
                label = 'Diğer';
                break;
            }
            return DropdownMenuItem<PaymentMethod>(
              value: method,
              child: Text(label),
            );
          }),
        ],
        onChanged: (value) {
          setState(() {
            _paymentMethod = value;
          });
        },
      );

  Widget _buildNotesField() => TextFormField(
    controller: _notesController,
    decoration: const InputDecoration(
      labelText: 'Notlar',
      border: OutlineInputBorder(),
      alignLabelWithHint: true,
    ),
    maxLines: 3,
  );

  Widget _buildLessonsList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'İlişkili Dersler',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: AppDimensions.spacing8),
      const Text(
        'Bu ödemeyle ilişkilendirilecek dersleri seçin:',
        style: TextStyle(fontSize: 14),
      ),
      const SizedBox(height: AppDimensions.spacing12),
      _isLoadingLessons
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacing16),
                child: CircularProgressIndicator(),
              ),
            )
          : _lessons.isEmpty
          ? const Text(
              'Bu öğrenciye ait ders bulunamadı.',
              style: TextStyle(fontStyle: FontStyle.italic),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                final formattedDate = DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.parse(lesson.date));
                final isSelected = _selectedLessonIds.contains(lesson.id);

                return CheckboxListTile(
                  title: Text(
                    '${lesson.subject} - ${lesson.topic ?? "Konu belirtilmemiş"}',
                  ),
                  subtitle: Text('$formattedDate, ${lesson.startTime}'),
                  secondary: Text(
                    '${lesson.fee.toStringAsFixed(2)} ₺',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedLessonIds.add(lesson.id);

                        // Seçilen dersin ücretini toplam tutara ekle
                        final currentAmount =
                            double.tryParse(
                              _amountController.text.replaceAll(',', '.'),
                            ) ??
                            0;
                        _amountController.text = (currentAmount + lesson.fee)
                            .toStringAsFixed(2);
                      } else {
                        _selectedLessonIds.remove(lesson.id);

                        // Seçimi kaldırılan dersin ücretini toplam tutardan çıkar
                        final currentAmount =
                            double.tryParse(
                              _amountController.text.replaceAll(',', '.'),
                            ) ??
                            0;
                        _amountController.text = (currentAmount - lesson.fee)
                            .toStringAsFixed(2);
                      }
                    });
                  },
                );
              },
            ),
    ],
  );

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStudentId == null || _selectedStudentName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir öğrenci seçin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final paidAmount = _paidAmountController.text.isEmpty
          ? 0.0
          : double.parse(_paidAmountController.text.replaceAll(',', '.'));

      // Ödeme durumunu hesapla
      PaymentStatus status;
      if (_paymentStatus == PaymentStatus.pending ||
          _paymentStatus == PaymentStatus.overdue ||
          _paymentStatus == PaymentStatus.cancelled) {
        status = _paymentStatus;
      } else {
        if (paidAmount >= amount) {
          status = PaymentStatus.paid;
        } else if (paidAmount > 0) {
          status = PaymentStatus.partiallyPaid;
        } else {
          status = PaymentStatus.pending;
        }
      }

      // Payment nesnesini oluştur
      final payment = PaymentModel(
        studentId: _selectedStudentId!,
        studentName: _selectedStudentName!,
        description: _descriptionController.text,
        amount: amount,
        paidAmount: paidAmount,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        dueDate: _dueDate != null
            ? DateFormat('yyyy-MM-dd').format(_dueDate!)
            : null,
        status: status,
        method: _paymentMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        lessonIds: _selectedLessonIds.isNotEmpty ? _selectedLessonIds : null,
      );

      // Ödemeyi kaydet
      await Provider.of<PaymentProvider>(
        context,
        listen: false,
      ).addPayment(payment);

      if (!mounted) return;

      // Başarılı mesajı göster ve geri dön
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme başarıyla eklendi'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;

      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ödeme eklenirken hata oluştu: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
