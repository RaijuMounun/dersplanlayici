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
import '../services/preferences/preference_service.dart';
import '../core/data/database_helper.dart';
import '../core/data/cache_manager.dart';
import '../core/error/error_logger.dart';
import '../core/constants/app_constants.dart';
import '../core/navigation/app_router.dart';

class DersPlanlamaApp extends StatefulWidget {
  const DersPlanlamaApp({super.key});

  @override
  State<DersPlanlamaApp> createState() => _DersPlanlamaAppState();
}

class _DersPlanlamaAppState extends State<DersPlanlamaApp> {
  final PreferenceService _preferenceService = PreferenceService();
  final CacheManager _cacheManager = CacheManager();
  final ErrorLogger _errorLogger = ErrorLogger();
  late final DatabaseHelper _databaseHelper;
  late final DatabaseService _databaseService;

  bool _isInitialized = false;
  Object? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Servisleri başlat
      await _preferenceService.init();
      await _errorLogger.info('PreferenceService initialized', tag: 'App');

      // Database servislerini oluştur
      _databaseHelper = DatabaseHelper();
      _databaseService = DatabaseService(_databaseHelper);
      await _databaseService.initDatabase();
      await _errorLogger.info('DatabaseService initialized', tag: 'App');

      setState(() {
        _isInitialized = true;
      });
    } on Exception catch (e, stackTrace) {
      await _errorLogger.error(
        'Failed to initialize services',
        tag: 'App',
        error: e,
        stackTrace: stackTrace,
      );
      setState(() {
        _initializationError = e;
      });
    }
  }

  @override
  void dispose() {
    // Servisleri kapat
    _errorLogger.info('Disposing services', tag: 'App');
    _errorLogger.dispose();
    _cacheManager.dispose();
    _preferenceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Başlatma ekranı
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: _initializationError != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Uygulama başlatılamadı',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _initializationError.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Settings repository oluştur
    final appSettingsRepository = AppSettingsRepository(
      databaseHelper: _databaseHelper,
    );

    // Payment repository oluştur
    final paymentRepository = PaymentRepository(_databaseService);

    return MultiProvider(
      providers: [
        // Servis providers
        Provider<DatabaseService>.value(value: _databaseService),
        Provider<PreferenceService>.value(value: _preferenceService),
        Provider<CacheManager>.value(value: _cacheManager),
        Provider<ErrorLogger>.value(value: _errorLogger),

        // Theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // Settings provider
        ChangeNotifierProvider(
          create: (context) => AppSettingsProvider(appSettingsRepository),
        ),

        // Feature providers
        ChangeNotifierProvider(
          create: (context) => StudentProvider(_databaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => LessonProvider(_databaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => FeeProvider(_databaseService),
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
