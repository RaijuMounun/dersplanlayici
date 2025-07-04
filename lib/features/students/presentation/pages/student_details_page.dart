import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/lessons/domain/models/lesson_model.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_lessons_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDetailsPage extends StatefulWidget {
  final String studentId;

  const StudentDetailsPage({super.key, required this.studentId});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  bool _isLoading = true;
  Student? _student;
  List<Lesson> _lessons = [];
  bool _lessonsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      final studentProvider = context.read<StudentProvider>();
      await studentProvider.loadStudents();

      if (!mounted) return;
      final student = studentProvider.getStudentById(widget.studentId);

      setState(() {
        _student = student;
        _isLoading = false;
      });

      // Öğrencinin derslerini yükle
      if (_student != null) {
        _loadStudentLessons();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci bilgileri yüklenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadStudentLessons() async {
    setState(() {
      _lessonsLoading = true;
    });

    try {
      if (!mounted) return;
      final lessonProvider = context.read<LessonProvider>();
      await lessonProvider.loadLessonsByStudent(_student!.id);

      if (!mounted) return;
      setState(() {
        _lessons = List.from(lessonProvider.lessons);
        _lessonsLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _lessonsLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci dersleri yüklenirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student != null ? _student!.name : 'Öğrenci Detayı'),
        actions: [
          if (_student != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Düzenle',
              onPressed: () => _navigateToEdit(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Sil',
              onPressed: () => _confirmDeleteStudent(context),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _student == null
          ? _buildStudentNotFound()
          : ResponsiveLayout(
              mobile: _buildMobileLayout(),
              tablet: _buildTabletLayout(),
              desktop: _buildDesktopLayout(),
            ),
      floatingActionButton: _student != null
          ? _buildFloatingActionButton()
          : null,
      bottomNavigationBar: _student != null
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomBarButton(
                      icon: Icons.add,
                      label: 'Ders Ekle',
                      onPressed: () =>
                          context.push('/new-lesson?studentId=${_student!.id}'),
                    ),
                    _buildBottomBarButton(
                      icon: Icons.payments,
                      label: 'Ödeme Ekle',
                      onPressed: () => context.push(
                        '/add-payment?studentId=${_student!.id}',
                      ),
                    ),
                    _buildBottomBarButton(
                      icon: Icons.history,
                      label: 'Ödeme Geçmişi',
                      onPressed: () => context.push(
                        '/fee-history?studentId=${_student!.id}',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStudentNotFound() {
    return Center(
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
            'Öğrenci bulunamadı',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          const Text('Aradığınız öğrenci silinmiş veya mevcut değil.'),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Öğrencilere Dön'),
          ),
        ],
      ),
    );
  }

  // Mobil görünüm
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentHeader(),
          const SizedBox(height: AppDimensions.spacing24),
          _buildContactInfo(),
          const SizedBox(height: AppDimensions.spacing24),
          _buildSubjectsInfo(),
          if (_student?.notes != null && _student!.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing24),
            _buildNotesInfo(),
          ],
          const SizedBox(height: AppDimensions.spacing24),
          _buildLessonsSection(),
        ],
      ),
    );
  }

  // Tablet görünüm
  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentHeader(),
          const SizedBox(height: AppDimensions.spacing32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildContactInfo()),
              const SizedBox(width: AppDimensions.spacing24),
              Expanded(child: _buildSubjectsInfo()),
            ],
          ),
          if (_student?.notes != null && _student!.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing24),
            _buildNotesInfo(),
          ],
          const SizedBox(height: AppDimensions.spacing32),
          _buildLessonsSection(),
        ],
      ),
    );
  }

  // Masaüstü görünüm
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sol panel - Öğrenci bilgileri
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentHeader(),
                const SizedBox(height: AppDimensions.spacing32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildContactInfo()),
                    const SizedBox(width: AppDimensions.spacing32),
                    Expanded(child: _buildSubjectsInfo()),
                  ],
                ),
                if (_student?.notes != null && _student!.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacing32),
                  _buildNotesInfo(),
                ],
              ],
            ),
          ),
        ),
        // Sağ panel - Dersler listesi
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing32),
            child: _buildLessonsSection(),
          ),
        ),
      ],
    );
  }

  // Öğrenci başlık bilgisi
  Widget _buildStudentHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Row(
          children: [
            CircleAvatar(
              radius: ResponsiveUtils.deviceValue(
                context: context,
                mobile: 30.0,
                tablet: 40.0,
                desktop: 50.0,
              ),
              backgroundColor: AppColors.primary,
              child: Text(
                _student!.name.isNotEmpty
                    ? _student!.name[0].toUpperCase()
                    : '',
                style: TextStyle(
                  fontSize: ResponsiveUtils.deviceValue(
                    context: context,
                    mobile: 24.0,
                    tablet: 32.0,
                    desktop: 40.0,
                  ),
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
                    _student!.name,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _student!.grade,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // İletişim bilgisi kartı
  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İletişim Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            if (_student!.parentName != null &&
                _student!.parentName!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.person,
                label: 'Veli',
                value: _student!.parentName!,
              ),
              const Divider(height: 24),
            ],
            if (_student!.phone != null && _student!.phone!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Telefon',
                value: _student!.phone!,
                onTap: () => _callStudent(),
              ),
              const Divider(height: 24),
            ],
            if (_student!.email != null && _student!.email!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.email,
                label: 'E-posta',
                value: _student!.email!,
                onTap: () => _sendEmail(),
              ),
          ],
        ),
      ),
    );
  }

  // Ders bilgileri kartı
  Widget _buildSubjectsInfo() {
    final hasSubjects =
        _student!.subjects != null && _student!.subjects!.isNotEmpty;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dersler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            if (hasSubjects)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _student!.subjects!.map((subject) {
                  return Chip(
                    label: Text(subject, style: TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.primary,
                  );
                }).toList(),
              )
            else
              Text(
                'Ders bilgisi girilmemiş',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Notlar kartı
  Widget _buildNotesInfo() {
    return Card(
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
            Text(_student!.notes ?? ''),
          ],
        ),
      ),
    );
  }

  // Dersler bölümü
  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dersler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (!_lessonsLoading)
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ders Ekle'),
                onPressed: () {
                  context.push('/add-lesson?studentId=${_student!.id}');
                },
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacing12),
        SizedBox(
          height: 400, // Yüksekliği sayfaya göre ayarla
          child: StudentLessonsWidget(
            student: _student!,
            lessons: _lessons,
            isLoading: _lessonsLoading,
            onRefresh: _loadStudentLessons,
            onDeleteLesson: _deleteLesson,
          ),
        ),
      ],
    );
  }

  Future<void> _deleteLesson(Lesson lesson) async {
    try {
      final lessonProvider = context.read<LessonProvider>();
      await lessonProvider.deleteLesson(lesson.id);

      if (mounted) {
        _loadStudentLessons(); // Dersleri yeniden yükle
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

  // Bilgi satırı widgetı
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  // Telefon araması yap
  void _callStudent() {
    if (_student?.phone == null || _student!.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öğrencinin telefon numarası bulunmuyor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final phoneNumber = _student!.phone!.replaceAll(RegExp(r'\D'), '');
    final url = 'tel:$phoneNumber';

    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arama yapılamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // E-posta gönder
  void _sendEmail() {
    if (_student?.email == null || _student!.email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öğrencinin e-posta adresi bulunmuyor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url =
        'mailto:${_student!.email}?subject=Ders%20Hakkında&body=Merhaba%20${_student!.name},';

    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-posta gönderimi başlatılamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Düzenleme sayfasına yönlendir
  void _navigateToEdit(BuildContext context) {
    context.push('/edit-student/${_student!.id}').then((_) {
      if (mounted) {
        _loadStudentDetails();
      }
    });
  }

  // Öğrenci silme onayı
  void _confirmDeleteStudent(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: Text(
          '${_student!.name} adlı öğrenciyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve öğrenciye ait tüm dersler de silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteStudent();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Öğrenciyi sil
  Future<void> _deleteStudent() async {
    try {
      await context.read<StudentProvider>().deleteStudent(_student!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci başarıyla silindi'),
            backgroundColor: AppColors.success,
          ),
        );
        // Ana sayfaya dön
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Öğrenci silinirken hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Yeni ders ekle
        context.push('/new-lesson?studentId=${_student!.id}');
      },
      tooltip: 'Ders Ekle',
      child: const Icon(Icons.add),
    );
  }

  Widget _buildBottomBarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
