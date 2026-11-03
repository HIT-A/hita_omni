import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:academic_api/academic_api.dart';
import 'package:provider_hit/provider_hit.dart';

const _publicKey =
    'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCgPLoJLt5v+gzsl5fsahkKQC87kog'
    'MR2999RdtYYfd4wpsLViwQg2lLQUWOOXPYQMypOo74wz0fY6mxRutuBcUVEUE8RifnGt'
    'kkEikrgR4q+fgqvNQCnuWCI/SOMG4aJl6W7Qu1OxHGwjHfJ1svQ7JiMhldBxSTFQqEF'
    'BeTmkCQIDAQAB';

class _RecordingTransport implements HttpTransport {
  final List<HttpRequestSpec> requests = <HttpRequestSpec>[];
  int _ldapCount = 0;

  @override
  Future<HttpResponseData> send(HttpRequestSpec request) async {
    requests.add(request);
    final path = request.uri.path;
    if (path.endsWith('/component/queryApplicationSetting/rsa')) {
      return HttpResponseData(
        statusCode: 200,
        body: '{"code":0,"content":"0"}',
        headers: const <String, String>{},
        cookies: const <HttpCookieData>[
          HttpCookieData(name: 'route', value: 'session-route'),
        ],
      );
    }
    if (path.endsWith('/c_raskey')) {
      return HttpResponseData(
        statusCode: 200,
        body: jsonEncode(<String, dynamic>{
          'CLIENT_RSA_EXPONENT': _publicKey,
          'CLIENT_RSA_MODULUS': '10001',
        }),
        headers: const <String, String>{},
      );
    }
    if (path.endsWith('/authentication/ldap')) {
      _ldapCount++;
      final fields = Uri.splitQueryString(request.body ?? '');
      final password = fields['password'] ?? '';
      final looksEncrypted = password.length > 100;
      if (!looksEncrypted) {
        return HttpResponseData(
          statusCode: 200,
          body: '{"code":500,"msg":"用户名或密码错误！！"}',
          headers: const <String, String>{},
        );
      }
      return HttpResponseData(
        statusCode: 200,
        body: jsonEncode(<String, dynamic>{
          'access_token': 'token-123',
          'refresh_token': 'refresh-123',
          'data': <String, dynamic>{'pylx': '1', 'yhxm': '张三', 'bmmc': '计算学部'},
          'info': <String, dynamic>{'yhdm': '20240001'},
        }),
        headers: const <String, String>{},
      );
    }
    return HttpResponseData(
      statusCode: 404,
      body: 'not found',
      headers: const <String, String>{},
    );
  }

  int get ldapCount => _ldapCount;
}

void main() {
  test('falls back to the X.509 key when plaintext login fails', () async {
    final transport = _RecordingTransport();
    final api = ShenzhenAuthApi(transport);

    final result = await api.login(
      username: '20240001',
      password: 'secret-password',
    );

    expect(result.accessToken, 'token-123');
    expect(result.refreshToken, 'refresh-123');
    expect(result.name, '张三');
    expect(result.studentId, '20240001');
    expect(result.school, '计算学部');
    expect(transport.ldapCount, 3);

    final raskeyRequest = transport.requests[1];
    expect(raskeyRequest.uri.path, '/incoSpringBoot/c_raskey');
    expect(raskeyRequest.headers['cookie'], 'route=session-route');

    final ldapRequests = transport.requests
        .where((request) => request.uri.path.endsWith('/authentication/ldap'))
        .toList();
    expect(ldapRequests, hasLength(3));
    final encryptedFields = Uri.splitQueryString(ldapRequests.last.body ?? '');
    final cipherText = base64Decode(encryptedFields['password']!);
    expect(cipherText, hasLength(128));
    expect(encryptedFields['password'], isNot('secret-password'));
  });
}
