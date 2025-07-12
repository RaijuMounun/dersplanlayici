import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';

class PaymentListPage extends StatefulWidget {
  const PaymentListPage({super.key});

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPayments();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Apply filter from state if needed
    if (_statusFilter.isNotEmpty && mounted) {
      Provider.of<PaymentProvider>(
        context,
        listen: false,
      ).filterByStatus(_statusFilter, notify: false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );

      await paymentProvider.loadPayments(notify: false);
    } on Exception catch (e) {
      // Hata durumunda sadece loading'i false yap
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödemeler yüklenirken hata oluştu: $e'),
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

  @override
  Widget build(BuildContext context) => Consumer<PaymentProvider>(
    builder: (context, paymentProvider, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Ödemeler'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Ödeme Geçmişi',
              onPressed: () {
                if (mounted) {
                  context.push('/fee-history');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Yenile',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadPayments();
              },
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (mounted) {
              await context.push('/add-payment');
              // Ödeme ekleme sayfasından döndükten sonra ödemeleri yeniden yükle
              if (mounted) {
                await _loadPayments();
              }
            }
          },
          tooltip: 'Ödeme Ekle',
          child: const Icon(Icons.add),
        ),
      ),
  );

  Widget _buildMobileLayout() => Column(
    children: [
      _buildSearchAndFilterBar(),
      Expanded(child: _buildPaymentsList()),
    ],
  );

  Widget _buildTabletLayout() => Column(
    children: [
      _buildSearchAndFilterBar(),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: _buildPaymentsList(),
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
            _buildSearchBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: _buildPaymentsList(),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildSearchAndFilterBar() => Padding(
    padding: const EdgeInsets.all(AppDimensions.spacing16),
    child: Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: AppDimensions.spacing12),
        _buildFilterChips(),
      ],
    ),
  );

  Widget _buildSearchBar() => TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Ödeme ara...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _searchQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
      ),
    ),
    onChanged: (value) {
      setState(() {
        _searchQuery = value;
      });
    },
  );

  Widget _buildFilterChips() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _buildFilterChip('', 'Tümü'),
        const SizedBox(width: AppDimensions.spacing8),
        _buildFilterChip('pending', 'Beklemede'),
        const SizedBox(width: AppDimensions.spacing8),
        _buildFilterChip('paid', 'Ödenmiş'),
        const SizedBox(width: AppDimensions.spacing8),
        _buildFilterChip('partiallyPaid', 'Kısmi Ödenmiş'),
        const SizedBox(width: AppDimensions.spacing8),
        _buildFilterChip('overdue', 'Gecikmiş'),
      ],
    ),
  );

  Widget _buildFilterPanel() => Card(
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
            'Ödeme Durumu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          _buildFilterOption('', 'Tümü'),
          _buildFilterOption('pending', 'Beklemede'),
          _buildFilterOption('paid', 'Ödenmiş'),
          _buildFilterOption('partiallyPaid', 'Kısmi Ödenmiş'),
          _buildFilterOption('overdue', 'Gecikmiş'),
          const SizedBox(height: AppDimensions.spacing24),
          const Text(
            'Öğrenci İstatistikleri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          _buildStatCard(),
        ],
      ),
    ),
  );

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _statusFilter == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : '';
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

  Widget _buildFilterOption(String status, String label) {
    final isSelected = _statusFilter == status;

    return InkWell(
      onTap: () {
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
      },
      borderRadius: BorderRadius.circular(AppDimensions.radius8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing8,
          horizontal: AppDimensions.spacing4,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.spacing8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    if (paymentProvider.summaries.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('İstatistik bulunamadı')),
      );
    }

    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Özet', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: AppDimensions.spacing8),
            Text('Yakında gelecek...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() => Consumer<PaymentProvider>(
    builder: (context, paymentProvider, child) {
      final filteredPayments = _filterPayments(paymentProvider.payments);

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
    },
  );

  List<PaymentModel> _filterPayments(List<PaymentModel> payments) {
    if (_searchQuery.isEmpty && _statusFilter.isEmpty) {
      return payments;
    }

    return payments.where((payment) {
      // Arama filtresi
      final matchesSearch =
          _searchQuery.isEmpty ||
          payment.studentName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          payment.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Durum filtresi
      final matchesStatus =
          _statusFilter.isEmpty ||
          payment.status.toString().split('.').last == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
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
              const SizedBox(height: AppDimensions.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Düzenle'),
                    onPressed: () {
                      context.push('/edit-payment/${payment.id}');
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Sil'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    onPressed: () {
                      _confirmDeletePayment(payment);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePayment(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödemeyi Sil'),
        content: Text(
          '${payment.studentName} adlı öğrencinin ${payment.description} ödemesini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePayment(payment.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayment(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<PaymentProvider>(context, listen: false);
      await provider.deletePayment(id, notify: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ödeme başarıyla silindi')),
        );
      }
    } on Exception catch (e) {
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
        Text(
          _searchQuery.isNotEmpty || _statusFilter.isNotEmpty
              ? 'Arama kriterlerine uygun ödeme bulunamadı'
              : 'Henüz ödeme kaydı bulunmuyor',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: AppDimensions.spacing24),
        ElevatedButton.icon(
          onPressed: () async {
            if (_searchQuery.isNotEmpty || _statusFilter.isNotEmpty) {
              setState(() {
                _searchQuery = '';
                _statusFilter = '';
                _searchController.clear();
              });
            } else {
              await context.push('/add-payment');
              // Ödeme ekleme sayfasından döndükten sonra ödemeleri yeniden yükle
              if (mounted) {
                await _loadPayments();
              }
            }
          },
          icon: Icon(
            _searchQuery.isNotEmpty || _statusFilter.isNotEmpty
                ? Icons.clear_all
                : Icons.add,
          ),
          label: Text(
            _searchQuery.isNotEmpty || _statusFilter.isNotEmpty
                ? 'Filtreleri Temizle'
                : 'Ödeme Ekle',
          ),
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
