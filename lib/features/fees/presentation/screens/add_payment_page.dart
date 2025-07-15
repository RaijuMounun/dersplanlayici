import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/app_text_field.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/fee_management_provider.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key, this.studentId, this.paymentId});
  final String? studentId;
  final String? paymentId;

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage>
    with SingleTickerProviderStateMixin {
  final _lessonPaymentFormKey = GlobalKey<FormState>();
  final _bulkPaymentFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingStudents = true;
  List<StudentModel> _students = [];
  TabController? _tabController;
  List<Lesson> _unpaidLessons = [];
  final List<Lesson> _selectedLessons = [];

  String? _selectedStudentId;
  final _amountController = TextEditingController();
  final _bulkAmountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  PaymentMethod? _paymentMethod;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Provider erişimini build sonrasına ertele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeForm();
      }
    });
  }

  @override
  void dispose() {
    // Controller'ları güvenli şekilde dispose et
    _tabController?.dispose();
    _amountController.dispose();
    _bulkAmountController.dispose();
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
          _students.firstWhere(
            (student) => student.id == widget.studentId,
            orElse: StudentModel.empty,
          );
          _onStudentChanged(widget.studentId);
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

  void _onStudentChanged(String? studentId) {
    if (studentId == null) return;

    setState(() {
      _selectedStudentId = studentId;
      _selectedLessons.clear();
      _amountController.text = '0';

      final feeManagementProvider = Provider.of<FeeManagementProvider>(
        context,
        listen: false,
      );
      _unpaidLessons = feeManagementProvider.getUnpaidLessonsForStudent(
        studentId,
      );
    });
  }

  void _onLessonSelected(bool? value, Lesson lesson) {
    setState(() {
      if (value == true) {
        _selectedLessons.add(lesson);
      } else {
        _selectedLessons.remove(lesson);
      }
      _updatePaymentAmount();
    });
  }

  void _updatePaymentAmount() {
    final totalAmount = _selectedLessons.fold<double>(
      0,
      (sum, item) => sum + item.fee,
    );
    _amountController.text = totalAmount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ödeme Ekle')),
    body: _isLoading || _isLoadingStudents
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildStudentDropdown(),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: 'Derse Göre Öde'),
                  Tab(text: 'Toplu Ödeme Yap'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLessonPaymentTab(), _buildBulkPaymentTab()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedStudentId != null ? _savePayment : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
  );

  Widget _buildLessonPaymentTab() {
    if (_selectedStudentId == null) {
      return const Center(child: Text('Lütfen bir öğrenci seçin.'));
    }

    if (_unpaidLessons.isEmpty) {
      return const Center(
        child: Text('Bu öğrencinin ödenmemiş dersi bulunmuyor.'),
      );
    }

    return Form(
      key: _lessonPaymentFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödenecek Dersleri Seçin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _unpaidLessons.length,
                itemBuilder: (context, index) {
                  final lesson = _unpaidLessons[index];
                  return CheckboxListTile(
                    title: Text(lesson.subject),
                    subtitle: Text(
                      '${DateFormat.yMd('tr_TR').format(DateTime.parse(lesson.date))} - ${lesson.fee} ₺',
                    ),
                    value: _selectedLessons.contains(lesson),
                    onChanged: (value) => _onLessonSelected(value, lesson),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            AppTextField(
              controller: _amountController,
              label: 'Ödeme Tutarı (₺)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tutar boş olamaz';
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                if (double.parse(value) <= 0) {
                  return 'Tutar 0 dan büyük olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacing16),
            _buildDatePicker(
              label: 'Ödeme Tarihi',
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: AppDimensions.spacing16),
            _buildPaymentMethodDropdown(),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              controller: _notesController,
              label: 'Notlar',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePayment() async {
    final isLessonTab = _tabController?.index == 0;
    final formKey = isLessonTab ? _lessonPaymentFormKey : _bulkPaymentFormKey;

    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );
      final student = _students.firstWhere((s) => s.id == _selectedStudentId);

      double amount;
      String description;
      List<String>? lessonIds;

      if (isLessonTab) {
        // Derse Göre Öde
        amount = double.tryParse(_amountController.text) ?? 0;
        lessonIds = _selectedLessons.map((l) => l.id).toList();
        description = _selectedLessons.length > 1
            ? '${_selectedLessons.length} ders için ödeme'
            : 'Ödeme: ${_selectedLessons.first.subject}';
      } else {
        // Toplu Ödeme
        amount = double.tryParse(_bulkAmountController.text) ?? 0;
        lessonIds = null;
        description = 'Toplu Ödeme';
      }

      if (amount <= 0) {
        // Hata göster
        return;
      }

      final newPayment = PaymentModel(
        studentId: student.id,
        studentName: student.name,
        description: description,
        amount: amount,
        paidAmount: amount, // Ödenen tutar, girilen tutar kadardır
        date: _selectedDate.toIso8601String(),
        method: _paymentMethod,
        notes: _notesController.text,
        lessonIds: lessonIds,
      );

      await paymentProvider.addPayment(newPayment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeme başarıyla kaydedildi'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(
          context,
        ).pop(true); // Geri dönüldüğünde listenin yenilenmesi için
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme kaydedilirken hata oluştu: $e'),
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

  Widget _buildBulkPaymentTab() {
    if (_selectedStudentId == null) {
      return const Center(child: Text('Lütfen bir öğrenci seçin.'));
    }

    return Consumer<FeeManagementProvider>(
      builder: (context, feeProvider, child) {
        final summary = feeProvider.feeSummaries.firstWhere(
          (s) => s.id == _selectedStudentId,
          orElse: FeeSummary.empty,
        );
        final remainingAmount = summary.totalAmount - summary.paidAmount;

        return Form(
          key: _bulkPaymentFormKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Toplam Bakiye'),
                  trailing: Text(
                    '${remainingAmount.toStringAsFixed(2)} ₺',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: remainingAmount > 0
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing24),
                AppTextField(
                  controller: _bulkAmountController,
                  label: 'Ödeme Tutarı (₺)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tutar boş olamaz';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Tutar 0 dan büyük olmalı';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _buildDatePicker(
                  label: 'Ödeme Tarihi',
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: AppDimensions.spacing16),
                _buildPaymentMethodDropdown(),
                const SizedBox(height: AppDimensions.spacing16),
                AppTextField(
                  controller: _notesController,
                  label: 'Notlar',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
      if (value != null) {
        _onStudentChanged(value);
      }
    },
    validator: (value) =>
        value == null || value.isEmpty ? 'Lütfen bir öğrenci seçin' : null,
  );

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    bool isOptional = false,
  }) => InkWell(
    onTap: () async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (pickedDate != null) {
        onDateSelected(pickedDate);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedDate != null
                ? DateFormat.yMd('tr_TR').format(selectedDate)
                : (isOptional ? 'Seçimlik' : 'Tarih Seçin'),
          ),
          const Icon(Icons.calendar_today),
        ],
      ),
    ),
  );

  Widget _buildPaymentMethodDropdown() =>
      DropdownButtonFormField<PaymentMethod>(
        value: _paymentMethod,
        decoration: const InputDecoration(
          labelText: 'Ödeme Yöntemi',
          border: OutlineInputBorder(),
        ),
        items: PaymentMethod.values
            .map(
              (method) => DropdownMenuItem(
                value: method,
                child: Text(method.toDisplayString()),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _paymentMethod = value;
          });
        },
      );
}
