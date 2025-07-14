import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/loading_indicator.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_model.dart';
import 'package:ders_planlayici/features/fees/domain/models/payment_transaction_model.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_transaction_provider.dart';

class PaymentTransactionPage extends StatefulWidget {
  const PaymentTransactionPage({
    super.key,
    required this.paymentId,
    this.transactionId,
  });
  final String paymentId;
  final String? transactionId;

  @override
  State<PaymentTransactionPage> createState() => _PaymentTransactionPageState();
}

class _PaymentTransactionPageState extends State<PaymentTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _receiptNoController = TextEditingController();

  bool _isLoading = false;
  bool _isEdit = false;
  DateTime _selectedDate = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  PaymentModel? _payment;
  PaymentTransactionModel? _transaction;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.transactionId != null;
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _receiptNoController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ödeme bilgilerini yükle
      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );
      _payment = paymentProvider.getPaymentById(widget.paymentId);

      if (_isEdit && widget.transactionId != null) {
        // İşlem detaylarını yükle
        final transactionProvider = Provider.of<PaymentTransactionProvider>(
          context,
          listen: false,
        );
        await transactionProvider.loadTransactionsByPaymentId(widget.paymentId);

        _transaction = transactionProvider.transactions.firstWhere(
          (transaction) => transaction.id == widget.transactionId,
          orElse: () => throw Exception('İşlem bulunamadı'),
        );

        // Form alanlarını doldur
        _amountController.text = _transaction!.amount.toString();
        _selectedDate = DateTime.parse(_transaction!.date);
        _paymentMethod = _transaction!.method;
        _notesController.text = _transaction!.notes ?? '';
        _receiptNoController.text = _transaction!.receiptNo ?? '';
      } else if (_payment != null) {
        // Yeni işlem oluşturma - kalan miktarı öner
        final remainingAmount = _payment!.amount - _payment!.paidAmount;
        if (remainingAmount > 0) {
          _amountController.text = remainingAmount.toString();
        }
      }
    } on Exception catch (e) {
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

  Future<void> _selectDate(BuildContext context) async {
    // Store context in a local variable
    final localContext = context;
    final DateTime? picked = await showDatePicker(
      context: localContext,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen geçerli bir tutar girin'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final notes = _notesController.text.trim();
    final receiptNo = _receiptNoController.text.trim();

    try {
      // Store context in a local variable
      if (!mounted) return;
      final localContext = context;
      // Provider'ları önceden al
      final transactionProvider = Provider.of<PaymentTransactionProvider>(
        localContext,
        listen: false,
      );
      final paymentProvider = Provider.of<PaymentProvider>(
        localContext,
        listen: false,
      );

      await LoadingIndicator.wrapWithLoading(
        context: localContext,
        message: _isEdit ? 'İşlem güncelleniyor...' : 'İşlem kaydediliyor...',
        future: Future(() async {
          if (_isEdit && _transaction != null) {
            // İşlemi güncelle
            final updatedTransaction = _transaction!.copyWith(
              amount: amount,
              method: _paymentMethod,
              date: date,
              notes: notes.isNotEmpty ? notes : null,
              receiptNo: receiptNo.isNotEmpty ? receiptNo : null,
            );
            await transactionProvider.updateTransaction(updatedTransaction);
          } else {
            // Yeni işlem ekle
            final newTransaction = PaymentTransactionModel(
              paymentId: widget.paymentId,
              amount: amount,
              method: _paymentMethod,
              date: date,
              notes: notes.isNotEmpty ? notes : null,
              receiptNo: receiptNo.isNotEmpty ? receiptNo : null,
            );
            await transactionProvider.addTransaction(newTransaction);
          }

          // Ödeme bilgilerini yenile
          await paymentProvider.loadPayments();
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'İşlem güncellendi' : 'İşlem kaydedildi'),
            backgroundColor: AppColors.success,
          ),
        );
        if (mounted) {
          context.pop(true); // Başarı sonucu döndür
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_isEdit ? 'Ödeme İşlemini Düzenle' : 'Ödeme İşlemi Ekle'),
    ),
    body: _isLoading
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
          if (_payment != null) _buildPaymentInfoCard(),
          const SizedBox(height: AppDimensions.spacing24),
          _buildDateField(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildAmountField(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildPaymentMethodDropdown(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildReceiptNoField(),
          const SizedBox(height: AppDimensions.spacing16),
          _buildNotesField(),
          const SizedBox(height: AppDimensions.spacing24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isEdit ? 'İşlemi Güncelle' : 'İşlemi Kaydet',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (_isEdit) ...[
            const SizedBox(height: AppDimensions.spacing16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _confirmDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('İşlemi Sil', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildPaymentInfoCard() {
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
                    const Text('Kalan Tutar'),
                    Text(
                      currencyFormatter.format(
                        _payment!.amount - _payment!.paidAmount,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _payment!.paidAmount < _payment!.amount
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
    );
  }

  Widget _buildDateField() {
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ödeme Tarihi',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(formattedDate),
      ),
    );
  }

  Widget _buildAmountField() => TextFormField(
    controller: _amountController,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
    ],
    decoration: const InputDecoration(
      labelText: 'Ödeme Tutarı',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.attach_money),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Lütfen bir tutar girin';
      }
      final amount = double.tryParse(value);
      if (amount == null || amount <= 0) {
        return 'Geçerli bir tutar girin';
      }
      return null;
    },
  );

  Widget _buildPaymentMethodDropdown() =>
      DropdownButtonFormField<PaymentMethod>(
        value: _paymentMethod,
        decoration: const InputDecoration(
          labelText: 'Ödeme Yöntemi',
          border: OutlineInputBorder(),
        ),
        items: PaymentMethod.values.map((method) {
          String label;
          IconData icon;
          switch (method) {
            case PaymentMethod.cash:
              label = 'Nakit';
              icon = Icons.money;
              break;
            case PaymentMethod.creditCard:
              label = 'Kredi Kartı';
              icon = Icons.credit_card;
              break;
            case PaymentMethod.bankTransfer:
              label = 'Banka Havalesi';
              icon = Icons.account_balance;
              break;
            case PaymentMethod.other:
              label = 'Diğer';
              icon = Icons.more_horiz;
              break;
          }
          return DropdownMenuItem<PaymentMethod>(
            value: method,
            child: Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _paymentMethod = value;
            });
          }
        },
      );

  Widget _buildReceiptNoField() => TextFormField(
    controller: _receiptNoController,
    decoration: const InputDecoration(
      labelText: 'Makbuz/Dekont No',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.receipt),
    ),
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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme İşlemini Sil'),
        content: const Text(
          'Bu ödeme işlemini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    if (widget.transactionId == null) return;

    try {
      if (!mounted) return;
      // Store context in a local variable
      final localContext = context;
      // Provider'ları önceden al
      final transactionProvider = Provider.of<PaymentTransactionProvider>(
        localContext,
        listen: false,
      );
      final paymentProvider = Provider.of<PaymentProvider>(
        localContext,
        listen: false,
      );

      await LoadingIndicator.wrapWithLoading(
        context: localContext,
        message: 'İşlem siliniyor...',
        future: Future(() async {
          await transactionProvider.deleteTransaction(
            widget.transactionId!,
            widget.paymentId,
          );

          // Ödeme bilgilerini yenile
          await paymentProvider.loadPayments();
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İşlem silindi'),
            backgroundColor: AppColors.success,
          ),
        );
        if (mounted) {
          context.pop(true);
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
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
}
