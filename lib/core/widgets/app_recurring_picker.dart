import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../utils/responsive_utils.dart';

/// Tekrar türleri
enum RecurringType { none, daily, weekly, biweekly, monthly, custom }

/// Ders tekrar bilgilerini içeren model
class RecurringInfo {
  final RecurringType type;
  final int? interval;
  final List<int>? weekdays; // 1: Pazartesi, 7: Pazar
  final int? dayOfMonth;
  final DateTime? endDate;
  final int? totalOccurrences;

  const RecurringInfo({
    required this.type,
    this.interval = 1,
    this.weekdays,
    this.dayOfMonth,
    this.endDate,
    this.totalOccurrences,
  });

  // İnsan tarafından okunabilir tanım
  String get description {
    switch (type) {
      case RecurringType.none:
        return 'Tekrarlanmaz';
      case RecurringType.daily:
        return interval == 1 ? 'Her gün' : 'Her $interval günde bir';
      case RecurringType.weekly:
        final days = weekdays ?? [];
        if (days.isEmpty) {
          return interval == 1 ? 'Her hafta' : 'Her $interval haftada bir';
        } else {
          final dayNames = days.map((d) => _getDayName(d)).join(', ');
          return interval == 1
              ? 'Her hafta: $dayNames'
              : 'Her $interval haftada bir: $dayNames';
        }
      case RecurringType.biweekly:
        return 'İki haftada bir';
      case RecurringType.monthly:
        if (dayOfMonth != null) {
          return interval == 1
              ? 'Her ay: $dayOfMonth. gün'
              : 'Her $interval ayda bir: $dayOfMonth. gün';
        }
        return interval == 1 ? 'Her ay' : 'Her $interval ayda bir';
      case RecurringType.custom:
        return 'Özel tekrar';
    }
  }

  // Gün adını döndürür
  String _getDayName(int day) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[day - 1];
  }
}

/// Ders tekrar seçimi için özel widget.
class AppRecurringPicker extends StatefulWidget {
  final RecurringInfo? initialValue;
  final ValueChanged<RecurringInfo>? onChanged;
  final String? label;
  final bool enabled;
  final bool required;

  const AppRecurringPicker({
    super.key,
    this.initialValue,
    this.onChanged,
    this.label,
    this.enabled = true,
    this.required = false,
  });

  @override
  State<AppRecurringPicker> createState() => _AppRecurringPickerState();
}

class _AppRecurringPickerState extends State<AppRecurringPicker> {
  late RecurringInfo _recurringInfo;

  @override
  void initState() {
    super.initState();
    _recurringInfo =
        widget.initialValue ?? const RecurringInfo(type: RecurringType.none);
  }

  @override
  Widget build(BuildContext context) {
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
        InkWell(
          onTap: widget.enabled ? _showRecurringDialog : null,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.repeat, size: 20),
              suffixIcon: widget.enabled
                  ? const Icon(Icons.arrow_drop_down, size: 20)
                  : null,
              filled: true,
              fillColor: widget.enabled
                  ? AppColors.surface
                  : AppColors.disabledBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing8,
              ),
            ),
            child: Text(
              _recurringInfo.description,
              style: TextStyle(
                color: widget.enabled
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRecurringDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tekrar Seçimi'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tekrar türü seçimi
                      const Text('Tekrar türü:'),
                      const SizedBox(height: AppDimensions.spacing8),
                      _buildRecurringTypeDropdown(setState),
                      const SizedBox(height: AppDimensions.spacing16),

                      // Günlük/haftalık/aylık tekrar için aralık seçimi
                      if (_recurringInfo.type != RecurringType.none &&
                          _recurringInfo.type != RecurringType.biweekly) ...[
                        _buildIntervalSelector(setState),
                        const SizedBox(height: AppDimensions.spacing16),
                      ],

                      // Haftalık tekrar için gün seçimi
                      if (_recurringInfo.type == RecurringType.weekly ||
                          _recurringInfo.type == RecurringType.biweekly) ...[
                        _buildWeekdaysSelector(setState),
                        const SizedBox(height: AppDimensions.spacing16),
                      ],

                      // Aylık tekrar için gün seçimi
                      if (_recurringInfo.type == RecurringType.monthly) ...[
                        _buildMonthDaySelector(setState),
                        const SizedBox(height: AppDimensions.spacing16),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onChanged?.call(_recurringInfo);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecurringTypeDropdown(StateSetter setState) {
    return DropdownButtonFormField<RecurringType>(
      value: _recurringInfo.type,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: RecurringType.none,
          child: Text('Tekrarlanmaz'),
        ),
        const DropdownMenuItem(
          value: RecurringType.daily,
          child: Text('Günlük'),
        ),
        const DropdownMenuItem(
          value: RecurringType.weekly,
          child: Text('Haftalık'),
        ),
        const DropdownMenuItem(
          value: RecurringType.biweekly,
          child: Text('İki haftada bir'),
        ),
        const DropdownMenuItem(
          value: RecurringType.monthly,
          child: Text('Aylık'),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          if (value == RecurringType.biweekly) {
            _recurringInfo = RecurringInfo(
              type: value,
              interval: 2,
              weekdays: _recurringInfo.weekdays,
            );
          } else {
            _recurringInfo = RecurringInfo(
              type: value,
              interval: _recurringInfo.interval,
              weekdays:
                  value == RecurringType.weekly ||
                      value == RecurringType.biweekly
                  ? _recurringInfo.weekdays ?? [DateTime.now().weekday]
                  : null,
              dayOfMonth: value == RecurringType.monthly
                  ? _recurringInfo.dayOfMonth ?? DateTime.now().day
                  : null,
            );
          }
        });
      },
    );
  }

  Widget _buildIntervalSelector(StateSetter setState) {
    return Row(
      children: [
        const Text('Her'),
        const SizedBox(width: AppDimensions.spacing8),
        SizedBox(
          width: 60,
          child: TextFormField(
            initialValue: _recurringInfo.interval.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
                vertical: AppDimensions.spacing4,
              ),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final interval = int.tryParse(value);
              if (interval != null && interval > 0) {
                setState(() {
                  _recurringInfo = RecurringInfo(
                    type: _recurringInfo.type,
                    interval: interval,
                    weekdays: _recurringInfo.weekdays,
                    dayOfMonth: _recurringInfo.dayOfMonth,
                    endDate: _recurringInfo.endDate,
                    totalOccurrences: _recurringInfo.totalOccurrences,
                  );
                });
              }
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Text(_getIntervalSuffix()),
      ],
    );
  }

  String _getIntervalSuffix() {
    switch (_recurringInfo.type) {
      case RecurringType.daily:
        return 'günde bir';
      case RecurringType.weekly:
        return 'haftada bir';
      case RecurringType.monthly:
        return 'ayda bir';
      default:
        return '';
    }
  }

  Widget _buildWeekdaysSelector(StateSetter setState) {
    final weekdays = _recurringInfo.weekdays ?? [DateTime.now().weekday];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tekrar günleri:'),
        const SizedBox(height: AppDimensions.spacing8),
        Wrap(
          spacing: AppDimensions.spacing8,
          children: List.generate(7, (index) {
            final day = index + 1; // 1: Pazartesi, 7: Pazar
            final isSelected = weekdays.contains(day);
            final dayName = _getDayName(day);

            return FilterChip(
              label: Text(dayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newWeekdays = List<int>.from(weekdays);
                  if (selected) {
                    if (!newWeekdays.contains(day)) {
                      newWeekdays.add(day);
                    }
                  } else {
                    newWeekdays.remove(day);
                  }
                  _recurringInfo = RecurringInfo(
                    type: _recurringInfo.type,
                    interval: _recurringInfo.interval,
                    weekdays: newWeekdays,
                    dayOfMonth: _recurringInfo.dayOfMonth,
                    endDate: _recurringInfo.endDate,
                    totalOccurrences: _recurringInfo.totalOccurrences,
                  );
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthDaySelector(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ayın günü:'),
        const SizedBox(height: AppDimensions.spacing8),
        SizedBox(
          width: 60,
          child: TextFormField(
            initialValue: (_recurringInfo.dayOfMonth ?? DateTime.now().day)
                .toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing8,
                vertical: AppDimensions.spacing4,
              ),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final day = int.tryParse(value);
              if (day != null && day > 0 && day <= 31) {
                setState(() {
                  _recurringInfo = RecurringInfo(
                    type: _recurringInfo.type,
                    interval: _recurringInfo.interval,
                    weekdays: _recurringInfo.weekdays,
                    dayOfMonth: day,
                    endDate: _recurringInfo.endDate,
                    totalOccurrences: _recurringInfo.totalOccurrences,
                  );
                });
              }
            },
          ),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    const dayAbbreviations = ['Pt', 'Sa', 'Çr', 'Pr', 'Cu', 'Ct', 'Pz'];
    return dayAbbreviations[day - 1];
  }
}
