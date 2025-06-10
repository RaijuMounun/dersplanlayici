import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/utils/date_utils.dart' as date_utils;
import 'package:ders_planlayici/core/widgets/app_card.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

enum LessonFilterType { all, upcoming, past, completed, cancelled }

class StudentLessonsWidget extends StatefulWidget {
  final Student student;
  final List<Lesson> lessons;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(Lesson) onDeleteLesson;

  const StudentLessonsWidget({
    super.key,
    required this.student,
    required this.lessons,
    required this.isLoading,
    required this.onRefresh,
    required this.onDeleteLesson,
  });

  @override
  State<StudentLessonsWidget> createState() => _StudentLessonsWidgetState();
}

class _StudentLessonsWidgetState extends State<StudentLessonsWidget> {
  LessonFilterType _currentFilter = LessonFilterType.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Lesson> get filteredLessons {
    List<Lesson> result = List.from(widget.lessons);

    // Arama filtreleme
    if (_searchQuery.isNotEmpty) {
      result = result.where((lesson) {
        return lesson.subject.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (lesson.topic != null &&
                lesson.topic!.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ));
      }).toList();
    }

    // Durum filtreleme
    switch (_currentFilter) {
      case LessonFilterType.upcoming:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        result = result.where((lesson) {
          final lessonDate = DateFormat('yyyy-MM-dd').parse(lesson.date);
          return lessonDate.isAfter(today) ||
              (lessonDate.isAtSameMomentAs(today) &&
                  lesson.status == LessonStatus.scheduled);
        }).toList();
        break;
      case LessonFilterType.past:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        result = result.where((lesson) {
          final lessonDate = DateFormat('yyyy-MM-dd').parse(lesson.date);
          return lessonDate.isBefore(today);
        }).toList();
        break;
      case LessonFilterType.completed:
        result = result
            .where((lesson) => lesson.status == LessonStatus.completed)
            .toList();
        break;
      case LessonFilterType.cancelled:
        result = result
            .where((lesson) => lesson.status == LessonStatus.cancelled)
            .toList();
        break;
      case LessonFilterType.all:
        // Tüm dersler, filtreleme yok
        break;
    }

    // Tarihe göre sırala (yaklaşan dersler önce)
    result.sort((a, b) {
      final dateA = DateFormat('yyyy-MM-dd').parse(a.date);
      final dateB = DateFormat('yyyy-MM-dd').parse(b.date);
      return dateA.compareTo(dateB);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(),
        const SizedBox(height: AppDimensions.spacing16),
        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (widget.lessons.isEmpty)
          _buildEmptyState()
        else if (filteredLessons.isEmpty)
          _buildNoResultsState()
        else
          _buildLessonsList(),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Ders ara...',
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
        ),
        const SizedBox(height: AppDimensions.spacing12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(LessonFilterType.all, 'Tümü'),
              const SizedBox(width: AppDimensions.spacing8),
              _buildFilterChip(LessonFilterType.upcoming, 'Yaklaşan'),
              const SizedBox(width: AppDimensions.spacing8),
              _buildFilterChip(LessonFilterType.past, 'Geçmiş'),
              const SizedBox(width: AppDimensions.spacing8),
              _buildFilterChip(LessonFilterType.completed, 'Tamamlandı'),
              const SizedBox(width: AppDimensions.spacing8),
              _buildFilterChip(LessonFilterType.cancelled, 'İptal'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(LessonFilterType filter, String label) {
    final isSelected = _currentFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = selected ? filter : LessonFilterType.all;
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

  Widget _buildLessonsList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: filteredLessons.length,
        itemBuilder: (context, index) {
          final lesson = filteredLessons[index];
          return _buildLessonCard(lesson);
        },
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    final formattedDate = date_utils.DateUtils.formatDateWithDay(lesson.date);
    final statusColor = _getLessonStatusColor(lesson.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
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
                      lesson.subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (lesson.topic != null && lesson.topic!.isNotEmpty)
                      Text(
                        lesson.topic!,
                        style: TextStyle(color: AppColors.textSecondary),
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
                  borderRadius: BorderRadius.circular(AppDimensions.radius4),
                ),
                child: Text(
                  _getLessonStatusText(lesson.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
              Text(formattedDate),
              const SizedBox(width: AppDimensions.spacing16),
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppDimensions.spacing4),
              Text('${lesson.startTime} - ${lesson.endTime}'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Düzenle'),
                onPressed: () {
                  context.push('/edit-lesson/${lesson.id}');
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Sil'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () {
                  _confirmDeleteLesson(lesson);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLesson(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersi Sil'),
        content: Text(
          '${date_utils.DateUtils.formatDateWithDay(lesson.date)} tarihindeki ${lesson.subject} dersini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeleteLesson(lesson);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Bu öğrenciye ait ders bulunmuyor',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/add-lesson?studentId=${widget.student.id}');
              },
              icon: const Icon(Icons.add),
              label: const Text('Ders Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              _searchQuery.isNotEmpty
                  ? '"$_searchQuery" aramasına uygun ders bulunamadı'
                  : 'Seçili filtrelere uygun ders bulunamadı',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _currentFilter = LessonFilterType.all;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Filtreleri Temizle'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLessonStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return AppColors.info;
      case LessonStatus.completed:
        return AppColors.success;
      case LessonStatus.cancelled:
        return AppColors.error;
      case LessonStatus.postponed:
        return AppColors.warning;
    }
  }

  String _getLessonStatusText(LessonStatus status) {
    switch (status) {
      case LessonStatus.scheduled:
        return 'Planlandı';
      case LessonStatus.completed:
        return 'Tamamlandı';
      case LessonStatus.cancelled:
        return 'İptal Edildi';
      case LessonStatus.postponed:
        return 'Ertelendi';
    }
  }
}
