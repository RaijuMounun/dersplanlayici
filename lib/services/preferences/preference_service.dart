import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Uygulama tercihlerini yönetmek için kullanılan servis sınıfı.
///
/// Bu sınıf, SharedPreferences kullanarak uygulama ayarlarını
/// kaydetmek ve okumak için kullanılır.
class PreferenceService {
  static final PreferenceService _instance = PreferenceService._internal();
  static SharedPreferences? _preferences;

  /// Preferences değiştiğinde bildirim göndermek için stream controller
  final _preferenceChangedController = StreamController<String>.broadcast();

  /// Preferences değişim stream'i
  Stream<String> get onPreferenceChanged => _preferenceChangedController.stream;

  factory PreferenceService() => _instance;

  PreferenceService._internal();

  /// Preference servisini başlatır
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    debugPrint('PreferenceService initialized');
  }

  /// Boolean değer kaydeder
  Future<bool> setBool(String key, bool value) async {
    final prefs = _preferences;
    if (prefs == null) {
      await init();
      return setBool(key, value);
    }

    final result = await prefs.setBool(key, value);
    _preferenceChangedController.add(key);
    return result;
  }

  /// String değer kaydeder
  Future<bool> setString(String key, String value) async {
    final prefs = _preferences;
    if (prefs == null) {
      await init();
      return setString(key, value);
    }

    final result = await prefs.setString(key, value);
    _preferenceChangedController.add(key);
    return result;
  }

  /// Integer değer kaydeder
  Future<bool> setInt(String key, int value) async {
    final prefs = _preferences;
    if (prefs == null) {
      await init();
      return setInt(key, value);
    }

    final result = await prefs.setInt(key, value);
    _preferenceChangedController.add(key);
    return result;
  }

  /// Double değer kaydeder
  Future<bool> setDouble(String key, double value) async {
    final prefs = _preferences;
    if (prefs == null) {
      await init();
      return setDouble(key, value);
    }

    final result = await prefs.setDouble(key, value);
    _preferenceChangedController.add(key);
    return result;
  }

  /// String listesi kaydeder
  Future<bool> setStringList(String key, List<String> value) async {
    final prefs = _preferences;
    if (prefs == null) {
      await init();
      return setStringList(key, value);
    }

    final result = await prefs.setStringList(key, value);
    _preferenceChangedController.add(key);
    return result;
  }

  /// Obje kaydeder (JSON olarak)
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return setString(key, jsonEncode(value));
  }

  /// Boolean değer okur
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  /// String değer okur
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  /// Integer değer okur
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  /// Double değer okur
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  /// String listesi okur
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  /// Obje okur (JSON'dan)
  Map<String, dynamic>? getObject(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to decode JSON for key $key: $e');
      return null;
    }
  }

  /// Belirtilen anahtar için varsayılan bir boolean değer döndürür
  bool getBoolWithDefault(String key, bool defaultValue) {
    return getBool(key) ?? defaultValue;
  }

  /// Belirtilen anahtar için varsayılan bir string değer döndürür
  String getStringWithDefault(String key, String defaultValue) {
    return getString(key) ?? defaultValue;
  }

  /// Belirtilen anahtar için varsayılan bir integer değer döndürür
  int getIntWithDefault(String key, int defaultValue) {
    return getInt(key) ?? defaultValue;
  }

  /// Belirtilen anahtar için varsayılan bir double değer döndürür
  double getDoubleWithDefault(String key, double defaultValue) {
    return getDouble(key) ?? defaultValue;
  }

  /// Verilen anahtarı siler
  Future<bool> remove(String key) async {
    final prefs = _preferences;
    if (prefs == null) {
      await init();
      return remove(key);
    }

    final result = await prefs.remove(key);
    _preferenceChangedController.add(key);
    return result;
  }

  /// Tüm tercihleri temizler
  Future<bool> clear() async {
    final prefs = _preferences;
    if (prefs == null) {
      await init();
      return clear();
    }

    final result = await prefs.clear();
    _preferenceChangedController.add('clear');
    return result;
  }

  /// Servis kapatılırken kaynakları serbest bırakır
  void dispose() {
    _preferenceChangedController.close();
  }
}
