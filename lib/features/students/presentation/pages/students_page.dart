import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/features/students/presentation/pages/add_student_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/student_details_page.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_list_item.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenciler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama işlevi
            },
          ),
        ],
      ),
      body: _buildStudentsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final studentProvider = Provider.of<StudentProvider>(
            context,
            listen: false,
          );
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentPage()),
          );

          if (mounted) {
            studentProvider.loadStudents();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
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
          return const Center(child: Text('Henüz öğrenci bulunmamaktadır.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: studentProvider.students.length,
          itemBuilder: (context, index) {
            final Student student = studentProvider.students[index];
            return StudentListItem(
              name: student.name,
              grade: student.grade,
              subjects: student.subjects,
              onTap: () async {
                final studentProvider = Provider.of<StudentProvider>(
                  context,
                  listen: false,
                );
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentDetailsPage(studentId: student.id),
                  ),
                );

                if (mounted) {
                  studentProvider.loadStudents();
                }
              },
            );
          },
        );
      },
    );
  }
}
