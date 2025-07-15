import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/loading_indicator.dart';
import 'package:ders_planlayici/features/fees/domain/services/fee_calculation_service.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';

class AutoFeeCalculationPage extends StatefulWidget {
  const AutoFeeCalculationPage({super.key});

  @override
  State<AutoFeeCalculationPage> createState() => _AutoFeeCalculationPageState();
}

class _AutoFeeCalculationPageState extends State<AutoFeeCalculationPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  TabController? _tabController;
  List<Map<String, dynamic>> _paymentSuggestions = [];
  List<StudentModel> _students = [];
  String? _selectedStudentId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _onlyCompletedLessons = true;
  double _calculatedFee = 0;
  List<Lesson> _calculatedLessons = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      final localContext = context;
      // Provider'ları önceden al
      final studentProvider = Provider.of<StudentProvider>(
        localContext,
        listen: false,
      );
      final lessonProvider = Provider.of<LessonProvider>(
        localContext,
        listen: false,
      );
      final paymentProvider = Provider.of<PaymentProvider>(
        localContext,
        listen: false,
      );

      await LoadingIndicator.wrapWithLoading(
        context: localContext,
        message: 'Veriler yükleniyor...',
        future: Future(() async {
          if (!mounted) return null;
          
          // Öğrencileri yükle
          await studentProvider.loadStudents();

          // Dersleri yükle
          await lessonProvider.loadLessons();

          // Ödemeleri yükle
          await paymentProvider.loadPayments();

          // Ödeme önerilerini oluştur
          final suggestions = FeeCalculationService.generatePaymentSuggestions(
            students: studentProvider.students,
            allLessons: lessonProvider.allLessons,
            allPayments: paymentProvider.payments,
          );

          return {
            'students': studentProvider.students,
            'suggestions': suggestions,
          };
        }),
      ).then((data) {
        if (mounted && data != null) {
          setState(() {
            _students = data['students'] as List<StudentModel>;
            _paymentSuggestions =
                data['suggestions'] as List<Map<String, dynamic>>;
            _isLoading = false;
          });
        }
      });
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler yüklenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _calculateFeeForDateRange() async {
    if (!mounted) return;

    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir öğrenci seçin.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      final localContext = context;
      // Provider'ı önceden al
      final lessonProvider = Provider.of<LessonProvider>(
        localContext,
        listen: false,
      );

      await LoadingIndicator.wrapWithLoading(
        context: localContext,
        message: 'Ücret hesaplanıyor...',
        future: Future(() async {
          if (!mounted) return null;

          // Öğrencinin derslerini al
          final lessons = lessonProvider.allLessons
              .where((lesson) => lesson.studentId == _selectedStudentId)
              .toList();

          // Tarih aralığındaki dersleri hesapla
          final filteredLessons = lessons.where((lesson) {
            final lessonDate = DateTime.parse(lesson.date);
            final isInRange =
                (lessonDate.isAfter(_startDate) ||
                    lessonDate.isAtSameMomentAs(_startDate)) &&
                (lessonDate.isBefore(_endDate) ||
                    lessonDate.isAtSameMomentAs(_endDate));

            if (_onlyCompletedLessons) {
              return isInRange && lesson.status == LessonStatus.completed;
            }

            return isInRange && lesson.status != LessonStatus.cancelled;
          }).toList();

          // Toplam ücreti hesapla
          final fee = FeeCalculationService.calculateStudentFeeForDateRange(
            lessons: lessons,
            startDate: _startDate,
            endDate: _endDate,
            onlyCompleted: _onlyCompletedLessons,
          );

          return {'fee': fee, 'lessons': filteredLessons};
        }),
      ).then((data) {
        if (mounted && data != null) {
          setState(() {
            _calculatedFee = data['fee'] as double;
            _calculatedLessons = data['lessons'] as List<Lesson>;
            _isLoading = false;
          });
        }
      });
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ücret hesaplanırken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _createPaymentFromSuggestion(Map<String, dynamic> suggestion) async {
    try {
      if (!mounted) return;
      
      // Ödeme oluşturma sayfasına yönlendir
      final lessonIds = suggestion['unbilledLessonIds'] as List<String>;
      final studentId = suggestion['studentId'] as String;
      final amount = suggestion['amount'] as double;
      final description = suggestion['description'] as String;

      // Go router ile parametreleri gönder
      if (mounted) {
      await context.push(
        '/add-payment?studentId=$studentId&amount=${amount.toStringAsFixed(2)}&description=$description&lessonIds=${lessonIds.join(",")}',
      );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme oluşturulurken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _createPaymentFromCalculation() {
    if (_selectedStudentId == null || _calculatedFee <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geçerli bir hesaplama yapılmadı.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    try {
      final student = _students.firstWhere((s) => s.id == _selectedStudentId);
      final lessonIds = _calculatedLessons.map((l) => l.id).toList();

      final startDateFormatted = DateFormat('dd/MM/yyyy').format(_startDate);
      final endDateFormatted = DateFormat('dd/MM/yyyy').format(_endDate);
      final description =
          '${student.name} - $startDateFormatted - $endDateFormatted arası dersler';

      // Go router ile parametreleri gönder
      if (mounted) {
      context.push(
        '/add-payment?studentId=$_selectedStudentId&amount=${_calculatedFee.toStringAsFixed(2)}&description=$description&lessonIds=${lessonIds.join(",")}',
      );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme oluşturulurken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Otomatik Ücret Hesaplama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ödeme Önerileri'),
            Tab(text: 'Tarih Bazlı Hesaplama'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
            children: [_buildSuggestionsTab(), _buildDateRangeCalculationTab()],
            ),
    );

  Widget _buildSuggestionsTab() => _paymentSuggestions.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Tüm dersler için ödeme oluşturulmuş.',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  'Ödenmemiş tamamlanmış ders bulunmuyor.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            itemCount: _paymentSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _paymentSuggestions[index];
              return _buildSuggestionCard(suggestion);
            },
          );

  Widget _buildDateRangeCalculationTab() => SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentDropdown(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildDateRangePicker(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildCompletedLessonsSwitch(),
          const SizedBox(height: AppDimensions.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculateFeeForDateRange,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Hesapla', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          _buildCalculationResult(),
        ],
      ),
    );

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion['studentName'] as String,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text('Ders Sayısı: ${suggestion['lessonCount']}'),
            const SizedBox(height: AppDimensions.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toplam Ücret: ${currencyFormatter.format(suggestion['amount'])}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _createPaymentFromSuggestion(suggestion),
                  child: const Text('Ödeme Oluştur'),
                ),
              ],
            ),
          ],
        ),
      ),
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
        setState(() {
          _selectedStudentId = value;
          _calculatedFee = 0;
          _calculatedLessons = [];
        });
      },
    );

  Widget _buildDateRangePicker() => Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null && mounted) {
                setState(() {
                  _startDate = pickedDate;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Başlangıç Tarihi',
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacing16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: _startDate,
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (pickedDate != null && mounted) {
                setState(() {
                  _endDate = pickedDate;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Bitiş Tarihi',
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
            ),
          ),
        ),
      ],
    );

  Widget _buildCompletedLessonsSwitch() => SwitchListTile(
      title: const Text('Sadece Tamamlanmış Dersleri Hesapla'),
      subtitle: const Text('Kapatırsanız, planlanan dersleri de dahil eder'),
      value: _onlyCompletedLessons,
      onChanged: (value) {
        setState(() {
          _onlyCompletedLessons = value;
        });
      },
    );

  Widget _buildCalculationResult() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hesaplama Sonucu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Toplam Ders: ${_calculatedLessons.length}'),
                Text(
                  'Toplam Ücret: ${currencyFormatter.format(_calculatedFee)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            if (_calculatedLessons.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: AppDimensions.spacing8),
              const Text(
                'Dersler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              ..._calculatedLessons.map((lesson) {
                final formattedDate = DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.parse(lesson.date));
                return ListTile(
                  dense: true,
                  title: Text('${lesson.subject} - ${lesson.topic ?? ""}'),
                  subtitle: Text('$formattedDate, ${lesson.startTime}'),
                  trailing: Text(
                    currencyFormatter.format(lesson.fee),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
              const SizedBox(height: AppDimensions.spacing16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculatedFee > 0
                      ? _createPaymentFromCalculation
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Ödeme Oluştur',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
