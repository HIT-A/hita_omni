import 'http_types.dart';

/// Cookies for one academic origin.
///
/// The HIT endpoints used by the core are single-origin, so domain and path
/// matching is intentionally unnecessary here. Every absorbed cookie is sent
/// back to that origin.
final class CookieJar {
  CookieJar([Map<String, String>? initial])
    : _cookies = <String, String>{...?initial};

  final Map<String, String> _cookies;

  Map<String, String> get values => Map<String, String>.unmodifiable(_cookies);

  void absorb(Iterable<HttpCookieData> cookies) {
    for (final cookie in cookies) {
      if (cookie.name.isEmpty) {
        continue;
      }
      _cookies[cookie.name] = cookie.value;
    }
  }

  String? get header {
    if (_cookies.isEmpty) {
      return null;
    }
    return _cookies.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('; ');
  }
}
