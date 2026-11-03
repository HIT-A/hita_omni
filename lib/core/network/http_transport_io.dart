import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:academic_api/academic_api.dart';

HttpTransport createHttpTransport() => const NativeHttpTransport();

final class NativeHttpTransport implements HttpTransport {
  const NativeHttpTransport();

  @override
  Future<HttpResponseData> send(HttpRequestSpec request) async {
    final client = HttpClient()..connectionTimeout = request.timeout;
    try {
      final httpRequest = await client
          .openUrl(request.method, request.uri)
          .timeout(request.timeout);
      httpRequest
        ..followRedirects = request.followRedirects
        ..maxRedirects = 5;
      request.headers.forEach(httpRequest.headers.set);
      final body = request.body;
      if (body != null) {
        httpRequest.add(utf8.encode(body));
      }

      final response = await httpRequest.close().timeout(request.timeout);
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();
      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name] = values.join(', ');
      });
      return HttpResponseData(
        statusCode: response.statusCode,
        body: utf8.decode(bytes, allowMalformed: true),
        headers: headers,
        cookies: <HttpCookieData>[
          for (final cookie in response.cookies)
            HttpCookieData(name: cookie.name, value: cookie.value),
        ],
        finalUri: response.redirects.isEmpty
            ? request.uri
            : request.uri.resolveUri(response.redirects.last.location),
      );
    } on TimeoutException catch (error) {
      throw HttpTransportException('请求超时，请检查网络后重试', error);
    } on SocketException catch (error) {
      throw HttpTransportException('无法连接到服务器，请检查网络', error);
    } on HandshakeException catch (error) {
      throw HttpTransportException('安全连接失败，请检查网络环境', error);
    } on HttpException catch (error) {
      throw HttpTransportException('网络请求失败', error);
    } finally {
      client.close(force: true);
    }
  }
}
