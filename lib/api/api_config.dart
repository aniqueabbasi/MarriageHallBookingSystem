class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:5053';

  /// The backend returns hall image paths relative to itself (e.g.
  /// "/uploads/halls/abc.jpg") — this resolves them to an absolute URL the
  /// device can actually load. Already-absolute URLs pass through unchanged.
  static String? resolveUrl(String? path) {
    if (path == null || path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$baseUrl$path';
  }
}
