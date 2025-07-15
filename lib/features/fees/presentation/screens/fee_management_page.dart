import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/fee_summary_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/fee_management_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:collection/collection.dart';
import 'package:ders_planlayici/core/navigation/route_names.dart';
import 'package:ders_planlayici/core/widgets/summary_card.dart';

class FeeManagementPage extends StatefulWidget {
  const FeeManagementPage({super.key});

  @override
  State<FeeManagementPage> createState() => _FeeManagementPageState();
}

class _FeeManagementPageState extends State<FeeManagementPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _searchQuery = '';
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Veri yükleme artık provider tarafından yönetiliyor.
    // Provider'ı dinlemek için post-frame callback kullanılabilir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<FeeManagementProvider>();
        if (provider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _applyStatusFilter(String status) {
    setState(() {
      _statusFilter = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeeManagementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ücret Yönetimi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Otomatik Ücret Hesaplama',
            onPressed: () => context.pushNamed(RouteNames.autoFeeCalculation),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ödeme Geçmişi',
            onPressed: () => context.pushNamed(RouteNames.feeHistory),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: provider.loadInitialData,
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
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildMobileLayout(provider),
              tablet: _buildTabletLayout(provider),
              desktop: _buildDesktopLayout(provider),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.addPayment),
        tooltip: 'Ödeme Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout(FeeManagementProvider provider) => TabBarView(
    controller: _tabController,
    children: [
      _buildOverviewTab(provider),
      _buildStudentsTab(provider),
      _buildPaymentsTab(provider),
    ],
  );

  Widget _buildTabletLayout(FeeManagementProvider provider) => TabBarView(
    controller: _tabController,
    children: [
      _buildOverviewTab(provider),
      _buildStudentsTab(provider),
      _buildPaymentsTab(provider),
    ],
  );

  Widget _buildDesktopLayout(FeeManagementProvider provider) => TabBarView(
    controller: _tabController,
    children: [
      _buildOverviewTab(provider),
      _buildStudentsTab(provider),
      _buildPaymentsTab(provider),
    ],
  );

  Widget _buildOverviewTab(FeeManagementProvider provider) {
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
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Toplam Tutar',
                  value: currencyFormatter.format(provider.totalAmount),
                  icon: Icons.attach_money,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: SummaryCard(
                  title: 'Ödenen Tutar',
                  value: currencyFormatter.format(provider.paidAmount),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Kalan Tutar',
                  value: currencyFormatter.format(provider.remainingAmount),
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: SummaryCard(
                  title: 'Gecikmiş Ödemeler',
                  value: provider.overdueCount.toString(),
                  icon: Icons.warning_amber,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing24),
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
                    (provider.paidAmount /
                            (provider.totalAmount > 0
                                ? provider.totalAmount
                                : 1)) *
                        100,
                    AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),
                  const Text(
                    'Son Eklenen Ödemeler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  ...provider.payments.take(5).map(_buildPaymentListItem),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(FeeManagementProvider provider) => Column(
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
          itemCount: _getFilteredStudents(provider.students).length,
          itemBuilder: (context, index) {
            final student = _getFilteredStudents(provider.students)[index];
            final summary = provider.feeSummaries.firstWhereOrNull(
              (s) => s.id == student.id,
            );
            return _buildStudentSummaryCard(student, summary);
          },
        ),
      ),
    ],
  );

  Widget _buildPaymentsTab(FeeManagementProvider provider) => Column(
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
          itemCount: _getFilteredPayments(provider.payments).length,
          itemBuilder: (context, index) {
            final payment = _getFilteredPayments(provider.payments)[index];
            return _buildPaymentCard(payment);
          },
        ),
      ),
    ],
  );

  // Bu metot artık kullanılmıyor.
  /*
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Card(
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
  */

  Widget _buildProgressBar(String label, double percentage, Color color) =>
      Column(
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

  Widget _buildPaymentListItem(PaymentModel payment) {
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
        context.pushNamed(
          RouteNames.editPayment,
          pathParameters: {'id': payment.id},
        );
      },
    );
  }

  Widget _buildStudentSummaryCard(StudentModel student, FeeSummary? summary) {
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
          context.pushNamed(
            RouteNames.feeHistory,
            queryParameters: {'studentId': student.id},
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
                          student.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(student.grade ?? ''),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    tooltip: 'Ödeme Ekle',
                    onPressed: () {
                      context.pushNamed(
                        RouteNames.addPayment,
                        queryParameters: {'studentId': student.id},
                      );
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
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.success,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Text('${percentage.toStringAsFixed(1)}% ödendi'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
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
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.parse(payment.date)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() => SingleChildScrollView(
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

  // Yardımcı metodlar
  List<StudentModel> _getFilteredStudents(List<StudentModel> students) {
    if (_searchQuery.isEmpty) {
      return students;
    }

    final query = _searchQuery.toLowerCase();
    return students
        .where(
          (student) =>
              student.name.toLowerCase().contains(query) ||
              (student.parentName?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  List<PaymentModel> _getFilteredPayments(List<PaymentModel> payments) {
    var filtered = List<PaymentModel>.from(payments);

    // Duruma göre filtrele
    if (_statusFilter.isNotEmpty) {
      final status = PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == _statusFilter,
        orElse: () => PaymentStatus.pending,
      );
      filtered = filtered.where((p) => p.status == status).toList();
    }

    // Arama sorgusuna göre filtrele
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (p) =>
                p.studentName.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query) ||
                (p.notes?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return filtered;
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
