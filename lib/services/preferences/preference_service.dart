import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama tercihlerini yönetmek için kullanılan servis sınıfı.
///
/// Bu sınıf, SharedPreferences kullanarak uygulama ayarlarını
/// kaydetmek ve okumak için kullanılır.
class PreferenceService {
  factory PreferenceService() => _instance;

  PreferenceService._internal();
  static final PreferenceService _instance = PreferenceService._internal();
  static SharedPreferences? _preferences;

  /// Preferences değiştiğinde bildirim göndermek için stream controller
  final _preferenceChangedController = StreamController<String>.broadcast();

  /// Preferences değişim stream'i
  Stream<String> get onPreferenceChanged => _preferenceChangedController.stream;

  /// Preference servisini başlatır
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
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
  Future<bool> setObject(String key, Map<String, dynamic> value) async =>
      setString(key, jsonEncode(value));

  /// Boolean değer okur
  bool? getBool(String key) => _preferences?.getBool(key);

  /// String değer okur
  String? getString(String key) => _preferences?.getString(key);

  /// Integer değer okur
  int? getInt(String key) => _preferences?.getInt(key);

  /// Double değer okur
  double? getDouble(String key) => _preferences?.getDouble(key);

  /// String listesi okur
  List<String>? getStringList(String key) => _preferences?.getStringList(key);

  /// Obje okur (JSON'dan)
  Map<String, dynamic>? getObject(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } on Exception {
      return null;
    }
  }

  /// Belirtilen anahtar için varsayılan bir boolean değer döndürür
  bool getBoolWithDefault(String key, bool defaultValue) =>
      getBool(key) ?? defaultValue;

  /// Belirtilen anahtar için varsayılan bir string değer döndürür
  String getStringWithDefault(String key, String defaultValue) =>
      getString(key) ?? defaultValue;

  /// Belirtilen anahtar için varsayılan bir integer değer döndürür
  int getIntWithDefault(String key, int defaultValue) =>
      getInt(key) ?? defaultValue;

  /// Belirtilen anahtar için varsayılan bir double değer döndürür
  double getDoubleWithDefault(String key, double defaultValue) =>
      getDouble(key) ?? defaultValue;

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
