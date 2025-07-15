import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ders_planlayici/core/widgets/app_bottom_navigation.dart';

/// Ana sayfa için kabuk (shell) widget'ı.
/// Bottom navigation bar'ı içerir ve sekmeler arasındaki geçişi yönetir.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.navigationShell});

  /// GoRouter tarafından yönetilen navigasyon kabuğu.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
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
