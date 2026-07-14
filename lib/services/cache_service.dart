/// In-memory cache placeholder. No feature needs cross-session caching yet —
/// this exists so a future one (e.g. caching hall listings) has a home
/// without inventing a new layer at that point.
class CacheService {
  final Map<String, Object?> _store = {};

  T? read<T>(String key) => _store[key] as T?;

  void write<T>(String key, T value) => _store[key] = value;

  void clear() => _store.clear();
}
