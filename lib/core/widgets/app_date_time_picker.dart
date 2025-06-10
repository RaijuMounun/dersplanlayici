import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../utils/responsive_utils.dart';

/// Tarih ve saat seçimi için özel widget.
/// Tek bir bileşende hem tarih hem de saat seçimini birleştirir.
class AppDateTimePicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateTimeChanged;
  final String? label;
  final String? dateHint;
  final String? timeHint;
  final bool showBorder;
  final bool enabled;
  final bool required;

  const AppDateTimePicker({
    super.key,
    this.initialDateTime,
    this.firstDate,
    this.lastDate,
    this.onDateTimeChanged,
    this.label,
    this.dateHint,
    this.timeHint,
    this.showBorder = true,
    this.enabled = true,
    this.required = false,
  });

  @override
  State<AppDateTimePicker> createState() => _AppDateTimePickerState();
}

class _AppDateTimePickerState extends State<AppDateTimePicker> {
  late DateTime _selectedDateTime;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime ?? DateTime.now();
    _dateController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(_selectedDateTime),
    );
    _timeController = TextEditingController(
      text: DateFormat('HH:mm').format(_selectedDateTime),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutuna göre farklı layout kullan
    bool isCompactMode = MediaQuery.of(context).size.width < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (widget.required)
                Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
        ],
        if (isCompactMode)
          // Dar ekran için dikey layout
          Column(
            children: [
              _buildDatePicker(context),
              const SizedBox(height: AppDimensions.spacing8),
              _buildTimePicker(context),
            ],
          )
        else
          // Geniş ekran için yatay layout
          Row(
            children: [
              Expanded(flex: 3, child: _buildDatePicker(context)),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(flex: 2, child: _buildTimePicker(context)),
            ],
          ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? _showDatePicker : null,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.dateHint ?? 'Tarih seçin',
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          suffixIcon: widget.enabled
              ? const Icon(Icons.arrow_drop_down, size: 20)
              : null,
          filled: true,
          fillColor: widget.enabled
              ? AppColors.surface
              : AppColors.disabledBackground,
          border: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  borderSide: BorderSide(color: AppColors.border),
                )
              : InputBorder.none,
          enabledBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  borderSide: BorderSide(color: AppColors.border),
                )
              : InputBorder.none,
          focusedBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                )
              : InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
        ),
        child: Text(
          _dateController.text,
          style: TextStyle(
            color: widget.enabled
                ? Theme.of(context).textTheme.bodyLarge?.color
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? _showTimePicker : null,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.timeHint ?? 'Saat seçin',
          prefixIcon: const Icon(Icons.access_time, size: 20),
          suffixIcon: widget.enabled
              ? const Icon(Icons.arrow_drop_down, size: 20)
              : null,
          filled: true,
          fillColor: widget.enabled
              ? AppColors.surface
              : AppColors.disabledBackground,
          border: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  borderSide: BorderSide(color: AppColors.border),
                )
              : InputBorder.none,
          enabledBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  borderSide: BorderSide(color: AppColors.border),
                )
              : InputBorder.none,
          focusedBorder: widget.showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radius8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                )
              : InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
        ),
        child: Text(
          _timeController.text,
          style: TextStyle(
            color: widget.enabled
                ? Theme.of(context).textTheme.bodyLarge?.color
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime firstDate =
        widget.firstDate ?? DateTime.now().subtract(const Duration(days: 365));
    final DateTime lastDate =
        widget.lastDate ?? DateTime.now().add(const Duration(days: 365 * 5));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
        _dateController.text = DateFormat(
          'dd.MM.yyyy',
        ).format(_selectedDateTime);
      });
      widget.onDateTimeChanged?.call(_selectedDateTime);
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _timeController.text = DateFormat('HH:mm').format(_selectedDateTime);
      });
      widget.onDateTimeChanged?.call(_selectedDateTime);
    }
  }
}
