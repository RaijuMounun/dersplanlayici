import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import '../utils/responsive_utils.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

/// Ders ekleme/düzenleme formlarında kullanılacak öğrenci seçim widget'ı.
class AppStudentPicker extends StatefulWidget {
  const AppStudentPicker({
    super.key,
    this.initialSelectedId,
    required this.students,
    required this.onStudentSelected,
    this.label,
    this.hint = 'Öğrenci seçin',
    this.enabled = true,
    this.required = false,
    this.showAddButton = false,
    this.onAddPressed,
  });
  final String? initialSelectedId;
  final List<Student> students;
  final Function(String) onStudentSelected;
  final String? label;
  final String hint;
  final bool enabled;
  final bool required;
  final bool showAddButton;
  final VoidCallback? onAddPressed;

  @override
  State<AppStudentPicker> createState() => _AppStudentPickerState();
}

class _AppStudentPickerState extends State<AppStudentPicker> {
  String? _selectedStudentId;
  final TextEditingController _searchController = TextEditingController();
  List<Student> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.initialSelectedId;
    _filteredStudents = List.from(widget.students);

    _searchController.addListener(() {
      _filterStudents(_searchController.text);
    });
  }

  @override
  void didUpdateWidget(AppStudentPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students) {
      _filteredStudents = List.from(widget.students);
      _filterStudents(_searchController.text);
    }

    if (oldWidget.initialSelectedId != widget.initialSelectedId) {
      setState(() {
        _selectedStudentId = widget.initialSelectedId;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStudents = List.from(widget.students);
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredStudents = widget.students
          .where(
            (student) =>
                student.name.toLowerCase().contains(lowerCaseQuery) ||
                student.grade.toLowerCase().contains(lowerCaseQuery),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedStudent = _selectedStudentId != null
        ? widget.students.firstWhere(
            (student) => student.id == _selectedStudentId,
            orElse: () => Student(id: '0', name: '', grade: ''),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(widget.label!, style: theme.textTheme.titleSmall),
              if (widget.required)
                Text(
                  ' *',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
        ],
        // Student Picker Container
        InkWell(
          onTap: widget.enabled ? _showStudentSelectionDialog : null,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(
                Icons.person,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
              suffixIcon: widget.enabled
                  ? Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    )
                  : null,
              filled: true,
              fillColor: widget.enabled
                  ? null
                  : theme.colorScheme.surface.withValues(alpha: 0.5),
              border: null,
              enabledBorder: null,
              focusedBorder: null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedStudent != null && selectedStudent.id != '0'
                        ? selectedStudent.name
                        : widget.hint,
                    style: TextStyle(
                      color:
                          selectedStudent != null && selectedStudent.id != '0'
                          ? theme.textTheme.bodyLarge?.color
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selectedStudent != null &&
                    selectedStudent.id != '0' &&
                    widget.enabled)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedStudentId = null;
                      });
                      widget.onStudentSelected('');
                    },
                    child: Icon(
                      Icons.clear,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showStudentSelectionDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Dialog genişliği responsive olarak ayarlanır
          final dialogWidth = ResponsiveUtils.deviceValue<double>(
            context: context,
            mobile: 320,
            tablet: 400,
            desktop: 500,
          );

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
            ),
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Öğrenci Seç', style: theme.textTheme.titleLarge),
                      if (widget.showAddButton)
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onAddPressed?.call();
                          },
                          icon: const Icon(Icons.add),
                          tooltip: 'Yeni Öğrenci Ekle',
                        ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Arama alanı
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Öğrenci ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Öğrenci listesi
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: _filteredStudents.isEmpty
                          ? Center(
                              child: Text(
                                'Öğrenci bulunamadı',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                final isSelected =
                                    student.id == _selectedStudentId;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surface,
                                    child: Text(
                                      student.name.isNotEmpty
                                          ? student.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    student.name,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  subtitle: Text(
                                    student.grade,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedStudentId = student.id;
                                    });
                                    widget.onStudentSelected(student.id);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
