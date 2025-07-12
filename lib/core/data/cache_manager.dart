import 'dart:async';
import 'dart:collection';

/// Önbellek giriş sınıfı
class CacheEntry<T> {
  final T value;
  final DateTime expiry;

  CacheEntry(this.value, Duration ttl) : expiry = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Önbellek yöneticisi
///
/// Bu sınıf, önbellek yönetimi sağlayarak uygulama performansını artırır.
/// Sık kullanılan verileri belirli bir süre boyunca bellekte tutarak,
/// tekrarlanan veritabanı sorguları veya API isteklerini azaltır.
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();

  // Önbellek için maksimum boyut (öğe sayısı)
  int _maxSize = 100;

  // Önbellek verilerini tutan map
  final _cache = HashMap<String, CacheEntry<dynamic>>();

  // Önbellek güncellemelerini dinlemek için controller
  final _cacheUpdatedController = StreamController<String>.broadcast();

  // Önbellek güncellemelerini dinlemek için stream
  Stream<String> get onCacheUpdated => _cacheUpdatedController.stream;

  // Periyodik temizleme için timer
  Timer? _cleanupTimer;

  factory CacheManager({int maxSize = 100}) {
    _instance._maxSize = maxSize;
    return _instance;
  }

  CacheManager._internal() {
    // Düzenli aralıklarla süresi dolmuş önbellek girişlerini temizle
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanExpiredEntries();
    });
  }

  /// Önbellekten bir değer alır.
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T;
  }

  /// Önbelleğe bir değer ekler.
  void set<T>(String key, T value, {Duration ttl = const Duration(hours: 1)}) {
    // Maksimum boyut aşıldıysa, en eski giriş silinir
    if (_cache.length >= _maxSize && !_cache.containsKey(key)) {
      _evictOldest();
    }

    _cache[key] = CacheEntry<T>(value, ttl);
    _cacheUpdatedController.add(key);
  }

  /// Bir anahtarın önbellekte olup olmadığını kontrol eder.
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Önbellekten bir değeri kaldırır.
  void remove(String key) {
    _cache.remove(key);
    _cacheUpdatedController.add(key);
  }

  /// Belirli bir prefixle başlayan tüm önbellek girişlerini kaldırır.
  void removeByPrefix(String prefix) {
    final keys = _cache.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keys) {
      _cache.remove(key);
      _cacheUpdatedController.add(key);
    }
  }

  /// Tüm önbelleği temizler.
  void clear() {
    _cache.clear();
    _cacheUpdatedController.add('clear');
  }

  /// Süresi dolmuş tüm girişleri temizler.
  void _cleanExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.expiry.isBefore(now))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheUpdatedController.add(key);
    }
  }

  /// En eski önbellek girişini kaldırır (LRU - Least Recently Used politikası).
  void _evictOldest() {
    if (_cache.isEmpty) return;

    // Basitleştirilmiş LRU: En erken sona erecek giriş silinir
    String? oldestKey;
    DateTime? oldestExpiry;

    for (final entry in _cache.entries) {
      if (oldestExpiry == null || entry.value.expiry.isBefore(oldestExpiry)) {
        oldestKey = entry.key;
        oldestExpiry = entry.value.expiry;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _cacheUpdatedController.add(oldestKey);
    }
  }

  /// Mevcut önbellekteki giriş sayısını döndürür.
  int get size => _cache.length;

  /// Servis kapatılırken kaynakları serbest bırakır.
  void dispose() {
    _cleanupTimer?.cancel();
    _cacheUpdatedController.close();
  }
}
