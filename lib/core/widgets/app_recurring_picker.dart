import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import '../utils/responsive_utils.dart';
import 'package:ders_planlayici/features/lessons/domain/models/recurring_pattern_model.dart'
    as db;

/// Tekrar türleri
enum RecurringType { none, daily, weekly, biweekly, monthly, custom }

/// Ders tekrar bilgilerini içeren model
class RecurringInfo {
  const RecurringInfo({
    required this.type,
    this.interval = 1,
    this.weekdays,
    this.dayOfMonth,
    this.endDate,
    this.totalOccurrences,
  });

  factory RecurringInfo.fromPattern(db.RecurringPattern pattern) {
    RecurringType type;
    if (pattern.type == db.RecurringType.weekly) {
      if (pattern.interval == 2) {
        type = RecurringType.biweekly;
      } else {
        type = RecurringType.weekly;
      }
    } else {
      type = RecurringType.monthly;
    }

    return RecurringInfo(
      type: type,
      interval: pattern.interval,
      weekdays: pattern.daysOfWeek,
      dayOfMonth: pattern.dayOfMonth,
      endDate: pattern.endDate != null
          ? DateTime.parse(pattern.endDate!)
          : null,
    );
  }

  final RecurringType type;
  final int? interval;
  final List<int>? weekdays; // 1: Pazartesi, 7: Pazar
  final int? dayOfMonth;
  final DateTime? endDate;
  final int? totalOccurrences;

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
          final dayNames = days.map(_getDayName).join(', ');
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
  const AppRecurringPicker({
    super.key,
    this.initialValue,
    this.onChanged,
    this.label,
    this.enabled = true,
    this.required = false,
  });
  final RecurringInfo? initialValue;
  final ValueChanged<RecurringInfo>? onChanged;
  final String? label;
  final bool enabled;
  final bool required;

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
    final theme = Theme.of(context);
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
        InkWell(
          onTap: widget.enabled ? _showRecurringDialog : null,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.repeat,
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
              border: null, // Tema border'ını kullan
              enabledBorder: null,
              focusedBorder: null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing8,
              ),
            ),
            child: Text(
              _recurringInfo.description,
              style: TextStyle(
                color: widget.enabled
                    ? theme.textTheme.bodyLarge?.color
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRecurringDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Tekrar Seçimi', style: theme.textTheme.titleLarge),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tekrar türü seçimi
                  Text('Tekrar türü:', style: theme.textTheme.titleSmall),
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
                    _buildDayOfMonthSelector(setState),
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
        ),
      ),
    );
  }

  Widget _buildRecurringTypeDropdown(
    StateSetter setState,
  ) => DropdownButtonFormField<RecurringType>(
    value: _recurringInfo.type,
    decoration: const InputDecoration(
      filled: true,
      fillColor: null, // Tema rengini kullan
      border: null, // Tema border'ını kullan
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing8,
      ),
    ),
    items: const [
      DropdownMenuItem(value: RecurringType.none, child: Text('Tekrarlanmaz')),
      DropdownMenuItem(value: RecurringType.daily, child: Text('Günlük')),
      DropdownMenuItem(value: RecurringType.weekly, child: Text('Haftalık')),
      DropdownMenuItem(
        value: RecurringType.biweekly,
        child: Text('İki Haftalık'),
      ),
      DropdownMenuItem(value: RecurringType.monthly, child: Text('Aylık')),
    ],
    onChanged: (value) {
      if (value != null) {
        setState(() {
          _recurringInfo = RecurringInfo(type: value);
        });
      }
    },
  );

  Widget _buildIntervalSelector(StateSetter setState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Aralık:', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: AppDimensions.spacing8),
      DropdownButtonFormField<int>(
        value: _recurringInfo.interval,
        decoration: const InputDecoration(
          filled: true,
          fillColor: null, // Tema rengini kullan
          border: null, // Tema border'ını kullan
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
        ),
        items: List.generate(12, (index) => index + 1)
            .map(
              (value) => DropdownMenuItem(value: value, child: Text('$value')),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _recurringInfo = RecurringInfo(
                type: _recurringInfo.type,
                interval: value,
                weekdays: _recurringInfo.weekdays,
                dayOfMonth: _recurringInfo.dayOfMonth,
              );
            });
          }
        },
      ),
    ],
  );

  Widget _buildWeekdaysSelector(StateSetter setState) {
    final theme = Theme.of(context);
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Günler:', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spacing8),
        Wrap(
          spacing: AppDimensions.spacing8,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected =
                _recurringInfo.weekdays?.contains(dayNumber) ?? false;

            return FilterChip(
              label: Text(days[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final currentWeekdays = List<int>.from(
                    _recurringInfo.weekdays ?? [],
                  );
                  if (selected) {
                    currentWeekdays.add(dayNumber);
                  } else {
                    currentWeekdays.remove(dayNumber);
                  }
                  _recurringInfo = RecurringInfo(
                    type: _recurringInfo.type,
                    interval: _recurringInfo.interval,
                    weekdays: currentWeekdays,
                    dayOfMonth: _recurringInfo.dayOfMonth,
                  );
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDayOfMonthSelector(StateSetter setState) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Ayın günü:', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: AppDimensions.spacing8),
      DropdownButtonFormField<int>(
        value: _recurringInfo.dayOfMonth ?? 1,
        decoration: const InputDecoration(
          filled: true,
          fillColor: null, // Tema rengini kullan
          border: null, // Tema border'ını kullan
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing8,
          ),
        ),
        items: List.generate(31, (index) => index + 1)
            .map(
              (value) => DropdownMenuItem(value: value, child: Text('$value')),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _recurringInfo = RecurringInfo(
                type: _recurringInfo.type,
                interval: _recurringInfo.interval,
                weekdays: _recurringInfo.weekdays,
                dayOfMonth: value,
              );
            });
          }
        },
      ),
    ],
  );
}
