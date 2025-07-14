import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/loading_indicator.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/core/navigation/route_names.dart';

class EditPaymentPage extends StatefulWidget {
  const EditPaymentPage({super.key, required this.id});
  final String id;

  @override
  State<EditPaymentPage> createState() => _EditPaymentPageState();
}

class _EditPaymentPageState extends State<EditPaymentPage> {
  bool _isLoading = true;
  PaymentModel? _payment;

  @override
  void initState() {
    super.initState();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );
      _payment = paymentProvider.getPaymentById(widget.id);

      if (_payment == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ödeme bulunamadı'),
              backgroundColor: AppColors.error,
            ),
          );
          context.pop();
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme yüklenirken hata oluştu: $e'),
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_isEditMode ? 'Ödemeyi Düzenle' : 'Yeni Ödeme'),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Düzenle',
          onPressed: () {
            // Ödeme düzenleme sayfasına git
            context.pushNamed(
              RouteNames.addPayment,
              queryParameters: {'id': widget.id},
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.payment),
          tooltip: 'Ödeme İşlemleri',
          onPressed: () {
            // Ödeme işlemleri sayfasına git
            context.pushNamed(
              RouteNames.paymentTransactions,
              pathParameters: {'id': widget.id},
            );
          },
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _payment == null
        ? const Center(child: Text('Ödeme bulunamadı'))
        : _buildPaymentDetails(),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Yeni ödeme işlemi ekle
        context.pushNamed(
          RouteNames.addPaymentTransaction,
          pathParameters: {'id': widget.id},
        );
      },
      tooltip: 'Ödeme İşlemi Ekle',
      child: const Icon(Icons.add),
    ),
    persistentFooterButtons: [
      Center(
        child: TextButton.icon(
          onPressed: () {
            context.pushNamed(
              RouteNames.paymentTransactions,
              pathParameters: {'id': widget.id},
            );
          },
          icon: const Icon(Icons.history),
          label: const Text('Tüm İşlem Geçmişini Görüntüle'),
        ),
      ),
    ],
  );

  Widget _buildPaymentDetails() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    final formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(_payment!.date));

    String? formattedDueDate;
    if (_payment!.dueDate != null) {
      formattedDueDate = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(_payment!.dueDate!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
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
                              _payment!.studentName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(_payment!.description),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            _payment!.status,
                          ).withAlpha(40),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius4,
                          ),
                        ),
                        child: Text(
                          _getStatusText(_payment!.status),
                          style: TextStyle(
                            color: _getStatusColor(_payment!.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Toplam Tutar'),
                          Text(
                            currencyFormatter.format(_payment!.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Ödenen Tutar'),
                          Text(
                            currencyFormatter.format(_payment!.paidAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _payment!.paidAmount >= _payment!.amount
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  LinearProgressIndicator(
                    value: _payment!.amount > 0
                        ? (_payment!.paidAmount / _payment!.amount).clamp(
                            0.0,
                            1.0,
                          )
                        : 0,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _payment!.paidAmount >= _payment!.amount
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ödeme Bilgileri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  _buildInfoRow('Ödeme Tarihi', formattedDate),
                  if (formattedDueDate != null)
                    _buildInfoRow('Son Ödeme Tarihi', formattedDueDate),
                  if (_payment!.method != null)
                    _buildInfoRow(
                      'Ödeme Yöntemi',
                      _getPaymentMethodText(_payment!.method!),
                    ),
                  _buildInfoRow(
                    'Kalan Tutar',
                    currencyFormatter.format(
                      _payment!.amount - _payment!.paidAmount,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_payment!.notes != null && _payment!.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notlar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(_payment!.notes!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacing16),
          Card(
            child: InkWell(
              onTap: () {
                if (mounted) {
                  context.pushNamed(
                    RouteNames.paymentTransactions,
                    pathParameters: {'id': widget.id},
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(AppDimensions.spacing16),
                child: Row(
                  children: [
                    Icon(Icons.payment, size: 24),
                    SizedBox(width: AppDimensions.spacing16),
                    Expanded(
                      child: Text(
                        'Ödeme İşlemlerini Görüntüle',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  void _confirmDelete() {
    // Store context in a local variable to avoid using across async gaps
    final dialogContext = context;
    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Ödemeyi Sil'),
        content: const Text(
          'Bu ödemeyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePayment();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayment() async {
    try {
      if (!mounted) return;
      // Store context in a local variable
      final localContext = context;
      // Provider'ı önceden al
      final provider = Provider.of<PaymentProvider>(
        localContext,
        listen: false,
      );

      await LoadingIndicator.wrapWithLoading(
        context: localContext,
        message: 'Ödeme siliniyor...',
        future: Future(() async {
          await provider.deletePayment(widget.id);
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeme silindi'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme silinirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
      case PaymentMethod.bankTransfer:
        return 'Banka Havalesi';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }
}
