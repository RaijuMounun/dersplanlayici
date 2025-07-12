import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/features/lessons/presentation/widgets/lesson_list_item.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

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

    // Dersleri yükle
    Future.microtask(() {
      if (mounted) {
        context.read<LessonProvider>().loadLessons();
      }
    });
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

    return Column(
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
    );
  }

  Widget _buildLessonList(LessonFilterType filterType) {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        print('🔍 [LessonsPage] _buildLessonList çağrıldı - Tip: $filterType');
        print('🔍 [LessonsPage] Loading durumu: ${lessonProvider.isLoading}');
        print('🔍 [LessonsPage] Hata durumu: ${lessonProvider.error}');

        // Veri yükleniyor mu kontrolü
        if (lessonProvider.isLoading) {
          print('🔍 [LessonsPage] Yükleme gösteriliyor');
          return const Center(child: CircularProgressIndicator());
        }

        // Filtreli ders listesini al
        final lessons = _getFilteredLessons(lessonProvider, filterType);
        print('🔍 [LessonsPage] Filtrelenmiş ders sayısı: ${lessons.length}');

        // Ders yoksa boş durum mesajı göster
        if (lessons.isEmpty) {
          print('🔍 [LessonsPage] Boş durum gösteriliyor');
          return _buildEmptyState(filterType);
        }

        print('🔍 [LessonsPage] Ders listesi gösteriliyor');
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
  }

  Widget _buildSelectionAppBar(List<Lesson> lessons) {
    return Container(
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
                ? () => _showBulkDeleteConfirmation()
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
  }

  // Mobil cihazlar için liste görünümü
  Widget _buildMobileList(List<Lesson> lessons) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacing8),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  _toggleSelectionMode();
                  _toggleLessonSelection(lessons[index].id);
                }
              },
              child: _buildLessonItem(lessons[index]),
            );
          },
        ),
        if (!_isSelectionMode)
          Positioned(
            bottom: AppDimensions.spacing16,
            right: AppDimensions.spacing16,
            child: FloatingActionButton(
              onPressed: () {
                context.push('/new-lesson').then((_) {
                  if (mounted) {
                    context.read<LessonProvider>().loadLessons();
                  }
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  // Tablet cihazlar için liste görünümü - daha büyük paddingler
  Widget _buildTabletList(List<Lesson> lessons) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  _toggleSelectionMode();
                  _toggleLessonSelection(lessons[index].id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacing8,
                ),
                child: _buildLessonItem(lessons[index]),
              ),
            );
          },
        ),
        if (!_isSelectionMode)
          Positioned(
            bottom: AppDimensions.spacing24,
            right: AppDimensions.spacing24,
            child: FloatingActionButton.extended(
              onPressed: () {
                context.push('/new-lesson').then((_) {
                  if (mounted) {
                    context.read<LessonProvider>().loadLessons();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Ders'),
            ),
          ),
      ],
    );
  }

  // Desktop cihazlar için liste görünümü - çift sütunlu
  Widget _buildDesktopList(List<Lesson> lessons) {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: AppDimensions.spacing16,
            mainAxisSpacing: AppDimensions.spacing16,
          ),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  _toggleSelectionMode();
                  _toggleLessonSelection(lessons[index].id);
                }
              },
              child: _buildLessonItem(lessons[index]),
            );
          },
        ),
        if (!_isSelectionMode)
          Positioned(
            bottom: AppDimensions.spacing24,
            right: AppDimensions.spacing24,
            child: FloatingActionButton.extended(
              onPressed: () {
                context.push('/new-lesson').then((_) {
                  if (mounted) {
                    context.read<LessonProvider>().loadLessons();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Ders'),
            ),
          ),
      ],
    );
  }

  // Ders liste öğesi
  Widget _buildLessonItem(Lesson lesson) {
    return LessonListItem(
      lessonTitle: lesson.subject,
      studentName: lesson.studentName,
      startTime: _parseDateTime(lesson.date, lesson.startTime),
      endTime: _parseDateTime(lesson.date, lesson.endTime),
      isCompleted: lesson.status == LessonStatus.completed,
      fee: lesson.fee,
      isRecurring: lesson.recurringPatternId != null,
      isSelected: _isSelectionMode && _selectedLessons.contains(lesson.id),
      onTap: _isSelectionMode
          ? () => _toggleLessonSelection(lesson.id)
          : () => context.push('/lesson/${lesson.id}'),
      onEditPressed: _isSelectionMode
          ? null
          : () {
              context.push('/edit-lesson/${lesson.id}').then((_) {
                if (mounted) {
                  context.read<LessonProvider>().loadLessons();
                }
              });
            },
      onDeletePressed: _isSelectionMode
          ? null
          : () => _showDeleteConfirmation(lesson),
      onMarkCompleted: _isSelectionMode
          ? null
          : () => _markLessonAsCompleted(lesson),
    );
  }

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
                context.push('/new-lesson').then((_) {
                  if (mounted) {
                    context.read<LessonProvider>().loadLessons();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Ders Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  List<Lesson> _getFilteredLessons(
    LessonProvider provider,
    LessonFilterType filterType,
  ) {
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(
      '🔍 [LessonsPage] Filtreleme yapılıyor - Tip: $filterType, Bugün: $now',
    );
    print('🔍 [LessonsPage] Toplam ders sayısı: ${provider.lessons.length}');

    List<Lesson> filteredLessons;
    switch (filterType) {
      case LessonFilterType.upcoming:
        filteredLessons = provider.lessons
            .where(
              (lesson) =>
                  lesson.status != LessonStatus.completed &&
                  (lesson.date.compareTo(now) > 0 ||
                      (lesson.date == now &&
                          lesson.startTime.compareTo(
                                DateFormat('HH:mm').format(DateTime.now()),
                              ) >
                              0)),
            )
            .toList();
        print('🔍 [LessonsPage] Gelecek dersler: ${filteredLessons.length}');
        break;
      case LessonFilterType.completed:
        filteredLessons = provider.lessons
            .where((lesson) => lesson.status == LessonStatus.completed)
            .toList();
        print('🔍 [LessonsPage] Tamamlanan dersler: ${filteredLessons.length}');
        break;
      case LessonFilterType.all:
        filteredLessons = provider.lessons;
        print('🔍 [LessonsPage] Tüm dersler: ${filteredLessons.length}');
        break;
    }

    if (filteredLessons.isNotEmpty) {
      print('🔍 [LessonsPage] İlk ders: ${filteredLessons.first.toString()}');
    }

    return filteredLessons;
  }

  // Tarih ve saat bilgilerini DateTime objesine çevirir
  DateTime _parseDateTime(String date, String time) {
    final dateComponents = date.split('-');
    final timeComponents = time.split(':');

    return DateTime(
      int.parse(dateComponents[0]), // yıl
      int.parse(dateComponents[1]), // ay
      int.parse(dateComponents[2]), // gün
      int.parse(timeComponents[0]), // saat
      int.parse(timeComponents[1]), // dakika
    );
  }

  // Ders silme onayı diyaloğunu göster
  void _showDeleteConfirmation(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersi Sil'),
        content: Text(
          '${lesson.subject} dersini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteLesson(lesson.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Dersi sil
  Future<void> _deleteLesson(String lessonId) async {
    try {
      await context.read<LessonProvider>().deleteLesson(lessonId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ders başarıyla silindi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ders silinirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Dersi tamamlandı olarak işaretle
  Future<void> _markLessonAsCompleted(Lesson lesson) async {
    try {
      final updatedLesson = lesson.copyWith(status: LessonStatus.completed);
      await context.read<LessonProvider>().updateLesson(updatedLesson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ders tamamlandı olarak işaretlendi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ders durumu güncellenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Toplu silme onayı diyaloğunu göster
  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seçili Dersleri Sil'),
        content: Text(
          '${_selectedLessons.length} adet dersi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBulkLessons();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Seçili dersleri toplu sil
  Future<void> _deleteBulkLessons() async {
    final selectedIds = List<String>.from(_selectedLessons);

    setState(() {
      _isSelectionMode = false;
      _selectedLessons.clear();
    });

    try {
      final result = await context.read<LessonProvider>().deleteLessons(
        selectedIds,
      );
      final successCount = result['success'] ?? 0;
      final errorCount = result['error'] ?? 0;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorCount > 0
                  ? '$successCount ders silindi, $errorCount ders silinemedi'
                  : '$successCount ders başarıyla silindi',
            ),
            backgroundColor: errorCount > 0
                ? AppColors.warning
                : AppColors.success,
            action: SnackBarAction(
              label: 'Tamam',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Toplu silme işlemi sırasında hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Ders filtre tipleri
enum LessonFilterType { upcoming, completed, all }
