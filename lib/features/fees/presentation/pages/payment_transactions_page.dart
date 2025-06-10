import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_transaction_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_transaction_provider.dart';

class PaymentTransactionsPage extends StatefulWidget {
  final String paymentId;

  const PaymentTransactionsPage({super.key, required this.paymentId});

  @override
  State<PaymentTransactionsPage> createState() =>
      _PaymentTransactionsPageState();
}

class _PaymentTransactionsPageState extends State<PaymentTransactionsPage> {
  bool _isLoading = true;
  Payment? _payment;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Store context in a local variable
      final localContext = context;
      
      // Ödeme bilgilerini yükle
      final paymentProvider = Provider.of<PaymentProvider>(
        localContext,
        listen: false,
      );
      _payment = paymentProvider.getPaymentById(widget.paymentId);

      // İşlemleri yükle
      await Provider.of<PaymentTransactionProvider>(
        localContext,
        listen: false,
      ).loadTransactionsByPaymentId(widget.paymentId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler yüklenirken hata oluştu: $e'),
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
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<PaymentTransactionProvider>(
      context,
    );
    final transactions = transactionProvider.transactions;
    final isLoading = transactionProvider.isLoading || _isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme İşlemleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payment == null
          ? const Center(child: Text('Ödeme bulunamadı'))
          : Column(
              children: [
                _buildPaymentInfoCard(),
                const SizedBox(height: AppDimensions.spacing16),
                _buildTransactionsSummary(transactions),
                const SizedBox(height: AppDimensions.spacing8),
                Expanded(
                  child: transactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionsList(transactions),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaction(),
        tooltip: 'Ödeme İşlemi Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return Card(
      margin: const EdgeInsets.all(AppDimensions.spacing16),
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
                    color: _getStatusColor(_payment!.status).withAlpha(40),
                    borderRadius: BorderRadius.circular(AppDimensions.radius4),
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
            const SizedBox(height: AppDimensions.spacing12),
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
                  ? (_payment!.paidAmount / _payment!.amount).clamp(0.0, 1.0)
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
    );
  }

  Widget _buildTransactionsSummary(List<PaymentTransaction> transactions) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    final remaining = _payment!.amount - _payment!.paidAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'İşlem Özeti',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Toplam İşlem'),
                      Text(
                        transactions.length.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Kalan Tutar'),
                      Text(
                        currencyFormatter.format(remaining),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: remaining > 0
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<PaymentTransaction> transactions) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final formattedDate = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime.parse(transaction.date));

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
          child: InkWell(
            onTap: () => _editTransaction(transaction.id),
            borderRadius: BorderRadius.circular(AppDimensions.radius8),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _getPaymentMethodIcon(transaction.method),
                          const SizedBox(width: AppDimensions.spacing8),
                          Text(
                            _getPaymentMethodText(transaction.method),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        currencyFormatter.format(transaction.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Text(
                        formattedDate,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      if (transaction.receiptNo != null &&
                          transaction.receiptNo!.isNotEmpty) ...[
                        const SizedBox(width: AppDimensions.spacing8),
                        Icon(
                          Icons.receipt,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.spacing4),
                        Text(
                          'Makbuz: ${transaction.receiptNo}',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  if (transaction.notes != null &&
                      transaction.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      transaction.notes!,
                      style: TextStyle(
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
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: AppColors.textSecondary.withAlpha(128),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          const Text(
            'Henüz ödeme işlemi kaydedilmemiş',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          const Text(
            'Sağ alttaki + butonuna tıklayarak ödeme işlemi ekleyebilirsiniz.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction() async {
    final result = await context.push<bool>(
      '/payment-transaction/${widget.paymentId}',
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _editTransaction(String transactionId) async {
    final result = await context.push<bool>(
      '/payment-transaction/${widget.paymentId}/$transactionId',
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Widget _getPaymentMethodIcon(PaymentMethod method) {
    IconData icon;
    Color color;

    switch (method) {
      case PaymentMethod.cash:
        icon = Icons.money;
        color = Colors.green;
        break;
      case PaymentMethod.creditCard:
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      case PaymentMethod.bankTransfer:
        icon = Icons.account_balance;
        color = Colors.indigo;
        break;
      case PaymentMethod.other:
        icon = Icons.more_horiz;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color);
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
}
