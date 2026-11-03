import 'dart:convert';

import 'cookie_jar.dart';
import 'http_types.dart';

class ApiClient {
  ApiClient({
    required this.transport,
    required this.baseUri,
    CookieJar? cookies,
    this.timeout = const Duration(seconds: 20),
  }) : cookies = cookies ?? CookieJar();

  final HttpTransport transport;
  final Uri baseUri;
  final CookieJar cookies;
  final Duration timeout;

  Future<HttpResponseData> get(
    String path, {
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
  }) {
    return _send(method: 'GET', path: path, headers: headers, timeout: timeout);
  }

  Future<HttpResponseData> postForm(
    String path, {
    Map<String, String> fields = const <String, String>{},
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
  }) {
    return _send(
      method: 'POST',
      path: path,
      headers: <String, String>{
        ...headers,
        'content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: Uri(queryParameters: fields).query,
      timeout: timeout,
    );
  }

  Future<HttpResponseData> postJson(
    String path, {
    Map<String, dynamic> body = const <String, dynamic>{},
    Map<String, String> headers = const <String, String>{},
    Duration? timeout,
  }) {
    return _send(
      method: 'POST',
      path: path,
      headers: <String, String>{
        ...headers,
        'content-type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
      timeout: timeout,
    );
  }

  Future<HttpResponseData> _send({
    required String method,
    required String path,
    required Map<String, String> headers,
    String? body,
    Duration? timeout,
  }) async {
    final cookieHeader = cookies.header;
    final response = await transport.send(
      HttpRequestSpec(
        method: method,
        uri: _resolve(path),
        headers: <String, String>{
          'accept': '*/*',
          'cookie': ?cookieHeader,
          ...headers,
        },
        body: body,
        timeout: timeout ?? this.timeout,
      ),
    );
    cookies.absorb(response.cookies);
    return response;
  }

  Uri _resolve(String path) {
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path
        : '${baseUri.path}/';
    final base = baseUri.replace(path: basePath);
    final relative = path.startsWith('/') ? path.substring(1) : path;
    return base.resolve(relative);
  }
}

Map<String, dynamic>? decodeJsonObject(String body) {
  try {
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

List<Map<String, dynamic>> jsonObjects(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return <Map<String, dynamic>>[
    for (final item in value)
      if (item is Map<String, dynamic>) item,
  ];
}

String jsonString(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  return value is String ? value : '';
}

int jsonInt(Map<String, dynamic>? json, String key, [int fallback = -1]) {
  final value = json?[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

bool isAuthFailure(int statusCode, String body) {
  if (statusCode == 401 || statusCode == 403) {
    return true;
  }
  final json = decodeJsonObject(body);
  if (json != null) {
    final code = jsonInt(json, 'code');
    if (code == 401 || code == 403) {
      return true;
    }
    final message = jsonString(json, 'msg').toLowerCase();
    if (message.contains('token') ||
        message.contains('登录') ||
        message.contains('认证')) {
      return true;
    }
  }
  return false;
}
