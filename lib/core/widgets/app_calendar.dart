import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Uygulamada kullanılan basit takvim widget'ı.
class AppCalendar extends StatelessWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final Map<DateTime, List<dynamic>>? events;
  final bool showWeekends;
  final Widget Function(DateTime date, List<dynamic> events)? eventBuilder;
  final Color? selectedDateColor;
  final Color? todayColor;
  final Color? eventIndicatorColor;

  const AppCalendar({
    super.key,
    required this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.events,
    this.showWeekends = true,
    this.eventBuilder,
    this.selectedDateColor,
    this.todayColor,
    this.eventIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = selectedDateColor ?? AppColors.primary;
    final today = todayColor ?? AppColors.accent;
    final eventColor = eventIndicatorColor ?? AppColors.secondary;

    // Ay adını al
    final month = _getMonthName(initialDate.month);

    return Column(
      children: [
        // Ay ve yıl başlığı
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$month ${initialDate.year}',
                style: theme.textTheme.titleLarge,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () =>
                        _onMonthChange(initialDate.month - 1, initialDate.year),
                    tooltip: 'Önceki ay',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () =>
                        _onMonthChange(initialDate.month + 1, initialDate.year),
                    tooltip: 'Sonraki ay',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Hafta günleri başlığı
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildWeekdayLabels(context),
          ),
        ),

        // Takvim günleri
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount:
                _getDaysInMonth(initialDate.year, initialDate.month) +
                _getFirstDayOffset(initialDate.year, initialDate.month),
            itemBuilder: (context, index) {
              return _buildDayCell(
                context,
                index,
                selectedColor,
                today,
                eventColor,
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWeekdayLabels(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return List.generate(7, (index) {
      final isWeekend = index >= 5; // Cumartesi ve Pazar

      return SizedBox(
        width: AppDimensions.calendarDaySize,
        height: AppDimensions.calendarDaySize,
        child: Center(
          child: Text(
            weekdays[index],
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isWeekend ? AppColors.textSecondary : null,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDayCell(
    BuildContext context,
    int index,
    Color selectedColor,
    Color todayColor,
    Color eventColor,
  ) {
    final theme = Theme.of(context);
    final monthStartOffset = _getFirstDayOffset(
      initialDate.year,
      initialDate.month,
    );

    // Önceki ayın günleri için boş hücre
    if (index < monthStartOffset) {
      return const SizedBox();
    }

    final dayNumber = index - monthStartOffset + 1;
    if (dayNumber > _getDaysInMonth(initialDate.year, initialDate.month)) {
      return const SizedBox();
    }

    final currentDate = DateTime(
      initialDate.year,
      initialDate.month,
      dayNumber,
    );
    final isToday = _isToday(currentDate);
    final isSelected = _isSameDay(currentDate, initialDate);
    final isWeekend =
        currentDate.weekday == DateTime.saturday ||
        currentDate.weekday == DateTime.sunday;

    // Eğer hafta sonları gösterilmeyecekse ve bu gün hafta sonuysa
    if (!showWeekends && isWeekend) {
      return const SizedBox();
    }

    // Bu tarihe ait etkinlikler var mı?
    final dateEvents = events != null && events!.containsKey(currentDate)
        ? events![currentDate]
        : [];
    final hasEvents = dateEvents != null && dateEvents.isNotEmpty;

    return InkWell(
      onTap: () => onDateSelected?.call(currentDate),
      borderRadius: BorderRadius.circular(AppDimensions.radius8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withAlpha(50) : null,
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          border: isToday ? Border.all(color: todayColor, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected || isToday ? FontWeight.bold : null,
                color: isWeekend ? AppColors.textSecondary : null,
              ),
            ),
            if (hasEvents) ...[
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: eventColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Yardımcı metodlar
  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstDayOffset(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    // Pazartesi: 0, Salı: 1, ..., Pazar: 6
    int weekday = firstDayOfMonth.weekday - 1;
    if (weekday < 0) weekday = 6; // Pazar gününü 6 yapalım
    return weekday;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onMonthChange(int month, int year) {
    if (month < 1) {
      month = 12;
      year--;
    } else if (month > 12) {
      month = 1;
      year++;
    }

    final newDate = DateTime(year, month, 1);
    onDateSelected?.call(newDate);
  }
}
