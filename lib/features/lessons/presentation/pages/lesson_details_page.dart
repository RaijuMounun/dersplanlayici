import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/lessons/domain/services/recurring_lesson_service.dart';

/// Ders detaylarını gösteren sayfa.
class LessonDetailsPage extends StatefulWidget {

  const LessonDetailsPage({super.key, required this.lessonId});
  final String lessonId;

  @override
  State<LessonDetailsPage> createState() => _LessonDetailsPageState();
}

class _LessonDetailsPageState extends State<LessonDetailsPage> {
  bool _isLoading = true;
  Lesson? _lesson;
  String? _recurringPatternDescription;

  @override
  void initState() {
    super.initState();
    _loadLessonDetails();
  }

  Future<void> _loadLessonDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      final lessonProvider = context.read<LessonProvider>();
      await lessonProvider.loadLessons();

      if (!mounted) return;
      final lesson = lessonProvider.getLessonById(widget.lessonId);

      setState(() {
        _lesson = lesson;
        _isLoading = false;
      });

      // Öğrenci bilgilerini de yükle
      if (_lesson != null && mounted) {
        await context.read<StudentProvider>().loadStudents();

        // Eğer tekrarlanan bir ders ise, desen bilgilerini yükle
        if (_lesson!.recurringPatternId != null) {
          await _loadRecurringPatternInfo();
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ders bilgileri yüklenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Tekrarlanan ders deseninin bilgilerini yükle
  Future<void> _loadRecurringPatternInfo() async {
    if (_lesson?.recurringPatternId == null) return;

    try {
      if (!mounted) return;

      final lessonProvider = context.read<LessonProvider>();
      final pattern = await lessonProvider.getRecurringPattern(
        _lesson!.recurringPatternId!,
      );

      if (pattern != null) {
        // Tekrarlama servisini kullanarak açıklama oluştur
        final service = RecurringLessonService();
        final description = service.getRecurringDescription(pattern);

        if (mounted) {
          setState(() {
            _recurringPatternDescription = description;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _recurringPatternDescription = 'Tekrarlı ders';
          });
        }
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _recurringPatternDescription = 'Tekrarlı ders';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
          _lesson != null ? 'Ders: ${_lesson!.subject}' : 'Ders Detayı',
        ),
        actions: [
          if (_lesson != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Düzenle',
              onPressed: () => _navigateToEdit(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Sil',
              onPressed: () => _confirmDeleteLesson(context),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lesson == null
          ? _buildLessonNotFound()
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
      floatingActionButton:
          _lesson != null && _lesson!.status != LessonStatus.completed
          ? FloatingActionButton.extended(
              onPressed: () => _markLessonAsCompleted(context),
              icon: const Icon(Icons.check),
              label: const Text('Tamamlandı'),
              backgroundColor: AppColors.success,
            )
          : null,
    );

  Widget _buildLessonNotFound() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withAlpha(150),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          const Text(
            'Ders bulunamadı',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          const Text('Aradığınız ders silinmiş veya mevcut değil.'),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Derslere Dön'),
          ),
        ],
      ),
    );

  // Mobil görünüm
  Widget _buildMobileLayout() => SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLessonHeader(),
          const SizedBox(height: AppDimensions.spacing24),
          _buildScheduleInfo(),
          const SizedBox(height: AppDimensions.spacing24),
          _buildStudentInfo(),
          const SizedBox(height: AppDimensions.spacing24),
          _buildNotes(),
        ],
      ),
    );

  // Tablet görünüm
  Widget _buildTabletLayout() => SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLessonHeader(),
          const SizedBox(height: AppDimensions.spacing32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildScheduleInfo()),
              const SizedBox(width: AppDimensions.spacing24),
              Expanded(child: _buildStudentInfo()),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing32),
          _buildNotes(),
        ],
      ),
    );

  // Masaüstü görünüm
  Widget _buildDesktopLayout() => SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLessonHeader(),
          const SizedBox(height: AppDimensions.spacing32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildScheduleInfo()),
              const SizedBox(width: AppDimensions.spacing32),
              Expanded(flex: 3, child: _buildStudentInfo()),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing32),
          _buildNotes(),
        ],
      ),
    );

  // Ders başlık bilgisi
  Widget _buildLessonHeader() {
    final statusColorMap = {
      LessonStatus.scheduled: AppColors.primary,
      LessonStatus.completed: AppColors.success,
      LessonStatus.cancelled: AppColors.error,
      LessonStatus.postponed: AppColors.warning,
    };

    final statusTextMap = {
      LessonStatus.scheduled: 'Planlandı',
      LessonStatus.completed: 'Tamamlandı',
      LessonStatus.cancelled: 'İptal Edildi',
      LessonStatus.postponed: 'Ertelendi',
    };

    final statusColor = statusColorMap[_lesson!.status] ?? AppColors.primary;
    final statusText = statusTextMap[_lesson!.status] ?? 'Planlandı';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _lesson!.subject,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                    ),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            if (_lesson!.topic != null && _lesson!.topic!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                _lesson!.topic!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Ders program bilgisi
  Widget _buildScheduleInfo() {
    final dateFormatter = DateFormat('dd MMMM yyyy');

    // Tarihi DateTime'a çevir
    final dateParts = _lesson!.date.split('-');
    final lessonDate = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    // Ders süresi hesaplaması
    final startTimeParts = _lesson!.startTime.split(':');
    final endTimeParts = _lesson!.endTime.split(':');

    final startDateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
    );

    final endDateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(endTimeParts[0]),
      int.parse(endTimeParts[1]),
    );

    final durationMinutes = endDateTime.difference(startDateTime).inMinutes;
    final durationHours = durationMinutes ~/ 60;
    final remainingMinutes = durationMinutes % 60;

    String durationText = '';
    if (durationHours > 0) {
      durationText += '$durationHours saat ';
    }
    if (remainingMinutes > 0) {
      durationText += '$remainingMinutes dakika';
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ders Programı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tarih',
              value: dateFormatter.format(lessonDate),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Saat',
              value: '${_lesson!.startTime} - ${_lesson!.endTime}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.timelapse,
              label: 'Süre',
              value: durationText,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.attach_money,
              label: 'Ücret',
              value: '₺${_lesson!.fee.toStringAsFixed(2)}',
            ),
            if (_lesson!.recurringPatternId != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.repeat,
                label: 'Tekrar',
                value: _recurringPatternDescription ?? 'Tekrarlı ders',
                iconColor: AppColors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Öğrenci bilgisi
  Widget _buildStudentInfo() {
    // Öğrenci bilgilerini sağlayıcıdan al
    final studentProvider = context.watch<StudentProvider>();
    final student = studentProvider.getStudentById(_lesson!.studentId);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Öğrenci Bilgisi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (student != null)
                  TextButton(
                    onPressed: () => context.push('/student/${student.id}'),
                    child: const Text('Profili Görüntüle'),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _lesson!.studentName.isNotEmpty
                        ? _lesson!.studentName[0].toUpperCase()
                        : '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lesson!.studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (student != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          student.grade,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            if (student != null) ...[
              const Divider(),
              const SizedBox(height: AppDimensions.spacing8),
              if (student.parentName != null && student.parentName!.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Veli',
                  value: student.parentName!,
                ),
              if (student.phone != null && student.phone!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing16),
                _buildInfoRow(
                  icon: Icons.phone,
                  label: 'Telefon',
                  value: student.phone!,
                ),
              ],
              if (student.email != null && student.email!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing16),
                _buildInfoRow(
                  icon: Icons.email,
                  label: 'E-posta',
                  value: student.email!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Notlar kısmı
  Widget _buildNotes() => Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _lesson!.notes?.isNotEmpty == true
                    ? _lesson!.notes!
                    : 'Not eklenmemiş',
                style: TextStyle(
                  fontSize: 16,
                  color: _lesson!.notes?.isNotEmpty == true
                      ? Colors.black
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

  // Bilgi satırı widgetı
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) => Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );

  // Düzenleme sayfasına yönlendir
  void _navigateToEdit(BuildContext context) {
    context.push('/edit-lesson/${_lesson!.id}').then((_) {
      if (mounted) {
        _loadLessonDetails();
      }
    });
  }

  // Ders silme onayı
  void _confirmDeleteLesson(BuildContext context) {
    if (_lesson!.recurringPatternId != null) {
      // Tekrarlanan ders için özel diyalog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Dersi Sil'),
          content: const Text(
            'Bu ders bir tekrarlanan ders serisinin parçasıdır. '
            'Yalnızca bu dersi mi yoksa tüm seriyi mi silmek istiyorsunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteLesson();
              },
              child: const Text('Sadece Bu Dersi Sil'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteRecurringSeries();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Tüm Seriyi Sil'),
            ),
          ],
        ),
      );
    } else {
      // Normal ders için standart diyalog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Dersi Sil'),
          content: Text(
            '${_lesson!.subject} dersini silmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteLesson();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Sil'),
            ),
          ],
        ),
      );
    }
  }

  // Dersi sil
  Future<void> _deleteLesson() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final lessonProvider = context.read<LessonProvider>();

    try {
      if (!mounted) return;
      await lessonProvider.deleteLesson(_lesson!.id);

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Ders başarıyla silindi'),
          backgroundColor: AppColors.success,
        ),
      );

      // Ana sayfaya dön
      if (mounted) {
        context.go('/');
      }
    } on Exception catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Ders silinirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Tekrarlanan ders serisini sil
  Future<void> _deleteRecurringSeries() async {
    if (_lesson?.recurringPatternId == null) return;

    try {
      final lessonProvider = context.read<LessonProvider>();
      final result = await lessonProvider.deleteRecurringLessons(
        _lesson!.recurringPatternId!,
      );

      if (!mounted) return;

      final successCount = result['success'] ?? 0;
      final errorCount = result['error'] ?? 0;

      String message = '$successCount ders başarıyla silindi';
      if (errorCount > 0) {
        message += ', $errorCount ders silinemedi';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: errorCount > 0
              ? AppColors.warning
              : AppColors.success,
        ),
      );

      // Ana sayfaya dön
      if (mounted) {
        context.go('/');
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tekrarlanan dersler silinirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Dersi tamamlandı olarak işaretle
  Future<void> _markLessonAsCompleted(BuildContext context) async {
    final updatedLesson = _lesson!.copyWith(status: LessonStatus.completed);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final lessonProvider = context.read<LessonProvider>();

    try {
      if (!mounted) return;
      await lessonProvider.updateLesson(updatedLesson);

      // Durumu güncelle ve sayfayı yenile
      if (mounted) {
        await _loadLessonDetails();
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Ders tamamlandı olarak işaretlendi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Ders durumu güncellenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
