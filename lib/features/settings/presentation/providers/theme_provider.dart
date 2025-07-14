import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/settings/data/repositories/app_settings_repository.dart';

class ThemeProvider extends ChangeNotifier {

  ThemeProvider(this._repository);
  final AppSettingsRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> _executeAction(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTheme() async {
    await _executeAction(() async {
      final settings = await _repository.getSettings();
      _themeMode = settings.themeMode;
    });
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    await _executeAction(() async {
      _themeMode = themeMode;
      final currentSettings = await _repository.getSettings();
      final newSettings = currentSettings.copyWith(themeMode: themeMode);
      await _repository.saveSettings(newSettings);
    });
  }
}
