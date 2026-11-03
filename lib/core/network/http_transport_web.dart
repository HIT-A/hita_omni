import 'dart:async';

import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

import 'package:academic_api/academic_api.dart';

HttpTransport createHttpTransport() {
  final client = BrowserClient()..withCredentials = true;
  return _BrowserHttpTransport(client);
}

final class _BrowserHttpTransport implements HttpTransport {
  _BrowserHttpTransport(this._client);

  final http.Client _client;

  @override
  Future<HttpResponseData> send(HttpRequestSpec request) async {
    try {
      const forbidden = <String>{
        'cookie',
        'connection',
        'user-agent',
        'origin',
        'referer',
        'content-length',
        'host',
      };
      final outgoing = http.Request(request.method, request.uri)
        ..followRedirects = request.followRedirects
        ..headers.addAll(<String, String>{
          for (final entry in request.headers.entries)
            if (!forbidden.contains(entry.key.toLowerCase()))
              entry.key: entry.value,
        });
      final body = request.body;
      if (body != null) {
        outgoing.body = body;
      }
      final response = await _client
          .send(outgoing)
          .timeout(request.timeout)
          .then(http.Response.fromStream);
      return HttpResponseData(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
        finalUri: response.request?.url ?? request.uri,
      );
    } on TimeoutException catch (error) {
      throw HttpTransportException('请求超时，请检查网络后重试', error);
    } on http.ClientException catch (error) {
      throw HttpTransportException('浏览器阻止了请求，请检查网络或跨域设置', error);
    }
  }
}
