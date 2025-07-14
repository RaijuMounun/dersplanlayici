import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/core/navigation/route_names.dart';

class FeeHistoryPage extends StatefulWidget {
  const FeeHistoryPage({super.key, this.studentId});
  final String? studentId;

  @override
  State<FeeHistoryPage> createState() => _FeeHistoryPageState();
}

class _FeeHistoryPageState extends State<FeeHistoryPage> {
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedStudentId;
  FeeSummary? _feeSummary;
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This logic is now handled by rebuilding with the new state
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    try {
      if (_selectedStudentId != null) {
        // Öğrenci belirtilmişse sadece o öğrencinin ödemelerini getir
        await paymentProvider.loadPaymentsByStudent(_selectedStudentId!);
        // Öğrenci özeti de yükle
        _feeSummary = await paymentProvider.loadStudentFeeSummary(
          _selectedStudentId!,
        );
      } else {
        // Tüm ödemeleri getir
        await paymentProvider.loadPayments();
        // Tüm öğrenci özetlerini yükle
        await paymentProvider.loadAllStudentFeeSummaries();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Ödeme Geçmişi'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Yenile',
          onPressed: _loadData,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ResponsiveLayout(
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
  );

  Widget _buildMobileLayout() => Column(
    children: [
      _buildDateRangeSelector(),
      if (_selectedStudentId == null) _buildStudentSelector(),
      if (_feeSummary != null) _buildFeeSummaryCard(),
      Expanded(child: _buildPaymentHistoryList()),
    ],
  );

  Widget _buildTabletLayout() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Row(
          children: [
            Expanded(child: _buildDateRangeSelector()),
            if (_selectedStudentId == null)
              Expanded(child: _buildStudentSelector()),
          ],
        ),
      ),
      if (_feeSummary != null) _buildFeeSummaryCard(),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: _buildPaymentHistoryList(),
        ),
      ),
    ],
  );

  Widget _buildDesktopLayout() => Row(
    children: [
      Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: _buildFilterPanel(),
        ),
      ),
      Expanded(
        flex: 3,
        child: Column(
          children: [
            if (_feeSummary != null) _buildFeeSummaryCard(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: _buildPaymentHistoryList(),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildDateRangeSelector() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tarih Aralığı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Başlangıç',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(formatter.format(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Bitiş',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(formatter.format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Filtrele'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Başlangıç tarihi bitiş tarihinden sonra olamaz
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Bitiş tarihi başlangıç tarihinden önce olamaz
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Widget _buildStudentSelector() {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Öğrenci',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              DropdownButtonFormField<String>(
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Öğrenci Seçin',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tüm Öğrenciler'),
                  ),
                  ...studentProvider.students.map(
                    (student) => DropdownMenuItem<String>(
                      value: student.id,
                      child: Text(student.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStudentId = value;
                  });
                  _loadData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtreler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            const Text(
              'Tarih Aralığı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            _buildDatePicker(
              label: 'Başlangıç Tarihi',
              selectedDate: _startDate,
              onTap: () => _selectDate(true),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            _buildDatePicker(
              label: 'Bitiş Tarihi',
              selectedDate: _endDate,
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            if (_selectedStudentId == null) ...[
              const Text(
                'Öğrenci',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              DropdownButtonFormField<String>(
                value: _selectedStudentId,
                decoration: const InputDecoration(
                  labelText: 'Öğrenci Seçin',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tüm Öğrenciler'),
                  ),
                  ...studentProvider.students.map(
                    (student) => DropdownMenuItem<String>(
                      value: student.id,
                      child: Text(student.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStudentId = value;
                  });
                  _loadData();
                },
              ),
            ],
            const SizedBox(height: AppDimensions.spacing16),
            const Text(
              'Ödeme Durumu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            _buildPaymentStatusFilters(),
            const SizedBox(height: AppDimensions.spacing24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadData,
                child: const Text('Uygula'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _startDate = DateTime.now().subtract(
                      const Duration(days: 30),
                    );
                    _endDate = DateTime.now();
                    _selectedStudentId = widget.studentId;
                  });
                  _loadData();
                },
                child: const Text('Filtreleri Sıfırla'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
          const Icon(Icons.calendar_today, size: 16),
        ],
      ),
    ),
  );

  Widget _buildPaymentStatusFilters() => Wrap(
    spacing: AppDimensions.spacing8,
    children: [
      _buildFilterChip('', 'Tümü'),
      _buildFilterChip('pending', 'Beklemede'),
      _buildFilterChip('paid', 'Ödenmiş'),
      _buildFilterChip('partiallyPaid', 'Kısmi Ödenmiş'),
      _buildFilterChip('overdue', 'Gecikmiş'),
      _buildFilterChip('cancelled', 'İptal Edilmiş'),
    ],
  );

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : '';
        });
      },
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary.withAlpha(50),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildFeeSummaryCard() {
    if (_feeSummary == null) return const SizedBox.shrink();

    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _feeSummary!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Toplam Ücret',
                      currencyFormatter.format(_feeSummary!.totalAmount),
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Ödenen',
                      currencyFormatter.format(_feeSummary!.paidAmount),
                      AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Kalan',
                      currencyFormatter.format(_feeSummary!.remainingAmount),
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),
              LinearProgressIndicator(
                value: _feeSummary!.paymentPercentage / 100,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.success,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Ödeme Oranı: %${_feeSummary!.paymentPercentage.toStringAsFixed(1)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Toplam Ders',
                      _feeSummary!.totalLessons.toString(),
                      AppColors.info,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Tamamlanan',
                      _feeSummary!.completedLessons.toString(),
                      AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Geciken Ödeme',
                      _feeSummary!.overduePayments.toString(),
                      AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      const SizedBox(height: AppDimensions.spacing4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );

  Widget _buildPaymentHistoryList() {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final filteredPayments = _getFilteredAndSortedPayments(
      paymentProvider.payments,
    );

    if (filteredPayments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredPayments.length,
      itemBuilder: (context, index) {
        final payment = filteredPayments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  List<PaymentModel> _getFilteredAndSortedPayments(
    List<PaymentModel> payments,
  ) {
    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);

    var filtered = payments.where((payment) {
      final paymentDate = payment.date;
      return paymentDate.compareTo(startDateStr) >= 0 &&
          paymentDate.compareTo(endDateStr) <= 0;
    });

    if (_selectedStatus.isNotEmpty) {
      final status = PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == _selectedStatus,
        orElse: () => PaymentStatus.pending,
      );
      filtered = filtered.where((payment) => payment.status == status);
    }

    final sorted = filtered.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    final formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(payment.date));
    final statusColor = _getStatusColor(payment.status);
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacing12,
        left: AppDimensions.spacing8,
        right: AppDimensions.spacing8,
      ),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.editPayment,
            pathParameters: {'id': payment.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          payment.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing8,
                      vertical: AppDimensions.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius4,
                      ),
                    ),
                    child: Text(
                      _getStatusText(payment.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (payment.dueDate != null) ...[
                    const SizedBox(width: AppDimensions.spacing8),
                    const Icon(
                      Icons.event,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.spacing4),
                    Text(
                      'Son Ödeme: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(payment.dueDate!))}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${currencyFormatter.format(payment.paidAmount)} / ${currencyFormatter.format(payment.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  payment.notes!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.payments_outlined,
          size: 64,
          color: AppColors.textSecondary.withAlpha(128),
        ),
        const SizedBox(height: AppDimensions.spacing16),
        const Text(
          'Seçilen tarih aralığında ödeme kaydı bulunamadı',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: AppDimensions.spacing24),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _startDate = DateTime.now().subtract(const Duration(days: 30));
              _endDate = DateTime.now();
            });
            _loadData();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Filtreleri Sıfırla'),
        ),
      ],
    ),
  );

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.info;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.partiallyPaid:
        return AppColors.warning;
      case PaymentStatus.overdue:
        return AppColors.error;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Beklemede';
      case PaymentStatus.paid:
        return 'Ödenmiş';
      case PaymentStatus.partiallyPaid:
        return 'Kısmi Ödenmiş';
      case PaymentStatus.overdue:
        return 'Gecikmiş';
      case PaymentStatus.cancelled:
        return 'İptal Edilmiş';
    }
  }
}
