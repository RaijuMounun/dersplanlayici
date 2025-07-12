import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_card.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  @override
  void initState() {
    super.initState();
    // Provider erişimini build sonrasına ertele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).loadStudents();
      }
    });
  }

  @override
  Widget build(BuildContext context) => _buildStudentsList();

  Widget _buildStudentsList() => Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (studentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (studentProvider.error != null &&
            studentProvider.error.toString().isNotEmpty) {
          return Center(child: Text('Hata: ${studentProvider.error}'));
        }

        if (studentProvider.students.isEmpty) {
          return _buildEmptyState();
        }

        // Responsive layout kullanarak ekran boyutuna göre farklı görünüm göster
        return ResponsiveLayout(
          mobile: _buildListView(studentProvider.students),
          tablet: _buildGridView(studentProvider.students, 2),
          desktop: _buildGridView(studentProvider.students, 3),
        );
      },
    );

  // Liste görünümü (mobil)
  Widget _buildListView(List<Student> students) => ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      itemCount: students.length,
      itemBuilder: (context, index) => _buildStudentCard(students[index]),
    );

  // Grid görünümü (tablet ve desktop)
  Widget _buildGridView(List<Student> students, int crossAxisCount) => GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimensions.spacing12,
        mainAxisSpacing: AppDimensions.spacing12,
        childAspectRatio: 1.2,
      ),
      itemCount: students.length,
      itemBuilder: (context, index) => _buildStudentCard(students[index]),
    );

  // Öğrenci kartı
  Widget _buildStudentCard(Student student) => StudentCard(
      studentName: student.name,
      studentGrade: student.grade,
      phoneNumber: student.phone,
      email: student.email,
      onTap: () async {
        final studentProvider = Provider.of<StudentProvider>(
          context,
          listen: false,
        );

        // Go Router ile navigasyon
        await context.push('/student/${student.id}');

        if (mounted) {
          await studentProvider.loadStudents();
        }
      },
      onEditPressed: () async {
        // Öğrenciyi bu scope'ta alıyoruz, böylece async gap sonrası tekrar context'e erişmek zorunda kalmıyoruz
        final provider = Provider.of<StudentProvider>(context, listen: false);

        // Öğrenci düzenleme sayfasına yönlendir
        await context.push('/student/${student.id}/edit');

        if (mounted) {
          await provider.loadStudents();
        }
      },
      onDeletePressed: () {
        // Öğrenci silme işlemi
        _showDeleteConfirmation(context, student);
      },
    );

  Widget _buildEmptyState() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
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
            'Henüz öğrenci bulunmamaktadır',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push('/add-student');

              if (mounted) {
                await Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).loadStudents();
              }
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Öğrenci Ekle'),
          ),
        ],
      ),
    );

  void _showDeleteConfirmation(BuildContext context, Student student) {
    // Dialog boyutunu responsive yap
    final dialogWidth = ResponsiveUtils.deviceValue(
      context: context,
      mobile: 320.0,
      tablet: 400.0,
      desktop: 480.0,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenci Sil'),
        content: SizedBox(
          width: dialogWidth,
          child: Text(
            '${student.name} isimli öğrenciyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Öğrenciyi sil
              final studentProvider = Provider.of<StudentProvider>(
                context,
                listen: false,
              );
              await studentProvider.deleteStudent(student.id);

              if (mounted) {
                await studentProvider.loadStudents();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
