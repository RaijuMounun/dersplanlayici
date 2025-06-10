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

/// Dersler listesini gösteren ana sayfa.
class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

        // Ders listesini göster - responsive layout kullan
        return ResponsiveLayout(
          mobile: _buildMobileList(lessons),
          tablet: _buildTabletList(lessons),
          desktop: _buildDesktopList(lessons),
        );
      },
    );
  }

  // Mobil cihazlar için liste görünümü
  Widget _buildMobileList(List<Lesson> lessons) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing8),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _buildLessonItem(lessons[index]);
      },
    );
  }

  // Tablet cihazlar için liste görünümü - daha büyük paddingler
  Widget _buildTabletList(List<Lesson> lessons) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing8),
          child: _buildLessonItem(lessons[index]),
        );
      },
    );
  }

  // Desktop cihazlar için liste görünümü - çift sütunlu
  Widget _buildDesktopList(List<Lesson> lessons) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: AppDimensions.spacing16,
        mainAxisSpacing: AppDimensions.spacing16,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return _buildLessonItem(lessons[index]);
      },
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
      fee: 0.0, // Burada fee bilgisi modelde yok, varsayılan değer kullanıyoruz
      isRecurring: lesson.recurringPatternId != null,
      onTap: () {
        // TODO: Ders detay sayfasına yönlendir
      },
      onEditPressed: () {
        // TODO: Ders düzenleme sayfasına yönlendir
      },
      onDeletePressed: () {
        // TODO: Ders silme işlevi
      },
      onMarkCompleted: () {
        // TODO: Dersi tamamlandı olarak işaretle
      },
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
                // TODO: Ders ekleme sayfasına yönlendir
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

    switch (filterType) {
      case LessonFilterType.upcoming:
        return provider.lessons
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
      case LessonFilterType.completed:
        return provider.lessons
            .where((lesson) => lesson.status == LessonStatus.completed)
            .toList();
      case LessonFilterType.all:
        return provider.lessons;
    }
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
}

/// Ders filtre tipleri
enum LessonFilterType { upcoming, completed, all }
