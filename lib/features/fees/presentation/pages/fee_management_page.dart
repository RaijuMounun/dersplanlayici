import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/core/widgets/loading_indicator.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

class FeeManagementPage extends StatefulWidget {
  const FeeManagementPage({super.key});

  @override
  State<FeeManagementPage> createState() => _FeeManagementPageState();
}

class _FeeManagementPageState extends State<FeeManagementPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  TabController? _tabController;
  List<FeeSummary> _feeSummaries = [];
  List<Student> _students = [];
  List<Payment> _payments = [];
  String _searchQuery = '';

  // Filtreleme seçenekleri
  String _statusFilter = '';

  // İstatistikler
  double _totalAmount = 0;
  double _paidAmount = 0;
  double _remainingAmount = 0;
  int _overdueCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await LoadingIndicator.wrapWithLoading(
        context: context,
        message: "Veriler yükleniyor...",
        future: Future(() async {
          // Öğrencileri yükle
          final studentProvider = Provider.of<StudentProvider>(
            context,
            listen: false,
          );
          await studentProvider.loadStudents(notify: false);

          // Ödemeleri yükle
          final paymentProvider = Provider.of<PaymentProvider>(
            context,
            listen: false,
          );
          await paymentProvider.loadPayments(notify: false);

          // Ücret özetlerini yükle
          await paymentProvider.loadAllStudentFeeSummaries(notify: false);

          return {
            'students': studentProvider.students,
            'payments': paymentProvider.payments,
            'summaries': paymentProvider.summaries,
          };
        }),
      ).then((data) {
        if (mounted) {
          setState(() {
            _students = data['students'] as List<Student>;
            _payments = data['payments'] as List<Payment>;
            _feeSummaries = data['summaries'] as List<FeeSummary>;
            _isLoading = false;

            // İstatistikleri hesapla
            _calculateStatistics();
          });
        }
      });
    } catch (e) {
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

  void _calculateStatistics() {
    _totalAmount = 0;
    _paidAmount = 0;
    _remainingAmount = 0;
    _overdueCount = 0;

    for (var payment in _payments) {
      _totalAmount += payment.amount;
      _paidAmount += payment.paidAmount;

      if (payment.status == PaymentStatus.overdue) {
        _overdueCount++;
      }
    }

    _remainingAmount = _totalAmount - _paidAmount;
  }

  void _applyStatusFilter(String status) {
    setState(() {
      _statusFilter = status;
    });

    // Use Future.microtask to avoid build-time state change
    Future.microtask(() {
      if (mounted) {
        Provider.of<PaymentProvider>(
          context,
          listen: false,
        ).filterByStatus(_statusFilter, notify: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ücret Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Otomatik Ücret Hesaplama',
            onPressed: () {
              context.push('/auto-fee-calculation');
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ödeme Geçmişi',
            onPressed: () {
              context.push('/fee-history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bakış'),
            Tab(text: 'Öğrenciler'),
            Tab(text: 'Ödemeler'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-payment');
        },
        tooltip: 'Ödeme Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return TabBarView(
      controller: _tabController,
      children: [_buildOverviewTab(), _buildStudentsTab(), _buildPaymentsTab()],
    );
  }

  Widget _buildTabletLayout() {
    return TabBarView(
      controller: _tabController,
      children: [_buildOverviewTab(), _buildStudentsTab(), _buildPaymentsTab()],
    );
  }

  Widget _buildDesktopLayout() {
    return TabBarView(
      controller: _tabController,
      children: [_buildOverviewTab(), _buildStudentsTab(), _buildPaymentsTab()],
    );
  }

  Widget _buildOverviewTab() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet kartları
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Toplam Tutar',
                  currencyFormatter.format(_totalAmount),
                  Icons.attach_money,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: _buildSummaryCard(
                  'Ödenen Tutar',
                  currencyFormatter.format(_paidAmount),
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Kalan Tutar',
                  currencyFormatter.format(_remainingAmount),
                  Icons.pending_actions,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: _buildSummaryCard(
                  'Gecikmiş Ödemeler',
                  _overdueCount.toString(),
                  Icons.warning_amber,
                  AppColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacing24),

          // Ödeme durumuna göre grafikler yerine basit progress bar'lar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ödeme İlerlemesi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildProgressBar(
                    'Toplam Ödemeler',
                    _paidAmount / (_totalAmount > 0 ? _totalAmount : 1) * 100,
                    AppColors.primary,
                  ),

                  // Son eklenen ödemeler
                  const SizedBox(height: AppDimensions.spacing24),
                  const Text(
                    'Son Eklenen Ödemeler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Son 5 ödemeyi listele
                  ..._payments
                      .take(5)
                      .map((payment) => _buildPaymentListItem(payment)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Öğrenci ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacing8),
            itemCount: _filteredStudents.length,
            itemBuilder: (context, index) {
              final student = _filteredStudents[index];
              final summary = _getSummaryForStudent(student.id);

              return _buildStudentSummaryCard(student, summary);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ödeme ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.spacing12),
              _buildFilterChips(),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacing8),
            itemCount: _filteredPayments.length,
            itemBuilder: (context, index) {
              final payment = _filteredPayments[index];
              return _buildPaymentCard(payment);
            },
          ),
        ),
      ],
    );
  }

  // Yardımcı widget'lar
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppDimensions.spacing8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text('${percentage.toStringAsFixed(1)}%')],
        ),
        const SizedBox(height: AppDimensions.spacing8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: AppColors.background,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
        ),
        const SizedBox(height: AppDimensions.spacing16),
      ],
    );
  }

  Widget _buildPaymentListItem(Payment payment) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return ListTile(
      title: Text(payment.studentName),
      subtitle: Text(payment.description),
      trailing: Text(
        currencyFormatter.format(payment.amount),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Icon(
        _getStatusIcon(payment.status),
        color: _getStatusColor(payment.status),
      ),
      onTap: () {
        context.push('/edit-payment/${payment.id}');
      },
    );
  }

  Widget _buildStudentSummaryCard(Student student, FeeSummary? summary) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    // Eğer özet yoksa boş göster
    final totalAmount = summary?.totalAmount ?? 0;
    final paidAmount = summary?.paidAmount ?? 0;
    final remainingAmount = summary?.remainingAmount ?? 0;
    final percentage = totalAmount > 0 ? (paidAmount / totalAmount) * 100 : 0;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacing8,
        horizontal: AppDimensions.spacing16,
      ),
      child: InkWell(
        onTap: () {
          context.push('/fee-history?studentId=${student.id}');
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
                          student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(student.grade),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    tooltip: 'Ödeme Ekle',
                    onPressed: () {
                      context.push('/add-payment?studentId=${student.id}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Toplam: ${currencyFormatter.format(totalAmount)}'),
                  Text(
                    'Kalan: ${currencyFormatter.format(remainingAmount)}',
                    style: TextStyle(
                      color: remainingAmount > 0
                          ? AppColors.warning
                          : AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing8),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.background,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text('${percentage.toStringAsFixed(1)}% ödendi'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
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
          context.push('/edit-payment/${payment.id}');
        },
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
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
                          style: TextStyle(color: AppColors.textSecondary),
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
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.parse(payment.date)),
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  if (payment.dueDate != null) ...[
                    const SizedBox(width: AppDimensions.spacing8),
                    Icon(Icons.event, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppDimensions.spacing4),
                    Text(
                      'Son Ödeme: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(payment.dueDate!))}',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '${currencyFormatter.format(payment.paidAmount)} / ${currencyFormatter.format(payment.amount)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tümü'),
            selected: _statusFilter.isEmpty,
            onSelected: (selected) {
              if (selected) {
                _applyStatusFilter('');
              }
            },
          ),
          const SizedBox(width: AppDimensions.spacing8),

          FilterChip(
            label: const Text('Beklemede'),
            selected: _statusFilter == 'pending',
            onSelected: (selected) {
              if (selected) {
                _applyStatusFilter('pending');
              } else {
                _applyStatusFilter('');
              }
            },
          ),
          const SizedBox(width: AppDimensions.spacing8),

          FilterChip(
            label: const Text('Ödenmiş'),
            selected: _statusFilter == 'paid',
            onSelected: (selected) {
              if (selected) {
                _applyStatusFilter('paid');
              } else {
                _applyStatusFilter('');
              }
            },
          ),
          const SizedBox(width: AppDimensions.spacing8),

          FilterChip(
            label: const Text('Kısmi Ödenmiş'),
            selected: _statusFilter == 'partiallyPaid',
            onSelected: (selected) {
              if (selected) {
                _applyStatusFilter('partiallyPaid');
              } else {
                _applyStatusFilter('');
              }
            },
          ),
          const SizedBox(width: AppDimensions.spacing8),

          FilterChip(
            label: const Text('Gecikmiş'),
            selected: _statusFilter == 'overdue',
            onSelected: (selected) {
              if (selected) {
                _applyStatusFilter('overdue');
              } else {
                _applyStatusFilter('');
              }
            },
          ),
        ],
      ),
    );
  }

  // Yardımcı metodlar
  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) {
      return _students;
    }

    final query = _searchQuery.toLowerCase();
    return _students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          (student.parentName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<Payment> get _filteredPayments {
    var filtered = _payments;

    // Arama sorgusu varsa filtrele
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((payment) {
        return payment.studentName.toLowerCase().contains(query) ||
            payment.description.toLowerCase().contains(query) ||
            (payment.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Durum filtresi varsa uygula
    if (_statusFilter.isNotEmpty) {
      filtered = filtered.where((payment) {
        return payment.status.toString().split('.').last == _statusFilter;
      }).toList();
    }

    return filtered;
  }

  FeeSummary? _getSummaryForStudent(String studentId) {
    try {
      return _feeSummaries.firstWhere((summary) => summary.id == studentId);
    } catch (e) {
      return null;
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
        return 'İptal';
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.pending_actions;
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.partiallyPaid:
        return Icons.sync;
      case PaymentStatus.overdue:
        return Icons.warning_amber;
      case PaymentStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.primary;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.partiallyPaid:
        return AppColors.warning;
      case PaymentStatus.overdue:
        return AppColors.error;
      case PaymentStatus.cancelled:
        return AppColors.textSecondary;
    }
  }
}
