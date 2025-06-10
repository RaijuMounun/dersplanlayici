import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../utils/responsive_utils.dart';
import 'package:ders_planlayici/features/students/domain/models/student_model.dart';

/// Ders ekleme/düzenleme formlarında kullanılacak öğrenci seçim widget'ı.
class AppStudentPicker extends StatefulWidget {
  final String? initialSelectedId;
  final List<Student> students;
  final Function(String) onStudentSelected;
  final String? label;
  final String hint;
  final bool enabled;
  final bool required;
  final bool showAddButton;
  final VoidCallback? onAddPressed;

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

  @override
  State<AppStudentPicker> createState() => _AppStudentPickerState();
}

class _AppStudentPickerState extends State<AppStudentPicker> {
  String? _selectedStudentId;
  bool _isSearchOpen = false;
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
      _filteredStudents = widget.students.where((student) {
        return student.name.toLowerCase().contains(lowerCaseQuery) ||
            student.grade.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedStudent = _selectedStudentId != null
        ? widget.students.firstWhere(
            (student) => student.id == _selectedStudentId,
            orElse: () => Student(id: "0", name: "", grade: ""),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (widget.required)
                Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
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
              prefixIcon: const Icon(Icons.person, size: 20),
              suffixIcon: widget.enabled
                  ? const Icon(Icons.arrow_drop_down, size: 20)
                  : null,
              filled: true,
              fillColor: widget.enabled
                  ? AppColors.surface
                  : AppColors.disabledBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing12,
                vertical: AppDimensions.spacing8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedStudent != null && selectedStudent.id != 0
                        ? selectedStudent.name
                        : widget.hint,
                    style: TextStyle(
                      color: selectedStudent != null && selectedStudent.id != 0
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : AppColors.textHint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selectedStudent != null &&
                    selectedStudent.id != 0 &&
                    widget.enabled)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedStudentId = null;
                      });
                      widget.onStudentSelected("");
                    },
                    child: Icon(
                      Icons.clear,
                      size: 18,
                      color: AppColors.textSecondary,
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
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Dialog genişliği responsive olarak ayarlanır
            final dialogWidth = ResponsiveUtils.deviceValue<double>(
              context: context,
              mobile: 320,
              tablet: 400,
              desktop: 500,
            );

            return AlertDialog(
              title: const Text('Öğrenci Seç'),
              content: SizedBox(
                width: dialogWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arama alanı
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Öğrenci ara...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearchOpen
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _isSearchOpen = false;
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius8,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing12,
                          vertical: AppDimensions.spacing8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isSearchOpen = value.isNotEmpty;
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacing16),

                    // Öğrenci listesi
                    Flexible(
                      child: _filteredStudents.isEmpty
                          ? const Center(child: Text('Öğrenci bulunamadı'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                final isSelected =
                                    student.id == _selectedStudentId;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getAvatarColor(
                                      student.name,
                                    ),
                                    child: Text(
                                      student.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(student.name),
                                  subtitle: Text(student.grade),
                                  selected: isSelected,
                                  selectedTileColor: AppColors.primary
                                      .withOpacity(0.1),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _selectedStudentId = student.id;
                                    });
                                    widget.onStudentSelected(student.id);
                                  },
                                );
                              },
                            ),
                    ),

                    // Yeni öğrenci ekleme butonu
                    if (widget.showAddButton) ...[
                      const SizedBox(height: AppDimensions.spacing16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onAddPressed?.call();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Yeni Öğrenci Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getAvatarColor(String name) {
    // İsme göre rastgele ama tutarlı renk oluştur
    final colorIndex =
        name.codeUnits.fold<int>(0, (prev, curr) => prev + curr) % 5;
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.exam,
      AppColors.appointment,
    ];
    return colors[colorIndex];
  }
}
