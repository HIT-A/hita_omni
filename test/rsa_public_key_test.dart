import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider_hit/provider_hit.dart';

const _liveKey =
    'MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCgPLoJLt5v+gzsl5fsahkKQC87kog'
    'MR2999RdtYYfd4wpsLViwQg2lLQUWOOXPYQMypOo74wz0fY6mxRutuBcUVEUE8RifnGt'
    'kkEikrgR4q+fgqvNQCnuWCI/SOMG4aJl6W7Qu1OxHGwjHfJ1svQ7JiMhldBxSTFQqEF'
    'BeTmkCQIDAQAB';

void main() {
  test('parses the swapped X.509 public key field', () {
    final key = parseRsaPublicKeyBase64(_liveKey);
    expect(key, isNotNull);
    expect(key!.modulus.bitLength, 1024);
    expect(key.exponent, BigInt.from(65537));
    expect(key.byteLength, 128);
  });

  test('ignores the exponent-looking modulus field', () {
    expect(parseRsaPublicKeyBase64('10001'), isNull);
  });

  test('encrypts with PKCS#1 v1.5 into one key-sized block', () {
    final key = parseRsaPublicKeyBase64(_liveKey)!;
    final encrypted = encryptRsaPkcs1('password', key);
    expect(encrypted, isNotNull);
    final bytes = base64Decode(encrypted!);
    expect(bytes, hasLength(128));
    expect(
      utf8.decode(bytes, allowMalformed: true),
      isNot(contains('password')),
    );
  });
}
