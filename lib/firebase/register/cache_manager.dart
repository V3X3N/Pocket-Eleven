class CacheManager {
  // Simple cache with automatic cleanup
  static final Map<String, bool> _emailCache = {};
  static DateTime _lastCacheClean = DateTime.now();

  static void cleanCacheIfNeeded() {
    if (DateTime.now().difference(_lastCacheClean).inMinutes > 5) {
      _emailCache.clear();
      _lastCacheClean = DateTime.now();
    }
  }

  static bool? getCachedEmail(String email) {
    cleanCacheIfNeeded();
    return _emailCache[email];
  }

  static void cacheEmail(String email, bool exists) {
    _emailCache[email] = exists;
  }

  static void clearAllCaches() {
    _emailCache.clear();
  }
}
