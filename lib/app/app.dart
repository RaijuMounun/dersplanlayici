import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ders_planlayici/core/theme/app_theme.dart';
import 'package:ders_planlayici/features/home/presentation/pages/home_page.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';

class DersPlanlamaApp extends StatelessWidget {
  const DersPlanlamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
      ],
      child: MaterialApp(
        title: 'Ders Planlayıcı',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
} 