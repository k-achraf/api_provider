/// Configuration for the in-memory response cache.
///
/// Pass a [CacheConfig] to [ApiProviderConfig.cache] to enable transparent
/// GET response caching with a configurable time-to-live.
///
/// Only GET requests are cached. The cache key is the full URL including
/// query parameters. Calling [ApiProvider.clearCache] evicts all entries.
///
/// ### Example
/// ```dart
/// ApiProvider.instance.init(ApiProviderConfig(
///   'https://api.example.com',
///   cache: CacheConfig(ttl: Duration(minutes: 5)),
/// ));
/// ```
class CacheConfig {
  /// How long a cached response remains valid.
  ///
  /// After this duration the entry is considered stale and a real network
  /// request is made on the next call.
  final Duration ttl;

  /// Maximum number of entries to keep in the cache.
  ///
  /// When the limit is exceeded the oldest entry is evicted (LRU-style).
  /// Defaults to 100.
  final int maxSize;

  /// Creates a [CacheConfig] with the given TTL and optional [maxSize].
  const CacheConfig({
    required this.ttl,
    this.maxSize = 100,
  });
}

/// Internal entry stored in the cache.
class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// A simple in-memory LRU cache used by the cache interceptor.
class ApiCache {
  final CacheConfig config;

  /// Insertion-ordered map used for LRU eviction.
  final _store = <String, _CacheEntry>{};

  ApiCache(this.config);

  /// Returns the cached value for [key] if present and not expired.
  dynamic get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }
    // Re-insert to mark as recently used (LRU)
    _store.remove(key);
    _store[key] = entry;
    return entry.data;
  }

  /// Stores [data] under [key] with the configured TTL.
  void set(String key, dynamic data) {
    if (_store.length >= config.maxSize) {
      // Evict the oldest (first) entry
      _store.remove(_store.keys.first);
    }
    _store[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(config.ttl),
    );
  }

  /// Removes all entries from the cache.
  void clear() => _store.clear();

  /// Number of entries currently in the cache.
  int get size => _store.length;
}
