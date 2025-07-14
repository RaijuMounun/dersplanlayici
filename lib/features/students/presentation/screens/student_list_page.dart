import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:ders_planlayici/core/theme/app_dimensions.dart';
import 'package:ders_planlayici/core/widgets/responsive_layout.dart';
import 'package:ders_planlayici/core/utils/responsive_utils.dart';
import 'package:ders_planlayici/features/students/presentation/widgets/student_list_item.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';
import 'package:ders_planlayici/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:ders_planlayici/core/error/error_handler.dart';
import 'package:ders_planlayici/core/widgets/app_dialogs.dart';
import 'package:ders_planlayici/core/navigation/route_names.dart';

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
  bool _isSearching = false;
  List<Student> _searchResults = [];
  Timer? _debounce;

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

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
        });

        if (_searchQuery.isNotEmpty) {
          _performSearch();
        } else {
          setState(() {
            _isSearching = false;
            _searchResults = [];
          });
        }
      }
    });
  }

  Future<void> _performSearch() async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await context.read<StudentProvider>().searchStudents(
        _searchQuery,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arama yapılırken bir hata oluştu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
    // Aktif bir arama varsa ve sonuçlar mevcutsa, arama sonuçlarını kullan
    if (_searchQuery.isNotEmpty && _searchResults.isNotEmpty) {
      // Eğer sınıf filtresi aktifse, arama sonuçlarını sınıfa göre filtrele
      if (_selectedGrade.isNotEmpty) {
        return _searchResults
            .where((student) => student.grade == _selectedGrade)
            .toList();
      }
      return _searchResults;
    }

    // Sadece sınıf filtresi varsa
    if (_selectedGrade.isNotEmpty) {
      return students
          .where((student) => student.grade == _selectedGrade)
          .toList();
    }

    // Hiçbir filtre yoksa
    return students;
  }

  @override
  Widget build(BuildContext context) => Consumer<StudentProvider>(
    builder: (context, studentProvider, child) {
      if (studentProvider.isLoading || _isSearching) {
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

  Widget _buildSearchFilterBar() => Padding(
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

  Widget _buildSearchField() => TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Öğrenci ara...',
      prefixIcon: _isSearching
          ? Container(
              margin: const EdgeInsets.all(14),
              width: 10,
              height: 10,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search),
      suffixIcon: _searchQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _searchController.clear,
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
      ),
    ),
  );

  Widget _buildGradeFilter() => DropdownButtonFormField<String>(
    value: _selectedGrade,
    decoration: InputDecoration(
      hintText: 'Sınıf Filtresi',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
      ),
    ),
    items: _gradeOptions
        .map(
          (grade) => DropdownMenuItem<String>(
            value: grade,
            child: Text(grade.isEmpty ? 'Tüm Sınıflar' : grade),
          ),
        )
        .toList(),
    onChanged: (value) {
      setState(() {
        _selectedGrade = value ?? '';
      });
    },
  );

  Widget _buildSelectionAppBar(List<Student> students) => Container(
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

  Widget _buildMobileList(List<Student> students) => Stack(
    children: [
      ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spacing8),
        itemCount: students.length,
        itemBuilder: (context, index) => GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _toggleStudentSelection(students[index].id);
            }
          },
          child: _buildStudentItem(students[index]),
        ),
      ),
      if (!_isSelectionMode)
        Positioned(
          bottom: AppDimensions.spacing16,
          right: AppDimensions.spacing16,
          child: FloatingActionButton(
            heroTag: 'student_list_fab',
            onPressed: () {
              context.pushNamed(RouteNames.addStudent);
            },
            child: const Icon(Icons.add),
          ),
        ),
    ],
  );

  Widget _buildTabletList(List<Student> students) => Stack(
    children: [
      ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        itemCount: students.length,
        itemBuilder: (context, index) => GestureDetector(
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
        ),
      ),
      if (!_isSelectionMode)
        Positioned(
          bottom: AppDimensions.spacing24,
          right: AppDimensions.spacing24,
          child: FloatingActionButton.extended(
            heroTag: 'student_list_tablet_fab',
            onPressed: () {
              context.pushNamed(RouteNames.addStudent);
            },
            icon: const Icon(Icons.add),
            label: const Text('Yeni Öğrenci'),
          ),
        ),
    ],
  );

  Widget _buildDesktopList(List<Student> students) => Stack(
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
        itemBuilder: (context, index) => GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _toggleStudentSelection(students[index].id);
            }
          },
          child: _buildStudentItem(students[index]),
        ),
      ),
      if (!_isSelectionMode)
        Positioned(
          bottom: AppDimensions.spacing24,
          right: AppDimensions.spacing24,
          child: FloatingActionButton.extended(
            heroTag: 'student_list_desktop_fab',
            onPressed: () {
              context.pushNamed(RouteNames.addStudent);
            },
            icon: const Icon(Icons.add),
            label: const Text('Yeni Öğrenci'),
          ),
        ),
    ],
  );

  Widget _buildStudentItem(Student student) => StudentListItem(
    name: student.name,
    grade: student.grade,
    subjects: student.subjects,
    isSelected: _isSelectionMode && _selectedStudents.contains(student.id),
    onTap: _isSelectionMode
        ? () => _toggleStudentSelection(student.id)
        : () => context.pushNamed(
            RouteNames.studentDetails,
            pathParameters: {'id': student.id},
          ),
    onEditPressed: _isSelectionMode
        ? null
        : () {
            // Düzenleme sayfasına git
            context.pushNamed(
              RouteNames.editStudent,
              pathParameters: {'id': student.id},
            );
          },
    onDeletePressed: _isSelectionMode
        ? null
        : () => _showDeleteConfirmation(student),
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
              context.pushNamed(RouteNames.addStudent);
            },
            icon: const Icon(Icons.add),
            label: const Text('Öğrenci Ekle'),
          ),
        ),
      ],
    ),
  );

  Widget _buildNoResultsState() => Center(
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
          _searchQuery.isNotEmpty
              ? '"$_searchQuery" ile ilgili hiçbir sonuç bulunamadı'
              : 'Filtre ile eşleşen sonuç bulunamadı',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  void _showDeleteConfirmation(Student student) async {
    final appSettingsProvider = Provider.of<AppSettingsProvider>(
      context,
      listen: false,
    );
    final studentProvider = context.read<StudentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    bool confirmed = true;

    if (appSettingsProvider.settings.confirmBeforeDelete) {
      confirmed = await showConfirmationDialog(
        context: context,
        title: 'Öğrenciyi Sil',
        content: const Text(
          'Bu öğrenciyi ve ilgili tüm verilerini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        confirmText: 'Sil',
      );
    }

    if (!confirmed) return;

    try {
      await studentProvider.deleteStudent(student.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('${student.name} başarıyla silindi.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AppErrorHandler.handleError(context, e);
    }
  }

  void _showBulkDeleteConfirmation() async {
    final appSettingsProvider = Provider.of<AppSettingsProvider>(
      context,
      listen: false,
    );
    final studentProvider = context.read<StudentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    bool confirmed = true;

    if (appSettingsProvider.settings.confirmBeforeDelete) {
      confirmed = await showConfirmationDialog(
        context: context,
        title: '${_selectedStudents.length} Öğrenciyi Sil',
        content: const Text(
          'Seçili öğrencileri ve ilgili tüm verilerini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        confirmText: 'Sil',
      );
    }

    if (!confirmed) return;

    try {
      int successCount = 0;
      int errorCount = 0;

      for (var id in _selectedStudents) {
        try {
          await studentProvider.deleteStudent(id);
          successCount++;
        } on Exception {
          errorCount++;
        }
      }

      if (!mounted) return;
      setState(() {
        _isSelectionMode = false;
        _selectedStudents.clear();
      });

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '$successCount öğrenci başarıyla silindi. $errorCount öğrenci silinemedi.',
          ),
          backgroundColor: errorCount > 0
              ? AppColors.warning
              : AppColors.success,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AppErrorHandler.handleError(context, e);
    }
  }
}
