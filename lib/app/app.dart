import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/students/presentation/providers/student_provider.dart';
import '../features/lessons/presentation/providers/lesson_provider.dart';
import '../features/fees/presentation/providers/fee_provider.dart';
import '../services/database/database_service.dart';
import '../core/data/database_helper.dart';
import '../core/constants/app_constants.dart';

class DersPlanlamaApp extends StatelessWidget {
  const DersPlanlamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Database servisini oluştur
    final databaseHelper = DatabaseHelper();
    final databaseService = DatabaseService(databaseHelper);

    return MultiProvider(
      providers: [
        // Database servisi provider
        Provider<DatabaseService>.value(value: databaseService),

        // Feature providers
        ChangeNotifierProvider(
          create: (context) => StudentProvider(databaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => LessonProvider(databaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => FeeProvider(databaseService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}
