import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_dimensions.dart';
import '../utils/responsive_utils.dart';

/// Tarih ve saat seçimi için özel widget.
/// Tek bir bileşende hem tarih hem de saat seçimini birleştirir.
class AppDateTimePicker extends StatefulWidget {
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
    final theme = Theme.of(context);
    // Ekran boyutuna göre farklı layout kullan
    final bool isCompactMode = MediaQuery.of(context).size.width < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(widget.label!, style: theme.textTheme.titleSmall),
              if (widget.required)
                Text(
                  ' *',
                  style: TextStyle(
                    color: theme.colorScheme.error,
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
    final theme = Theme.of(context);
    return InkWell(
      onTap: widget.enabled ? _showDatePicker : null,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.dateHint ?? 'Tarih seçin',
          prefixIcon: Icon(
            Icons.calendar_today,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          suffixIcon: widget.enabled
              ? Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                )
              : null,
          filled: true,
          fillColor: widget.enabled
              ? null
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          border: widget.showBorder ? null : InputBorder.none,
          enabledBorder: widget.showBorder ? null : InputBorder.none,
          focusedBorder: widget.showBorder ? null : InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
        ),
        child: Text(
          _dateController.text,
          style: TextStyle(
            color: widget.enabled
                ? theme.textTheme.bodyLarge?.color
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: widget.enabled ? _showTimePicker : null,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: widget.timeHint ?? 'Saat seçin',
          prefixIcon: Icon(
            Icons.access_time,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          suffixIcon: widget.enabled
              ? Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                )
              : null,
          filled: true,
          fillColor: widget.enabled
              ? null
              : theme.colorScheme.surface.withValues(alpha: 0.5),
          border: widget.showBorder ? null : InputBorder.none,
          enabledBorder: widget.showBorder ? null : InputBorder.none,
          focusedBorder: widget.showBorder ? null : InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
        ),
        child: Text(
          _timeController.text,
          style: TextStyle(
            color: widget.enabled
                ? theme.textTheme.bodyLarge?.color
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: widget.firstDate ?? DateTime(2020),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        ),
    );

    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        ),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
        _timeController.text = DateFormat('HH:mm').format(_selectedDateTime);
      });
      widget.onDateTimeChanged?.call(_selectedDateTime);
    }
  }
}
