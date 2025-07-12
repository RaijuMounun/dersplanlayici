import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/calendar/presentation/pages/calendar_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/student_list_page.dart';
import 'package:ders_planlayici/features/settings/presentation/pages/settings_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/lessons_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/payment_list_page.dart';
import 'package:ders_planlayici/core/widgets/app_bottom_navigation.dart';

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
    const StudentListPage(),
    const PaymentListPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _pages[_selectedIndex],
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
        AppBottomNavigationItem(label: 'Ödemeler', icon: Icons.payments),
        AppBottomNavigationItem(label: 'Ayarlar', icon: Icons.settings),
      ],
    ),
  );
}
