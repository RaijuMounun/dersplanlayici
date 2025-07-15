import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/features/lessons/presentation/widgets/lesson_list_item.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/core/navigation/route_names.dart';

/// Dersler listesini gösteren ana sayfa.
class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSelectionMode = false;
  final Set<String> _selectedLessons = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Dersler provider'ın constructor'ında zaten yükleniyor.
    // Future.microtask(() {
    //   if (mounted) {
    //     context.read<LessonProvider>().loadLessons();
    //   }
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedLessons.clear();
      }
    });
  }

  void _toggleLessonSelection(String lessonId) {
    setState(() {
      if (_selectedLessons.contains(lessonId)) {
        _selectedLessons.remove(lessonId);
      } else {
        _selectedLessons.add(lessonId);
      }

      // Seçili ders kalmadıysa seçim modunu kapat
      if (_selectedLessons.isEmpty && _isSelectionMode) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<Lesson> lessons) {
    setState(() {
      if (_selectedLessons.length == lessons.length) {
        // Tümü zaten seçiliyse, seçimleri temizle
        _selectedLessons.clear();
      } else {
        // Tümünü seç
        _selectedLessons.clear();
        for (var lesson in lessons) {
          _selectedLessons.add(lesson.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tab bar'ın boyutunu ekran genişliğine göre ayarla
    final tabHeight = ResponsiveUtils.deviceValue<double>(
      context: context,
      mobile: 48.0,
      tablet: 56.0,
      desktop: 64.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dersler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama işlevi
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar - responsive boyutlar ile
          SizedBox(
            height: tabHeight,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
              ),
              tabs: const [
                Tab(text: 'Gelecek'),
                Tab(text: 'Tamamlanan'),
                Tab(text: 'Tümü'),
              ],
            ),
          ),

          // Tab İçerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLessonList(LessonFilterType.upcoming),
                _buildLessonList(LessonFilterType.completed),
                _buildLessonList(LessonFilterType.all),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'lessons_fab',
        onPressed: () {
          context.pushNamed(RouteNames.addLesson);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLessonList(LessonFilterType filterType) =>
      Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          // Veri yükleniyor mu kontrolü
          if (lessonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtreli ders listesini al
          final lessons = _getFilteredLessons(lessonProvider, filterType);

          // Ders yoksa boş durum mesajı göster
          if (lessons.isEmpty) {
            return _buildEmptyState(filterType);
          }

          // Seçim modu aktifse üst menü göster
          return Column(
            children: [
              if (_isSelectionMode) _buildSelectionAppBar(lessons),

              // Ders listesini göster - responsive layout kullan
              Expanded(
                child: ResponsiveLayout(
                  mobile: _buildMobileList(lessons),
                  tablet: _buildTabletList(lessons),
                  desktop: _buildDesktopList(lessons),
                ),
              ),
            ],
          );
        },
      );

  Widget _buildSelectionAppBar(List<Lesson> lessons) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacing16,
      vertical: AppDimensions.spacing8,
    ),
    child: Row(
      children: [
        Text(
          '${_selectedLessons.length} ders seçildi',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () => _selectAll(lessons),
          icon: Icon(
            _selectedLessons.length == lessons.length
                ? Icons.deselect
                : Icons.select_all,
            size: 20,
          ),
          label: Text(
            _selectedLessons.length == lessons.length
                ? 'Tümünü Kaldır'
                : 'Tümünü Seç',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Seçilenleri Sil',
          onPressed: _selectedLessons.isNotEmpty
              ? _showBulkDeleteConfirmation
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Seçim Modunu Kapat',
          onPressed: _toggleSelectionMode,
        ),
      ],
    ),
  );

  // Mobil cihazlar için liste görünümü
  Widget _buildMobileList(List<Lesson> lessons) => Stack(
    children: [
      ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spacing8),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return GestureDetector(
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _toggleLessonSelection(lesson.id);
              }
            },
            child: LessonListItem(
              lessonTitle: lesson.subject,
              studentName: lesson.studentName,
              startTime: DateTime.tryParse(
                '${lesson.date}T${lesson.startTime}',
              ),
              endTime: DateTime.tryParse('${lesson.date}T${lesson.endTime}'),
              isCompleted: lesson.status == LessonStatus.completed,
              fee: lesson.fee,
              isRecurring: lesson.recurringPatternId != null,
              isSelected: _selectedLessons.contains(lesson.id),
              onTap: () {
                if (_isSelectionMode) {
                  _toggleLessonSelection(lesson.id);
                } else {
                  // Ders detaylarına git
                  context.pushNamed(
                    RouteNames.lessonDetails,
                    pathParameters: {'id': lesson.id},
                  );
                }
              },
              onEditPressed: () => context.pushNamed(
                RouteNames.editLesson,
                pathParameters: {'id': lesson.id},
              ),
              onDeletePressed: () => _showDeleteConfirmation(lesson.id),
              onMarkCompleted: () => _markLessonAsCompleted(context, lesson),
            ),
          );
        },
      ),
      if (!_isSelectionMode)
        Positioned(
          bottom: AppDimensions.spacing16,
          right: AppDimensions.spacing16,
          child: FloatingActionButton(
            onPressed: () {
              context.pushNamed(RouteNames.addLesson);
            },
            child: const Icon(Icons.add),
          ),
        ),
    ],
  );

  // Tablet cihazlar için liste görünümü - daha büyük paddingler
  Widget _buildTabletList(List<Lesson> lessons) =>
      _buildMobileList(lessons); // Şimdilik mobil ile aynı

  // Desktop cihazlar için liste görünümü - çift sütunlu
  Widget _buildDesktopList(List<Lesson> lessons) => ListView.builder(
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacing32,
      vertical: AppDimensions.spacing16,
    ),
    itemCount: lessons.length,
    itemBuilder: (context, index) {
      final lesson = lessons[index];
      return LessonListItem(
        lessonTitle: lesson.subject,
        studentName: lesson.studentName,
        startTime: DateTime.tryParse('${lesson.date}T${lesson.startTime}'),
        endTime: DateTime.tryParse('${lesson.date}T${lesson.endTime}'),
        isCompleted: lesson.status == LessonStatus.completed,
        fee: lesson.fee,
        isRecurring: lesson.recurringPatternId != null,
        isSelected: _selectedLessons.contains(lesson.id),
        onTap: () {
          if (_isSelectionMode) {
            _toggleLessonSelection(lesson.id);
          } else {
            // Ders detaylarına git
            context.pushNamed(
              RouteNames.lessonDetails,
              pathParameters: {'id': lesson.id},
            );
          }
        },
        onEditPressed: () => context.pushNamed(
          RouteNames.editLesson,
          pathParameters: {'id': lesson.id},
        ),
        onDeletePressed: () => _showDeleteConfirmation(lesson.id),
        onMarkCompleted: () => _markLessonAsCompleted(context, lesson),
      );
    },
  );

  Widget _buildEmptyState(LessonFilterType filterType) {
    String message;
    IconData icon;

    switch (filterType) {
      case LessonFilterType.upcoming:
        message = 'Gelecek ders bulunmuyor';
        icon = Icons.event_available;
        break;
      case LessonFilterType.completed:
        message = 'Tamamlanmış ders bulunmuyor';
        icon = Icons.check_circle;
        break;
      case LessonFilterType.all:
        message = 'Henüz ders eklenmemiş';
        icon = Icons.book;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.deviceValue(
              context: context,
              mobile: 64.0,
              tablet: 80.0,
              desktop: 96.0,
            ),
            color: AppColors.textSecondary.withAlpha(128),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            message,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          SizedBox(
            width: ResponsiveUtils.deviceValue(
              context: context,
              mobile: 160.0,
              tablet: 200.0,
              desktop: 220.0,
            ),
            height: ResponsiveUtils.deviceValue(
              context: context,
              mobile: 40.0,
              tablet: 48.0,
              desktop: 56.0,
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // Ders ekleme sayfasına yönlendir
                context.pushNamed(RouteNames.addLesson);
              },
              icon: const Icon(Icons.add),
              label: const Text('Ders Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  // Dersleri filtrelemek için yardımcı metot
  List<Lesson> _getFilteredLessons(
    LessonProvider lessonProvider,
    LessonFilterType filterType,
  ) {
    final now = DateTime.now();
    final allLessons = lessonProvider.allLessons;

    List<Lesson> filtered;
    switch (filterType) {
      case LessonFilterType.upcoming:
        filtered = allLessons
            .where(
              (lesson) =>
                  lesson.status != LessonStatus.completed &&
                  ((DateTime.tryParse('${lesson.date}T${lesson.startTime}') ??
                              DateTime(1970))
                          .compareTo(now) >
                      0),
            )
            .toList();
        break;
      case LessonFilterType.completed:
        filtered = allLessons
            .where((lesson) => lesson.status == LessonStatus.completed)
            .toList();
        break;
      case LessonFilterType.all:
        filtered = allLessons;
        break;
    }
    return filtered;
  }

  Lesson? _getLessonById(String lessonId) {
    for (final lesson in context.read<LessonProvider>().allLessons) {
      if (lesson.id == lessonId) {
        return lesson;
      }
    }
    return null;
  }

  // Helper function to show delete confirmation dialog
  void _showDeleteConfirmation(String lessonId) async {
    final lesson = _getLessonById(lessonId);
    if (lesson == null) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersi Sil'),
        content: Text(
          '\'${lesson.subject}\' dersini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => navigator.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteLesson(lessonId, scaffoldMessenger);
    }
  }

  // Dersi sil
  Future<void> _deleteLesson(
    String lessonId,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    final lessonProvider = context.read<LessonProvider>();
    try {
      await lessonProvider.deleteLesson(lessonId);
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Ders başarıyla silindi'),
          backgroundColor: AppColors.success,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Ders silinirken hata oluştu: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Dersi tamamlandı olarak işaretle
  Future<void> _markLessonAsCompleted(
    BuildContext context,
    Lesson lesson,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final lessonProvider = context.read<LessonProvider>();
    try {
      final updatedLesson = lesson.copyWith(status: LessonStatus.completed);
      await lessonProvider.updateLesson(updatedLesson);
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Ders tamamlandı olarak işaretlendi.')),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  // Toplu silme onayı diyaloğunu göster
  void _showBulkDeleteConfirmation() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_selectedLessons.length} Dersi Sil'),
        content: Text(
          '${_selectedLessons.length} adet dersi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => navigator.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteBulkLessons(scaffoldMessenger);
    }
  }

  Future<void> _deleteBulkLessons(
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    final lessonProvider = context.read<LessonProvider>();
    final lessonCount = _selectedLessons.length;
    final lessonsToDelete = List<String>.from(_selectedLessons);
    var successCount = 0;

    for (final id in lessonsToDelete) {
      try {
        await lessonProvider.deleteLesson(id);
        successCount++;
      } on Exception {
        // Hata durumunda sayacı artırma, isteğe bağlı loglama
      }
    }

    if (!mounted) return;

    if (successCount > 0) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$successCount ders başarıyla silindi.'),
          backgroundColor: AppColors.success,
        ),
      );
    }

    if (successCount < lessonCount) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${lessonCount - successCount} ders silinemedi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }

    setState(() {
      _selectedLessons.clear();
      _isSelectionMode = false;
    });
  }
}

/// Ders filtre tipleri
enum LessonFilterType { upcoming, completed, all }
