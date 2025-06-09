import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/calendar/presentation/pages/calendar_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/students_page.dart';
import 'package:ders_planlayici/features/settings/presentation/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const CalendarPage(),
    const StudentsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Takvim',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Öğrenciler',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
} 