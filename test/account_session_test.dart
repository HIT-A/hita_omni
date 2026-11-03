import 'dart:convert';

import 'package:academic_api/academic_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AccountSession buildSession({String token = 'token-a'}) {
    return AccountSession(
      providerId: 'hit.shenzhen',
      username: '20240001',
      credentials: <String, String>{'accessToken': token},
      cookies: const <String, String>{'JSESSIONID': 'abc'},
      profile: const <String, String>{
        'studentId': '20240001',
        'name': '张三',
        'school': '计算学部',
        'studentType': 'undergraduate',
        'studentTypeLabel': '本科生',
      },
      signedInAt: DateTime(2026, 9, 1, 8),
    );
  }

  test('session identity is stable and changes with the token', () {
    final first = buildSession();
    final second = buildSession();
    final other = buildSession(token: 'token-b');

    expect(first.sessionId, second.sessionId);
    expect(first.sessionId, isNot(other.sessionId));
    expect(first.sessionId, contains('hit.shenzhen:20240001:'));
  });

  test('session round-trips through JSON', () {
    final session = buildSession();
    final decoded = jsonDecode(jsonEncode(session.toJson()));
    final restored = AccountSession.fromJson(decoded as Map<String, dynamic>);

    expect(restored.sessionId, session.sessionId);
    expect(restored.displayName, '张三');
    expect(restored.studentTypeLabel, '本科生');
    expect(restored.credentials['accessToken'], 'token-a');
    expect(restored.cookies['JSESSIONID'], 'abc');
  });

  test('migrates the v1 campus session shape', () {
    final restored = AccountSession.fromJson(<String, dynamic>{
      'campus': 'harbin',
      'username': '20240001',
      'accessToken': 'legacy-token',
      'studentId': '20240001',
      'name': '李四',
      'school': '计算学部',
      'studentType': 'graduate',
      'cookies': <String, dynamic>{'JSESSIONID': 'legacy'},
      'signedInAt': '2026-09-01T08:00:00.000',
    });

    expect(restored.providerId, 'hit.harbin');
    expect(restored.credentials['accessToken'], 'legacy-token');
    expect(restored.profile['studentType'], 'graduate');
    expect(restored.cookies['JSESSIONID'], 'legacy');
  });
}
