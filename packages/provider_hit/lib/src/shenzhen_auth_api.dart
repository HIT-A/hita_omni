import 'package:academic_api/academic_api.dart';

import 'hit_campus.dart';
import 'rsa_public_key.dart';

const _baseUrl = 'https://mjw.hitsz.edu.cn/incoSpringBoot';
const _basicAuth = 'Basic aW5jb246MTIzNDU=';
const _userAgent =
    'Mozilla/5.0 (Linux; Android 15; V2182A Build/AP3A.240905.015.A2; wv) '
    'AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 '
    'Chrome/144.0.7559.132 Mobile Safari/537.36 uni-app Html5Plus/1.0';

class ShenzhenAuthApi {
  ShenzhenAuthApi(this._transport);

  final HttpTransport _transport;

  Future<HitLoginResult> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) {
      throw AuthException('请输入教务账号和密码');
    }

    final client = ApiClient(
      transport: _transport,
      baseUri: Uri.parse(_baseUrl),
      timeout: const Duration(seconds: 20),
    );
    final authorization = _headers(_basicAuth, roleCode: '01');
    await client.postForm(
      '/component/queryApplicationSetting/rsa',
      headers: authorization,
    );
    final rsaResponse = await client.postForm(
      '/c_raskey',
      headers: _headers(_basicAuth),
    );
    final rsaKeys = _parseRsaKeys(rsaResponse.body);

    Map<String, dynamic>? lastPayload;
    const roles = <String>['06', '01'];

    for (final role in roles) {
      final response = await client.postForm(
        '/authentication/ldap',
        fields: <String, String>{
          'username': normalizedUsername,
          'password': password,
        },
        headers: _headers(_basicAuth, roleCode: role),
      );
      final payload = decodeJsonObject(response.body);
      lastPayload = payload;
      final result = _resultFromPayload(payload, client.cookies.values);
      if (result != null) {
        return result;
      }
    }

    for (final role in roles) {
      for (final key in rsaKeys) {
        final encrypted = encryptRsaPkcs1(password, key);
        if (encrypted == null) {
          continue;
        }
        final response = await client.postForm(
          '/authentication/ldap',
          fields: <String, String>{
            'username': normalizedUsername,
            'password': encrypted,
          },
          headers: _headers(_basicAuth, roleCode: role),
        );
        final payload = decodeJsonObject(response.body);
        lastPayload = payload;
        final result = _resultFromPayload(payload, client.cookies.values);
        if (result != null) {
          return result;
        }
      }
    }

    final message = _string(lastPayload, 'msg');
    throw AuthException(
      message.isEmpty ? '账号或密码错误，或教务系统暂时不可用' : '登录失败：$message',
    );
  }

  Map<String, String> _headers(String authorization, {String roleCode = '06'}) {
    return <String, String>{
      'authorization': authorization,
      'rolecode': roleCode,
      '_lang': 'cn',
      'Connection': 'keep-alive',
      'User-Agent': _userAgent,
    };
  }

  HitLoginResult? _resultFromPayload(
    Map<String, dynamic>? payload,
    Map<String, String> cookies,
  ) {
    if (payload == null) {
      return null;
    }
    final data = _map(payload['data']);
    final accessToken =
        _firstNonEmpty(<String>[
          _string(payload, 'access_token'),
          _string(data, 'access_token'),
        ]) ??
        '';
    if (accessToken.isEmpty) {
      return null;
    }
    final info = _map(payload['info']);
    final studentType = HitStudentType.fromApi(_string(data, 'pylx'));
    final studentId = _firstNonEmpty(<String>[
      _string(info, 'yhdm'),
      _string(data, 'yhdm'),
      _string(data, 'xh'),
      _string(info, 'xh'),
    ]);
    final name = _firstNonEmpty(<String>[
      _string(data, 'yhxm'),
      _string(info, 'xm'),
      _string(data, 'xm'),
    ]);
    final school = _firstNonEmpty(<String>[
      _string(data, 'bmmc'),
      _string(data, 'yxmc'),
    ]);
    final refreshToken = _firstNonEmpty(<String>[
      _string(payload, 'refresh_token'),
      _string(data, 'refresh_token'),
    ]);
    return HitLoginResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      cookies: Map<String, String>.unmodifiable(cookies),
      studentType: studentType,
      studentId: studentId,
      name: name,
      school: school,
    );
  }

  List<RsaPublicKey> _parseRsaKeys(String body) {
    final json = decodeJsonObject(body);
    if (json == null) {
      return const <RsaPublicKey>[];
    }
    final keys = <RsaPublicKey>[];
    final seen = <String>{};

    void addKey(RsaPublicKey? key) {
      if (key == null ||
          key.modulus.bitLength < 512 ||
          key.exponent <= BigInt.one) {
        return;
      }
      final id = '${key.modulus}:${key.exponent}';
      if (seen.add(id)) {
        keys.add(key);
      }
    }

    // The endpoint currently returns the X.509 key in CLIENT_RSA_EXPONENT and
    // "10001" in CLIENT_RSA_MODULUS. Try both fields before raw pairing.
    addKey(parseRsaPublicKeyBase64(_string(json, 'CLIENT_RSA_EXPONENT')));
    addKey(parseRsaPublicKeyBase64(_string(json, 'CLIENT_RSA_MODULUS')));

    final moduli = _parseBigIntegers(_string(json, 'CLIENT_RSA_MODULUS'));
    final exponents = _parseBigIntegers(_string(json, 'CLIENT_RSA_EXPONENT'));
    for (final modulus in moduli) {
      for (final exponent in exponents) {
        addKey(RsaPublicKey(modulus: modulus, exponent: exponent));
      }
    }
    return keys.take(6).toList();
  }

  List<BigInt> _parseBigIntegers(String raw) {
    final value = raw.trim().replaceAll(RegExp(r'\s+'), '');
    if (value.isEmpty) {
      return const <BigInt>[];
    }
    if (value.toLowerCase().startsWith('0x')) {
      final parsed = BigInt.tryParse(value.substring(2), radix: 16);
      return parsed == null ? const <BigInt>[] : <BigInt>[parsed];
    }
    if (RegExp(r'^\d+$').hasMatch(value)) {
      final hex = BigInt.tryParse(value, radix: 16);
      final decimal = BigInt.tryParse(value, radix: 10);
      return <BigInt>[?hex, if (decimal != null && decimal != hex) decimal];
    }
    if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(value)) {
      final parsed = BigInt.tryParse(value, radix: 16);
      return parsed == null ? const <BigInt>[] : <BigInt>[parsed];
    }
    return const <BigInt>[];
  }
}

Map<String, dynamic>? _map(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

String _string(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  return value is String ? value.trim() : '';
}

String? _firstNonEmpty(Iterable<String> values) {
  for (final value in values) {
    if (value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

class HitLoginResult {
  const HitLoginResult({
    required this.accessToken,
    required this.cookies,
    required this.studentType,
    this.refreshToken,
    this.studentId,
    this.name,
    this.school,
  });

  final String accessToken;
  final String? refreshToken;
  final Map<String, String> cookies;
  final HitStudentType studentType;
  final String? studentId;
  final String? name;
  final String? school;
}
