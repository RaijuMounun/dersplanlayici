import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/calendar/presentation/pages/calendar_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/students_page.dart';
import 'package:ders_planlayici/features/settings/presentation/pages/settings_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/lessons_page.dart';
import 'package:ders_planlayici/core/widgets/app_bottom_navigation.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';

/// Ana sayfa widget'ı. Bottom navigation bar ile farklı sayfalara geçiş sağlar.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CalendarPage(),
    const LessonsPage(),
    const StudentsPage(),
    const SettingsPage(),
  ];

  final List<String> _titles = ['Takvim', 'Dersler', 'Öğrenciler', 'Ayarlar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _buildActions(),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          AppBottomNavigationItem(label: 'Takvim', icon: Icons.calendar_today),
          AppBottomNavigationItem(label: 'Dersler', icon: Icons.book),
          AppBottomNavigationItem(label: 'Öğrenciler', icon: Icons.people),
          AppBottomNavigationItem(label: 'Ayarlar', icon: Icons.settings),
        ],
      ),
    );
  }

  List<Widget>? _buildActions() {
    // Seçili sayfaya göre app bar için action'ları döndür
    switch (_selectedIndex) {
      case 0: // Takvim
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Takvim arama işlevselliği
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Takvim filtreleme işlevselliği
            },
          ),
        ];
      case 1: // Dersler
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Dersler arama işlevselliği
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Dersler filtreleme işlevselliği
            },
          ),
        ];
      case 2: // Öğrenciler
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Öğrenci arama işlevselliği
            },
          ),
        ];
      case 3: // Ayarlar
        return null;
      default:
        return null;
    }
  }

  Widget? _buildFloatingActionButton() {
    // Seçili sayfaya göre FAB döndür
    switch (_selectedIndex) {
      case 0: // Takvim
        return FloatingActionButton(
          onPressed: () {
            // TODO: Ders ekleme sayfasına yönlendir
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 1: // Dersler
        return FloatingActionButton(
          onPressed: () {
            // TODO: Ders ekleme sayfasına yönlendir
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 2: // Öğrenciler
        return FloatingActionButton(
          onPressed: () {
            // TODO: Öğrenci ekleme sayfasına yönlendir
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.person_add),
        );
      case 3: // Ayarlar
        return null;
      default:
        return null;
    }
  }
}
