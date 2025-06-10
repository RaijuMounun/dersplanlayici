import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_list_item.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedStudents = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGrade = '';
  final List<String> _gradeOptions = [
    '',
    'İlkokul',
    'Ortaokul',
    'Lise',
    'Üniversite',
    'Mezun',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<StudentProvider>().loadStudents();
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedStudents.clear();
      }
    });
  }

  void _toggleStudentSelection(String studentId) {
    setState(() {
      if (_selectedStudents.contains(studentId)) {
        _selectedStudents.remove(studentId);
      } else {
        _selectedStudents.add(studentId);
      }

      // Seçili öğrenci kalmadıysa seçim modunu kapat
      if (_selectedStudents.isEmpty && _isSelectionMode) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<Student> students) {
    setState(() {
      if (_selectedStudents.length == students.length) {
        // Tümü zaten seçiliyse, seçimleri temizle
        _selectedStudents.clear();
      } else {
        // Tümünü seç
        _selectedStudents.clear();
        for (var student in students) {
          _selectedStudents.add(student.id);
        }
      }
    });
  }

  List<Student> _getFilteredStudents(List<Student> students) {
    if (_searchQuery.isEmpty && _selectedGrade.isEmpty) {
      return students;
    }

    return students.where((student) {
      bool matchesSearch = true;
      bool matchesGrade = true;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch =
            student.name.toLowerCase().contains(query) ||
            (student.parentName?.toLowerCase().contains(query) ?? false) ||
            (student.subjects?.join(' ').toLowerCase().contains(query) ??
                false);
      }

      if (_selectedGrade.isNotEmpty) {
        matchesGrade = student.grade == _selectedGrade;
      }

      return matchesSearch && matchesGrade;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (studentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = _getFilteredStudents(studentProvider.students);

        if (students.isEmpty && studentProvider.students.isEmpty) {
          return _buildEmptyState();
        }

        if (students.isEmpty) {
          return _buildNoResultsState();
        }

        return Column(
          children: [
            _buildSearchFilterBar(),
            if (_isSelectionMode) _buildSelectionAppBar(students),
            Expanded(
              child: ResponsiveLayout(
                mobile: _buildMobileList(students),
                tablet: _buildTabletList(students),
                desktop: _buildDesktopList(students),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: ResponsiveLayout(
        mobile: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: AppDimensions.spacing8),
            _buildGradeFilter(),
          ],
        ),
        tablet: Row(
          children: [
            Expanded(flex: 3, child: _buildSearchField()),
            const SizedBox(width: AppDimensions.spacing16),
            Expanded(flex: 2, child: _buildGradeFilter()),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(flex: 4, child: _buildSearchField()),
            const SizedBox(width: AppDimensions.spacing16),
            Expanded(flex: 2, child: _buildGradeFilter()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Öğrenci ara...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
        ),
      ),
    );
  }

  Widget _buildGradeFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedGrade,
      decoration: InputDecoration(
        hintText: 'Sınıf Filtresi',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
        ),
      ),
      items: _gradeOptions.map((grade) {
        return DropdownMenuItem<String>(
          value: grade,
          child: Text(grade.isEmpty ? 'Tüm Sınıflar' : grade),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGrade = value ?? '';
        });
      },
    );
  }

  Widget _buildSelectionAppBar(List<Student> students) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      child: Row(
        children: [
          Text(
            '${_selectedStudents.length} öğrenci seçildi',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _selectAll(students),
            icon: Icon(
              _selectedStudents.length == students.length
                  ? Icons.deselect
                  : Icons.select_all,
              size: 20,
            ),
            label: Text(
              _selectedStudents.length == students.length
                  ? 'Tümünü Kaldır'
                  : 'Tümünü Seç',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Seçilenleri Sil',
            onPressed: _selectedStudents.isNotEmpty
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

  Widget _buildMobileList(List<Student> students) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacing8),
          itemCount: students.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  _toggleSelectionMode();
                  _toggleStudentSelection(students[index].id);
                }
              },
              child: _buildStudentItem(students[index]),
            );
          },
        ),
        if (!_isSelectionMode)
          Positioned(
            bottom: AppDimensions.spacing16,
            right: AppDimensions.spacing16,
            child: FloatingActionButton(
              onPressed: () {
                context.push('/add-student').then((_) {
                  if (mounted) {
                    context.read<StudentProvider>().loadStudents();
                  }
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildTabletList(List<Student> students) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  _toggleSelectionMode();
                  _toggleStudentSelection(students[index].id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacing8,
                ),
                child: _buildStudentItem(students[index]),
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
                context.push('/add-student').then((_) {
                  if (mounted) {
                    context.read<StudentProvider>().loadStudents();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Öğrenci'),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopList(List<Student> students) {
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
          itemCount: students.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  _toggleSelectionMode();
                  _toggleStudentSelection(students[index].id);
                }
              },
              child: _buildStudentItem(students[index]),
            );
          },
        ),
        if (!_isSelectionMode)
          Positioned(
            bottom: AppDimensions.spacing24,
            right: AppDimensions.spacing24,
            child: FloatingActionButton.extended(
              onPressed: () {
                context.push('/add-student').then((_) {
                  if (mounted) {
                    context.read<StudentProvider>().loadStudents();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Yeni Öğrenci'),
            ),
          ),
      ],
    );
  }

  Widget _buildStudentItem(Student student) {
    return StudentListItem(
      name: student.name,
      grade: student.grade,
      subjects: student.subjects,
      isSelected: _isSelectionMode && _selectedStudents.contains(student.id),
      onTap: _isSelectionMode
          ? () => _toggleStudentSelection(student.id)
          : () => context.push('/student/${student.id}'),
      onEditPressed: _isSelectionMode
          ? null
          : () {
              // Düzenleme sayfasına git
              context.push('/edit-student/${student.id}').then((_) {
                if (mounted) {
                  context.read<StudentProvider>().loadStudents();
                }
              });
            },
      onDeletePressed: _isSelectionMode
          ? null
          : () => _showDeleteConfirmation(student),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            'Henüz öğrenci eklenmemiş',
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
                context.push('/add-student');
              },
              icon: const Icon(Icons.add),
              label: const Text('Öğrenci Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withAlpha(128),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Text(
            'Arama kriterlerinize uygun öğrenci bulunamadı',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedGrade = '';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Filtreleri Temizle'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: Text(
          '${student.name} adlı öğrenciyi silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteStudent(student.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(String id) async {
    try {
      await context.read<StudentProvider>().deleteStudent(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Öğrenci başarıyla silindi'),
            backgroundColor: AppColors.success,
          ),
        );
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

  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seçili Öğrencileri Sil'),
        content: Text(
          '${_selectedStudents.length} adet öğrenciyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBulkStudents();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBulkStudents() async {
    setState(() {
      _isSelectionMode = false;
    });

    int successCount = 0;
    int errorCount = 0;

    try {
      for (var id in _selectedStudents) {
        try {
          await context.read<StudentProvider>().deleteStudent(id);
          successCount++;
        } catch (e) {
          errorCount++;
        }
      }

      _selectedStudents.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorCount > 0
                  ? '$successCount öğrenci silindi, $errorCount öğrenci silinemedi'
                  : '$successCount öğrenci başarıyla silindi',
            ),
            backgroundColor: errorCount > 0
                ? AppColors.warning
                : AppColors.success,
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
