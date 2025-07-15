import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/core/navigation/app_router.dart';
import 'package:ders_planlayici/core/theme/app_theme.dart';
import 'package:ders_planlayici/features/fees/data/repositories/fee_repository.dart';
import 'package:ders_planlayici/features/fees/data/repositories/payment_repository.dart';
import 'package:ders_planlayici/features/fees/data/repositories/payment_transaction_repository.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/fee_provider.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_provider.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/payment_transaction_provider.dart';
import 'package:ders_planlayici/features/fees/presentation/providers/fee_management_provider.dart';
import 'package:ders_planlayici/features/lessons/data/repositories/lesson_repository.dart';
import 'package:ders_planlayici/features/lessons/data/repositories/recurring_pattern_repository.dart';
import 'package:ders_planlayici/features/lessons/domain/services/recurring_lesson_service.dart';
import 'package:ders_planlayici/features/lessons/presentation/providers/lesson_provider.dart';
import 'package:ders_planlayici/features/settings/data/repositories/app_settings_repository.dart';
import 'package:ders_planlayici/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:ders_planlayici/features/settings/presentation/providers/theme_provider.dart';
import 'package:ders_planlayici/features/students/data/repositories/student_repository.dart';
import 'package:ders_planlayici/features/students/presentation/providers/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';

class DersPlanlamaApp extends StatelessWidget {
  const DersPlanlamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    // Repositories & Services
    final appSettingsRepository = AppSettingsRepository(dbHelper);
    final studentRepository = StudentRepository(dbHelper);
    final recurringLessonService = RecurringLessonService();
    final recurringPatternRepository = RecurringPatternRepository(dbHelper);
    final lessonRepository = LessonRepository(
      dbHelper,
      recurringLessonService,
      recurringPatternRepository,
    );
    final feeRepository = FeeRepository(dbHelper);
    final paymentRepository = PaymentRepository(dbHelper);
    final paymentTransactionRepository = PaymentTransactionRepository(dbHelper);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppSettingsProvider(appSettingsRepository),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider(appSettingsRepository)..loadTheme(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              StudentProvider(studentRepository)..loadStudents(),
        ),
        ChangeNotifierProxyProvider2<
          AppSettingsProvider,
          StudentProvider,
          LessonProvider
        >(
          create: (context) => LessonProvider(
            lessonRepository,
            context.read<AppSettingsProvider>(),
            context.read<StudentProvider>(),
          ),
          update: (context, appSettingsProvider, studentProvider, previous) {
            previous?.updateDependencies(appSettingsProvider, studentProvider);
            return previous ??
                LessonProvider(
                  lessonRepository,
                  appSettingsProvider,
                  studentProvider,
                );
          },
        ),
        ChangeNotifierProvider(
          create: (context) => FeeProvider(feeRepository)..loadFees(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              PaymentProvider(paymentRepository)..loadPayments(),
        ),
        ChangeNotifierProxyProvider3<
          StudentProvider,
          PaymentProvider,
          LessonProvider,
          FeeManagementProvider
        >(
          create: (context) => FeeManagementProvider(
            context.read<StudentProvider>(),
            context.read<PaymentProvider>(),
            context.read<LessonProvider>(),
          ),
          update:
              (
                context,
                studentProvider,
                paymentProvider,
                lessonProvider,
                feeManagementProvider,
              ) {
                feeManagementProvider?.updateDependencies(
                  studentProvider,
                  paymentProvider,
                  lessonProvider,
                );
                return feeManagementProvider ??
                    FeeManagementProvider(
                      studentProvider,
                      paymentProvider,
                      lessonProvider,
                    );
              },
        ),
        ChangeNotifierProvider(
          create: (context) =>
              PaymentTransactionProvider(paymentTransactionRepository),
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
