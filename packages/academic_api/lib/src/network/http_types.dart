class HttpCookieData {
  const HttpCookieData({required this.name, required this.value});

  final String name;
  final String value;
}

class HttpRequestSpec {
  const HttpRequestSpec({
    required this.method,
    required this.uri,
    this.headers = const <String, String>{},
    this.body,
    this.timeout = const Duration(seconds: 20),
    this.followRedirects = true,
  });

  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final String? body;
  final Duration timeout;
  final bool followRedirects;
}

class HttpResponseData {
  const HttpResponseData({
    required this.statusCode,
    required this.body,
    required this.headers,
    this.cookies = const <HttpCookieData>[],
    this.finalUri,
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final List<HttpCookieData> cookies;
  final Uri? finalUri;
}

abstract interface class HttpTransport {
  Future<HttpResponseData> send(HttpRequestSpec request);
}

class HttpTransportException implements Exception {
  HttpTransportException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'HttpTransportException: $message';
}
