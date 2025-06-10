import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_card.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';

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
  Widget build(BuildContext context) {
    return _buildStudentsList();
  }

  Widget _buildStudentsList() {
    return Consumer<StudentProvider>(
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

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          itemCount: studentProvider.students.length,
          itemBuilder: (context, index) {
            final Student student = studentProvider.students[index];
            return StudentCard(
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
                  studentProvider.loadStudents();
                }
              },
              onEditPressed: () async {
                // Öğrenciyi bu scope'ta alıyoruz, böylece async gap sonrası tekrar context'e erişmek zorunda kalmıyoruz
                final provider = Provider.of<StudentProvider>(
                  context,
                  listen: false,
                );

                // Öğrenci düzenleme sayfasına yönlendir
                await context.push('/student/${student.id}/edit');

                if (mounted) {
                  provider.loadStudents();
                }
              },
              onDeletePressed: () {
                // Öğrenci silme işlemi
                _showDeleteConfirmation(context, student);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: AppColors.textSecondary.withAlpha(128),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            'Henüz öğrenci bulunmamaktadır',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton.icon(
            onPressed: () async {
              await context.push('/add-student');

              if (mounted) {
                Provider.of<StudentProvider>(
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
  }

  void _showDeleteConfirmation(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenci Sil'),
        content: Text(
          '${student.name} isimli öğrenciyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
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
                studentProvider.loadStudents();
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
