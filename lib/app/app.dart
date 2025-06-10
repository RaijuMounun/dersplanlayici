import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/students/presentation/providers/student_provider.dart';
import '../features/lessons/presentation/providers/lesson_provider.dart';
import '../features/fees/presentation/providers/fee_provider.dart';
import '../features/fees/presentation/providers/payment_provider.dart';
import '../features/fees/data/repositories/payment_repository.dart';
import '../features/settings/presentation/providers/theme_provider.dart';
import '../features/settings/presentation/providers/app_settings_provider.dart';
import '../features/settings/data/repositories/app_settings_repository.dart';
import '../services/database/database_service.dart';
import '../core/data/database_helper.dart';
import '../core/constants/app_constants.dart';
import '../core/navigation/app_router.dart';

class DersPlanlamaApp extends StatelessWidget {
  const DersPlanlamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Database servisini oluştur
    final databaseHelper = DatabaseHelper();
    final databaseService = DatabaseService(databaseHelper);

    // Settings repository oluştur
    final appSettingsRepository = AppSettingsRepository(
      databaseHelper: databaseHelper,
    );

    // Payment repository oluştur
    final paymentRepository = PaymentRepository(databaseService);

    return MultiProvider(
      providers: [
        // Database servisi provider
        Provider<DatabaseService>.value(value: databaseService),

        // Theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // Settings provider
        ChangeNotifierProvider(
          create: (context) => AppSettingsProvider(appSettingsRepository),
        ),

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
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(paymentRepository),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
